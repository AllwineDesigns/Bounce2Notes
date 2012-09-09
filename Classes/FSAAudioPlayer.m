//
//  FSAAudioPlayer.m
//  ParticleSystem
//
//  Created by John Allwine on 5/11/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSAAudioPlayer.h"
#import "FSAUtil.h"
#import "Accelerate/Accelerate.h"

static OSStatus inputRenderCallback (void *inRefCon,
                                     AudioUnitRenderActionFlags *ioActionFlags,
                                     const AudioTimeStamp *inTimeStamp,
                                     UInt32 inBusNumber,
                                     UInt32 inNumberFrames,
                                     AudioBufferList *ioData) {
    FSAAudioCallbackData* callbackData = (FSAAudioCallbackData*)inRefCon;
    
    AudioUnitSampleType *outSamplesChannelLeft = (AudioUnitSampleType *) ioData->mBuffers[0].mData;
    AudioUnitSampleType *outSamplesChannelRight = (AudioUnitSampleType *) ioData->mBuffers[1].mData;
    
    memset(outSamplesChannelLeft, 0, inNumberFrames*sizeof(AudioUnitSampleType));
    memset(outSamplesChannelRight, 0, inNumberFrames*sizeof(AudioUnitSampleType));
    
    FSASoundList* soundList = callbackData->soundList;
    
    if([callbackData->pending_lock tryLock]) {
        if(soundList->pending_tail != NULL) {
            soundList->pending_tail->next = soundList->playing->next;
            soundList->playing->next = soundList->pending_head->next;
            soundList->pending_tail = NULL;
            soundList->pending_head->next = NULL;
        }
        [callbackData->pending_lock unlock];
    }
    
    FSASoundStruct* prev = soundList->playing;
    FSASoundStruct* sound = prev->next;
    
    FSASoundStruct finished_head;
    finished_head.next = NULL;
    FSASoundStruct* finished_tail = NULL;
    
    if(sound == NULL) {
        *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
    }
    float maxSample = 0;
    while(sound != NULL) {
        maxSample += sound->volume*sound->data->maxLeftSample[sound->sampleNumber];
        sound = sound->next;  
    }
    callbackData->curMaxSample = maxSample;

    sound = prev->next;

    while(sound != NULL) {

        AudioUnitSampleType *dataInLeft = sound->data->left;
        AudioUnitSampleType *dataInRight;
        
        if(sound->data->isStereo) {
            dataInRight = sound->data->right;
        } else {
            dataInRight = sound->data->left;
        }
        
        UInt32 sampleNumber = sound->sampleNumber;
        Float32 volume = sound->volume;
        UInt32 frameCount = sound->data->frameCount;
        UInt32 numFrames  = inNumberFrames;
        if(sampleNumber+numFrames >= frameCount) {
            numFrames = frameCount-sampleNumber;
        }
        
        /*
         int volume8_24 = volume*(1<<24);

        NSLog(@"inNumberFrames: %lu\n", inNumberFrames);
        NSLog(@"numFrames: %lu\n", numFrames);
        NSLog(@"frameCount: %lu\n", frameCount);
        NSLog(@"sampleNumber: %lu\n", sampleNumber);
        NSLog(@"int: %lu\n", sizeof(int));
        NSLog(@"AudioUnitSampleType: %lu\n", sizeof(AudioUnitSampleType));
        vDSP_vrampmuladd_s8_24((const int*)&dataInLeft[sampleNumber], 1, &volume8_24, 0, (int*)outSamplesChannelLeft, 1, numFrames);
        vDSP_vrampmuladd_s8_24((const int*)&dataInRight[sampleNumber], 1, &volume8_24, 0, (int*)outSamplesChannelRight, 1, numFrames);

        sampleNumber += numFrames;
        */

        for (UInt32 frameNumber = 0; frameNumber < numFrames; ++frameNumber) {
            
            outSamplesChannelLeft[frameNumber] += volume*dataInLeft[sampleNumber];
            outSamplesChannelRight[frameNumber] += volume*dataInRight[sampleNumber];
            
            ++sampleNumber;
        }
        
        sound->sampleNumber = sampleNumber;
        if(sampleNumber == frameCount) {
            // finished playing sound, take it out of the playing list
            // and add it back into the sound pool
            prev->next = sound->next;
            sound->next = finished_head.next;
            finished_head.next = sound;
            if(finished_tail == NULL) {
                finished_tail = sound;
            }
            
            sound = prev->next;
        } else {
            prev = sound;
            sound = sound->next;  
        }

    }
    
    if(finished_tail != NULL) {
        [callbackData->finished_lock lock];
        finished_tail->next = soundList->finished_head->next;
        soundList->finished_head->next = finished_head.next;
        if(soundList->finished_tail == NULL) {
            soundList->finished_tail = finished_tail;
        }
        [callbackData->finished_lock unlock];
    }

    return noErr;
}

#pragma mark -
#pragma mark Audio route change listener callback

// Audio session callback function for responding to audio route changes. If playing back audio and
//   the user unplugs a headset or headphones, or removes the device from a dock connector for hardware  
//   that supports audio playback, this callback detects that and stops playback. 
//
// Refer to AudioSessionPropertyListener in Audio Session Services Reference.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
    
    // Ensure that this callback was invoked because of an audio route change
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    // This callback, being outside the implementation block, needs a reference to the FSAAudioPlayer
    //   object, which it receives in the inUserData parameter. You provide this reference when
    //   registering this callback (see the call to AudioSessionAddPropertyListener).
    FSAAudioPlayer *audioObject = (FSAAudioPlayer *) inUserData;
    
    // if application sound is not playing, there's nothing to do, so return.
    if (NO == audioObject.isPlaying) {
        
        NSLog (@"Audio route change while application audio is stopped.");
        return;
        
    } else {
        
        // Determine the specific type of audio route change that occurred.
        CFDictionaryRef routeChangeDictionary = inPropertyValue;
        
        CFNumberRef routeChangeReasonRef =
        CFDictionaryGetValue (
                              routeChangeDictionary,
                              CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                              );
        
        SInt32 routeChangeReason;
        
        CFNumberGetValue (
                          routeChangeReasonRef,
                          kCFNumberSInt32Type,
                          &routeChangeReason
                          );
        
        // "Old device unavailable" indicates that a headset or headphones were unplugged, or that 
        //    the device was removed from a dock connector that supports audio output. In such a case,
        //    pause or stop audio (as advised by the iOS Human Interface Guidelines).
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
            NSLog (@"Audio output device was removed; stopping audio playback.");
            NSString *FSAAudioPlayerObjectPlaybackStateDidChangeNotification = @"FSAAudioPlayerObjectPlaybackStateDidChangeNotification";
            [[NSNotificationCenter defaultCenter] postNotificationName: FSAAudioPlayerObjectPlaybackStateDidChangeNotification object: audioObject]; 
            
        } else {
            
            NSLog (@"A route change occurred that does not require stopping application audio.");
        }
    }
}


#pragma mark -

@implementation FSAAudioPlayer
@synthesize stereoStreamFormat;
@synthesize monoStreamFormat;
@synthesize graphSampleRate;
@synthesize ioBufferDuration;
@synthesize ioUnit;
@synthesize playing;
@synthesize interruptedDuringPlayback;

#pragma mark -
#pragma mark Initialize

// Get the app ready for playback.
- (id) init {
    
    self = [super init];
    
    if (!self) return nil;
    
    self.interruptedDuringPlayback = NO;
            
    [self setupAudioSession];
    [self setupStereoStreamFormat];
    [self setupMonoStreamFormat];

    [self setupSoundList];
    
    _numSounds = 0;
    _allocatedSounds = 10;
    soundData = (FSASoundData**)malloc(_allocatedSounds*sizeof(FSASoundData*));
    
    callbackData.soundList = &soundList;
    callbackData.pending_lock = [[NSLock alloc] init];
    callbackData.finished_lock = [[NSLock alloc] init];
//    callbackData.player = self;
    
    [self configureAndInitializeAudioProcessingGraph];
    
    return self;
}


#pragma mark -
#pragma mark Audio set up

- (void) setupAudioSession {
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    // Specify that this object is the delegate of the audio session, so that
    //    this object's endInterruption method will be invoked when needed.
    [mySession setDelegate: self];
    
    // Assign the Playback category to the audio session.
    NSError *audioSessionError = nil;
 //   [mySession setCategory: AVAudioSessionCategoryPlayback
 //                    error: &audioSessionError];
    
 //   if (audioSessionError != nil) {
 //       
 //       NSLog (@"Error setting audio session category.");
 //       return;
 //   }
    
    // Request the desired hardware sample rate.
    self.graphSampleRate = 44100.0;    // Hertz
    
    [mySession setPreferredHardwareSampleRate: graphSampleRate
                                        error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error setting preferred hardware sample rate.");
        return;
    }
    
    // Activate the audio session
    [mySession setActive: YES
                   error: &audioSessionError];
    
    if (audioSessionError != nil) {
        
        NSLog (@"Error activating audio session during initial setup.");
        return;
    }
    
    // Obtain the actual hardware sample rate and store it for later use in the audio processing graph.
    self.graphSampleRate = [mySession currentHardwareSampleRate];

   // self.ioBufferDuration = 0.01;

   // self.ioBufferDuration = 0.023220;
   // self.ioBufferDuration = .1;

//    [mySession setPreferredIOBufferDuration: ioBufferDuration
  //                                    error: &audioSessionError];
    
    Float32 currentBufferDuration;  
    UInt32 propertySize = sizeof(currentBufferDuration);
    AudioSessionGetProperty (                                     // 2
                             kAudioSessionProperty_CurrentHardwareIOBufferDuration,
                             &propertySize,
                             &currentBufferDuration
                             );
    NSLog(@"%f currentBufferDuration", currentBufferDuration);
    
    
    // Register the audio route change listener callback function with the audio session.
    AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     self
                                     );
}

- (void) setupStereoStreamFormat {
    
    // The AudioUnitSampleType data type is the recommended type for sample data in audio
    //    units. This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    
    // Fill the application audio format struct's fields to define a linear PCM, 
    //        stereo, noninterleaved stream at the hardware sample rate.
    stereoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    stereoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    stereoStreamFormat.mBytesPerPacket    = bytesPerSample;
    stereoStreamFormat.mFramesPerPacket   = 1;
    stereoStreamFormat.mBytesPerFrame     = bytesPerSample;
    stereoStreamFormat.mChannelsPerFrame  = 2;                    // 2 indicates stereo
    stereoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    stereoStreamFormat.mSampleRate        = graphSampleRate;
    
    
    NSLog (@"The stereo stream format:");
    [self printASBD: stereoStreamFormat];
}

- (void) setupMonoStreamFormat {
    
    // The AudioUnitSampleType data type is the recommended type for sample data in audio
    //    units. This obtains the byte size of the type for use in filling in the ASBD.
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    
    // Fill the application audio format struct's fields to define a linear PCM, 
    //        stereo, noninterleaved stream at the hardware sample rate.
    monoStreamFormat.mFormatID          = kAudioFormatLinearPCM;
    monoStreamFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    monoStreamFormat.mBytesPerPacket    = bytesPerSample;
    monoStreamFormat.mFramesPerPacket   = 1;
    monoStreamFormat.mBytesPerFrame     = bytesPerSample;
    monoStreamFormat.mChannelsPerFrame  = 1;                  // 1 indicates mono
    monoStreamFormat.mBitsPerChannel    = 8 * bytesPerSample;
    monoStreamFormat.mSampleRate        = graphSampleRate;
    
    NSLog (@"The mono stream format for the \"beats\" mixer input bus:");
    [self printASBD: monoStreamFormat];
    
}

- (void) setupSoundList {
    NSString *device = machineName();
    int max_sounds = 15;
    if([device isEqualToString:@"iPhone2,1"]) {
        max_sounds = 10;
    } else if([device isEqualToString:@"iPad3,3"]) {
        max_sounds = 40;
    }
    
    FSASoundStruct *heads = (FSASoundStruct*)calloc(4+max_sounds,sizeof(FSASoundStruct));
    
    soundList.playing = &heads[0];
    soundList.pending_head = &heads[1];
    soundList.finished_head = &heads[2];
    soundList.pool = &heads[3];
    
    for(int i = 0; i < max_sounds; ++i) {
        FSASoundStruct *sound = &heads[4+i];
        sound->next = soundList.pool->next;
        soundList.pool->next = sound;
    }
}

- (FSASoundData*) readAudioFileIntoMemory: (NSString*)file {
    if(_numSounds == _allocatedSounds) {
        _allocatedSounds *= 2;
        soundData = (FSASoundData**)realloc(soundData, _allocatedSounds*sizeof(FSASoundData*));
    }    
    soundData[_numSounds] = (FSASoundData*)calloc(1,sizeof(FSASoundData));
    FSASoundData *data = soundData[_numSounds];
    
    ++_numSounds;

    CFURLRef audioFile = (CFURLRef)[[NSBundle mainBundle] URLForResource:file withExtension:@""];

    // Instantiate an extended audio file object.
    ExtAudioFileRef audioFileObject = 0;
    
    // Open an audio file and associate it with the extended audio file object.
    OSStatus result = ExtAudioFileOpenURL (audioFile, &audioFileObject);
    
    if (noErr != result || NULL == audioFileObject) {[self printErrorMessage: @"ExtAudioFileOpenURL" withStatus: result]; return NULL;}
    
    // Get the audio file's length in frames.
    UInt64 totalFramesInFile = 0;
    UInt32 frameLengthPropertySize = sizeof (totalFramesInFile);
    
    result =    ExtAudioFileGetProperty (
                                         audioFileObject,
                                         kExtAudioFileProperty_FileLengthFrames,
                                         &frameLengthPropertySize,
                                         &totalFramesInFile
                                         );
    
    if (noErr != result) {[self printErrorMessage: @"ExtAudioFileGetProperty (audio file length in frames)" withStatus: result]; return NULL;}
    
    data->frameCount = totalFramesInFile;
    
    // Get the audio file's number of channels.
    AudioStreamBasicDescription fileAudioFormat = {0};
    UInt32 formatPropertySize = sizeof (fileAudioFormat);
    
    result =    ExtAudioFileGetProperty (
                                         audioFileObject,
                                         kExtAudioFileProperty_FileDataFormat,
                                         &formatPropertySize,
                                         &fileAudioFormat
                                         );
    [self printASBD:fileAudioFormat];
    
    if (noErr != result) {[self printErrorMessage: @"ExtAudioFileGetProperty (file audio format)" withStatus: result]; return NULL;}
    
    UInt32 channelCount = fileAudioFormat.mChannelsPerFrame;

    
    AudioStreamBasicDescription importFormat = {0};
    if (2 == channelCount) {
        // Sound is stereo, so allocate memory in the soundStructArray instance variable to  
        //    hold the right channel audio data
        data->left = (AudioUnitSampleType *) calloc (totalFramesInFile, sizeof (AudioUnitSampleType));
        data->right = (AudioUnitSampleType *) calloc (totalFramesInFile, sizeof (AudioUnitSampleType));
        data->maxLeftSample = (float*)calloc(totalFramesInFile, sizeof(float));
        data->maxRightSample = (float*)calloc(totalFramesInFile, sizeof(float));

        if(data->left == NULL) {
            NSLog(@"error allocating memory for left channel data for sound %@", audioFile);
        }
        if(data->right == NULL) {
            NSLog(@"error allocating memory for right channel data for sound %@", audioFile);
        }
        data->isStereo = YES;
        importFormat = stereoStreamFormat;
    } else if(1 == channelCount) {
        data->left = (AudioUnitSampleType *) calloc (totalFramesInFile, sizeof (AudioUnitSampleType));
        data->maxLeftSample = (float*)calloc(totalFramesInFile, sizeof(float));
        
        data->isStereo = NO;
        importFormat = monoStreamFormat;
    } else {
        
        NSLog (@"*** WARNING: File format not supported - wrong number of channels");
        ExtAudioFileDispose (audioFileObject);
        return NULL;
    }
    
    // Assign the appropriate mixer input bus stream data format to the extended audio 
    //        file object. This is the format used for the audio data placed into the audio 
    //        buffer in the SoundStruct data structure, which is in turn used in the 
    //        inputRenderCallback callback function.
    
    result =    ExtAudioFileSetProperty (
                                         audioFileObject,
                                         kExtAudioFileProperty_ClientDataFormat,
                                         sizeof (importFormat),
                                         &importFormat
                                         );
    
    if (noErr != result) {[self printErrorMessage: @"ExtAudioFileSetProperty (client data format)" withStatus: result]; return NULL;}
    
    // Set up an AudioBufferList struct, which has two roles:
    //
    //        1. It gives the ExtAudioFileRead function the configuration it 
    //            needs to correctly provide the data to the buffer.
    //
    //        2. It points to the soundStructArray[audioFile].audioDataLeft buffer, so 
    //            that audio data obtained from disk using the ExtAudioFileRead function
    //            goes to that buffer
    
    // Allocate memory for the buffer list struct according to the number of 
    //    channels it represents.
    AudioBufferList *bufferList;
    
    bufferList = (AudioBufferList *) malloc (
                                             sizeof (AudioBufferList) + sizeof (AudioBuffer) * (channelCount - 1)
                                             );
    
    if (NULL == bufferList) {NSLog (@"*** malloc failure for allocating bufferList memory"); return NULL;}
    
    // initialize the mNumberBuffers member
    bufferList->mNumberBuffers = channelCount;
    
    // initialize the mBuffers member to 0
    AudioBuffer emptyBuffer = {0};
    size_t arrayIndex;
    for (arrayIndex = 0; arrayIndex < channelCount; arrayIndex++) {
        bufferList->mBuffers[arrayIndex] = emptyBuffer;
    }
    
    // set up the AudioBuffer structs in the buffer list
    bufferList->mBuffers[0].mNumberChannels  = 1;
    bufferList->mBuffers[0].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
    bufferList->mBuffers[0].mData            = data->left;

    if(2 == channelCount) {
        bufferList->mBuffers[1].mNumberChannels  = 1;
        bufferList->mBuffers[1].mDataByteSize    = totalFramesInFile * sizeof (AudioUnitSampleType);
        bufferList->mBuffers[1].mData            = data->right;
    }
    
    // Perform a synchronous, sequential read of the audio data out of the file and
    //    into the soundStructArray[audioFile].audioDataLeft and (if stereo) .audioDataRight members.
    UInt32 numberOfPacketsToRead = (UInt32) totalFramesInFile;
    
    result = ExtAudioFileRead (
                               audioFileObject,
                               &numberOfPacketsToRead,
                               bufferList
                               );
    
    free (bufferList);
    
    if (noErr != result) {
        
        [self printErrorMessage: @"ExtAudioFileRead failure - " withStatus: result];
        
        // If reading from the file failed, then free the memory for the sound buffer.
        free (data->left);
        data->left = 0;
        
        if(2 == channelCount) {
            free (data->right);
            data->right = 0;
        }
        ExtAudioFileDispose (audioFileObject);            
        return NULL;
    }
    
    float maxSample = 0;
    for(int64_t i = numberOfPacketsToRead-1; i >= 0; i--) {
        float t = i/1000.;
        if(t > 1) t = 1;
        t = t*t*t;
        
        data->left[i] *= t;
        float sample = (float)data->left[i]/(1 << 24);
        if(sample > maxSample) {
            maxSample = sample;
        }
        data->maxLeftSample[i] = maxSample;
    }
    
    if(channelCount == 2) {
        for(UInt32 i = 0; i < numberOfPacketsToRead; i++) {
            float t = i/1000.;
            if(t > 1) t = 1;
            t = t*t*t;
            
            data->right[i] *= t;
            float maxSample = 0;
            for(int64_t i = numberOfPacketsToRead-1; i >= 0; i--) {
                float t = i/1000.;
                if(t > 1) t = 1;
                t = t*t*t;
                
                data->right[i] *= t;
                float sample = (float)data->right[i]/(1 << 24);
                if(sample > maxSample) {
                    maxSample = sample;
                }
                data->maxRightSample[i] = maxSample;
            }
        }
    } else {
        data->maxRightSample = data->maxLeftSample;
    }
    
    NSLog (@"Finished reading file %@ into memory", audioFile);
    
    // Dispose of the extended audio file object, which also
    //    closes the associated file.
    ExtAudioFileDispose (audioFileObject);

    return data;
}


#pragma mark -
#pragma mark Audio processing graph setup

// This method performs all the work needed to set up the audio processing graph:

// 1. Instantiate and open an audio processing graph
// 2. Obtain the audio unit nodes for the graph
// 3. Configure the Multichannel Mixer unit
//     * specify the number of input buses
//     * specify the output sample rate
//     * specify the maximum frames-per-slice
// 4. Initialize the audio processing graph

- (void) configureAndInitializeAudioProcessingGraph {
    
    NSLog (@"Configuring and then initializing audio processing graph");
    OSStatus result = noErr;
    
    //............................................................................
    // Create a new audio processing graph.
    result = NewAUGraph (&processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"NewAUGraph" withStatus: result]; return;}
    
    
    //............................................................................
    // Specify the audio unit component descriptions for the audio units to be
    //    added to the graph.
    
    // I/O unit
    AudioComponentDescription iOUnitDescription;
    iOUnitDescription.componentType          = kAudioUnitType_Output;
    iOUnitDescription.componentSubType       = kAudioUnitSubType_RemoteIO;
    iOUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    iOUnitDescription.componentFlags         = 0;
    iOUnitDescription.componentFlagsMask     = 0;

    //............................................................................
    // Add nodes to the audio processing graph.
    NSLog (@"Adding nodes to audio processing graph");
    
    AUNode   iONode;         // node for I/O unit
    
    // Add the nodes to the audio processing graph
    result =    AUGraphAddNode (
                                processingGraph,
                                &iOUnitDescription,
                                &iONode);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNewNode failed for I/O unit" withStatus: result]; return;}
    
    //............................................................................
    // Open the audio processing graph
    
    // Following this call, the audio units are instantiated but not initialized
    //    (no resource allocation occurs and the audio units are not in a state to
    //    process audio).
    result = AUGraphOpen (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphOpen" withStatus: result]; return;}
    
    //............................................................................
    // Obtain the io unit instance from its corresponding node.
    
    result =    AUGraphNodeInfo (
                                 processingGraph,
                                 iONode,
                                 NULL,
                                 &ioUnit
                                 );
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphNodeInfo" withStatus: result]; return;}
    
    NSLog (@"Setting kAudioUnitProperty_MaximumFramesPerSlice for io unit global scope");
    // Increase the maximum frames per slice allows the mixer unit to accommodate the
    //    larger slice size used when the screen is locked.
    UInt32 maximumFramesPerSlice = 4096;
    
    result = AudioUnitSetProperty (
                                   ioUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set io unit max frames per slice)" withStatus: result]; return;}
    
      
    // Setup the struture that contains the input render callback 
    AURenderCallbackStruct inputCallbackStruct;
    inputCallbackStruct.inputProc        = &inputRenderCallback;
    inputCallbackStruct.inputProcRefCon  = &callbackData;
        
    // Set a callback for the specified node's specified input
    result = AUGraphSetNodeInputCallback (
                                            processingGraph,
                                            iONode,
                                            0,
                                            &inputCallbackStruct
                                        );
        
    if (noErr != result) {[self printErrorMessage: @"AUGraphSetNodeInputCallback" withStatus: result]; return;}
    
    
    NSLog (@"Setting stereo stream format for io unit");
    result = AudioUnitSetProperty (
                                   ioUnit,
                                   kAudioUnitProperty_StreamFormat,
                                   kAudioUnitScope_Input,
                                   0,
                                   &stereoStreamFormat,
                                   sizeof (stereoStreamFormat)
                                   );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetProperty (set io unit input stream format)" withStatus: result];return;}
    
    //............................................................................
    // Initialize audio processing graph
    
    // Diagnostic code
    // Call CAShow if you want to look at the state of the audio processing 
    //    graph.
    NSLog (@"Audio processing graph state immediately before initializing it:");
    CAShow (processingGraph);
    
    NSLog (@"Initializing the audio processing graph");
    // Initialize the audio processing graph, configure audio data stream formats for
    //    each input and output, and validate the connections between audio units.
    result = AUGraphInitialize (processingGraph);
    
    if (noErr != result) {[self printErrorMessage: @"AUGraphInitialize" withStatus: result]; return;}

}

- (void) playSound:(FSASoundData*)data volume:(Float32)volume {
    if(volume < .00000001) {
        return;
    }
    [callbackData.finished_lock lock];
    if(soundList.finished_tail != NULL) {
        soundList.finished_tail->next = soundList.pool->next;
        soundList.pool->next = soundList.finished_head->next;
        soundList.finished_head->next = NULL;
        soundList.finished_tail = NULL;
    }
    [callbackData.finished_lock unlock];
    
    [callbackData.pending_lock lock];
    
    // see if this sound already exists and hasn't started playing yet
    FSASoundStruct* pl = soundList.pending_head->next;
    FSASoundStruct *same_sound = NULL;
    while(pl != NULL) {
        if(pl->data == data && pl->sampleNumber == 0) {
            same_sound = pl;
            break;
        }
        pl = pl->next;
    }
    
    if(same_sound != NULL) {
        // if it does, just increase the volume
        if(same_sound->numSounds < 4) {
            same_sound->volume += volume;
            same_sound->numSounds++;
            if(same_sound->volume > .4) {
                same_sound->volume = .4;
            }
        } else if(same_sound->volume < volume) {
            same_sound->volume = volume;
            if(same_sound->volume > .4) {
                same_sound->volume = .4;
            }
        }
    } else if(soundList.pool->next == NULL) { 
        // if pool is empty, and volume is higher than the lowest volume sound that just started playing, than replace that sound with this one
        FSASoundStruct* sound = soundList.pending_head->next;
        FSASoundStruct* min_sound = NULL;
        float min_vol = 999999;
        
        while(sound != NULL) {
            if(sound->sampleNumber == 0 && sound->volume < min_vol) {
                min_sound = sound;
                min_vol = sound->volume;
            }
            sound = sound->next;
        }
        
        if(min_sound != NULL) {
            if(min_sound->volume < volume) {
                min_sound->numSounds = 1;
                min_sound->volume = volume;
                min_sound->data = data;
            }
        }
        
    } else {
        FSASoundStruct* sound = soundList.pool->next;
        soundList.pool->next = sound->next;
    
        sound->next = soundList.pending_head->next;
        soundList.pending_head->next = sound;
    
        sound->volume = volume;
        sound->data = data;
        sound->sampleNumber = 0;
        sound->numSounds = 1;
        
        if(soundList.pending_tail == NULL) {
            soundList.pending_tail = sound;
        }
    }
   // NSLog(@"callbackdata.curMaxSample: %f\n", callbackData.curMaxSample);
    float newMaxSample = (1-callbackData.curMaxSample);
   // NSLog(@"newMaxSample: %f\n", newMaxSample);

    FSASoundStruct* sound = soundList.pending_head->next;
    float maxSample = 0;
    while(sound != NULL) {
        maxSample += sound->volume*sound->data->maxLeftSample[0];
        sound = sound->next;
    }
   // NSLog(@"maxSample: %f\n", maxSample);

    
    if(maxSample > newMaxSample) {
        sound = soundList.pending_head->next;
        while(sound != NULL) {
            sound->volume *= newMaxSample/maxSample;
            sound = sound->next;
        }
    }
    
    [callbackData.pending_lock unlock];
}


#pragma mark -
#pragma mark Playback control

// Start playback
- (void) startAUGraph  {
    
    NSLog (@"Starting audio processing graph");
    OSStatus result = AUGraphStart (processingGraph);
    if (noErr != result) {[self printErrorMessage: @"AUGraphStart" withStatus: result]; return;}
    
    self.playing = YES;
}

// Stop playback
- (void) stopAUGraph {
    
    NSLog (@"Stopping audio processing graph");
    Boolean isRunning = false;
    OSStatus result = AUGraphIsRunning (processingGraph, &isRunning);
    if (noErr != result) {[self printErrorMessage: @"AUGraphIsRunning" withStatus: result]; return;}
    
    if (isRunning) {
        
        result = AUGraphStop (processingGraph);
        if (noErr != result) {[self printErrorMessage: @"AUGraphStop" withStatus: result]; return;}
        self.playing = NO;
    }
}

#pragma mark -
#pragma mark Audio Session Delegate Methods
// Respond to having been interrupted. This method sends a notification to the 
//    controller object, which in turn invokes the playOrStop: toggle method. The 
//    interruptedDuringPlayback flag lets the  endInterruptionWithFlags: method know 
//    whether playback was in progress at the time of the interruption.
- (void) beginInterruption {
    
    NSLog (@"Audio session was interrupted.");
    
    if (playing) {
        
        self.interruptedDuringPlayback = YES;
        
        NSString *FSAAudioPlayerObjectPlaybackStateDidChangeNotification = @"FSAAudioPlayerObjectPlaybackStateDidChangeNotification";
        [[NSNotificationCenter defaultCenter] postNotificationName: FSAAudioPlayerObjectPlaybackStateDidChangeNotification object: self]; 
    }
}


// Respond to the end of an interruption. This method gets invoked, for example, 
//    after the user dismisses a clock alarm. 
- (void) endInterruptionWithFlags: (NSUInteger) flags {
    
    // Test if the interruption that has just ended was one from which this app 
    //    should resume playback.
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
        
        NSError *endInterruptionError = nil;
        [[AVAudioSession sharedInstance] setActive: YES
                                             error: &endInterruptionError];
        if (endInterruptionError != nil) {
            
            NSLog (@"Unable to reactivate the audio session after the interruption ended.");
            return;
            
        } else {
            
            NSLog (@"Audio session reactivated after interruption.");
            
            if (interruptedDuringPlayback) {
                
                self.interruptedDuringPlayback = NO;
                
                // Resume playback by sending a notification to the controller object, which
                //    in turn invokes the playOrStop: toggle method.
                NSString *FSAAudioPlayerObjectPlaybackStateDidChangeNotification = @"FSAAudioPlayerObjectPlaybackStateDidChangeNotification";
                [[NSNotificationCenter defaultCenter] postNotificationName: FSAAudioPlayerObjectPlaybackStateDidChangeNotification object: self]; 
                
            }
        }
    }
}


#pragma mark -
#pragma mark Utility methods

// You can use this method during development and debugging to look at the
//    fields of an AudioStreamBasicDescription struct.
- (void) printASBD: (AudioStreamBasicDescription) asbd {
    
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10lX",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10ld",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10ld",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10ld",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10ld",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10ld",    asbd.mBitsPerChannel);
}


- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result {
    
    char resultString[5];
    UInt32 swappedResult = CFSwapInt32HostToBig (result);
    bcopy (&swappedResult, resultString, 4);
    resultString[4] = '\0';
    NSLog(@"**** ERROR **** %@: %ld\n", errorString, result);
    /*
    NSLog (
           @"*** %@ error: %d %08X %4.4s\n",
           errorString,
           (char*) resultString
           );
     */
}


#pragma mark -
#pragma mark Deallocate

- (void) dealloc {
    [callbackData.finished_lock release];
    [callbackData.pending_lock release];
    
    callbackData.finished_lock = nil;
    callbackData.pending_lock = nil;

    FSASoundStruct *node = soundList.playing;
    while(node != NULL) {
        FSASoundStruct *next = node->next;
        
        free(node);
        node = next;
    }
    
    node = soundList.pool;
    while(node != NULL) {
        FSASoundStruct *next = node->next;
        
        free(node);
        node = next;
    }
    
    node = soundList.pending_head;
    while(node != NULL) {
        FSASoundStruct *next = node->next;
        
        free(node);
        node = next;
    }
    
    node = soundList.finished_head;
    while(node != NULL) {
        FSASoundStruct *next = node->next;
        
        free(node);
        node = next;
    }
    
    for(int i = 0; i < _numSounds; i++) {
        free(soundData[i]->left);
        free(soundData[i]->right);
        free(soundData[i]);
    }
    free(soundData);
        
    [super dealloc];
}

@end



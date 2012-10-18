//
//  FSAAudioPlayer.h
//  ParticleSystem
//
//  Created by John Allwine on 5/11/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

typedef struct {
    AudioUnitSampleType *left;
    AudioUnitSampleType *right;
    UInt32 frameCount;
    float *maxLeftSample;
    float *maxRightSample;
    BOOL isStereo;
} FSASoundData;

typedef struct FSASoundStruct {
    UInt32 sampleNumber;
    UInt32 numSounds;
    Float32 volume;
    FSASoundData* data;
    struct FSASoundStruct* next;
} FSASoundStruct;

typedef struct FSASoundList {
    FSASoundStruct* playing;  // sounds that the audio callback has started playing. The render callback function has
                        // full access to this list (no synchronization necessary)
    
    FSASoundStruct* pool;     // uninitialized sounds that are available for playing. Only the playSound method has
                        // access to the pool (no synchronization necessary).
    
    FSASoundStruct* pending_head;  // sounds that we've indicated that we want to play, but haven't started playing
    FSASoundStruct* pending_tail;  // tail of the pending sounds, so its fast to put them all on the playing list
                             // A lock is necessary to access these.
    
    FSASoundStruct* finished_head; // sounds that have finished playing and need to be put back into the pool
    FSASoundStruct* finished_tail; // tail of finished sounds, so its fast to put them back into the pool
                             // A lock is necessary to access these.
} FSASoundList;

@class FSAAudioPlayer;

typedef struct FSAAudioCallbackData {
    FSASoundList *soundList;
    NSLock *pending_lock;
    NSLock *finished_lock;
    float curMaxSample;
    
  //  FSAAudioPlayer *player;
} FSAAudioCallbackData;

@interface FSAAudioPlayer : NSObject <AVAudioSessionDelegate> {
    Float64 graphSampleRate;
    Float64 ioBufferDuration;
    FSASoundList soundList;
    
    FSASoundData **soundData;
    unsigned int _numSounds;
    unsigned int _allocatedSounds;
    
    FSAAudioCallbackData callbackData;
            
    AudioStreamBasicDescription     stereoStreamFormat;
    AudioStreamBasicDescription     monoStreamFormat;

    AUGraph                         processingGraph;
    BOOL                            playing;
    BOOL                            interruptedDuringPlayback;
    AudioUnit                       ioUnit;
}

@property (readwrite)           AudioStreamBasicDescription stereoStreamFormat;
@property (readwrite)           AudioStreamBasicDescription monoStreamFormat;

@property (readwrite)           Float64                     graphSampleRate;
@property (readwrite)           Float64                     ioBufferDuration;

@property (getter = isPlaying)  BOOL                        playing;
@property                       BOOL                        interruptedDuringPlayback;
@property                       AudioUnit                   ioUnit;

- (void) setupAudioSession;
- (void) setupStereoStreamFormat;
- (void) setupMonoStreamFormat;
- (void) setupSoundList;

// caller is responsible for freeing FSASoundData pointer
- (FSASoundData*) readAudioFileIntoMemory: (NSString*)file; 

- (void) configureAndInitializeAudioProcessingGraph;
- (void) startAUGraph;
- (void) stopAUGraph;

- (void) playSound: (FSASoundData*)data volume:(float)vol;

- (void) printASBD: (AudioStreamBasicDescription) asbd;
- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result;

@end




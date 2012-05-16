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
} FSASoundData;

typedef struct FSASound {
    UInt32 sampleNumber;
    Float32 volume;
    FSASoundData* data;
    struct FSASound* next;
} FSASound;

typedef struct FSASoundList {
    FSASound* playing;
    FSASound* pool;
} FSASoundList;

@interface FSAAudioPlayer : NSObject <AVAudioSessionDelegate> {
    Float64 graphSampleRate;
    Float64 ioBufferDuration;
    FSASoundData* soundData;
    FSASoundList soundList;
    int numSounds;
    
    AudioStreamBasicDescription     stereoStreamFormat;
    AUGraph                         processingGraph;
    BOOL                            playing;
    BOOL                            interruptedDuringPlayback;
    AudioUnit                       ioUnit;
}

@property (readonly) int numSounds;
@property (readwrite)           AudioStreamBasicDescription stereoStreamFormat;
@property (readwrite)           Float64                     graphSampleRate;
@property (readwrite)           Float64                     ioBufferDuration;

@property (getter = isPlaying)  BOOL                        playing;
@property                       BOOL                        interruptedDuringPlayback;
@property                       AudioUnit                   ioUnit;

-(id)initWithSounds:(NSArray*)files;
- (void) setupAudioSession;
- (void) setupStereoStreamFormat;
- (void) setupSoundList;
- (void) readAudioFilesIntoMemory: (NSArray*)files;

- (void) configureAndInitializeAudioProcessingGraph;
- (void) startAUGraph;
- (void) stopAUGraph;

- (void) playSound: (UInt32)index volume: (Float32)volume;

- (void) printASBD: (AudioStreamBasicDescription) asbd;
- (void) printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result;

@end




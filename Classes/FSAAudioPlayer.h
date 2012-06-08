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
    UInt32 numSounds;
    Float32 volume;
    FSASoundData* data;
    struct FSASound* next;
} FSASound;

typedef struct FSASoundList {
    FSASound* playing;  // sounds that the audio callback has started playing. The render callback function has
                        // full access to this list (no synchronization necessary)
    FSASound* pool;     // uninitialized sounds that are available for playing. Only the playSound method has
                        // access to the pool (no synchronization necessary).
    
    FSASound* pending_head;  // sounds that we've indicated that we want to play, but haven't started playing
    FSASound* pending_tail;  // tail of the pending sounds, so its fast to put them all on the playing list
                             // A lock is necessary to access these.
    
    FSASound* finished_head; // sounds that have finished playing and need to be put back into the pool
    FSASound* finished_tail; // tail of finished sounds, so its fast to put them back into the pool
                             // A lock is necessary to access these.
} FSASoundList;

@class FSAAudioPlayer;

typedef struct FSAAudioCallbackData {
    FSASoundList *soundList;
    NSLock *pending_lock;
    NSLock *finished_lock;
    
    FSAAudioPlayer *player;
} FSAAudioCallbackData;

@interface FSAAudioPlayer : NSObject <AVAudioSessionDelegate> {
    Float64 graphSampleRate;
    Float64 ioBufferDuration;
    FSASoundData* soundData;
    FSASoundList soundList;
    float volumeMultiply;
    
    FSAAudioCallbackData callbackData;
    
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
-(id)initWithSounds:(NSArray*)files volume: (float)v;

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




//
//  SoundManager.m
//  ParticleSystem
//
//  Created by John Allwine on 5/8/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

// Uses AVAudioPlayer objects to play sounds

#import "SoundManager.h"

@implementation SoundManager

@synthesize sounds = _sounds;
@synthesize playing = _playing;
@synthesize counts = _counts;

-(id)initWithSounds:(NSArray *)files {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[files count]];
    
    _ready_pool = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    
    for(NSString *file in files) {
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] 
                                                       pathForResource:file
                                                       ofType:@"caf"]];
        [arr addObject:data];
        
        NSMutableSet *ready_set = [NSMutableSet setWithCapacity:5];
        for(int i = 0; i < 5; ++i) {
            AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
            player.delegate = self;
            [player prepareToPlay];
            [ready_set addObject:player];
            
            [player release];
        }

        CFDictionarySetValue(_ready_pool, data, ready_set);
    }
    
    self.sounds = [NSArray arrayWithArray:arr];
    self.playing = [NSMutableSet setWithCapacity:20];
    return self;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {    
    NSMutableSet *ready = (NSMutableSet*)CFDictionaryGetValue(_ready_pool, player.data);
    [player prepareToPlay];
    [ready addObject:player];
    [self.playing removeObject:player];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    
}

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    
}

-(void)playSound:(int)i volume:(float)v {
    NSData *data = [self.sounds objectAtIndex:i];
    
    NSMutableSet *ready = (NSMutableSet*)CFDictionaryGetValue(_ready_pool, data);
    
    if([ready count] > 0 && [self.playing count] < 10) {
        
        AVAudioPlayer* player = [ready anyObject];
        [self.playing addObject:player];
        [ready removeObject:player];
 //       player.volume = v;
        [player play];
        
        //NSLog(@"%d: %d sounds playing - %d ready\n", i, [self.playing count], [ready count]);
    }
    
}

-(void)dealloc {
    CFRelease(_ready_pool);
    _ready_pool = nil;
    self.sounds = nil;
    self.playing = nil;
    [super dealloc];
}

@end


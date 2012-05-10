//
//  SoundManager.h
//  ParticleSystem
//
//  Created by John Allwine on 5/8/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundManager : NSObject <AVAudioPlayerDelegate> {
    NSArray *_sounds;
    CFMutableDictionaryRef _ready_pool;
    NSMutableSet *_playing;
}

@property (retain, nonatomic) NSArray* sounds;
@property (retain, nonatomic) NSMutableSet* playing;
@property (retain, nonatomic) NSCountedSet* counts;

-(id)initWithSounds: (NSArray*)files;
-(void)playSound: (int)i volume: (float)v;
@end

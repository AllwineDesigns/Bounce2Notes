//
//  BounceSound.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSASound.h"

#define BOUNCE_SOUND_VOLUME 2  

@class BounceObject;

@protocol BounceSound <NSObject,NSCoding>
-(void)play: (float)volume;
-(void)resized:(float)old_size;
-(NSString*)label;
@end

@interface BounceNote : NSObject <BounceSound> {
    id<FSASoundDelegate> _sound;
    NSString *_label;
}
-(id)initWithSound:(id<FSASoundDelegate>)sound;
-(id)initWithSound:(id<FSASoundDelegate>)sound label:(NSString*)label;
@end

@interface BounceSong : NSObject <BounceSound> {
    unsigned int _curSound;
    NSArray *_sounds;
    NSString *_label;
}

-(id)initWithSounds:(NSArray*)sounds label:(NSString*)label;

@end

@interface BounceRandomSounds : NSObject <BounceSound> {
    NSArray *_sounds;
    NSString *_label;
    float _v;
}

-(id)initWithSounds:(NSArray*)sounds label:(NSString*)label;
-(id)initWithSounds:(NSArray*)sounds label:(NSString*)label volume:(float)v;


@end

@interface BounceChordProgression : NSObject <BounceSound> {
    
}

@end


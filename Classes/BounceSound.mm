//
//  BounceSound.m
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSound.h"
#import "FSASoundManager.h"
#import "BounceObject.h"
#import "FSAUtil.h"
#import "BounceNoteManager.h"
#import "fsa/Noise.hpp"

@implementation BounceNote

-(id)initWithCoder:(NSCoder *)aDecoder {
    id<FSASoundDelegate> sound = [[FSASoundManager instance] getSound:[aDecoder decodeObjectForKey:@"BounceNoteSound"] volume:BOUNCE_SOUND_VOLUME];
    NSString* label = [aDecoder decodeObjectForKey:@"BounceNoteLabel"];
    return [self initWithSound:sound label:label];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_sound.key forKey:@"BounceNoteSound"];
    [aCoder encodeObject:_label forKey:@"BounceNoteLabel"];
}

-(id)initWithSound:(id<FSASoundDelegate>)sound label:(NSString *)label {
    self = [super init];
    if(self) {
        _sound = sound;
        _label = label;
        [_sound retain];
        [_label retain];
    }
    return self;
}
-(id)initWithSound:(id<FSASoundDelegate>)sound {
    self = [self initWithSound:sound label:@""];

    return self;
}

-(NSString*)label {
    return _label;
}

-(void)play:(float)volume {
    [_sound play:volume];
}

-(void)resized:(float)old_size {
}

-(void)dealloc {
    [_sound release];
    [_label release];
    [super dealloc];
}

@end

@implementation BounceSong

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        NSArray *keys = [aDecoder decodeObjectForKey:@"BounceSongSounds"];
        NSMutableArray *sounds = [NSMutableArray arrayWithCapacity:[keys count]];
        for(NSString* key in keys) {
            [sounds addObject:[[FSASoundManager instance] getSound:key volume:BOUNCE_SOUND_VOLUME]];       
        }
        _sounds = [sounds retain];
        _label = [[aDecoder decodeObjectForKey:@"BounceSongLabel"] retain];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[_sounds count]];
    for(FSASound *sound in _sounds) {
        [keys addObject:sound.key];
    }
    [aCoder encodeObject:keys forKey:@"BounceSongSounds"];
    [aCoder encodeObject:_label forKey:@"BounceSongLabel"];
}

-(id)initWithSounds:(NSArray *)sounds label:(NSString *)label {
    self = [super init];
    if(self) {
        _sounds = [sounds retain];
        _label = [label retain];
    }
    
    return self;
}

-(void)play:(float)volume {
    [[_sounds objectAtIndex:_curSound] play:volume];
    _curSound = (_curSound+1)%[_sounds count];
}

-(void)resized:(float)old_size {
    
}

-(NSString*)label {
    return _label;
}

-(void)dealloc {
    [_sounds release];
    [_label release];
    [super dealloc];
}

@end

@implementation BounceRandomSounds

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        NSArray *keys = [aDecoder decodeObjectForKey:@"BounceRandomSoundsSounds"];
        NSMutableArray *sounds = [NSMutableArray arrayWithCapacity:[keys count]];
        for(NSString* key in keys) {
            [sounds addObject:[[FSASoundManager instance] getSound:key volume:BOUNCE_SOUND_VOLUME]];       
        }
        _sounds = [sounds retain];
        _label = [[aDecoder decodeObjectForKey:@"BounceRandomSoundsLabel"] retain];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[_sounds count]];
    for(FSASound *sound in _sounds) {
        [keys addObject:sound.key];
    }
    [aCoder encodeObject:keys forKey:@"BounceRandomSoundsSounds"];
    [aCoder encodeObject:_label forKey:@"BounceRandomSoundsLabel"];
}

-(id)initWithSounds:(NSArray *)sounds label:(NSString *)label {
    self = [self initWithSounds:sounds label:label volume:1];
    
    return self;
}
-(id)initWithSounds:(NSArray *)sounds label:(NSString *)label volume:(float)v {
    self = [super init];
    if(self) {
        _sounds = [sounds retain];
        _label = [label retain];
        _v = v;
    }
    
    return self;
}

-(void)play:(float)volume {
    if([_sounds count] > 0) {
        unsigned int i = RANDFLOAT*[_sounds count];
        [[_sounds objectAtIndex:i] play:volume*_v];
    }
}

-(void)resized:(float)old_size {
    
}

-(NSString*)label {
    return _label;
}

-(void)dealloc {
    [_sounds release];
    [_label release];
    [super dealloc];
}

@end

@implementation BounceChordProgression

-(id)initWithCoder:(NSCoder *)aDecoder {
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
}

-(void)play:(float)volume {
    unsigned int i_iv_v[] = { 0, 3,4 };
    int time = [[NSProcessInfo processInfo] systemUptime]/2;
    unsigned int rootIndex = i_iv_v[(int)(random(time)*3)];
    
    unsigned int triad[] = {0,2,4};
    unsigned int index = rootIndex+triad[(int)(RANDFLOAT*3)];
    [[[BounceNoteManager instance] getSound:index] play:volume];
}

-(NSString*)label {
    return @"Chord";
}

-(void)resized:(float)old_size {
    
}

@end

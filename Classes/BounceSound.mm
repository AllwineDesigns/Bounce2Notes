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

@implementation BounceNote
-(id)initWithSound:(id<FSASoundDelegate>)sound {
    self = [super init];
    if(self) {
        _sound = sound;
    }
    return self;
}

-(void)play:(float)volume {
    [_sound play:volume];
}

-(void)resized:(float)old_size {
}

@end

@implementation BouncePentatonicSizeSound

-(id)initWithBounceObject:(BounceObject *)obj {
    self = [super init];
    if(self) {
        _obj = obj;
    }
    return self;
}

-(void)resized: (float)old_size {
    NSArray *sounds = [NSArray arrayWithObjects:@"c_1", @"d_1", @"e_1",@"g_1", @"a_1", @"c_2", nil];
    float size = _obj.size;
    int note = (1-size)*(1-size)*[sounds count];
    int old_note = (1-old_size)*(1-old_size)*[sounds count];
    if(old_note != note) {
        [self play:.2];
    }
}

-(void)play:(float)volume {
    NSArray *sounds = [NSArray arrayWithObjects:@"c_1", @"d_1", @"e_1",@"g_1", @"a_1", @"c_2", nil];
    float size = _obj.size;
    int note = (1-size)*(1-size)*[sounds count];
    
    [[[FSASoundManager instance] getSound:[sounds objectAtIndex:note] volume:BOUNCE_SOUND_VOLUME] play:volume];
}

@end

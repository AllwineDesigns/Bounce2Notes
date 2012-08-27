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

@end

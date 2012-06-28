//
//  FSASound.m
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSASound.h"

@implementation FSASound

-(id)initWithAudioPlayer:(FSAAudioPlayer*)player soundData:(FSASoundData*)data volume:(float)vol {
    self = [super init];
    if(self) {
        _player = player;
        [player retain];
        
        _data = data;
        _volume = vol;
    }
    return self;
}

-(void)play:(float)volume {
    [_player playSound:_data volume:_volume*volume];
}

-(void)dealloc {
    [_player release];
    [super dealloc];
}

@end

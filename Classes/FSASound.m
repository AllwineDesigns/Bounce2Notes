//
//  FSASound.m
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSASound.h"

@implementation FSASound

@synthesize volume = _volume;

-(id)initWithKey:(NSString*)key audioPlayer:(FSAAudioPlayer*)player soundData:(FSASoundData*)data volume:(float)vol {
    self = [super init];
    if(self) {
        _key = [key retain];
        _player = player;
        [player retain];
        
        _data = data;
        _volume = vol;
    }
    return self;
}
-(NSString*)key {
    return _key;
}

-(void)play:(float)volume {
    [_player playSound:_data volume:_volume*volume];
}

-(void)dealloc {
    [_key release];
    [_player release];
    [super dealloc];
}

@end

@implementation FSARest
-(NSString*)key {
    return @"rest";
}
-(void)play:(float)volume {
}
-(void)setVolume:(float)f {
    
}
@end

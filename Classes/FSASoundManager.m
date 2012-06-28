//
//  FSASoundManager.m
//  ParticleSystem
//
//  Created by John Allwine on 6/16/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSASoundManager.h"

static FSASoundManager* fsaSoundManager;

@implementation FSASoundManager

-(id)init {
    self = [super init];
    
    if(self) {
        _player = [[FSAAudioPlayer alloc] init];
        [_player startAUGraph];
        _sounds = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    
    return self;
}

-(FSASound*)getSound: (NSString*)file {
    FSASound* sound = [_sounds objectForKey:file];
    if(sound == nil) {
        FSASoundData* data = [_player readAudioFileIntoMemory:file];
        float volume = 1;
        
        sound = [[FSASound alloc] initWithAudioPlayer:_player soundData: data volume:volume];
        
        [_sounds setObject:sound forKey:file];
        [sound release];
    }
    
    return sound;
}


-(void)dealloc {

    [super dealloc];
}

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        fsaSoundManager = [[FSASoundManager alloc] init];
    }
}

+(FSASoundManager*)instance {
    return fsaSoundManager;
}



@end

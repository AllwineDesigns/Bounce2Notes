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
        
        FSARest *rest = [[FSARest alloc] init];
        [_sounds setObject:rest forKey:@"rest"];
        [rest release];
    }
    
    return self;
}

-(FSASound*)getSound: (NSString*)file {
    return [self getSound:file volume:1];
}

-(FSASound*)getSound: (NSString*)file volume:(float)vol {
    FSASound* sound = [_sounds objectForKey:file];
    if(sound == nil) {
        FSASoundData* data = [_player readAudioFileIntoMemory:file];
        float volume = vol;
                
        sound = [[FSASound alloc] initWithAudioPlayer:_player soundData: data volume:volume];
        
        [_sounds setObject:sound forKey:file];
        [sound release];
    }
    sound.volume = vol;
    
    return sound;
}


-(void)dealloc {
    [_player release];
    [_sounds release];
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

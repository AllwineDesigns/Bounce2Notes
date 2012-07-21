//
//  FSASoundManager.h
//  ParticleSystem
//
//  Created by John Allwine on 6/16/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSAAudioPlayer.h"
#import "FSASound.h"

@interface FSASoundManager : NSObject {
    FSAAudioPlayer *_player;
    
    NSMutableDictionary *_sounds;
}

-(id)init;
-(FSASound*)getSound: (NSString*)file;
-(FSASound*)getSound: (NSString*)file volume:(float)vol;

+(FSASoundManager*)instance;

@end

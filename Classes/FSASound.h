//
//  FSASound.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSAAudioPlayer.h"

@protocol FSASoundDelegate <NSObject>
-(void)play: (float)volume;
@end

@interface FSASound : NSObject <FSASoundDelegate> {
    FSAAudioPlayer *_player;
    FSASoundData *_data;
    float _volume;
    
}

-(id)initWithAudioPlayer:(FSAAudioPlayer*)player soundData:(FSASoundData*)data volume:(float)vol;
@end

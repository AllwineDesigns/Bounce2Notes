//
//  BounceSound.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSASound.h"

#define BOUNCE_SOUND_VOLUME 10

@class BounceObject;

@protocol BounceSound <FSASoundDelegate>
-(void)resized:(float)old_size;
@end

@interface BounceNote : NSObject <BounceSound> {
    id<FSASoundDelegate> _sound;
}
-(id)initWithSound:(id<FSASoundDelegate>)sound;
@end

@interface BouncePentatonicSizeSound : NSObject <BounceSound> {
    BounceObject *_obj;
}
-(id)initWithBounceObject:(BounceObject*)obj;
@end

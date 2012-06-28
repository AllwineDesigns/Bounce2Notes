//
//  BounceSound.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSASound.h"

@class BounceObject;

@protocol BounceSound <FSASoundDelegate>

-(void)resized:(float)old_size;

@end

@interface BounceSound : NSObject <BounceSound> {
    BounceObject *_obj;
}

-(id)initWithBounceObject:(BounceObject*)obj;

@end

//
//  BounceArena.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "ChipmunkObject.h"
#import "BounceObject.h"

#define WALL_TYPE 222

@interface BounceArena : ChipmunkObject {
    CGSize _dimensions;
}

@property (nonatomic, readonly) CGSize dimensions;

-initWithRect: (CGRect)rect;
-(BOOL)isInBounds:(BounceObject*)obj;
-(BOOL)isInBoundsAt:(const vec2&)loc;
-(BOOL)isInBoundsAt:(const vec2&)loc withPadding:(float)pad;


@end

//
//  BounceArena.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "ChipmunkObject.h"

#define WALL_TYPE 222

@interface BounceArena : ChipmunkObject {
    CGSize _dimensions;
}

-initWithRect: (CGRect)rect;
-(BOOL)isInBoundsAt:(const vec2&)loc;

@end

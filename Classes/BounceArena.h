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
    CGRect _rect;
}

-initWithRect: (CGRect)rect;

@end

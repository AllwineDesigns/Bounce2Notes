//
//  BounceKillArena.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "ChipmunkObject.h"

@interface BounceKillArena : ChipmunkObject {
    CGRect _rect;
    BOOL _killTop;
    BOOL _killLeft;
    BOOL _killBottom;
    BOOL _killRight;
}

-initWithRect: (CGRect)rect;
@end

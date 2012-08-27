//
//  BounceShapeGenerator.m
//  ParticleSystem
//
//  Created by John Allwine on 8/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceShapeGenerator.h"
#import "fsa/Noise.hpp"

#define RANDFLOAT ((float)arc4random()/4294967295)

@implementation BounceShapeGenerator

@synthesize bounceShape = _bounceShape;

-(id)initWithBounceShape:(BounceShape)bounceShape {
    self = [super init];
    if(self) {
        _bounceShape = bounceShape;
    }
    return self;
}

-(BounceShape)randomBounceShapeWithLocation:(const vec2&)loc { 
    return _bounceShape;
}
@end

@implementation BounceRandomShapeGenerator

-(BounceShape)bounceShape {
    unsigned int i = (unsigned int)(RANDFLOAT*NUM_BOUNCE_SHAPES);
    
    return BounceShape(i);
}

-(BounceShape)randomBounceShapeWithLocation:(const vec2 &)loc {
    unsigned int i = (unsigned int)(random(loc*12.34)*NUM_BOUNCE_SHAPES);

    return BounceShape(i);
}

@end

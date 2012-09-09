//
//  BounceShapeGenerator.m
//  ParticleSystem
//
//  Created by John Allwine on 8/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceShapeGenerator.h"
#import "fsa/Noise.hpp"
#import "FSAUtil.h"

@implementation BounceShapeGenerator

@synthesize bounceShape = _bounceShape;

-(id)initWithCoder:(NSCoder *)aDecoder {
    _bounceShape = BounceShape([aDecoder decodeInt32ForKey:@"BounceShapeGeneratorBounceShape"]);
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:_bounceShape forKey:@"BounceShapeGeneratorBounceShape"];
}

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

-(BOOL)isEqual:(id)object {
    return [object isKindOfClass:[BounceShapeGenerator class]] && _bounceShape == ((BounceShapeGenerator*)object)->_bounceShape;
}

@end

@implementation BounceRandomShapeGenerator

-(id)initWithCoder:(NSCoder *)aDecoder {
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
}

-(BounceShape)bounceShape {
    unsigned int i = (unsigned int)(RANDFLOAT*NUM_BOUNCE_SHAPES);
    
    return BounceShape(i);
}

-(BounceShape)randomBounceShapeWithLocation:(const vec2 &)loc {
    unsigned int i = (unsigned int)(random(loc*12.34)*NUM_BOUNCE_SHAPES);

    return BounceShape(i);
}

-(BOOL)isEqual:(id)object {
    return [object isKindOfClass:[BounceRandomShapeGenerator class]];
}

@end

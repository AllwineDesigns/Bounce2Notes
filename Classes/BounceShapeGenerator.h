//
//  BounceShapeGenerator.h
//  ParticleSystem
//
//  Created by John Allwine on 8/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BounceObject.h"
#import "fsa/Vector.hpp"

using namespace fsa;

@interface BounceShapeGenerator : NSObject <NSCoding> {
    BounceShape _bounceShape;
}

@property (nonatomic, readonly) BounceShape bounceShape;

-(id)initWithBounceShape: (BounceShape)bounceShape;
-(BounceShape)randomBounceShapeWithLocation:(const vec2&)loc;

@end

@interface BounceRandomShapeGenerator : BounceShapeGenerator

@end

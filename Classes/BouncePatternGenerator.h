//
//  BouncePatternGenerator.h
//  ParticleSystem
//
//  Created by John Allwine on 8/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//
 

#import <Foundation/Foundation.h>
#import "BounceObject.h"
#import "fsa/Vector.hpp"

using namespace fsa;

@interface BouncePatternGenerator : NSObject <NSCoding> {
    FSATexture *_patternTexture;
}

@property (nonatomic, readonly) FSATexture* patternTexture;

-(id)initWithPatternTexture: (FSATexture*)patternTexture;
-(FSATexture*)randomPatternTextureWithLocation:(const vec2&)loc;

@end

@interface BounceRandomPatternGenerator : BouncePatternGenerator {
    NSArray *_patterns;
}
@end

//
//  BouncePatternGenerator.m
//  ParticleSystem
//
//  Created by John Allwine on 8/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BouncePatternGenerator.h"
#import "fsa/Noise.hpp"
#import "FSATextureManager.h"
#import "FSAUtil.h"

@implementation BouncePatternGenerator

@synthesize patternTexture = _patternTexture;

-(id)initWithCoder:(NSCoder *)aDecoder {
    _patternTexture = [[[FSATextureManager instance] getTexture:[aDecoder decodeObjectForKey:@"BouncePatternGeneratorPattern"]] retain];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_patternTexture.key forKey:@"BouncePatternGeneratorPattern"];
}

-(id)initWithPatternTexture:(FSATexture *)patternTexture {
    self = [super init];
    if(self) {
        _patternTexture = [patternTexture retain];
    }
    return self;
}

-(FSATexture*)randomPatternTextureWithLocation:(const vec2&)loc { 
    return _patternTexture;
}

-(BOOL)isEqual:(id)object {
    return [object isKindOfClass:[BouncePatternGenerator class]] && _patternTexture == ((BouncePatternGenerator*)object)->_patternTexture;
}

-(void)dealloc {
    [_patternTexture release];
    [super dealloc];
}
@end

@implementation BounceRandomPatternGenerator

-(id)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    
}

-(id)init {
    self = [super init];
    if(self) {
        FSATextureManager *texManager = [FSATextureManager instance];
        _patterns = [[NSArray alloc] initWithObjects:
        [texManager getTexture:@"spiral.jpg"],
        [texManager getTexture:@"plasma.jpg"],
        [texManager getTexture:@"weave.jpg"],
       // [texManager getTexture:@"checkered.jpg"],
        [texManager getTexture:@"black.jpg"],
        [texManager getTexture:@"white.jpg"],
        [texManager getTexture:@"sections.jpg"],
       // [texManager getTexture:@"squares.jpg"],
        [texManager getTexture:@"stripes.jpg"],
                     nil ];
    }
    return self;
}

-(FSATexture*)patternTexture {
    unsigned int i = (unsigned int)(RANDFLOAT*[_patterns count]);
    
    return [_patterns objectAtIndex:i];
}

-(FSATexture*)randomPatternTextureWithLocation:(const vec2 &)loc {
    unsigned int i = (unsigned int)(random(loc*12.34)*[_patterns count]);
    
    return [_patterns objectAtIndex:i];
}

-(BOOL)isEqual:(id)object {
    return [object isKindOfClass:[BounceRandomPatternGenerator class]];
}

-(void)dealloc {
    [_patterns release];
    [super dealloc];
}

@end
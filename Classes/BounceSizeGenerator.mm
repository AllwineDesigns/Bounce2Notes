//
//  BounceSizeGenerator.m
//  ParticleSystem
//
//  Created by John Allwine on 9/8/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSizeGenerator.h"
#import "BounceObject.h"
#import "FSAUtil.h"

@implementation BounceSizeGenerator {
    CGSize _size;
}

@synthesize size = _size;

-(id)initWithCoder:(NSCoder *)aDecoder {
    _size.width = [aDecoder decodeFloatForKey:@"BounceSizeGeneratorSize"];
    _size.height = [aDecoder decodeFloatForKey:@"BounceSizeGeneratorSecondarySize"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeFloat:_size.width forKey:@"BounceSizeGeneratorSize"];
    [aCoder encodeFloat:_size.height forKey:@"BounceSizeGeneratorSecondarySize"];
}

-(id)initWithSize:(float)size {
    self = [super init];
    if(self) {
        _size.width = size;
        _size.height = size*GOLDEN_RATIO;
    }
    
    return self;
}

-(BOOL)isEqual:(id)object {
    if([object class] == [BounceSizeGenerator class]) {
        CGSize s = [((BounceSizeGenerator*)object) size];
        
        return _size.width == s.width && _size.height == s.height;
    }
    
    return NO;
}

-(float)interp:(id)b x:(id)x { // returns t such that [a lerp:b param:t] returns x
    CGSize s = [self size];
    CGSize s2 = [(BounceSizeGenerator*)b size];
    CGSize sx = [(BounceSizeGenerator*)x size];
    
    float v = s.width;
    float v2 = s2.width;
    
    if([x isKindOfClass:[BounceRandomSizeGenerator class]]) {
        if([self isKindOfClass:[BounceRandomSizeGenerator class]]) {
            return 0;
        } else if([b isKindOfClass:[BounceRandomSizeGenerator class]]) {
            return 1;
        } else {
            return 2;
        }
    }
    
    float xv = sx.width;
    
    return (xv-v)/(v2-v);
}

-(id)lerp:(id)n param:(float)t {
    if([self isKindOfClass:[BounceRandomSizeGenerator class]] || [n isKindOfClass:[BounceRandomSizeGenerator class]]) {
        if(t < .5) {
            return self;
        } else {
            return n;
        }
    }
    CGSize s = [self size];
    CGSize s2 = [(BounceSizeGenerator*)n size];
    
    float v = s.width;
    float v2 = s2.width;
    return [[[BounceSizeGenerator alloc] initWithSize:v*(1-t)+v2*t] autorelease];
}

@end

@implementation BounceRandomSizeGenerator

-(CGSize)size {
    CGSize size;
    
    float t = RANDFLOAT;
    
    size.width = (1-t)*.03+t*.2;
    size.height = size.width*GOLDEN_RATIO;
    
    NSString *device = machineName();
    if(![device hasPrefix:@"iPad"]) {
        size.width *= 1.5;
        size.height *= 1.5;
    }
    
    return size;
}

-(BOOL)isEqual:(id)object {
    return [object class] == [BounceRandomSizeGenerator class];
}

@end

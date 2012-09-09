//
//  BounceColorGenerator.m
//  ParticleSystem
//
//  Created by John Allwine on 8/22/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceColorGenerator.h"
#import "FSAUtil.h"
#import "fsa/Noise.hpp"
#import "FSAUtil.h"

@implementation BounceColorGenerator

-(id)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
}


-(vec4)randomColor {
    NSAssert(NO, @"randomColor must be implemented by subclass");
    return vec4();
}
-(vec4)randomColorFromTime:(NSTimeInterval)time {
    NSAssert(NO, @"randomColorFromTime: must be implemented by subclass");
    return vec4();
}
-(vec4)randomColorFromLocation:(const vec2&)loc {
    NSAssert(NO, @"randomColorFromLocation: must be implemented by subclass");
    return vec4();

}
-(vec4)perlinColorFromLocation:(const vec2&)loc time:(NSTimeInterval)time {
    NSAssert(NO, @"perlinColorFromLocation:time: must be implemented by subclass");
    return vec4();
}

-(BOOL)isEqual:(id)object {
    return [object class] == [self class];
}
@end

@implementation BouncePastelColorGenerator

-(vec4)colorFromK:(float)k k2:(float)k2 {
    vec4 color(0,0,0,1);
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             360.*k, .4, .05*k2+.75   );
    return color;
}

-(vec4)randomColor {
    float k = RANDFLOAT;
    float k2 = RANDFLOAT;
    
    return [self colorFromK:k k2:k2];

}

-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time);
    float k2 = random(time*184.283);
    
    return [self colorFromK:k k2:k2];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc);
    float k2 = random(loc*92.137);
    return [self colorFromK:k k2:k2];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    vec2 l2 = 6*loc+vec2(456,-120);
    
    float t = time;
    float t2 = time+1000;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    float k2 = .5*pnoise(l2.x, l2.y, t2)+.5;
    
    return [self colorFromK:k k2:k2];
}

@end

@implementation BounceRedColorGenerator

-(vec4)colorFromK:(float)k k2:(float)k2 k3:(float)k3 {
    vec4 color(0,0,0,1);
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             10.*k, .2*k3+.8, .6*k2+.4   );
    return color;
}

-(vec4)randomColor {
    float k = RANDFLOAT;
    float k2 = RANDFLOAT;
    float k3 = RANDFLOAT;
    
    return [self colorFromK:k k2:k2 k3:k3];
    
}


-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time);
    float k2 = random(time*184.283);
    float k3 = random(time*23.8192);
    
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc);
    float k2 = random(loc*92.137);
    float k3 = random(loc*7.29283);
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    vec2 l2 = 6*loc+vec2(456,-120);
    vec2 l3 = 6*loc+vec2(8721,-1220);
    
    float t = time;
    float t2 = time+1000;
    float t3 = time+2000;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    float k2 = .5*pnoise(l2.x, l2.y, t2)+.5;
    float k3 = .5*pnoise(l3.x, l3.y, t3)+.5;
    
    return [self colorFromK:k k2:k2 k3:k3];
}

@end

@implementation BounceOrangeColorGenerator


-(vec4)colorFromK:(float)k k2:(float)k2 k3:(float)k3 {
    vec4 color(0,0,0,1);
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             15.*k+15, .2*k3+.8, .6*k2+.4   );
    return color;
}


-(vec4)randomColor {
    float k = RANDFLOAT;
    float k2 = RANDFLOAT;
    float k3 = RANDFLOAT;
    
    return [self colorFromK:k k2:k2 k3:k3];
    
}

-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time);
    float k2 = random(time*184.283);
    float k3 = random(time*23.8192);
    
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc);
    float k2 = random(loc*92.137);
    float k3 = random(loc*7.29283);
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    vec2 l2 = 6*loc+vec2(456,-120);
    vec2 l3 = 6*loc+vec2(8721,-1220);
    
    float t = time;
    float t2 = time+1000;
    float t3 = time+2000;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    float k2 = .5*pnoise(l2.x, l2.y, t2)+.5;
    float k3 = .5*pnoise(l3.x, l3.y, t3)+.5;
    
    return [self colorFromK:k k2:k2 k3:k3];
}

@end

@implementation BounceYellowColorGenerator

-(vec4)colorFromK:(float)k k2:(float)k2 k3:(float)k3 {
    vec4 color(0,0,0,1);
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             15.*k+45, .2*k3+.8, .6*k2+.4   );
    return color;
}


-(vec4)randomColor {
    float k = RANDFLOAT;
    float k2 = RANDFLOAT;
    float k3 = RANDFLOAT;
    
    return [self colorFromK:k k2:k2 k3:k3];
    
}

-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time);
    float k2 = random(time*184.283);
    float k3 = random(time*23.8192);
    
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc);
    float k2 = random(loc*92.137);
    float k3 = random(loc*7.29283);
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    vec2 l2 = 6*loc+vec2(456,-120);
    vec2 l3 = 6*loc+vec2(8721,-1220);
    
    float t = time;
    float t2 = time+1000;
    float t3 = time+2000;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    float k2 = .5*pnoise(l2.x, l2.y, t2)+.5;
    float k3 = .5*pnoise(l3.x, l3.y, t3)+.5;
    
    return [self colorFromK:k k2:k2 k3:k3];
}

@end

@implementation BounceGreenColorGenerator

-(vec4)colorFromK:(float)k k2:(float)k2 k3:(float)k3 {
    vec4 color(0,0,0,1);
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             30.*k+100, .2*k3+.8, .6*k2+.4   );
    return color;
}


-(vec4)randomColor {
    float k = RANDFLOAT;
    float k2 = RANDFLOAT;
    float k3 = RANDFLOAT;
    
    return [self colorFromK:k k2:k2 k3:k3];
    
}

-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time);
    float k2 = random(time*184.283);
    float k3 = random(time*23.8192);
    
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc);
    float k2 = random(loc*92.137);
    float k3 = random(loc*7.29283);
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    vec2 l2 = 6*loc+vec2(456,-120);
    vec2 l3 = 6*loc+vec2(8721,-1220);
    
    float t = time;
    float t2 = time+1000;
    float t3 = time+2000;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    float k2 = .5*pnoise(l2.x, l2.y, t2)+.5;
    float k3 = .5*pnoise(l3.x, l3.y, t3)+.5;
    
    return [self colorFromK:k k2:k2 k3:k3];
}

@end

@implementation BounceBlueColorGenerator

-(vec4)colorFromK:(float)k k2:(float)k2 k3:(float)k3 {
    vec4 color(0,0,0,1);
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             45.*k+215, .2*k3+.8, .6*k2+.4   );
    return color;
}


-(vec4)randomColor {
    float k = RANDFLOAT;
    float k2 = RANDFLOAT;
    float k3 = RANDFLOAT;
    
    return [self colorFromK:k k2:k2 k3:k3];
    
}

-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time);
    float k2 = random(time*184.283);
    float k3 = random(time*23.8192);
    
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc);
    float k2 = random(loc*92.137);
    float k3 = random(loc*7.29283);
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    vec2 l2 = 6*loc+vec2(456,-120);
    vec2 l3 = 6*loc+vec2(8721,-1220);
    
    float t = time;
    float t2 = time+1000;
    float t3 = time+2000;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    float k2 = .5*pnoise(l2.x, l2.y, t2)+.5;
    float k3 = .5*pnoise(l3.x, l3.y, t3)+.5;
    
    return [self colorFromK:k k2:k2 k3:k3];
}

@end

@implementation BouncePurpleColorGenerator

-(vec4)colorFromK:(float)k k2:(float)k2 k3:(float)k3 {
    vec4 color(0,0,0,1);
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             10.*k+270, .2*k3+.8, .5*k2+.5   );
    return color;
}


-(vec4)randomColor {
    float k = RANDFLOAT;
    float k2 = RANDFLOAT;
    float k3 = RANDFLOAT;
    
    return [self colorFromK:k k2:k2 k3:k3];
    
}

-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time);
    float k2 = random(time*184.283);
    float k3 = random(time*23.8192);
    
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc);
    float k2 = random(loc*92.137);
    float k3 = random(loc*7.29283);
    return [self colorFromK:k k2:k2 k3:k3];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    vec2 l2 = 6*loc+vec2(456,-120);
    vec2 l3 = 6*loc+vec2(8721,-1220);
    
    float t = time;
    float t2 = time+1000;
    float t3 = time+2000;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    float k2 = .5*pnoise(l2.x, l2.y, t2)+.5;
    float k3 = .5*pnoise(l3.x, l3.y, t3)+.5;
    
    return [self colorFromK:k k2:k2 k3:k3];
}

@end

@implementation BounceGrayColorGenerator

-(vec4)colorFromK:(float)k {
    vec4 color(0,0,0,1);
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             0, 0, .7*k+.3   );
    return color;
}


-(vec4)randomColor {
    float k = RANDFLOAT;
    
    return [self colorFromK:k];
    
}

-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time);
    
    return [self colorFromK:k];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc);

    return [self colorFromK:k];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    
    float t = time;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    
    return [self colorFromK:k];
}

@end

@implementation BounceRandomColorGenerator

-(id)init {
    self = [super init];
    if(self) {
        _generators = [[NSArray alloc] initWithObjects:[[BouncePastelColorGenerator alloc] init],
                       [[BounceRedColorGenerator alloc] init],
                       [[BounceOrangeColorGenerator alloc] init],
                       [[BounceYellowColorGenerator alloc] init],
                       [[BounceGreenColorGenerator alloc] init],
                       [[BounceBlueColorGenerator alloc] init],
                       [[BouncePurpleColorGenerator alloc] init],
                       [[BounceGrayColorGenerator alloc] init], nil];
        for(BounceColorGenerator *g in _generators) {
            [g release];
        }
    }
    return self;
}

-(vec4)randomColor {
    float k = RANDFLOAT;
    unsigned int i = k*[_generators count];
    
    return [[_generators objectAtIndex:i] randomColor];
    
}

-(vec4)randomColorFromTime:(NSTimeInterval)time {
    float k = random(time*2.345);
    
    unsigned int i = k*[_generators count];
    
    return [[_generators objectAtIndex:i] randomColorFromTime:time];
}

-(vec4)randomColorFromLocation:(const vec2 &)loc {
    float k = random(loc*4.1234);
    
    unsigned int i = k*[_generators count];
    
    return [[_generators objectAtIndex:i] randomColorFromLocation:loc];
}

-(vec4)perlinColorFromLocation:(const vec2 &)loc time:(NSTimeInterval)time {
    vec2 l = 6*loc+vec2(123,923);
    
    float t = time;
    
    float k = .5*pnoise(l.x, l.y, t)+.5;
    unsigned int i = k*[_generators count];
    
    return [[_generators objectAtIndex:i] perlinColorFromLocation:loc time:time];
}

-(void)dealloc {
    [_generators release];
    [super dealloc];
}

@end


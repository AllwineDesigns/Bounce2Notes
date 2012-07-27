//
//  FSAGestureCurves.m
//  ParticleSystem
//
//  Created by John Allwine on 7/21/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSAGestureCurves.h"
#import "FSAGlowyGestureCurve.h"
#import "fsa/Noise.hpp"
#import "FSAUtil.h"

@implementation FSAGestureCurves {
    NSMutableDictionary *_curves;
}

-(id)init {
    self = [super init];
    if(self) {
        _curves = [[NSMutableDictionary alloc] initWithCapacity:11];
    }
    return self;
}

-(void)step:(float)dt {
    NSMutableSet *deleteKeys = [NSMutableSet setWithCapacity:11];
    
    for(NSValue *key in _curves) {
        FSAGestureCurve *curve = [_curves objectForKey:key];
        
        [curve step:dt];
        if(curve.ended && [curve disappeared]) {
            [deleteKeys addObject:key];
        }
    }
    
    for(NSValue *key in deleteKeys) {
        [_curves removeObjectForKey:key];
    }

}


-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    NSValue *key = [NSValue valueWithPointer:uniqueId];
            
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             360.*random(64.28327*loc), .4, .05*random(736.2827*loc)+.75   );
    color.w = 1;
    
    FSAGestureCurve *curve = [[FSAGlowyGestureCurve alloc] initWithColor:color];
    
    [curve addPoint:loc];
    
    [_curves setObject:curve forKey:key];
    [curve release];
}
-(void)drag:(void*)uniqueId at:(const vec2&)loc {
    NSValue *key = [NSValue valueWithPointer:uniqueId];
    
    FSAGestureCurve *curve = [_curves objectForKey:key];
    [curve addPoint:loc];

}
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc {
    NSValue *key = [NSValue valueWithPointer:uniqueId];
    
    FSAGestureCurve *curve = [_curves objectForKey:key];
    [curve addPoint:loc];
    curve.ended = YES;
    
}
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    NSValue *key = [NSValue valueWithPointer:uniqueId];

    FSAGestureCurve *curve = [_curves objectForKey:key];
    [curve addPoint:loc];
    curve.ended = YES;}

-(void)draw {
    for(FSAGestureCurve *curve in [_curves objectEnumerator]) {
        [curve draw];
    }
}

-(void)dealloc {
    [_curves release];
    
    [super dealloc];
}

@end

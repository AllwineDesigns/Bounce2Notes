//
//  FSAGestureCurves.h
//  ParticleSystem
//
//  Created by John Allwine on 7/21/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSAGestureCurve.h"

@interface FSAGestureCurves : NSObject 

-(void)step:(float)dt;
-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)drag:(void*)uniqueId at:(const vec2&)loc;
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)draw;

@end

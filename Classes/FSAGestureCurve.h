//
//  FSAGestureCurve.h
//  ParticleSystem
//
//  Created by John Allwine on 7/21/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSACurve.h"

@interface FSAGestureCurve : FSACurve

@property (nonatomic) BOOL ended;
@property (nonatomic) float fadeTime;
@property (nonatomic, readonly) float time;

-(BOOL)disappeared;
-(float*)times;
-(float*)resampledTimes;
-(vec2*)resampledPoints;
-(unsigned int)resampledNumPoints;

-(void)step: (float)dt;
-(void)draw;

@end

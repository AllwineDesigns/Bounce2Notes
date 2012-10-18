//
//  AnchoredBounceObject.h
//  ParticleSystem
//
//  Created by John Allwine on 9/9/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BounceObject.h"
#import "fsa/Vector.hpp"
#import "BouncePages.h"

@interface AnchoredBounceObject : NSObject <BounceWidget> {
    BounceObject *_object;
    vec2 _anchor;
    vec2 _vel;
}

@property (nonatomic, readonly) BounceObject *object;

-(id)initWithBounceObject:(BounceObject*)obj;
-(void)setPosition:(const vec2&)loc;
-(void)setVelocity:(const vec2&)vel;
-(void)setAngle:(float)a;
-(void)setAngVel:(float)angVel;
-(void)addToSimulation:(BounceSimulation*)simulation;
-(void)step:(float)dt;

@end

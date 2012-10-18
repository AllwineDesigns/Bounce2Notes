//
//  AnchoredBounceObject.m
//  ParticleSystem
//
//  Created by John Allwine on 9/9/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "AnchoredBounceObject.h"
#import "BounceSimulation.h"

@implementation AnchoredBounceObject

@synthesize object = _object;

-(id)initWithBounceObject:(BounceObject *)obj {
    _object = [obj retain];
    
    return self;
}
-(void)setPosition:(const vec2&)loc {
    _anchor = loc;
}
-(void)setVelocity:(const vec2&)vel {
}
-(void)setAngle:(float)a {
    _object.angle = a;
}
-(void)setAngVel:(float)angVel {
    _object.angVel = angVel;
}
-(void)addToSimulation:(BounceSimulation*)simulation {
    [_object addToSimulation:simulation];
}
-(void)step:(float)dt {
    if([_object hasBeenAddedToSimulation]) {
        BounceSimulation *sim = [_object simulation];
        if(![sim isObjectParticipatingInGesture:_object]) {
            float springK = 150;
            float drag = .15;
            
            vec2 pos = _object.position;
            pos += _vel*dt;
            vec2 a = -springK*(pos-_anchor);
            
            _vel +=  a*dt-drag*_vel;
            
            [_object setPosition:pos];
            [_object setVelocity:_vel];
            
        } else {
            _vel = vec2(0,0);
        }
    }
}
@end

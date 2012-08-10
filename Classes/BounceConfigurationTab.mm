//
//  BounceConfigurationTab.m
//  ParticleSystem
//
//  Created by John Allwine on 7/11/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationTab.h"
#import "fsa/Vector.hpp"
#import "BounceConfigurationPane.h"
#import "BounceConstants.h"

using namespace fsa;

@implementation BounceConfigurationTab

@synthesize offset = _offset;

-(id)initWithPane:(BounceConfigurationPane *)pane index:(unsigned int)index offset:(const vec2 &)offset {
    self = [super initObjectWithShape:BOUNCE_CAPSULE at:vec2(0,-5) withVelocity:vec2() withColor:vec4() withSize:.15 withAngle:0];
    
    if(self) {
        _pane = pane;
        [pane retain];
        _isPreviewable = NO;
        _isRemovable = NO;
        _index = index;
        vec2 panePos = _pane.object.position;
        vec2 pos = panePos+offset;

        [self setPosition: pos];
        
        _offset = offset;
        _isStationary = YES;

        [self makeStatic];
    }
    
    return self;
}

//-(void)makeStatic {
 //   [self makeHeavyRogue];
//}

-(void)playSound:(float)volume {
    
}

-(void)singleTapAt:(const vec2 &)loc {
    [_pane setCurrentSimulation:_index];
    _intensity = 2.2;
    [_renderable burst:5];
}

-(void)flickAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    float dot = vel.dot(0,1);
    if(dot > 0) {
        [self singleTapAt:loc];
    } else {
        [_pane deactivate];
    }
}

-(void)createCallbackWithSize:(float)size secondarySize:(float)size2 {
    
}

-(void)grabCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel stationary:(BOOL)stationary {
    [_pane setCurrentSimulation:_index];

    vec2 springLoc(_pane.object.springLoc);
    springLoc.y = pos.y-_offset.y;
    [_pane.object setSpringLoc:springLoc];
}
-(void)endGrabCallback {
    vec2 activeLoc = _pane.object.activeSpringLoc;
    vec2 inactiveLoc = _pane.object.inactiveSpringLoc;
    
    vec2 springLoc = _pane.object.springLoc;
    
    BounceConstants *constants = [BounceConstants instance];
    
    float aspect = constants.aspect;
    float invaspect = 1./aspect;

    if(springLoc.y <  -invaspect) {
        [_pane deactivate];
    } else {
        [_pane activate];
        [_pane setCurrentSimulation:_index];
    }
}

-(void)cancelGrabCallback {
   [_pane reset];
}

-(void)transformCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel size:(float)size secondarySize:(float)size2 doSecondarySize:(BOOL)_doSecondarySize {
    
}

-(void)dealloc {
    [_pane release];
    [super dealloc];
}

@end

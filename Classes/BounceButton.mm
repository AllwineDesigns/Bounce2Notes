//
//  BounceButton.m
//  ParticleSystem
//
//  Created by John Allwine on 8/19/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceButton.h"

@implementation BounceButton

@synthesize delegate = _delegate;

-(id)init {
    self = [super initObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2() withColor:vec4(.5,.75,1,1) withSize:.05 withAngle:0];
    
    if(self) {
        self.isPreviewable = NO;
        self.isRemovable = NO;
        self.simulationWillDraw = NO;
        self.isStationary = YES;
        [self makeStatic];
    }
    
    return self;
}

-(void)makeSimulated {
    [self makeStatic];
}


-(void)singleTapAt:(const vec2 &)loc {
    [_delegate pressed:self];
    [_renderable burst:5];
    _intensity = 2.2;
}

-(void)flickAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    
}

-(void)createCallbackWithSize:(float)size secondarySize:(float)size2 {
}

-(void)beginGrabCallback:(const vec2&)loc {
}

-(void)grabCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel stationary:(BOOL)stationary {
    
}

-(void)endGrabCallback {
    
}

-(void)beginTransformCallback {
    
}

-(void)grabCallback:(const vec2 &)loc {
}

-(void)endTransformCallback {
    
}

-(void)transformCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel size:(float)size secondarySize:(float)size2 doSecondarySize:(BOOL)_doSecondarySize {
    
}

@end

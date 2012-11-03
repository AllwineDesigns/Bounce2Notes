//
//  BounceConfigurationTab.m
//  ParticleSystem
//
//  Created by John Allwine on 7/11/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationTab.h"
#import "fsa/Vector.hpp"
#import "BouncePane.h"
#import "BounceConstants.h"
#import "BounceSettings.h"

using namespace fsa;

@implementation BounceConfigurationTab

-(id)initWithPane:(BouncePane *)pane index:(unsigned int)index offset:(const vec2 &)offset {
    self = [super initObjectWithShape:BOUNCE_BALL at:vec2(0,-5) withVelocity:vec2() withColor:vec4() withSize:.15 withAngle:0];
    
    if(self) {
        _pane = pane;
        [pane retain];
        _isPreviewable = NO;
        _isRemovable = NO;
        _simulationWillDraw = NO;
        _simulationWillArchive = NO;
        _order = 1000000;
        _index = index;
        vec2 panePos = _pane.object.position;
        vec2 pos = panePos+offset;

        [self setPosition: pos];
        
        _offset = offset;
        _isStationary = NO;

        [self makeStatic];
    }
    
    return self;
}
-(const vec2&)offset {
    return _offset;
}
-(void)setOffset:(const vec2&)offset {
    _offset = offset;
}

-(void)setOrder:(int)order {
    
}

-(void)makeSimulated {
    [self makeStatic];
}

//-(void)makeStatic {
//    [self makeHeavyRogue];
//}

-(void)playSound:(float)volume {
    
}

-(void)singleTapAt:(const vec2 &)loc {
    [_pane tabSingleTappedAt:loc index:_index];
    _intensity = 2.2;
    [_renderable burst:5];
}

-(void)flickAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    [_pane tabFlickedAt:(const vec2&)loc withVelocity:(const vec2&)vel index:_index];
    _intensity = 2.2;
    [_renderable burst:5];
}

-(void)createCallbackWithSize:(float)size secondarySize:(float)size2 {
    
}

-(void)grabCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel stationary:(BOOL)stationary {
    [_pane tabGrabbedAt:pos offset:_offset index:_index];
}
-(void)endGrabCallback {
    [_pane tabGrabEnded: _index];
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

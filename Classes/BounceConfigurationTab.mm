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

using namespace fsa;

@implementation BounceConfigurationTab

@synthesize offset = _offset;

-(id)initWithPane:(BounceConfigurationPane *)pane index:(unsigned int)index offset:(const vec2 &)offset {
    self = [super initObjectWithShape:BOUNCE_RECTANGLE at:vec2(0,-5) withVelocity:vec2() withColor:vec4() withSize:.15 withAngle:0];
    
    if(self) {
        _pane = pane;
        [pane retain];
        _isManipulatable = NO;
        _index = index;
        _offset = offset;

        [self makeStatic];
    }
    
    return self;
}

-(void)playSound:(float)volume {
    
}

-(void)singleTap {
    [_pane setCurrentSimulation:_index];
    _intensity = 2.2;
    [_renderable burst:5];
}

-(void)dealloc {
    [_pane release];
    [super dealloc];
}

@end

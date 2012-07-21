//
//  MainBounceSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "MainBounceSimulation.h"
#import "BounceConstants.h"
#import "FSAShaderManager.h"

@implementation MainBounceSimulation

-(id)initWithAspect: (float)aspect {
    float invaspect = 1./aspect;
    
    CGRect rect = CGRectMake(-1,-invaspect, 2, 2*invaspect);
    
    self = [super initWithRect:rect];
    
    if(self) {
        _aspect = aspect;
        _killArena = [[BounceKillArena alloc] initWithRect:rect simulation:self];
        [_killArena addToSpace:_space];
        
        _configPane = [[BounceConfigurationPane alloc] initWithBounceSimulation:self];
        
        [[BounceObject randomObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2()] addToSimulation:self];
    }
    
    return self;
}

//-(void)step:(float)t {
//    [super step:t];
//    [_configPane step:t];
//}

-(void)next {
    [super next];
    [_configPane step:_dt];
}

-(void)setGravity:(const vec2 &)g {
    [_configPane setGravity:g];
    [super setGravity:g];
}

-(void)addToVelocity:(const vec2 &)v {
    [_configPane addToVelocity:v];
    [super addToVelocity:v];
}

-(void)singleTap: (void*)uniqueId at:(const vec2 &)loc {   
    if(![_configPane singleTap:uniqueId at:loc]) {
        [super singleTap:uniqueId at:loc];
    }
}

-(void)flick: (void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    if(![_configPane flick:uniqueId at:loc inDirection:dir time:time]) {
        [super flick:uniqueId at:loc inDirection:dir time:time];
    }
}

-(void)longTouch:(void*)uniqueId at:(const vec2&)loc {
    if(![_configPane longTouch:uniqueId at:loc]) {
        [super longTouch:uniqueId at:loc];
    }
}
-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    if(![_configPane beginDrag:uniqueId at:loc]) {
        [super beginDrag:uniqueId at:loc];
    }
}
-(void)drag:(void*)uniqueId at:(const vec2&)loc {
    if(![_configPane drag:uniqueId at:loc]) {
        [super drag:uniqueId at:loc];
    }
}
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc {
    if(![_configPane endDrag:uniqueId at:loc]) {
        [super endDrag:uniqueId at:loc];
    }
}
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    if(![_configPane cancelDrag:uniqueId at:loc]) {
        [super cancelDrag:uniqueId at:loc];
    }
}

-(void)beginTopSwipe:(void*)uniqueId at:(float)y {
    if(![_killArena isEnabled]) {
        [_killArena enableTop];
        [_killArena setTop:y];
    }
}
-(void)topSwipe:(void*)uniqueId at:(float)y {
    if([_killArena isTopEnabled]) {
        [_killArena setTop:y];
    }
    
}
-(void)endTopSwipe:(void*)uniqueId {
    if([_killArena isTopEnabled]) {
        [_killArena disableTop];
    }
}

-(void)beginBottomSwipe:(void*)uniqueId at:(float)y {
    if(![_killArena isEnabled]) {
        [_killArena enableBottom];
        [_killArena setBottom:y];
    }
}
-(void)bottomSwipe:(void*)uniqueId at:(float)y {
    if([_killArena isBottomEnabled]) {
        [_killArena setBottom:y];
    }
}
-(void)endBottomSwipe:(void*)uniqueId {
    if([_killArena isBottomEnabled]) {
        [_killArena disableBottom];
    }
}

-(void)beginLeftSwipe:(void*)uniqueId at:(float)x {
    if(![_killArena isEnabled]) {
        [_killArena enableLeft];
        [_killArena setLeft:x];
    }
}
-(void)leftSwipe:(void*)uniqueId at:(float)x {
    if([_killArena isLeftEnabled]) {
        [_killArena setLeft:x];
    }
}
-(void)endLeftSwipe:(void*)uniqueId {
    if([_killArena isLeftEnabled]) {
        [_killArena disableLeft];
    }
}

-(void)beginRightSwipe:(void*)uniqueId at:(float)x {
    if(![_killArena isEnabled]) {
        [_killArena enableRight];
        [_killArena setRight:x];
    }
}
-(void)rightSwipe:(void*)uniqueId at:(float)x {
    if([_killArena isRightEnabled]) {
        [_killArena setRight:x];
    }
}
-(void)endRightSwipe:(void*)uniqueId {
    if([_killArena isRightEnabled]) {
        [_killArena disableRight];
    }
}

-(void)draw {
    [super draw];
    [_killArena draw];
    [_configPane draw];
                        
}

-(void)dealloc {
    [_killArena removeFromSpace];
    [_killArena release]; _killArena = nil;
    [_configPane release]; _configPane = nil;
    
    [super dealloc];
}
@end

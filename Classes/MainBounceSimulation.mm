//
//  MainBounceSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "MainBounceSimulation.h"
#import "BounceConstants.h"

@implementation MainBounceSimulation

-(id)initWithAspect: (float)aspect {
    float invaspect = 1./aspect;
    
    CGRect rect = CGRectMake(-1,-invaspect, 2, 2*invaspect);
    
    self = [super initWithRect:rect];
    
    if(self) {
        _aspect = aspect;
        _killArena = [[BounceKillArena alloc] initWithRect:rect simulation:self];
        [_killArena addToSpace:_space];
        
        [self addObject:[BounceObject randomObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2()]];
    }
    
    return self;
}

-(void)singleTapAt:(const vec2 &)loc {
    float upi = [[BounceConstants instance] unitsPerInch];
    
    if(loc.y < _arena.rect.origin.y+upi*.5) {
        NSLog(@"tapped bottom\n");
        
        if([_configPane isActive]) {
            [_configPane deactivate];
        } else {
            [_configPane activate];
        }
    } else {
        [super singleTapAt:loc];
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
}

-(void)dealloc {
    [_killArena removeFromSpace];
    [_killArena release]; _killArena = nil;
    
    [super dealloc];
}
@end

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
#import "BounceSettings.h"
#import "FSATextureManager.h"

@implementation MainBounceSimulation

@synthesize delegate = _delegate;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    float aspect = [BounceConstants instance].aspect;

    
    _aspect = aspect;
    
   // _aspect = [aDecoder decodeFloatForKey:@"MainBounceSimulationAspect"];
    
    float invaspect = 1./_aspect;
    CGRect rect = CGRectMake(-1,-invaspect, 2, 2*invaspect);
    
    [_arena removeFromSpace];
    [_arena release];
    _arena = [[BounceArena alloc] initWithRect:rect];
    [_arena addToSpace:_space];
    
    _killArena = [[BounceKillArena alloc] initWithRect:rect simulation:self];
    [_killArena addToSpace:_space];
        
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeFloat:_aspect forKey:@"MainBounceSimulationAspect"];
}

-(id)initWithAspect: (float)aspect {
    float invaspect = 1./aspect;
    
    CGRect rect = CGRectMake(-1,-invaspect, 2, 2*invaspect);
    
    self = [super initWithRect:rect];
    
    if(self) {
        _aspect = aspect;
        _killArena = [[BounceKillArena alloc] initWithRect:rect simulation:self];
        [_killArena addToSpace:_space];
                
        BounceObject *obj = [[BounceObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2() withColor: vec4(.46,.68,.76,1) withSize:.15 withAngle:0];
        obj.angVel = -100;
        [obj addToSimulation:self];
        [obj release];
        /*
        BounceObject *obj = [BounceObject randomObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2()];
        
        obj.patternTexture = [[FSATextureManager instance] getTexture:@"John Allwine"];
        [obj addToSimulation:self];
         */
    }
    
    return self;
}

-(void)setGravity:(const vec2 &)g {
    [super setGravity:g];
}

-(void)addToVelocity:(const vec2 &)v {
    [super addToVelocity:v];
}

-(void)singleTap: (void*)uniqueId at:(const vec2 &)loc {   
    if([BounceSettings instance].playMode && [self gestureForKey:uniqueId] == nil) {

    } else {
        [super singleTap:uniqueId at:loc];
    }
}

-(void)flick: (void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    if([BounceSettings instance].playMode && [self gestureForKey:uniqueId] == nil) {
    
    } else {
        [super flick:uniqueId at:loc inDirection:dir time:time];
    }
}

-(void)longTouch:(void*)uniqueId at:(const vec2&)loc {
    if([BounceSettings instance].playMode && [self gestureForKey:uniqueId] == nil) {
        
    } else {
        [super longTouch:uniqueId at:loc];
    }
}
-(void)beginCreate:(void *)uniqueId at:(const vec2 &)loc {
    [super beginCreate:uniqueId at:loc];

    if([[BounceSettings instance] bounceLocked]) {
        BounceGesture *gesture = [self gestureForKey:uniqueId];
        if(gesture == nil) {
            return;
        }
        BounceObject *obj = [gesture object];
        
        if(![obj hasBeenAddedToSimulation]) {
            [obj randomizeSize];
            [obj addToSimulation:self];
            [obj playSound:.2];
        }
        
        [gesture beginGrabAt:loc];
    }
}

-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    if([BounceSettings instance].playMode && ![[self objectAt:loc] isKindOfClass:[BounceConfigurationTab class]]) {
        NSSet *objects = [self objectsAt:loc withinRadius:0.06875];
        for(BounceObject *o in objects) {
            NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
            if(now-o.lastPlayed > .02) {
                [o playSound:.2];
                [o.renderable burst:5];
                o.intensity = 2.2;
                o.lastPlayed = now;
            }
        }
    } else {
        [super beginDrag:uniqueId at:loc];
    }
}
-(void)drag:(void*)uniqueId at:(const vec2&)loc {
    if([BounceSettings instance].playMode && [self gestureForKey:uniqueId] == nil) {
        NSSet *objects = [self objectsAt:loc withinRadius:0.06875];
        for(BounceObject *o in objects) {
            NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
            if(now-o.lastPlayed > .02) {
                [o playSound:.2];
                [o.renderable burst:5];
                o.intensity = 2.2;
                o.lastPlayed = now;
            }
        }
    } else {
        [super drag:uniqueId at:loc];
    }
}
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc {
    if([BounceSettings instance].playMode && [self gestureForKey:uniqueId] == nil) {
    } else {
        [super endDrag:uniqueId at:loc];
    }
}
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    if([BounceSettings instance].playMode && [self gestureForKey:uniqueId] == nil) {
    
    } else {
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

-(void)addObject:(BounceObject *)object {
    BounceSettings *settings = [BounceSettings instance];
    [object setVelocityLimit:settings.velocityLimit];
    [object setBounciness:settings.bounciness];
    [object setFriction:settings.friction];
    [object setGravityScale:settings.gravityScale];
    [object setDamping:settings.damping];
    
    [super addObject:object];
}

-(void)saveSimulation {
    [_delegate saveSimulation];
}

-(void)loadSimulation:(NSString *)file {
    [_delegate loadSimulation:file];
}

-(void)loadBuiltInSimulation:(NSString *)file {
    [_delegate loadBuiltInSimulation:file];
}

-(void)deleteSimulation:(NSString *)file {
    [_delegate deleteSimulation:file];
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

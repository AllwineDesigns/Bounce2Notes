//
//  BounceSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 5/13/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSimulation.h"
#import "FSAUtil.h"
#import "fsa/Noise.hpp"
#import <chipmunk/chipmunk_unsafe.h>
#import "FSATextureManager.h"
#import "BounceConstants.h"

int collisionBegin(cpArbiter *arb, cpSpace *space, void *data) {
    return 1;
}
int preSolve(cpArbiter *arb, cpSpace *space, void *data) {
    cpBody *body1;
    cpBody *body2;
    cpArbiterGetBodies(arb, &body1, &body2);
    
    BounceObject *obj1 = (BounceObject*)cpBodyGetUserData(body1);
    ChipmunkObject *cobj = (ChipmunkObject*)cpBodyGetUserData(body2);
    BounceObject *obj2 = nil;
    if([cobj isKindOfClass:[BounceObject class]]) {
        obj2 = (BounceObject*)cobj;
    }

    vec2 vel1(obj1.velocity);
    [obj1 setLastVelocity: vel1];
    
    if(obj2) {
        vec2 vel2(obj2.velocity);
        [obj2 setLastVelocity: vel2];
    }
    
    return 1;
}
void postSolve(cpArbiter *arb, cpSpace *space, void *data) {
    cpBody *body1;
    cpBody *body2;
    cpArbiterGetBodies(arb, &body1, &body2);
    
    float ke = 0;
    
    BounceObject *obj1 = (BounceObject*)cpBodyGetUserData(body1);
    ChipmunkObject *cobj = (ChipmunkObject*)cpBodyGetUserData(body2);
    BounceObject *obj2 = nil;
    if([cobj isKindOfClass:[BounceObject class]]) {
        obj2 = (BounceObject*)cobj;
    }
    
    float lastSpeed1 = obj1.lastVelocity.length();
    ke += lastSpeed1*lastSpeed1;
    
    if(obj2) {
        float lastSpeed2 = obj2.lastVelocity.length();
        ke += lastSpeed2*lastSpeed2;
    
        ke *= .5;
    }
    
    float intensity1 = obj1.intensity;
    
    intensity1 += .05*ke/obj1.size;
    if(intensity1 > 2.2) {
        intensity1 = 2.2;
    }
    
    obj1.intensity = intensity1;
    
    if(obj2) {
        float intensity2 = obj2.intensity;
        
        intensity2 += .05*ke/obj2.size;
        if(intensity2 > 2.2) {
            intensity2 = 2.2;
        }
        
        obj2.intensity = intensity2;
    }
}

void separate(cpArbiter *arb, cpSpace *space, void *data) {
    cpBody *body1;
    cpBody *body2;
    cpArbiterGetBodies(arb, &body1, &body2);
    
    BounceObject *obj1 = (BounceObject*)cpBodyGetUserData(body1);
    ChipmunkObject *cobj = (ChipmunkObject*)cpBodyGetUserData(body2);
    BounceObject *obj2 = nil;
    if([cobj isKindOfClass:[BounceObject class]]) {
        obj2 = (BounceObject*)cobj;
    }
    
    cpContactPointSet set = cpArbiterGetContactPointSet(arb);
    
    float size1 = obj1.size;
    float angle1 = obj1.angle;  
    vec2 pos1(obj1.position);
    vec2 vel1(obj1.velocity);
    float cos1 = cos(angle1);
    float sin1 = sin(angle1);
        
    vec2 tr1(size1, size1);
    vec2 tl1(-size1, size1);
    vec2 bl1(-size1, -size1);
    vec2 br1(size1, -size1);
            
    for(int i=0; i<set.count; i++){
        vec2 p1(set.points[i].point);
        p1 -= pos1;
            
        p1.rotate(cos1,sin1);
        vel1.rotate(cos1,sin1); 
        
        float trd1 = (p1-tr1).length();
        float tld1 = (p1-tl1).length();
        float bld1 = (p1-bl1).length();
        float brd1 = (p1-br1).length();
            
        if(trd1 <= tld1 && trd1 <= bld1 && trd1 <= brd1) {
            [obj1 addVelocity: vel1 toVert:0];
        } else if(tld1 <= bld1 && trd1 <= brd1) {
            [obj1 addVelocity: vel1 toVert:1];
        } else if(bld1 <= brd1) {
            [obj1 addVelocity: vel1 toVert:2];
        } else {
            [obj1 addVelocity: vel1 toVert:3];
        }
    }
    
    
    if(obj2) {
        float size2 = obj2.size;
        float angle2 = obj2.angle;  
        vec2 pos2(obj2.position);
        vec2 vel2(obj2.velocity);
        float cos2 = cos(angle2);
        float sin2 = sin(angle2);
        
        vec2 tr2(size2, size2);
        vec2 tl2(-size2, size2);
        vec2 bl2(-size2, -size2);
        vec2 br2(size2, -size2);
                
        for(int i=0; i<set.count; i++){
            vec2 p2(set.points[i].point);
            p2 -= pos2;
            
            p2.rotate(cos2,sin2);
            vel2.rotate(cos2,sin2); 
            
            float trd2 = (p2-tr2).length();
            float tld2 = (p2-tl2).length();
            float bld2 = (p2-bl2).length();
            float brd2 = (p2-br2).length();
            
            if(trd2 <= tld2 && trd2 <= bld2 && trd2 <= brd2) {
                [obj2 addVelocity: vel2 toVert:0];
            } else if(tld2 <= bld2 && trd2 <= brd2) {
                [obj2 addVelocity: vel2 toVert:1];
            } else if(bld2 <= brd2) {
                [obj2 addVelocity: vel2 toVert:2];
            } else {
                [obj2 addVelocity: vel2 toVert:3];
            }
        }
    }
}

@implementation BounceSimulation
-(id)initWithRect: (CGRect)rect audioDelegate:(id<FSAAudioDelegate>)delegate objectShader:(FSAShader*)objectShader stationaryShader:(FSAShader*)stationaryShader {
    _gestures = [[NSMutableDictionary alloc] initWithCapacity:10];
    _objects = [[NSMutableSet alloc] initWithCapacity:10];
    _delayedRemoveObjects = [[NSMutableSet alloc] initWithCapacity:10];
    _dt = .02;
    
    _space = cpSpaceNew();
    cpSpaceSetCollisionSlop(_space, .02);
        
    cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, OBJECT_TYPE, collisionBegin, preSolve, postSolve, separate, self);
    cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, WALL_TYPE, collisionBegin, preSolve, postSolve, separate, self);
    
    _audioDelegate = delegate;
    _objectShader = objectShader;
    _stationaryShader = stationaryShader;
    
    _arena = [[BounceArena alloc] initWithRect:rect];
    [_arena addToSpace:_space];
    
    _killArena = [[BounceKillArena alloc] initWithRect:rect];
    [_killArena addToSpace:_space];
    
    [self addObject:[BounceObject randomObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2()]];
    
    return self;
}
-(void)addObject: (BounceObject*)object {
    [object addToSpace:_space];
    
    [_objects addObject:object];
}
-(void)removeObject: (BounceObject*)object {
    [object removeFromSpace];
    [_objects removeObject:object];
}
-(void)postSolveRemoveObject: (BounceObject*)object {
    [_delayedRemoveObjects addObject:object];
}

-(BounceGesture*)gestureWithParticipatingObject:(BounceObject*)object {
    for(BounceGesture *gesture in [_gestures objectEnumerator]) {
        if([gesture object] == object) {
            return gesture;
        }
    }
    return nil;
}

-(BOOL)isObjectParticipatingInGesture: (BounceObject*)obj {
    for(BounceGesture *gesture in [_gestures objectEnumerator]) {
        if([gesture object] == obj) {
            return YES;
        }
    }

    return NO;
}
-(BOOL)isObjectBeingCreatedOrGrabbed: (BounceObject*)obj {
    for(BounceGesture *gesture in [_gestures objectEnumerator]) {
        if([gesture object] == obj && ([gesture isCreateGesture] || [gesture isGrabGesture])) {
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)isObjectBeingTransformed: (BounceObject*)obj {
    for(BounceGesture *gesture in [_gestures objectEnumerator]) {
        if([gesture object] == obj && [gesture isTransformGesture]) {
            return YES;
        }
    }
    
    return NO;
}

static void getAllBounceObjectsQueryFunc(cpShape *shape, cpContactPointSet *points, void* data) {
    NSMutableSet *objects = (NSMutableSet*)data;
    
    cpBody *body = cpShapeGetBody(shape);
    ChipmunkObject *obj = (ChipmunkObject*)cpBodyGetUserData(body);
    
    if([obj isKindOfClass:[BounceObject class]]) {
        [objects addObject:obj];
    }
}

-(NSSet*)objectsAt:(const vec2 &)loc withinRadius:(float)radius {
    NSMutableSet *objects = [NSMutableSet setWithCapacity:10];
    cpBody *body = cpBodyNew(1, 1);
    cpBodySetPos(body, (const cpVect&)loc);
    cpShape *shape = cpCircleShapeNew(body, radius, cpvzero);
    
    cpSpaceShapeQuery(_space, shape, getAllBounceObjectsQueryFunc, (void*)objects);
    
    cpShapeFree(shape);
    cpBodyFree(body);
    
    return objects;
}

-(BounceObject*)objectAt:(const vec2 &)loc {
    NSSet *objects = [self objectsAt:loc withinRadius:.2*[BounceConstants instance].unitsPerInch];
    float minDist = 9999;
    BounceObject *obj = nil;
    
    for(BounceObject *o in objects) {
        float dist = ([o position]-loc).length();
        if(dist < minDist) {
            minDist = dist;
            obj = o;
        }
    }
    
    return obj;
}

-(void)step: (float)t {
    t += _timeRemainder;
    
    if(t > 5*_dt) {
        t = 5*_dt;
    }
    
    while(t > _dt) {
        [self next];
        t -= _dt;
    }
    
    _timeRemainder = t;
    
    for(BounceObject *obj in _delayedRemoveObjects) {
        if(![self isObjectParticipatingInGesture:obj]) {
            [self removeObject:obj];
        }
    }
    
    [_delayedRemoveObjects removeAllObjects];
}
-(void)next {
    cpSpaceStep(_space, _dt);
    
    for(BounceObject *obj in _objects) {
        [obj step:_dt];
    }    
}

-(void)addToVelocity:(const vec2&)v {
    for(BounceObject *obj in _objects) {
        if(![obj isStationary]) {
            [obj setVelocity:[obj velocity]+v];
        }
    }
}

-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float)radius {
    NSSet *objects = [self objectsAt:loc withinRadius:radius];
    
    for(BounceObject *obj in objects) {
        [obj setVelocity:[obj velocity]+vel];
    }
    
}
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    [obj setVelocity:[obj velocity]+vel];
}

-(void)removeObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    if(obj.age > 1) {
        [self removeObject:obj];
    }
}
-(void)addObjectAt:(const vec2&)loc {
    [self addObject:[BounceObject randomObjectAt:loc]];
}
-(void)addObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel {
    [self addObject:[BounceObject randomObjectAt:loc withVelocity:vel]];
}
-(BOOL)isObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    return obj != nil;
}
-(BOOL)anyObjectsAt:(const vec2&)loc withinRadius:(float)radius {
    NSSet *objects = [self objectsAt:loc withinRadius:radius]; 
    return objects.count > 0;
}
-(void)setGravity:(const vec2&)g {
    cpSpaceSetGravity(_space, (cpVect&)g);
}

-(BOOL)isObjectParticipatingInGestureAt: (const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    if(obj == nil) {
        return NO;
    }
    return [self isObjectParticipatingInGesture:obj];
}
-(BOOL)isObjectBeingCreatedOrGrabbedAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    if(obj == nil) {
        return NO;
    }
    return [self isObjectBeingCreatedOrGrabbed:obj];
}
-(BOOL)isObjectBeingTransformedAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    if(obj == nil) {
        return NO;
    }
    return [self isObjectBeingTransformed:obj];
    
}
-(BOOL)isStationaryObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    if(obj == nil) {
        return NO;
    }
    return obj.isStationary;
}

-(void)addGesture:(BounceGesture*)gesture forKey:(void*)k {
    NSValue *key = [NSValue valueWithPointer:k];
    [_gestures setObject:gesture forKey:key];
}
-(BounceGesture*)gestureForKey:(void*)k {
    NSValue *key = [NSValue valueWithPointer:k];
    return [_gestures objectForKey:key];
}
-(void)removeGestureForKey:(void*)k {
    NSValue *key = [NSValue valueWithPointer:k];

    [_gestures removeObjectForKey:key];
}

-(void)singleTapAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    if(obj == nil) {
        [self addObjectAt:loc];
    } else {
        if(obj.age > 1 && ![self isObjectParticipatingInGesture:obj]) {
            [self removeObject:obj];
        }
    }
}
-(void)flickAt:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    BounceObject *obj = [self objectAt:loc];
    NSSet *objects = [self objectsAt:loc withinRadius:.3];
    vec2 vel = dir*(1./time);
    if(obj != nil && obj.isStationary) {
        obj.isStationary = NO;
        [obj setVelocity:[obj velocity]+vel];
        [obj makeSimulated];
    } else if([objects count] > 0) {
        for(BounceObject *obj in objects) {
            if(!obj.isStationary) {
                [obj setVelocity:[obj velocity]+vel];
            }
        }
    } else {
        [self addObjectAt:loc withVelocity:vel];
    }
}

-(void)longTouch:(void*)uniqueId at:(const vec2&)loc {    
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    if([gesture isCreateGesture]) {
        [gesture object].isStationary = YES;
        [gesture beginGrabAt:loc];
        if(![[gesture object] hasBeenAddedToSpace]) {
            [self addObject:[gesture object]];
        }
    } else if([gesture isGrabGesture]) {
        [gesture object].isStationary = YES;
    }
}
-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    if(obj == nil) {
        obj = [BounceObject randomObjectAt:loc];
        [obj makeRogue];
        
        [self addGesture:[BounceGesture createGestureForObject:obj] forKey:uniqueId];
    } else {
        if([self isObjectBeingCreatedOrGrabbed:obj]) {
            BounceGesture *gesture2 = [self gestureWithParticipatingObject:obj];
            
            [self addGesture:[BounceGesture transformGestureForObject:obj at:loc withOtherGesture:gesture2]forKey:uniqueId];
        } else {
            [obj makeRogue];
            [self addGesture:[BounceGesture grabGestureForObject:obj at:loc] forKey:uniqueId];
        }
    }
}
-(void)drag:(void*)uniqueId at:(const vec2&)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];

    [gesture updateGestureLocation:loc];
    
    if(![[gesture object] hasBeenAddedToSpace]) {
        [self addObject:[gesture object]];
    }
}
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    BounceObject *obj = [gesture object];
    if(obj.isStationary) {
        [obj makeStatic];
    } else {
        [obj makeSimulated];
    }
    
    [gesture endGesture];
    
    [self removeGestureForKey:uniqueId];
    
}
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    BounceObject *obj = [gesture object];
    if(obj.isStationary) {
        [obj makeStatic];
    } else {
        [obj makeSimulated];
    }
    
    [gesture endGesture];

    
    [self removeGestureForKey:uniqueId];
}

-(void)beginTopSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}
-(void)topSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}
-(void)endTopSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}

-(void)beginBottomSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}
-(void)bottomSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}
-(void)endBottomSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}

-(void)beginLeftSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}
-(void)leftSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}
-(void)endLeftSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}

-(void)beginRightSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}
-(void)rightSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}
-(void)endRightSwipe:(void*)uniqueId at:(const vec2&)loc {
    
}

-(void)beginRemovingBallsTop:(float)y {
    
}
-(void)updateRemovingBallsTop:(float)y {
    
}
-(void)endRemovingBallsTop {
    
}

-(void)beginRemovingBallsBottom:(float)y {
    
}
-(void)updateRemovingBallsBottom:(float)y {
    
}
-(void)endRemovingBallsBottom {
    
}

-(void)beginRemovingBallsLeft:(float)x {
    
}
-(void)updateRemovingBallsLeft:(float)x {
    
}
-(void)endRemovingBallsLeft {
    
}

-(void)beginRemovingBallsRight:(float)x {
    
}
-(void)updateRemovingBallsRight:(float)x {
    
}
-(void)endRemovingBallsRight {
    
}

-(BOOL)isRemovingBalls {
    return NO;
}
-(BOOL)isRemovingBallsTop {
    return NO;
}
-(BOOL)isRemovingBallsBottom {
    return NO;
}
-(BOOL)isRemovingBallsLeft {
    return NO;
}
-(BOOL)isRemovingBallsRight {
    return NO;
}

-(float)removingBallsTopY {
    return 0;
}
-(float)removingBallsBottomY {
    return 0;
}
-(float)removingBallsLeftX {
    return 0;
}
-(float)removingBallsRightX {
    return 0;
}

-(void)dealloc {
    // TODO

    [super dealloc];
}

-(void)draw {
    for(BounceObject *obj in _objects) {
        [obj drawWithObjectShader:_objectShader andStationaryShader:_stationaryShader];
    }
}


@end

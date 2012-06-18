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


@implementation BounceSimulation
-(id)initWithRect: (CGRect)rect audioDelegate:(id<FSAAudioDelegate>*)delegate {
    _gestures = [[NSMutableDictionary alloc] initWithCapacity:10];
    _objects = [[NSMutableSet alloc] initWithCapacity:10];
    _delayedRemoveObjects = [[NSMutableSet alloc] initWithCapacity:10];
    _dt = .02;
    
    _space = cpSpaceNew();
    cpSpaceSetCollisionSlop(_space, .02);
        
//    cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, OBJECT_TYPE, collisionBegin, preSolve, postSolve, separate, this);
//    cpSpaceAddCollisionHandler(space, OBJECT_TYPE, WALL_TYPE, collisionBegin, preSolve, postSolve, separate, this);
    
    _audioDelegate = delegate;
    
    _arena = [[BounceArena alloc] initWithRect:rect];
    [_arena addToSpace:_space];
    
    _killArena = [[BounceKillArena alloc] initWithRect:rect];
    [_killArena addToSpace:_space];
    
    [self addObject:[BounceBall bounceRandomObjectAt:vec2()]];
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

-(void)isObjectParticipatingInGesture: (BounceObject*)obj {
    NSAssert(NO, "not implemented, isObjectParticipatingInGesture\n");
}
-(void)isObjectBeingCreatedOrGrabbed: (BounceObject*)obj {
    NSAssert(NO, "not implemented, isObjectBeingCreatedOrGrabbed\n");
}
-(void)isObjectBeingTransformed: (BounceObject*)obj {
    NSAssert(NO, "not implemented, isObjectBeingTransformed\n");

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
    NSMutableSet *objects;
    
    cpBody *body = cpBodyNew(1, 1);
    cpBodySetPos(body, (const cpVect&)loc);
    cpShape *shape = cpCircleShapeNew(body, radius, cpvzero);
    
    cpSpaceShapeQuery(_space, shape, getAllBounceObjectsQueryFunc, (void*)objects);
    
    cpShapeFree(shape);
    cpBodyFree(body);
    
    return objects;
}

-(BounceObject*)objectAt:(const vec2 &)loc {
    NSSet *objects = [self objectsAt:loc withinRadius:.3*[BounceConstants instance].unitsPerInch];
    float minDist = 9999;
    BounceObject *obj = nil;
    
    for(BounceObject *o in objects) {
        float dist = (o.position-loc).length();
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
        obj.intensity *= .9;
        obj.age += _dt;
        vec2 *vertOffsets = obj.vertOffsets;
        vec2 *vertVels = obj.vertVels;
        
        vertOffsets[0] += vertVels[0]*_dt;
        vertOffsets[1] += vertVels[1]*_dt;
        vertOffsets[2] += vertVels[2]*_dt;
        vertOffsets[3] += vertVels[3]*_dt;
        
        float spring_k = 200;
        vec2 tra = -spring_k*vertOffsets[0];
        vec2 tla = -spring_k*vertOffsets[1];
        vec2 bla = -spring_k*vertOffsets[2];
        vec2 bra = -spring_k*vertOffsets[3];
        
        float drag = .2;
        vertVels[0] += tla*_dt-drag*vertVels[0];
        vertVels[1] += tra*_dt-drag*vertVels[1];
        vertVels[2] += bla*_dt-drag*vertVels[2];
        vertVels[3] += bra*_dt-drag*vertVels[3];
        
        float c = .75*obj.size;
        
        vertOffsets[0].clamp(-c, c);
        vertOffsets[1].clamp(-c, c);
        vertOffsets[2].clamp(-c, c);
        vertOffsets[3].clamp(-c, c);
    }    
}

-(void)addToVelocity:(const vec2&)v {
    for(BounceObject *obj in _objects) {
        if(![obj isStationary]) {
            obj.velocity += v;
        }
    }
}

-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float)radius {
    NSSet *objects = [self objectsAt:loc withinRadius:radius];
    
    for(BounceObject *obj in objects) {
        obj.velocity += vel;
    }
    
}
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    obj.velocity += vel;
}

-(void)removeObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    [self removeObject:obj];
}
-(void)addObjectAt:(const vec2&)loc {
    int type = int(3*random(loc*83.2902));
    switch(type) {
        case 0:   
            [self addObject:[BounceBall bounceRandomObjectAt:loc]];
            break;
        case 1:
            [self addObject:[BounceTriangle bounceRandomObjectAt:loc]];
            break;
        case 2:
            [self addObject:[BounceSquare bounceRandomObjectAt:loc]];
            break;
        default:
            break;
    }
}
-(void)addObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel {
    int type = int(3*random(loc*83.2902));

    switch(type) {
        case 0:   
            [self addObject:[BounceBall bounceRandomObjectAt:loc withVelocity:vel]];
            break;
        case 1:
            [self addObject:[BounceTriangle bounceRandomObjectAt:loc withVelocity:vel]];
            break;
        case 2:
            [self addObject:[BounceSquare bounceRandomObjectAt:loc withVelocity:vel]];
            break;
        default:
            break;
    }
}
-(BOOL)isObjectAt:(const vec2&)loc {
    return [self objectAt:loc] != nil;
}
-(BOOL)anyObjectsAt:(const vec2&)loc withinRadius:(float)radius {
    return [self objectsAt:loc withinRadius:radius].count > 0;
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
-(BOOL)isStationaryBallAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    if(obj == nil) {
        return NO;
    }
    return obj.isStationary;
}

-(void)makeObjectStationaryAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}

-(BOOL)isCreatingObjectForGesture:(void*)uniqueId {
    
}
-(void)creatingObjectFrom:(const vec2&)from to:(const vec2&)to forGesture:(void*)uniqueId {
    
}
-(void)createObjectForGesture:(void*)uniqueId {
    
}
-(void)cancelCreatingObjectForGesture:(void*)uniqueId {
    
}

-(void)beginGrabbingCreatedObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)createStationaryObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}

-(BOOL)isGrabbingObjectForGesture:(void*)uniqueId {
    
}
-(void)beginGrabbingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)grabbingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)releaseObjectForGesture:(void*)uniqueId {
    
}

-(BOOL)isTransformingObject:(void*)uniqueId {
    
}
-(void)beginTransformingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)transformObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)makeTransformingObjectStationaryAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)beginGrabbingTransformingObjectForGesture:(void*)uniqueId {
    
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
    
}
-(BOOL)isRemovingBallsTop {
    
}
-(BOOL)isRemovingBallsBottom {
    
}
-(BOOL)isRemovingBallsLeft {
    
}
-(BOOL)isRemovingBallsRight {
    
}

-(float)removingBallsTopY {
    
}
-(float)removingBallsBottomY {
    
}
-(float)removingBallsLeftX {
    
}
-(float)removingBallsRightX {
    
}


@end

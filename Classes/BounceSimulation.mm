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
    
    float size = obj1.size;
    float volume = .1*(size*ke > 1 ? 1 : size*ke);
    [obj1.sound play:volume];
    
    if(obj2) {
        float intensity2 = obj2.intensity;
        
        intensity2 += .05*ke/obj2.size;
        if(intensity2 > 2.2) {
            intensity2 = 2.2;
        }
        
        obj2.intensity = intensity2;
        size = obj2.size;
        volume = .1*(size*ke > 1 ? 1 : size*ke);
        [obj2.sound play:volume];
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
    
    [obj1 separate:&set];
    
    if(obj2) {
        [obj2 separate:&set];
    }
}

@implementation BounceSimulation

@synthesize arena = _arena;

-(id)initWithRect: (CGRect)rect {
    _gestures = [[NSMutableDictionary alloc] initWithCapacity:10];
    _objects = [[NSMutableSet alloc] initWithCapacity:10];
    _delayedRemoveObjects = [[NSMutableSet alloc] initWithCapacity:10];
    _dt = .02;
    
    _space = cpSpaceNew();
    cpSpaceSetCollisionSlop(_space, .02);
        
    cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, OBJECT_TYPE, collisionBegin, preSolve, postSolve, separate, self);
    cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, WALL_TYPE, collisionBegin, preSolve, postSolve, separate, self);
        
    _arena = [[BounceArena alloc] initWithRect:rect];
    [_arena addToSpace:_space];
    
    
    return self;
}

-(void)setColor:(const vec4 &)color {
    for(BounceObject *obj in _objects) {
        [obj setColor:color];
    }
}
-(void)addObject: (BounceObject*)object {
    [object addToSpace:_space];
    [object.sound play:.2];
    
    [_objects addObject:object];
}
-(void)removeObject: (BounceObject*)object {
    if(![self isObjectParticipatingInGesture:object]) {
        [object.sound play:.2];
        [object removeFromSpace];
        [_objects removeObject:object];
    }
}
-(void)postSolveRemoveObject: (BounceObject*)object {
    [_delayedRemoveObjects addObject:object];
}

-(void)addToSpace:(ChipmunkObject*)obj {
    [obj addToSpace:_space];
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
        [self removeObject:obj];
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
        if(![obj isStationary] && ![self isObjectParticipatingInGesture:obj]) {
            [obj setVelocity:[obj velocity]+v];
        }
    }
}

-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float)radius {
    NSSet *objects = [self objectsAt:loc withinRadius:radius];
    
    for(BounceObject *obj in objects) {
        if(!obj.isStationary && ![self isObjectParticipatingInGesture:obj]) {
            [obj setVelocity:[obj velocity]+vel];
        }
    }
    
}
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    if(!obj.isStationary && ![self isObjectParticipatingInGesture:obj]) {
        [obj setVelocity:[obj velocity]+vel];
    }
}

-(void)removeObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    
    if(obj.age > 1) {
        [self removeObject:obj];
    }
}
-(BounceObject*)addObjectAt:(const vec2&)loc {
    BounceObject *obj = [BounceObject randomObjectAt:loc];
    [self addObject:obj];
    
    return obj;
}
-(BounceObject*)addObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel {
    BounceObject *obj = [BounceObject randomObjectAt:loc withVelocity:vel];
    [self addObject:obj];
    
    return obj;
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
-(BOOL)isInBoundsAt:(const vec2 &)loc {
    return [_arena isInBoundsAt:loc];
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

-(void)tapObject:(BounceObject*)obj {
    if(obj.age > 1) {
        [self removeObject:obj];
    }
}
-(void)tapSpaceAt:(const vec2&)loc {
    [self addObjectAt:loc];
}

-(void)flickStationaryObject:(BounceObject*)obj withVelocity:(const vec2&)vel {
    obj.isStationary = NO;
    [obj setVelocity:[obj velocity]+vel];
    [obj makeSimulated];
}
-(void)flickObjectsAt:(const vec2&)loc withVelocity:(const vec2&)vel {
    [self addVelocity:vel toObjectsAt:loc withinRadius:.3];

}
-(void)flickSpaceAt:(const vec2&)loc withVelocity:(const vec2&)vel {
    [self addObjectAt:loc withVelocity:vel];
}

-(void)singleTapAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    if(obj == nil) {
        [self tapSpaceAt:loc];
    } else {
        [self tapObject:obj];
    }
}
-(void)flickAt:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    BounceObject *obj = [self objectAt:loc];
    vec2 vel = dir*(1./time);
    if(obj != nil && obj.isStationary && ![self isObjectParticipatingInGesture:obj]) {
        [self flickStationaryObject:obj withVelocity:vel];
    } else if([self anyObjectsAt:loc withinRadius:.1]) {
        [self flickObjectsAt:loc withVelocity:vel];
    } else {
        [self flickSpaceAt:loc withVelocity:vel];
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
-(void)beginCreate:(void*)uniqueId at:(const vec2&)loc {
    BounceObject *obj = [BounceObject randomObjectAt:loc];        
    [self addGesture:[BounceGesture createGestureForObject:obj] forKey:uniqueId];
}
-(void)beginDrag:(void*)uniqueId object:(BounceObject*)obj at:(const vec2&)loc {
    [self addGesture:[BounceGesture grabGestureForObject:obj at:loc] forKey:uniqueId];
}
-(void)beginTransform:(void*)uniqueId object:(BounceObject*)obj at:(const vec2&)loc {
    BounceGesture *gesture2 = [self gestureWithParticipatingObject:obj];
    
    [self addGesture:[BounceGesture transformGestureForObject:obj at:loc withOtherGesture:gesture2]forKey:uniqueId];
}
-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    if(obj == nil) {
        [self beginCreate:uniqueId at:loc];
    } else {
        NSSet *objects = [self objectsAt:loc withinRadius:.2*[BounceConstants instance].unitsPerInch];
        BounceObject *objectBeingCreatedOrGrabbed = nil;
        for(BounceObject *object in objects) {
            if([self isObjectBeingCreatedOrGrabbed:object]) {
                objectBeingCreatedOrGrabbed = object;
                break;
            }
        }
        
        if([self isObjectBeingCreatedOrGrabbed:obj]) {
            // if the closest object to the touch is being created or dragged
            // then begin transforming it
            [self beginTransform:uniqueId object:obj at:loc];
        } else if(objectBeingCreatedOrGrabbed) {
            // if the closest object to the touch isn't being created or dragged
            // but there is one close to the touch that is being created or dragged then
            // begin transforming that one
            
            // this makes it much easier to resize tiny balls, or to get a better
            // hold on large balls that have smalls ones near it
            [self beginTransform:uniqueId object:objectBeingCreatedOrGrabbed at:loc];
        } else if(![self isObjectParticipatingInGesture:obj]) {
            [self beginDrag:uniqueId object:obj at:loc];
        }
    }
}
-(void)drag:(void*)uniqueId at:(const vec2&)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];

    if(gesture) {
        [gesture updateGestureLocation:loc];
        
        if(![[gesture object] hasBeenAddedToSpace]) {
            [self addObject:[gesture object]];
        }
    }
}
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    if(gesture) {
        [gesture endGesture];
    
        [self removeGestureForKey:uniqueId];
    }
    
}
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    if(gesture) {
        [gesture endGesture];
    
        [self removeGestureForKey:uniqueId];
    }
}

-(void)dealloc {
    for(BounceObject *obj in _objects) {
        [obj removeFromSpace];
    }
    [_objects release]; _objects = nil;
    [_delayedRemoveObjects release]; _delayedRemoveObjects = nil;
    [_arena removeFromSpace];
    [_arena release]; _arena = nil;

    
    [_gestures release]; _gestures = nil;
    
    cpSpaceFree(_space);

    [super dealloc];
}

-(void)draw {
    for(BounceObject *obj in _objects) {
        [obj draw];
    }
}


@end

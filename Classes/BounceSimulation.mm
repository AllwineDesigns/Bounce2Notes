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
#import "BounceShapeGenerator.h"
#import "BouncePatternGenerator.h"
#import "BounceSettings.h"

#import "BounceSlider.h"

int collisionBegin(cpArbiter *arb, cpSpace *space, void *data) {
    return 1;
}
int preSolve(cpArbiter *arb, cpSpace *space, void *data) {   
    cpBody *body1;
    cpBody *body2;
    cpArbiterGetBodies(arb, &body1, &body2);
    
    
    /*
    vec2 pos1(body1->p);
    vec2 pos2(body2->p);
    
    vec2 colN(cpArbiterGetNormal(arb, 0));
        
    cpContactPointSet set = cpArbiterGetContactPointSet(arb);
    for(int i=0; i < set.count; i++){
        vec2 p(set.points[i].point);
        vec2 n = p-pos2;

        if(n1.dot(n2) > 0) {
            cpArbiterIgnore(arb);
            return 0;
        }
    }
     */
    
        
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
        [obj1 collideWith:obj2];
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
    [obj1 playSound:volume];

    obj1.contactPoints = cpArbiterGetContactPointSet(arb);
    
    if(obj2) {
        float intensity2 = obj2.intensity;
        
        intensity2 += .05*ke/obj2.size;
        if(intensity2 > 2.2) {
            intensity2 = 2.2;
        }
        
        obj2.intensity = intensity2;
        float size = obj2.size;
        float volume = .1*(size*ke > 1 ? 1 : size*ke);
        [obj2 playSound:volume];
        
        obj2.contactPoints = obj1.contactPoints;
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
    
    
    [obj1 separate];
    
    if(obj2) {
        [obj2 separate];
    }
}

@implementation BounceSimulation

@synthesize objects = _objects;
@synthesize space = _space;
@synthesize arena = _arena;

-(id)initWithCoder:(NSCoder *)aDecoder {
    BounceArena *arena = [aDecoder decodeObjectForKey:@"BounceSimulationArena"];   
    self = [self initWithRect:arena.rect];

    _gravity.x = [aDecoder decodeFloatForKey:@"BounceSimulationGravityX"];
    _gravity.y = [aDecoder decodeFloatForKey:@"BounceSimulationGravityY"];
            
    NSArray *objects = [aDecoder decodeObjectForKey:@"BounceSimulationObjects"];
    for(BounceObject *obj in objects) {
        obj.simulation = self;
        [obj addToSpace:self.space];
        [_objects addObject:obj];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[_objects count]];
    for(BounceObject *obj in _objects) {
        if(obj.simulationWillArchive) {
            [objects addObject:obj];
        }
    }
    [aCoder encodeObject:objects forKey:@"BounceSimulationObjects"];
    [objects release];
    
    [aCoder encodeObject:_arena forKey:@"BounceSimulationArena"];
    [aCoder encodeFloat:_gravity.x forKey:@"BounceSimulationGravityX"];
    [aCoder encodeFloat:_gravity.y forKey:@"BounceSimulationGravityY"];
}

-(id)initWithRect: (CGRect)rect {
    _gestures = [[NSMutableDictionary alloc] initWithCapacity:10];
//    _objects = [[NSMutableSet alloc] initWithCapacity:10];
    _objects = [[NSMutableArray alloc] initWithCapacity:10];
    _delayedRemoveObjects = [[NSMutableSet alloc] initWithCapacity:10];
    _delayedAddObjects = [[NSMutableSet alloc] initWithCapacity:10];

    
    _space = cpSpaceNew();
    cpSpaceSetCollisionSlop(_space, .02);
            
    cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, OBJECT_TYPE, collisionBegin, preSolve, postSolve, separate, self);
    cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, WALL_TYPE, collisionBegin, preSolve, postSolve, separate, self);
        
    _arena = [[BounceArena alloc] initWithRect:rect];
    [_arena addToSpace:_space];
    
    
    return self;
}


-(void)setPosition:(const vec2&)pos {
    self.arena.position = pos;
}
-(void)setVelocity:(const vec2&)vel {
    self.arena.velocity = vel;
}
-(void)setAngle:(float)angle {
    self.arena.angle = angle;
}
-(void)setAngVel:(float)angVel {
    self.arena.angVel = angVel;
}



-(void)setColor:(const vec4 &)color {
    for(BounceObject *obj in _objects) {
        [obj setColor:color];
    }
}
-(void)setPatternTexturesWithGenerator:(BouncePatternGenerator *)gen {
    for(BounceObject *obj in _objects) {
        vec2 loc = obj.position;
        [obj setPatternTexture:[gen randomPatternTextureWithLocation:loc]];
    }
}
-(void)setBounceShapesWithGenerator:(BounceShapeGenerator *)gen {
    for(BounceObject *obj in _objects) {
        vec2 loc = obj.position;
        [obj setBounceShape:[gen randomBounceShapeWithLocation:loc]];
    }
}
-(void)setBounceShape:(BounceShape)bounceshape {
    for(BounceObject *obj in _objects) {
        [obj setBounceShape:bounceshape];
    }
}
-(void)setPatternTexture:(FSATexture *)patternTexture {
    for(BounceObject *obj in _objects) {
        [obj setPatternTexture:patternTexture];
    }
}
-(void)randomizePattern {
    for(BounceObject *obj in _objects) {
        if(obj.isPreviewable) {
            [obj randomizePattern];
        }
    }
}
-(void)randomizeColor {
    for(BounceObject *obj in _objects) {
        [obj randomizeColor];
    }
}
-(void)randomizeShape {
    for(BounceObject *obj in _objects) {
        if(obj.isPreviewable) {
            [obj randomizeShape];
        }
    }
}
-(void)randomizeNote {
    for(BounceObject *obj in _objects) {
        if(obj.isPreviewable) {
            [obj randomizeNote];
        }
    }
}

-(void)randomizeSize {
    for(BounceObject *obj in _objects) {
        if(obj.isPreviewable) {
            [obj randomizeSize];
        }
    }
}

-(void)addObject: (BounceObject*)object {
    int order = 1;
    for(BounceObject *obj in _objects) {
        if(obj.isPreviewable && obj.order >= order) {
            order = obj.order+1;
        }
    }
    object.order = order;

    [_objects addObject:object];

}
-(void)removeObject: (BounceObject*)object {
    [_objects removeObject:object];
}

-(BOOL)containsObject: (BounceObject*)object {
    return [_objects containsObject:object];
}
-(void)postSolveRemoveObject: (BounceObject*)object {
    [_delayedRemoveObjects addObject:object];
}
-(void)postSolveAddObject: (BounceObject*)object {
    [_delayedAddObjects addObject:object];
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

/*
static void getAllBounceObjectsQueryFunc(cpShape *shape, cpContactPointSet *points, void* data) {
    BounceQueryStruct *queryStruct = (BounceQueryStruct*)data;
    
    cpBody *body = cpShapeGetBody(shape);
    ChipmunkObject *obj = (ChipmunkObject*)cpBodyGetUserData(body);
    
    if([obj isKindOfClass:[BounceObject class]]) {
        [queryStruct->set addObject:obj];
    }
}
 */

static void getAllBounceObjectsNearestQueryFunc(cpShape *shape, cpFloat dist, cpVect p, void* data) {
    BounceQueryStruct *queryStruct = (BounceQueryStruct*)data;
    
    cpBody *body = cpShapeGetBody(shape);
    ChipmunkObject *obj = (ChipmunkObject*)cpBodyGetUserData(body);
    
    if([obj isKindOfClass:[BounceObject class]]) {
        [queryStruct->set addObject:obj];
    }
}

static void getNearestBounceObjectNearestQueryFunc(cpShape *shape, cpFloat dist, cpVect p, void* data) {
    BounceQueryStruct *queryStruct = (BounceQueryStruct*)data;
    
    cpBody *body = cpShapeGetBody(shape);
    ChipmunkObject *obj = (ChipmunkObject*)cpBodyGetUserData(body);
    
    if([obj isKindOfClass:[BounceObject class]]) {
        if((dist < queryStruct->minDist && queryStruct->minDist > 0) || ([(BounceObject*)obj order] > [queryStruct->nearest order] && dist < 0)) {
            queryStruct->nearest = (BounceObject*)obj;
            queryStruct->minDist = dist;
        }
    }
}
-(NSSet*)objectsAt:(const vec2 &)loc withinRadius:(float)radius {
    BounceQueryStruct queryStruct;
    NSMutableSet *objects = [NSMutableSet setWithCapacity:10];
    
    queryStruct.set = objects;
    queryStruct.simulation = self;
    
    cpSpaceNearestPointQuery(_space, (cpVect&)loc, (cpFloat)radius, CP_ALL_LAYERS, CP_NO_GROUP, getAllBounceObjectsNearestQueryFunc, (void*)&queryStruct);
    
    return objects;
}
-(BounceObject*)objectAt:(const vec2 &)loc {
    BounceQueryStruct queryStruct;
    
    NSMutableSet *objects = [NSMutableSet setWithCapacity:10];

    queryStruct.set = objects;
    queryStruct.nearest = nil;
    queryStruct.minDist = 10000;
    queryStruct.simulation = self;
    
    cpSpaceNearestPointQuery(_space, (cpVect&)loc, .2*[BounceConstants instance].unitsPerInch, CP_ALL_LAYERS, CP_NO_GROUP, getNearestBounceObjectNearestQueryFunc, (void*)&queryStruct);
    
    return queryStruct.nearest;
}
/*
-(NSSet*)objectsAt:(const vec2 &)loc withinRadius:(float)radius {
    BounceQueryStruct queryStruct;
    
    NSMutableSet *objects = [NSMutableSet setWithCapacity:10];
    
    queryStruct.set = objects;
    queryStruct.simulation = self;
    
    cpBody *body = cpBodyNew(1, 1);
    cpBodySetPos(body, (const cpVect&)loc);
    cpShape *shape = cpCircleShapeNew(body, radius, cpvzero);
    
    cpSpaceShapeQuery(_space, shape, getAllBounceObjectsQueryFunc, (void*)&queryStruct);
    
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
 */

-(void)step: (float)dt {
    cpSpaceStep(_space, dt);
    
    for(BounceObject *obj in _objects) {
        [obj step:dt];
    }
    
    for(BounceObject *obj in _delayedRemoveObjects) {
        [obj removeFromSimulation];
    }
    
    for(BounceObject *obj in _delayedAddObjects) {
        [obj addToSimulation:self];
    }
    
    [_delayedRemoveObjects removeAllObjects];
    [_delayedAddObjects removeAllObjects];
}

-(void)addToVelocity:(const vec2&)v {
    for(BounceObject *obj in _objects) {
        if(![obj isStationary] && ![self isObjectParticipatingInGesture:obj]) {
            [obj setVelocity:[obj velocity]+v];
        }
    }
}

-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float)radius {

    
}
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    if(!obj.isStationary && ![self isObjectParticipatingInGesture:obj]) {
        [obj setVelocity:[obj velocity]+vel];
    }
}

-(BounceObject*)addObjectAt:(const vec2&)loc {
    BounceObject *obj = [BounceObject randomObjectAt:loc];
    [obj addToSimulation:self];    
    [obj playSound:.2];
    return obj;
}
-(BounceObject*)addObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel {
    BounceObject *obj = [BounceObject randomObjectAt:loc withVelocity:vel];
    [obj addToSimulation:self];    
    [obj playSound:.2];
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

-(void)setGravityScale:(float)s {
   // _gravityScale = s;
   // vec2 gravity = _gravityScale*_gravity;
   // cpSpaceSetGravity(_space, (cpVect&)gravity);
    
    for(BounceObject *obj in _objects) {
        [obj setGravityScale:s];
    }
}
-(vec2)gravity {
    return _gravity;
}
-(void)setGravity:(const vec2&)g {
    _gravity = g;
  //  vec2 gravity = _gravityScale*_gravity;
   // cpSpaceSetGravity(_space, (cpVect&)gravity);
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
-(BOOL)isInBounds:(BounceObject *)obj {
    return [_arena isInBounds:obj];
}
-(BOOL)isInBoundsAt:(const vec2 &)loc {
    return [_arena isInBoundsAt:loc];
}

-(BOOL)isInBoundsAt:(const vec2 &)loc withPadding:(float)pad {
    return [_arena isInBoundsAt:loc withPadding:pad];
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

-(void)tapObject:(BounceObject*)obj at:(const vec2&)loc {
    [obj singleTapAt:loc];
}
-(void)tapSpaceAt:(const vec2&)loc {
}

-(void)flickStationaryObject:(BounceObject*)obj withVelocity:(const vec2&)vel {
    obj.isStationary = NO;
    [obj setVelocity:[obj velocity]+vel];
    [obj makeSimulated];
   // NSLog(@"flicked stationary object\n");
}

-(void)flickSpaceAt:(const vec2&)loc withVelocity:(const vec2&)vel {
}

-(void)singleTap: (void*)uniqueId at:(const vec2&)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    if(gesture != nil && [gesture isCreateGesture]) {
        BounceObject *obj = [gesture object];

        if(![obj hasBeenAddedToSimulation]) {
            [obj addToSimulation:self];
            [obj playSound:.2];
        }
        [obj randomizeSize];
    } else {
        BounceObject *obj = [self objectAt:loc];
        if(obj == nil) {
            [self tapSpaceAt:loc];
        } else {
            [self tapObject:obj at:loc];
        }
    }
}

-(void)flickObject:(BounceObject*)obj at:(const vec2&)loc withVelocity:(const vec2&)vel {
    [obj flickAt:loc withVelocity:vel];
}

-(void)flick: (void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    vec2 vel = dir*(1./time);
    
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    if(gesture != nil) {
        BounceObject *obj = [gesture object];

        if([gesture isCreateGesture]) {
            if(![obj hasBeenAddedToSimulation]) {
                [obj addToSimulation:self];
                [obj playSound:.2];
            }
            [obj randomizeSize];
            [obj setVelocity:vel];
        } else if([gesture isGrabGesture]) {
            [self flickObject:obj at:loc withVelocity:vel];
        }
    } else {
        BounceObject *obj = [self objectAt:loc];

        if(obj) {
            [self flickObject:obj at:loc withVelocity:vel];
        } else {
            [self flickSpaceAt:loc withVelocity:vel];
        }
    }
}

-(void)longTouch:(void*)uniqueId at:(const vec2&)loc {    
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    if(gesture == nil) {
        NSLog(@"no gesture for long touch\n");
    }
        
    if([gesture isCreateGesture]) {
        BounceObject *obj = [gesture object];
        obj.isStationary = YES;
        
        if(![obj hasBeenAddedToSimulation]) {
            [obj randomizeSize];
            [obj addToSimulation:self];
            [obj playSound:.2];
        }
        
        [gesture beginGrabAt:loc];
    } else if([gesture isGrabGesture]) {
        BounceObject *obj = [gesture object];
        if(obj.isPreviewable) {
            obj.isStationary = YES;
        }
        [self longTouchObject:obj at:loc];
    }
}

-(void)longTouchObject:(BounceObject *)obj at:(const vec2 &)loc {
    
}

-(void)beginCreate:(void*)uniqueId at:(const vec2&)loc {
    BounceObject *obj = [BounceObject randomObjectAt:loc];
    obj.size = .01;

  //  [obj addToSimulation:self];
    [self addGesture:[BounceGesture createGestureForObject:obj] forKey:uniqueId];
}
-(void)beginGrab:(void*)uniqueId object:(BounceObject*)obj at:(const vec2&)loc {
    [self addGesture:[BounceGesture grabGestureForObject:obj at:loc] forKey:uniqueId];
}
-(void)beginTransform:(void*)uniqueId object:(BounceObject*)obj at:(const vec2&)loc {
    BounceGesture *gesture2 = [self gestureWithParticipatingObject:obj];
    
    [self addGesture:[BounceGesture transformGestureForObject:obj at:loc withOtherGesture:gesture2]forKey:uniqueId];
}
-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceObject *anyObject = [self objectAt:loc];
    
    BounceObject *obj = [self objectAt:loc];
    NSSet *objects = [self objectsAt:loc withinRadius:.4*[BounceConstants instance].unitsPerInch];
    BounceObject *objectBeingCreatedOrGrabbed = nil;
    for(BounceObject *object in objects) {
        if([self isObjectBeingCreatedOrGrabbed:object]) {
            objectBeingCreatedOrGrabbed = object;
            break;
        }
    }
    
    if(obj == nil && anyObject == nil && !objectBeingCreatedOrGrabbed) {
        [self beginCreate:uniqueId at:loc];
    } else {
        
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
            [self beginGrab:uniqueId object:obj at:loc];
        }
    }
}
-(void)drag:(void*)uniqueId at:(const vec2&)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];

    if(gesture) {
        [gesture updateGestureLocation:loc];
        
        NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime]-gesture.creationTimestamp;
        if(time > .2 && ![[gesture object] hasBeenAddedToSimulation]) {
            [[gesture object] addToSimulation:self];
            [[gesture object] playSound:.2];
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
        [gesture cancelGesture];
    
        [self removeGestureForKey:uniqueId];
    }
}

-(BOOL)respondsToGesture:(void *)uniqueId {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    return gesture != nil;
}

-(void)setDamping:(float)damping {
    for(BounceObject *obj in _objects) {
        [obj setDamping:damping];
    }
                                   
 //   cpSpaceSetDamping(_space, damping);
}

-(void)setFriction:(float)f {
   // [_arena setFriction:f];
    for(BounceObject *obj in _objects) {
        [obj setFriction:f];
    }
}

-(void)setBounciness:(float)b {
  //  [_arena setBounciness:b];
    for(BounceObject *obj in _objects) {
        [obj setBounciness:b];
    }
}

-(void)setVelocityLimit:(float)limit {
    for(BounceObject *obj in _objects) {
        [obj setVelocityLimit:limit];
    }
}

-(void)setSound:(id<BounceSound>)sound {
    for(BounceObject *obj in _objects) {
        if(obj.isPreviewable) {
            obj.sound = sound;
        }
    }
}

-(void)dealloc {
    for(BounceObject *obj in _objects) {
        [obj removeFromSpace];
    }
    [_objects release]; _objects = nil;
    [_delayedRemoveObjects release]; _delayedRemoveObjects = nil;
    [_delayedAddObjects release]; _delayedAddObjects = nil;

    [_arena removeFromSpace];
    [_arena release]; _arena = nil;
    
    [_gestures release]; _gestures = nil;
    
    cpSpaceFree(_space);

    [super dealloc];
}

-(void)draw {
    for(BounceObject *obj in _objects) {
        if(obj.simulationWillDraw) {
            [obj draw];
        }
    }
}

@end

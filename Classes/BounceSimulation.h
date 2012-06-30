//
//  BounceSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 5/13/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <chipmunk/chipmunk.h>
#import "FSAAudioPlayer.h"
#import <fsa/Vector.hpp>
#import "BounceObject.h"
#import "BounceArena.h"
#import "BounceGesture.h"

using namespace fsa;

@interface BounceSimulation : NSObject {    
    cpSpace* _space;
        
    NSMutableSet *_objects;
    NSMutableSet *_delayedRemoveObjects;
    NSMutableDictionary *_gestures;
        
    BounceArena *_arena;
    
    float _dt;
    float _timeRemainder;
}

@property (nonatomic, readonly) BounceArena* arena;

-(id)initWithRect: (CGRect)rect;
-(void)addObject: (BounceObject*)object;
-(void)removeObject: (BounceObject*)object;
-(void)postSolveRemoveObject: (BounceObject*)object;
-(BOOL)isObjectParticipatingInGesture: (BounceObject*)obj;
-(BOOL)isObjectBeingCreatedOrGrabbed: (BounceObject*)obj;
-(BOOL)isObjectBeingTransformed: (BounceObject*)obj;
-(NSSet*)objectsAt: (const vec2&)loc withinRadius:(float)radius;
-(BounceObject*)objectAt:(const vec2&)loc;

-(void)addToSpace:(ChipmunkObject*)obj;

-(void)step: (float)t;
-(void)next;

-(void)addToVelocity:(const vec2&)v;
-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float) radius;
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc;

-(void)addGesture:(BounceGesture*)gesture forKey:(void*)uniqueId;
-(BounceGesture*)gestureForKey:(void*)uniqueId;
-(void)removeGestureForKey:(void*)uniqueId;

-(void)removeObjectAt:(const vec2&)loc;
-(void)addObjectAt:(const vec2&)loc;
-(void)addObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel;
-(BOOL)isObjectAt:(const vec2&)loc;
-(BOOL)anyObjectsAt:(const vec2&)loc withinRadius:(float)radius;
-(void)setGravity:(const vec2&)g;

-(BounceGesture*)gestureWithParticipatingObject:(BounceObject*)object;

-(BOOL)isObjectParticipatingInGestureAt: (const vec2&)loc;
-(BOOL)isObjectBeingCreatedOrGrabbedAt:(const vec2&)loc;
-(BOOL)isObjectBeingTransformedAt:(const vec2&)loc;
-(BOOL)isStationaryObjectAt:(const vec2&)loc;

-(void)tapObject:(BounceObject*)obj;
-(void)tapSpaceAt:(const vec2&)loc;

-(void)flickStationaryObject:(BounceObject*)obj withVelocity:(const vec2&)vel;
-(void)flickObjectsAt:(const vec2&)loc withVelocity:(const vec2&)vel;
-(void)flickSpaceAt:(const vec2&)loc withVelocity:(const vec2&)vel;

-(void)beginCreate:(void*)uniqueId at:(const vec2&)loc;
-(void)beginDrag:(void*)uniqueId object:(BounceObject*)obj at:(const vec2&)loc;
-(void)beginTransform:(void*)uniqueId object:(BounceObject*)obj at:(const vec2&)loc;

-(void)singleTapAt:(const vec2&)loc;
-(void)flickAt:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time;

-(void)longTouch:(void*)uniqueId at:(const vec2&)loc;
-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)drag:(void*)uniqueId at:(const vec2&)loc;
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc;

-(void)draw;

@end

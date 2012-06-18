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
#import "BounceKillArena.h"

using namespace fsa;

typedef enum {
    WALL_TYPE,
    OBJECT_TYPE,
    KILL_TOP_TYPE,
    KILL_BOTTOM_TYPE,
    KILL_LEFT_TYPE,
    KILL_RIGHT_TYPE
} BounceObjectType;

@interface BounceSimulation : NSObject {
    id<FSAAudioDelegate>* _audioDelegate;
    
    cpSpace* _space;
    
    NSMutableSet *_objects;
    NSMutableSet *_delayedRemoveObjects;
    NSMutableDictionary *_gestures;
        
    BounceArena *_arena;
    BounceKillArena *_killArena;
    
    float _dt;
    float _timeRemainder;
}

-(id)initWithRect: (CGRect)rect audioDelegate:(id<FSAAudioDelegate>*)delegate;
-(void)addObject: (BounceObject*)object;
-(void)removeObject: (BounceObject*)object;
-(void)postSolveRemoveObject: (BounceObject*)object;
-(BOOL)isObjectParticipatingInGesture: (BounceObject*)obj;
-(BOOL)isObjectBeingCreatedOrGrabbed: (BounceObject*)obj;
-(BOOL)isObjectBeingTransformed: (BounceObject*)obj;
-(NSSet*)objectsAt: (const vec2&)loc withinRadius:(float)radius;
-(BounceObject*)objectAt:(const vec2&)loc;

-(void)step: (float)t;
-(void)next;

-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float) radius;
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc;

-(void)removeObjectAt:(const vec2&)loc;
-(void)addObjectAt:(const vec2&)loc;
-(void)addObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel;
-(BOOL)isObjectAt:(const vec2&)loc;
-(BOOL)anyObjectsAt:(const vec2&)loc withinRadius:(float)radius;
-(void)setGravity:(const vec2&)g;
-(void)addToVelocity:(const vec2&)v;

-(BOOL)isObjectParticipatingInGestureAt: (const vec2&)loc;
-(BOOL)isObjectBeingCreatedOrGrabbedAt:(const vec2&)loc;
-(BOOL)isBallBeingTransformedAt:(const vec2&)loc;
-(BOOL)isStationaryBallAt:(const vec2&)loc;

-(void)makeObjectStationaryAt:(const vec2&)loc forGesture:(void*)uniqueId;

-(BOOL)isCreatingObjectForGesture:(void*)uniqueId;
-(void)creatingObjectFrom:(const vec2&)from to:(const vec2&)to forGesture:(void*)uniqueId;
-(void)createObjectForGesture:(void*)uniqueId;
-(void)cancelCreatingObjectForGesture:(void*)uniqueId;

-(void)beginGrabbingCreatedObjectAt:(const vec2&)loc forGesture:(void*)uniqueId;
-(void)createStationaryObjectAt:(const vec2&)loc forGesture:(void*)uniqueId;

-(BOOL)isGrabbingObjectForGesture:(void*)uniqueId;
-(void)beginGrabbingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId;
-(void)grabbingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId;
-(void)releaseObjectForGesture:(void*)uniqueId;

-(BOOL)isTransformingObject:(void*)uniqueId;
-(void)beginTransformingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId;
-(void)transformObjectAt:(const vec2&)loc forGesture:(void*)uniqueId;
-(void)makeTransformingObjectStationaryAt:(const vec2&)loc forGesture:(void*)uniqueId;
-(void)beginGrabbingTransformingObjectForGesture:(void*)uniqueId;

-(void)beginRemovingBallsTop:(float)y;
-(void)updateRemovingBallsTop:(float)y;
-(void)endRemovingBallsTop;

-(void)beginRemovingBallsBottom:(float)y;
-(void)updateRemovingBallsBottom:(float)y;
-(void)endRemovingBallsBottom;

-(void)beginRemovingBallsLeft:(float)x;
-(void)updateRemovingBallsLeft:(float)x;
-(void)endRemovingBallsLeft;

-(void)beginRemovingBallsRight:(float)x;
-(void)updateRemovingBallsRight:(float)x;
-(void)endRemovingBallsRight;

-(BOOL)isRemovingBalls;
-(BOOL)isRemovingBallsTop;
-(BOOL)isRemovingBallsBottom;
-(BOOL)isRemovingBallsLeft;
-(BOOL)isRemovingBallsRight;

-(float)removingBallsTopY;
-(float)removingBallsBottomY;
-(float)removingBallsLeftX;
-(float)removingBallsRightX;

@end

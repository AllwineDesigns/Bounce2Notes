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
#import "FSAShader.h"
#import "BounceGesture.h"

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
    id<FSAAudioDelegate> _audioDelegate;
    
    cpSpace* _space;
    
    FSAShader *_objectShader;
    FSAShader *_stationaryShader;
        
    NSMutableSet *_objects;
    NSMutableSet *_delayedRemoveObjects;
    NSMutableDictionary *_gestures;
        
    BounceArena *_arena;
    BounceKillArena *_killArena;
    
    float _dt;
    float _timeRemainder;
}

-(id)initWithRect: (CGRect)rect audioDelegate:(id<FSAAudioDelegate>)delegate objectShader:(FSAShader*)objectShader stationaryShader:(FSAShader*)stationaryShader;
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

-(void)addToVelocity:(const vec2&)v;
-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float) radius;
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc;

-(void)addGesture:(BounceGesture*)gesture forKey:(void*)key;
-(BounceGesture*)gestureForKey:(void*)key;
-(void)removeGestureForKey:(void*)key;

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

-(void)singleTapAt:(const vec2&)loc;
-(void)flickAt:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time;

-(void)longTouch:(void*)uniqueId at:(const vec2&)loc;
-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)drag:(void*)uniqueId at:(const vec2&)loc;
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc;

-(void)beginTopSwipe:(void*)uniqueId at:(const vec2&)loc;
-(void)topSwipe:(void*)uniqueId at:(const vec2&)loc;
-(void)endTopSwipe:(void*)uniqueId at:(const vec2&)loc;

-(void)beginBottomSwipe:(void*)uniqueId at:(const vec2&)loc;
-(void)bottomSwipe:(void*)uniqueId at:(const vec2&)loc;
-(void)endBottomSwipe:(void*)uniqueId at:(const vec2&)loc;

-(void)beginLeftSwipe:(void*)uniqueId at:(const vec2&)loc;
-(void)leftSwipe:(void*)uniqueId at:(const vec2&)loc;
-(void)endLeftSwipe:(void*)uniqueId at:(const vec2&)loc;

-(void)beginRightSwipe:(void*)uniqueId at:(const vec2&)loc;
-(void)rightSwipe:(void*)uniqueId at:(const vec2&)loc;
-(void)endRightSwipe:(void*)uniqueId at:(const vec2&)loc;

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

-(void)draw;

@end

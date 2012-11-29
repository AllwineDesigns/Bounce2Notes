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

@class BounceShapeGenerator;
@class BouncePatternGenerator;

@interface BounceSimulation : NSObject <NSCoding> {
    cpSpace* _space;
        
    NSMutableArray *_objects;
    NSMutableSet *_delayedRemoveObjects;
    NSMutableSet *_delayedAddObjects;

    NSMutableDictionary *_gestures;
            
    BounceArena *_arena;
        
    @public vec2 _gravity;
}

@property (nonatomic, readonly) NSArray *objects;
@property (nonatomic, readonly) cpSpace* space;
@property (nonatomic, readonly) BounceArena* arena;

-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(id)initWithRect: (CGRect)rect;

-(void)addObject: (BounceObject*)object;
-(void)removeObject: (BounceObject*)object;
-(BOOL)containsObject: (BounceObject*)object;

-(void)postSolveRemoveObject: (BounceObject*)object;
-(void)postSolveAddObject: (BounceObject*)object;

-(BOOL)isObjectParticipatingInGesture: (BounceObject*)obj;
-(BOOL)isObjectBeingCreatedOrGrabbed: (BounceObject*)obj;
-(BOOL)isObjectBeingTransformed: (BounceObject*)obj;
-(NSSet*)objectsAt: (const vec2&)loc withinRadius:(float)radius;
-(BounceObject*)objectAt:(const vec2&)loc;

-(void)addToSpace:(ChipmunkObject*)obj;

-(void)step: (float)dt;

-(void)addToVelocity:(const vec2&)v;
-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float) radius;
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc;

-(void)addGesture:(BounceGesture*)gesture forKey:(void*)uniqueId;
-(BounceGesture*)gestureForKey:(void*)uniqueId;
-(void)removeGestureForKey:(void*)uniqueId;

-(BounceObject*)addObjectAt:(const vec2&)loc;
-(BounceObject*)addObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel;
-(BOOL)isObjectAt:(const vec2&)loc;
-(BOOL)anyObjectsAt:(const vec2&)loc withinRadius:(float)radius;
-(vec2)gravity;
-(void)setGravity:(const vec2&)g;
-(void)setGravityScale:(float)s;
-(void)setVelocityLimit:(float)limit;

-(void)setPosition:(const vec2&)pos;
-(void)setVelocity:(const vec2&)vel;
-(void)setAngle:(float)angle;
-(void)setAngVel:(float)angVel;

-(void)setBounciness:(float)b;
-(void)setFriction:(float)f;

-(void)setBounceShapesWithGenerator:(BounceShapeGenerator*)gen;
-(void)setColor:(const vec4&)color;
-(void)setBounceShape:(BounceShape)bounceshape;
-(void)setPatternTexture:(FSATexture*)patternTexture;
-(void)setPatternTexturesWithGenerator:(BouncePatternGenerator*)gen;
-(void)randomizeColor;
-(void)randomizeShape;
-(void)randomizeNote;
-(void)randomizePattern;
-(void)randomizeSize;
-(void)setSound:(id<BounceSound>)sound;

-(BOOL)isInBounds:(BounceObject*)obj;
-(BOOL)isInBoundsAt:(const vec2&)loc;
-(BOOL)isInBoundsAt:(const vec2&)loc withPadding:(float)pad;

-(BOOL)respondsToGesture:(void*)uniqueId;

-(BounceGesture*)gestureWithParticipatingObject:(BounceObject*)object;

-(void)setDamping:(float)damping;

-(BOOL)isObjectParticipatingInGestureAt: (const vec2&)loc;
-(BOOL)isObjectBeingCreatedOrGrabbedAt:(const vec2&)loc;
-(BOOL)isObjectBeingTransformedAt:(const vec2&)loc;
-(BOOL)isStationaryObjectAt:(const vec2&)loc;

-(void)longTouchObject:(BounceObject*)obj at:(const vec2&)loc;
-(void)tapObject:(BounceObject*)obj at:(const vec2&)loc;
-(void)tapSpaceAt:(const vec2&)loc;

-(void)flickSpaceAt:(const vec2&)loc withVelocity:(const vec2&)vel;
-(void)flickObject:(BounceObject*)obj at:(const vec2&)loc withVelocity:(const vec2&)vel;

-(void)beginCreate:(void*)uniqueId at:(const vec2&)loc;
-(void)beginGrab:(void*)uniqueId object:(BounceObject*)obj at:(const vec2&)loc;
-(void)beginTransform:(void*)uniqueId object:(BounceObject*)obj at:(const vec2&)loc;

-(void)singleTap:(void*)uniqueId at:(const vec2&)loc;
-(void)flick: (void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time;

-(void)longTouch:(void*)uniqueId at:(const vec2&)loc;
-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)drag:(void*)uniqueId at:(const vec2&)loc;
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc;
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc;

-(void)draw;

@end

typedef struct {
    BounceObject *nearest;
    float minDist;
    NSMutableSet *set;
    BounceSimulation *simulation;
} BounceQueryStruct;

//
//  BounceGesture.h
//  ParticleSystem
//
//  Created by John Allwine on 6/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BounceObject.h"

typedef enum {
    BOUNCE_GESTURE_CREATE,
    BOUNCE_GESTURE_GRAB,
    BOUNCE_GESTURE_TRANSFORM
} BounceGestureState;

@interface BounceGesture : NSObject {
    BounceObject *_obj;
    BounceGestureState _state;
    
    vec2 _begin;
    
    NSTimeInterval _creationTimestamp;
    NSTimeInterval _timestamp;
    
    vec2 _offset;
    float _offsetAngle;
    float _offsetR;

    BOOL _doSecondarySize;
    vec2 _P;
    vec2 _Pp;
    vec2 _C;  
    float _size;
    float _size2;
    float _rotation;
    BounceGesture *_gesture1;
    BounceGesture *_gesture2;
}

@property (nonatomic, readonly) NSTimeInterval creationTimestamp;
@property (nonatomic) BOOL doSecondarySize;

+(id)createGestureForObject: (BounceObject*)obj;
+(id)grabGestureForObject: (BounceObject*)obj at:(const vec2&)at;
+(id)transformGestureForObject:(BounceObject*)obj at:(const vec2&)at withOtherGesture:(BounceGesture*)gesture;

-(id)initCreateGestureForObject: (BounceObject*)obj;
-(id)initGrabGestureForObject: (BounceObject*)obj at:(const vec2&)at;
-(id)initTransformGestureForObject: (BounceObject*)obj at:(const vec2&)at withOtherGesture:(BounceGesture*)gesture;

-(BounceObject*)object;

-(BOOL)isCreateGesture;
-(BOOL)isGrabGesture;
-(BOOL)isTransformGesture;

-(void)updateGestureLocation:(const vec2&)to;
-(void)endGesture;
-(void)cancelGesture;

-(void)beginGrabAt:(const vec2&)loc;
-(void)beginTransformWithGesture:(BounceGesture*)gesture;
-(const vec2)transformBeginPosition;
-(const vec2)transformEndPosition;

@end

//
//  BounceGesture.m
//  ParticleSystem
//
//  Created by John Allwine on 6/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceGesture.h"

@implementation BounceGesture

+(id)createGestureForObject: (BounceObject*)obj {
    BounceGesture *gesture = [[BounceGesture alloc] initCreateGestureForObject:obj];
    [gesture autorelease];
    return gesture;
}
+(id)grabGestureForObject: (BounceObject*)obj at:(const vec2&)at {
    BounceGesture *gesture = [[BounceGesture alloc] initGrabGestureForObject:obj at:at];
    [gesture autorelease];
    return gesture;
}
+(id)transformGestureForObject:(BounceObject*)obj at:(const vec2&)at withOtherGesture:(BounceGesture*)gesture2 {
    BounceGesture *gesture = [[BounceGesture alloc] initTransformGestureForObject:obj at:at withOtherGesture:gesture2];
    [gesture autorelease];
    return gesture;
}

-(id)initCreateGestureForObject: (BounceObject*)obj {
    self = [super init];
    
    if(self) {
        _obj = obj;
        [_obj retain];
        _timestamp = [[NSProcessInfo processInfo] systemUptime];
        _state = BOUNCE_GESTURE_CREATE;
    }
    
    return self;
}
-(id)initGrabGestureForObject: (BounceObject*)obj at:(const vec2&)at {
    self = [super init];
    
    if(self) {
        _obj = obj;
        [_obj retain];
        
        _offset = at-obj.position;
        _offsetAngle = atan2f(_offset.y, _offset.x);
        _offsetR = _offset.length();
        _timestamp = [[NSProcessInfo processInfo] systemUptime];

        _state = BOUNCE_GESTURE_GRAB;
    }
    
    return self;
}
-(id)initTransformGestureForObject: (BounceObject*)obj at:(const vec2&)at withOtherGesture:(BounceGesture*)gesture {
    self = [super init];
    
    if(self) {
        _obj = obj;
        [_obj retain];
        
        _P = at;
        _Pp = at;
        _C = _obj.position;
        _rotation = _obj.angle;
        _size = _obj.size;
        _gesture1 = self;
        _gesture2 = gesture;
        _state = BOUNCE_GESTURE_TRANSFORM;
        [gesture beginTransformWithGesture:self];
    }
    
    return self;
}


-(BounceObject*)object {
    return _obj;
}

-(BOOL)isCreateGesture {
    return _state == BOUNCE_GESTURE_CREATE;
}
-(BOOL)isGrabGesture {
    return _state == BOUNCE_GESTURE_GRAB;
}
-(BOOL)isTransformGesture {
    return _state == BOUNCE_GESTURE_TRANSFORM;
}

-(void)updateGestureLocation:(const vec2&)to {
    NSTimeInterval timestamp = [[NSProcessInfo processInfo] systemUptime];
    NSTimeInterval time = timestamp-_timestamp;
    NSTimeInterval invtime = 1./time;
    _timestamp = timestamp;
    
    vec2 pos = _obj.position;
    switch(_state) {
        case BOUNCE_GESTURE_CREATE: {
            _offset = to-pos;
            
            float angle = atan2f(_offset.y, _offset.x);
            float oldAngle = _obj.angle;
            float newAngle = angle-_offsetAngle;
            _obj.angle = newAngle;
            _obj.angVel = (newAngle-oldAngle)*invtime;
            _obj.size = _offset.length();

            break;
        }
        case BOUNCE_GESTURE_GRAB: {
            vec2 curOffset = to-pos;
            float curAngle = atan2f(curOffset.y, curOffset.x);
            float ballAngle = _obj.angle;
            
            float newAngle = ballAngle+curAngle-_offsetAngle;
            vec2 dir(cos(curAngle), sin(curAngle));
            
            _offset = _offsetR*dir;
            vec2 newPos = to-_offset;
            
            _offsetAngle = curAngle;
            
            _obj.angVel = (newAngle-ballAngle)*invtime;
            vec2 vel = (newPos-pos)*invtime;
            if(vel.length() > 3) {
                _obj.isStationary = NO;
            }
            [_obj setVelocity:vel];
            _obj.angle = newAngle;
            [_obj setPosition:newPos];
            break;
        }
        case BOUNCE_GESTURE_TRANSFORM: {
            _Pp = to;
            BounceGesture *g1 = _gesture1;
            BounceGesture *g2 = _gesture2;
            vec2 P1 = [g1 transformBeginPosition];
            vec2 P2 = [g2 transformBeginPosition];
            vec2 P1p = [g1 transformEndPosition];
            vec2 P2p = [g2 transformEndPosition];
            
            vec2 M = .5*(P1+P2);
            vec2 Mp = .5*(P1p+P2p);
            vec2 translate = Mp-M;
            
            vec2 d = P1-P2;
            vec2 dp = P1p-P2p;
            
            float rotation = atan2f(dp.y, dp.x)-atan2f(d.y, d.x);
            float scale = dp.length()/d.length();
            
            vec2 o = _C-M;
            
            float xp = scale*(o.x*cos(rotation)-o.y*sin(rotation))+translate.x+M.x;
            float yp = scale*(o.x*sin(rotation)+o.y*cos(rotation))+translate.y+M.y;
            
            float size = _size*scale;
            
            vec2 pos(xp,yp);
            vec2 old_pos = _obj.position;
            vec2 vel = (pos-old_pos)*invtime;
            
            float old_angle = _obj.angle;
            float angle = rotation+_rotation;
            float angVel = (angle-old_angle)*invtime;
            
            [_obj setPosition:pos];
            [_obj setVelocity:vel];
            _obj.size = size;
            _obj.angle = angle;
            _obj.angVel = angVel;
            
            break;
        }
        default:
            NSAssert(NO, @"unkown bounce gesture state\n");
    }
}

-(void)endGesture {
    switch(_state) {
        case BOUNCE_GESTURE_CREATE:
            break;
        case BOUNCE_GESTURE_GRAB:
            break;
        case BOUNCE_GESTURE_TRANSFORM:
            BounceGesture *g;
            if(_gesture1 == self) {
                g = _gesture2;
            } else {
                g = _gesture1;
            }
            [g beginGrabAt:[g transformEndPosition]];
            break;
        default:
            NSAssert(NO, @"unknown bounce gesture state\n");
    }
    [_obj release];
}

-(void)beginGrabAt:(const vec2&)loc {
    _offset = loc-_obj.position;
    _offsetAngle = atan2f(_offset.y, _offset.x);
    _offsetR = _offset.length();
    _timestamp = [[NSProcessInfo processInfo] systemUptime];
    _state = BOUNCE_GESTURE_GRAB;
}
-(void)beginTransformWithGesture:(BounceGesture*)gesture {
    _state = BOUNCE_GESTURE_TRANSFORM;
    _gesture1 = gesture;
    _gesture2 = self;
    _P = [_obj position]+_offset;
    _Pp = _P;
    _C = _obj.position;
    _rotation = _obj.angle;
    _size = _obj.size;
}
-(const vec2)transformBeginPosition {
    return _P;
}
-(const vec2)transformEndPosition {
    return _Pp;
}

@end

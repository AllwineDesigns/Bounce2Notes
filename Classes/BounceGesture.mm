//
//  BounceGesture.m
//  ParticleSystem
//
//  Created by John Allwine on 6/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceGesture.h"
#import "BounceSound.h"
#import "BounceSettings.h"

@implementation BounceGesture

@synthesize creationTimestamp = _creationTimestamp;
@synthesize doSecondarySize = _doSecondarySize;

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
        [_obj makeHeavyRogue];
        _timestamp = [[NSProcessInfo processInfo] systemUptime];
        _creationTimestamp = _timestamp;
        _begin = obj.position;
        
        [_obj beginCreateCallback];

        _state = BOUNCE_GESTURE_CREATE;
    }
    
    return self;
}
-(id)initGrabGestureForObject: (BounceObject*)obj at:(const vec2&)at {
    self = [super init];
    
    if(self) {
        _obj = obj;
        [_obj retain];
        [_obj makeHeavyRogue];
        
        _offset = at-obj.position;
        _offsetAngle = atan2f(_offset.y, _offset.x);
        _offsetR = _offset.length();
        _timestamp = [[NSProcessInfo processInfo] systemUptime];
        _creationTimestamp = _timestamp;
        [_obj beginGrabCallback:at];

        _state = BOUNCE_GESTURE_GRAB;
    }
    
    return self;
}
-(id)initTransformGestureForObject: (BounceObject*)obj at:(const vec2&)at withOtherGesture:(BounceGesture*)gesture {
    self = [super init];
    
    if(self) {
        _obj = obj;
        [_obj retain];
        [_obj makeHeavyRogue];
        
        _P = at;
        _Pp = at;
        _C = _obj.position;
        _rotation = _obj.angle;
        _size = _obj.size;
        _size2 = _obj.secondarySize;
        _gesture1 = self;
        _gesture2 = gesture;
        _state = BOUNCE_GESTURE_TRANSFORM;
        
        _timestamp = [[NSProcessInfo processInfo] systemUptime];
        _creationTimestamp = _timestamp;
        
        [_obj beginTransformCallback];
        
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
    
    if(time < .04) {
        time = .04;
    }
    
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
            float old_size = _obj.size;
            float size = _offset.length();
            
            [_obj createCallbackWithSize: size secondarySize:size/1.61803399];
            [_obj createCallbackWithLoc1:_begin loc2:to];

            id<BounceSound> sound = _obj.sound;
            [sound resized:old_size];

            break;
        }
        case BOUNCE_GESTURE_GRAB: {
            if([BounceSettings instance].grabRotates) {
                vec2 curOffset = to-pos;
                float curAngle = atan2f(curOffset.y, curOffset.x);
                float ballAngle = _obj.angle;
                
                float newAngle = ballAngle+curAngle-_offsetAngle;
                vec2 dir(cos(curAngle), sin(curAngle));
                
                _offset = _offsetR*dir;
                vec2 newPos = to-_offset;
                
                _offsetAngle = curAngle;
                
                vec2 vel = .5*(newPos-pos)*invtime;
                BOOL stationary = _obj.isStationary;
                [_obj grabCallbackWithPosition:newPos velocity:vel angle:newAngle angVel:(newAngle-ballAngle)*invtime stationary:stationary];
            } else {
                vec2 newPos = to-_offset;
                vec2 vel = .5*(newPos-pos)*invtime;

                [_obj grabCallbackWithPosition:newPos velocity:vel angle:_obj.angle angVel:0 stationary:_obj.isStationary];
            }
            

            [_obj grabCallback:to];
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
            
            float old_angle = _obj.angle;
            float angle = rotation+_rotation;
            float angVel = (angle-old_angle)*invtime;
            
            float size = _size*scale;
            float size2 = _size2*scale;
                        
            float xp = scale*(o.x*cos(rotation)-o.y*sin(rotation))+translate.x+M.x;
            float yp = scale*(o.x*sin(rotation)+o.y*cos(rotation))+translate.y+M.y;
            
            vec2 pos(xp,yp);
            vec2 old_pos = _obj.position;
            vec2 vel = (pos-old_pos)*invtime;
            
            [_obj transformCallbackWithPosition:pos velocity:vel angle:angle angVel:angVel size:size secondarySize:size2 doSecondarySize:_doSecondarySize];
            
            break;
        }
        default:
            NSAssert(NO, @"unkown bounce gesture state\n");
    }
}

-(void)endGesture {
    switch(_state) {
        case BOUNCE_GESTURE_CREATE:
            if(_obj.isStationary) {
                [_obj makeStatic];
            } else {
                [_obj makeSimulated];
            }
            [_obj endCreateCallback];
        case BOUNCE_GESTURE_GRAB:
            if(_obj.isStationary) {
                [_obj makeStatic];
            } else {
                [_obj makeSimulated];
            }
            [_obj endGrabCallback];
            break;
        case BOUNCE_GESTURE_TRANSFORM:
            BounceGesture *g;
            if(_gesture1 == self) {
                g = _gesture2;
            } else {
                g = _gesture1;
            }
            [_obj endTransformCallback];
            [g beginGrabAt:[g transformEndPosition]];
            break;
        default:
            NSAssert(NO, @"unknown bounce gesture state\n");
    }
    [_obj release]; _obj = nil;
}

-(void)cancelGesture {
    switch(_state) {
        case BOUNCE_GESTURE_CREATE:
            if(_obj.isStationary) {
                [_obj makeStatic];
            } else {
                [_obj makeSimulated];
            }
            [_obj cancelCreateCallback];
        case BOUNCE_GESTURE_GRAB:
            if(_obj.isStationary) {
                [_obj makeStatic];
            } else {
                [_obj makeSimulated];
            }
            [_obj cancelGrabCallback];
            break;
        case BOUNCE_GESTURE_TRANSFORM:
            BounceGesture *g;
            if(_gesture1 == self) {
                g = _gesture2;
            } else {
                g = _gesture1;
            }
            [_obj cancelTransformCallback];
            [g beginGrabAt:[g transformEndPosition]];
            break;
        default:
            NSAssert(NO, @"unknown bounce gesture state\n");
    }
    [_obj release]; _obj = nil;
}

-(void)beginGrabAt:(const vec2&)loc {
    _offset = loc-_obj.position;
    _offsetAngle = atan2f(_offset.y, _offset.x);
    _offsetR = _offset.length();
    _timestamp = [[NSProcessInfo processInfo] systemUptime];
    _state = BOUNCE_GESTURE_GRAB;
    [_obj beginGrabCallback:loc];
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
    _size2 = _obj.secondarySize;
    
    vec2 x(1,0);
    vec2 y(0,1);
    
    vec2 d = [_gesture2 transformBeginPosition]-[_gesture1 transformBeginPosition];
    
    if(_obj.hasSecondarySize) {
        x.rotate(-_rotation);
        y.rotate(-_rotation);
        
        float xdot = fabs(x.dot(d));
        float ydot = fabs(y.dot(d));

        _doSecondarySize = (ydot > xdot);
        _gesture1.doSecondarySize = _doSecondarySize;
    } else {
        _doSecondarySize = NO;
    }
}
-(const vec2)transformBeginPosition {
    return _P;
}
-(const vec2)transformEndPosition {
    return _Pp;
}

-(void)dealloc {
    if(_obj) {
        [_obj release]; _obj = nil;
    }
    [super dealloc];
}

@end

//
//  BounceLock.m
//  ParticleSystem
//
//  Created by John Allwine on 10/22/12.
//
//

#import "BounceLock.h"
#import "FSATextureManager.h"
#import "BouncePane.h"
#import "BounceSettings.h"
#import "BounceConstants.h"

@implementation BounceLock

-(id)init {
    BounceRenderableInputs inputs;
    inputs.intensity = &_data.intensity;
    inputs.isStationary = &_data.isStationary;
    inputs.color = &_data.color;
    inputs.position = &_data.position;
    inputs.size = &_data.size;
    inputs.angle = &_data.angle;
    inputs.patternTexture = &_data.patternTexture;
    
    _data.color = vec4(0,0,0,0);
    _data.isStationary = NO;
    _data.intensity = 2.2;
    _data.position = vec2(0,0);
   // _data.size = .06;
    float upi = [[BounceConstants instance] unitsPerInch];
    _data.size = upi*.15;
    _data.angle = 0;
    _data.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
    
    _renderable = [[BounceGenericRenderable alloc] initWithInputs:inputs];
    _renderable.shapeTexture = [[FSATextureManager instance] getTexture:@"unlocked.jpg"];
    
  //  _color = vec4(.6,.8,.85,1);
    _color = vec4(1,1,1,1);
        
    [self setOrientation:getBouncePaneOrientation()];
    
    return self;
}

-(void)setLocked: (BOOL)b {
    _isLocked = b;
    if(_isLocked) {
        _renderable.shapeTexture = [[FSATextureManager instance] getTexture:@"locked.jpg"];
    } else {
        _renderable.shapeTexture = [[FSATextureManager instance] getTexture:@"unlocked.jpg"];
    }
    _data.intensity = 2.2;
    [_renderable burst:5];
    
    [[BounceSettings instance] setBounceLocked:_isLocked];
}

-(BOOL)isLocked {
    return _isLocked;
}

-(void)toggleLocked {
    [self setLocked:!_isLocked];
}

-(void)step:(float)dt {
    if(!_isToggling) {
        _data.intensity *= .9;
    }
    
    float spring_k = 150;
    float drag = .15;
        
    _data.position += _vel*dt;
    vec2 a = -spring_k*(_data.position-_springLoc);
    
    _vel +=  a*dt-drag*_vel;
        
    float angSpringK = 300;
    float angDrag = .25;
    
    _data.angle += _angVel*dt;
    
    float dAngle = fmod(_springAngle-_data.angle, 2*M_PI);
    if(dAngle > M_PI) {
        dAngle -= 2*M_PI;
    }
    
    float angAcc = angSpringK*(dAngle);
    _angVel += angAcc*dt-angDrag*_angVel;
    
    [_renderable step:dt];
    
    NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
    if(_isActivated && !_isToggling && now-_activatedTimestamp > 2) {
        [self setActivated:NO];
    }
    
    if(_isToggling && now-_togglingTimestamp > 5) {
        [self toggleLocked];
        [self setToggling:NO];
    }
}

-(void)setOrientation:(BouncePaneOrientation)orientation {
    BouncePaneSideInfo info = getBouncePaneSideInfo(BOUNCE_PANE_TOP, orientation);
    
    vec2 down = info.dir;
    vec2 right = down;
    right.rotate(-M_PI_2);
        
    _springLoc = info.pos+1.25*down*_data.size+right*(info.length*.5-1.25*_data.size);
    _springAngle = getBouncePaneAngle(orientation);
    if(!_isActivated) {
        _data.position = _springLoc;
        _data.angle = _springAngle;
    }
}

-(void)setActivated:(BOOL)activated {
    if(!_isActivated && activated) {
        _activatedTimestamp = [[NSProcessInfo processInfo] systemUptime];
    } else if(_isActivated && !activated) {
        _deactivatedTimestamp = [[NSProcessInfo processInfo] systemUptime];
    }

    _isActivated = activated;
}
-(BOOL)isActivated {
    return _isActivated;
}

-(void)draw {
    if(_isActivated) {
        NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
        if(now-_activatedTimestamp > .5) {
            _data.color =  _color;
        } else {
            _data.color = (now-_activatedTimestamp)*2*_color;
        }
    } else {
        NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
        if(now-_deactivatedTimestamp > .5) {
            _data.color =  vec4(0,0,0,0);
        } else {
            _data.color = (1-(now-_deactivatedTimestamp)*2)*_color;
        }
    }
    if(_isToggling) {
        NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
        if(now-_togglingTimestamp > 5) {
            _data.intensity = 2.2;
        } else {
            _data.intensity = (now-_togglingTimestamp)*.2;
        }
    }
    [_renderable draw];

}

-(BOOL)isLockAt:(const vec2&)loc {
    cpBB bb;

    bb.l = _springLoc.x-2*_data.size;
    bb.r = _springLoc.x+2*_data.size;
    bb.b = _springLoc.y-2*_data.size;
    bb.t = _springLoc.y+2*_data.size;
    
    if(cpBBContainsVect(bb,(const cpVect&)loc)) {
        return YES;
    }
    return NO;
}

-(void)setToggling:(BOOL)toggling {
    if(!_isToggling && toggling) {
        _togglingTimestamp = [[NSProcessInfo processInfo] systemUptime];
    } else if(_isToggling && !toggling) {
        _activatedTimestamp = [[NSProcessInfo processInfo] systemUptime]-.5;
        _gestureId = 0;
    }
    
    _isToggling = toggling;
}

-(BOOL)isToggling {
    return _isToggling;
}

-(BOOL)singleTap: (void*)uniqueId at:(const vec2&)loc {
    if([self isLockAt:loc]) {
        [self setActivated:YES];
    }
    return NO;
}
-(BOOL)flick:(void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    if([self isLockAt:loc] && dir.length() < 2*_data.size) {
        [self setActivated:YES];
        return YES;
    }
    return NO;
}

-(BOOL)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    if([self isLockAt:loc] && [self isActivated]) {
        _gestureId = uniqueId;
        [self setToggling:YES];
        
        return YES;
    }
    
    return NO;
}
-(BOOL)drag:(void*)uniqueId at:(const vec2&)loc {
    if(uniqueId == _gestureId) {
        if(![self isLockAt:loc]) {
            [self setToggling:NO];
        }
        return YES;
    }
    
    return NO;
}
-(BOOL)endDrag:(void*)uniqueId at:(const vec2&)loc {
    if(uniqueId == _gestureId) {
        [self setToggling:NO];
        return YES;
    }
    return NO;
}
-(BOOL)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    if(uniqueId == _gestureId) {
        [self setToggling:NO];
        return YES;
    }
    return NO;
}

-(void)dealloc {
    [_renderable release];
    [super dealloc];
}
@end

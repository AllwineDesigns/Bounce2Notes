//
//  BouncePane.m
//  ParticleSystem
//
//  Created by John Allwine on 9/7/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//
#import "BouncePane.h"

#import "BounceConstants.h"
#import "FSAShaderManager.h"
#import "FSATextureManager.h"
#import "fsa/Noise.hpp"
#import "FSAUtil.h"
#import "BounceConfigurationSimulation.h"
#import "BounceConfigurationObject.h"
#import "FSASoundManager.h"
#import "BounceSettingsSimulation.h"
#import "BounceMusicConfigurationSimulation.h"
#import "BounceSettings.h"
#import "BounceSaveLoadSimulation.h"

BouncePaneSideInfo bouncePaneSideInfo[4] = { {vec2(0,-1),vec2(0,1),0},
    {vec2(-1,0),vec2(1,0), -M_PI_2},{vec2(0,1),vec2(0,-1), M_PI},{vec2(1,0),vec2(-1,0), M_PI_2} };

float bouncePaneAngles[4] = { 0, -M_PI_2, M_PI, M_PI_2 };

@implementation BounceConfigurationPaneObject 

@synthesize springAngle = _springAngle;
@synthesize inactivePadding = _inactivePadding;
@synthesize orientation = _orientation;
@synthesize side = _side;
@synthesize color = _color;
@synthesize paneSize = _paneSize;
@synthesize springLoc = _springLoc;
@synthesize tappedSpringLoc = _tappedSpringLoc;
@synthesize inactiveSpringLoc = _inactiveSpringLoc;
@synthesize activeSpringLoc = _activeSpringLoc;
@synthesize customSpringLoc = _customSpringLoc;

-(id)init {
    self = [super initStatic];
    if(self) {
        NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
        
        BounceConstants *constants = [BounceConstants instance];
        
        _upi = constants.unitsPerInch;
        _aspect = constants.aspect;
        _invaspect = 1./_aspect;
        
        _paneSize.width = 1.6;
        _paneSize.height = _upi;
        
        _inactivePadding = .5;
        
        NSString *device = machineName();
        if([device hasPrefix:@"iPad"]) {
            _paneSize.width = _upi*4;
            _paneSize.height = _upi*2.25;
        }
        
        _side = BOUNCE_PANE_BOTTOM;
        _orientation = BOUNCE_PANE_PORTRAIT;
        
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        switch (deviceOrientation) {
            case UIDeviceOrientationPortrait:
                _orientation = BOUNCE_PANE_PORTRAIT;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                _orientation = BOUNCE_PANE_PORTRAIT_UPSIDE_DOWN;
                break;
            case UIDeviceOrientationLandscapeRight:
                _orientation = BOUNCE_PANE_LANDSCAPE_RIGHT;
                break;
            case UIDeviceOrientationLandscapeLeft:
                _orientation = BOUNCE_PANE_LANDSCAPE_LEFT;
                break;
            case UIDeviceOrientationFaceUp:
                break;
            case UIDeviceOrientationFaceDown:
                break;
                
            default:
                
                break;
        }
        
        vec4 color;
        HSVtoRGB(&(color.x), &(color.y), &(color.z), 
                 360.*random(64.28327*time), .4, .05*random(736.2827*time)+.75   );
        color.w = 1;
        _color = color;
        
        [self updateInfo];
        
        _springLoc = _inactiveSpringLoc;
        
        [self setPosition:_inactiveSpringLoc];
        
        float top = _paneSize.height*.5;
        float bottom = -_paneSize.height*.5;
        float left = -_paneSize.width*.5;
        float right = _paneSize.width*.5;
        
        vec2 verts[4];
        verts[0] = vec2(right, top);
        verts[1] = vec2(right, bottom);
        verts[2] = vec2(left, bottom);
        verts[3] = vec2(left, top);
        
        [self addPolyShapeWithNumVerts:4 withVerts:verts withOffset:cpvzero];  
        
        cpShapeSetFriction(_shapes[0], .5);
        cpShapeSetElasticity(_shapes[0], .95);
        cpShapeSetCollisionType(_shapes[0], WALL_TYPE);
    }
    
    return self;
}

-(BouncePaneSideInfo)getSideInfo {
    BouncePaneSideInfo info = bouncePaneSideInfo[(_side+_orientation)%4];
    info.pos.y *= _invaspect;
    
    return info;
}

-(float)getS {
    float s;
    switch(_side) {
        case BOUNCE_PANE_BOTTOM:
        case BOUNCE_PANE_TOP:
            s = _paneSize.height;
            break;
        case BOUNCE_PANE_LEFT:
        case BOUNCE_PANE_RIGHT:
            s = _paneSize.width;
            break;
    }
    
    return s;
}

-(void)updateInfo {
    BouncePaneSideInfo info = [self getSideInfo];

    float s = [self getS];
    
    _springAngle = bouncePaneAngles[_orientation];
    
    unsigned int state = 0;
    if(_tappedSpringLoc == _springLoc) {
        state = 1;
    } else if(_activeSpringLoc == _springLoc) {
        state = 2;
    } else if(_inactiveSpringLoc == _springLoc) {
        state = 3;
    }
    
    _tappedSpringLoc = info.pos-.5*s*info.dir;
    _activeSpringLoc = info.pos+.5*s*info.dir;
    _inactiveSpringLoc = info.pos-(.5*s+_inactivePadding)*info.dir;

    switch(state) {
        case 1:
            _springLoc = _tappedSpringLoc;
            break;
        case 2:
            _springLoc = _activeSpringLoc;
            break;
        case 3:
            _springLoc = _inactiveSpringLoc;
            break;
    }
}

-(void)setOrientation:(BouncePaneOrientation)orientation {
    _orientation = orientation;
    
    [self updateInfo];
}
-(void)setSide:(BouncePaneSide)side {
    _side = side;
    
    [self updateInfo];
}

-(BOOL)isHidden {
    BouncePaneSideInfo info = [self getSideInfo];
    vec2 v = self.position-info.pos;
    
    float dot = v.dot(info.dir);
    
    return dot <= -.5*[self getS];
}

-(BOOL)isPaneAt:(const vec2&)loc {
    vec2 l = loc;
    vec2 pos = self.position;
    l -= pos;
    
    l.rotate(self.angle);
    
    float top = (_paneSize.height*.5);
    float bottom = -_paneSize.height*.5;
    float left = -_paneSize.width*.5;
    float right = _paneSize.width*.5;
    
    return l.x >= left && l.x <= right &&
    l.y >= bottom && l.y <= top;
}
-(void)randomizeColor {
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
    
    _color = [[[BounceSettings instance] colorGenerator] randomColorFromTime:time];
}

-(void)tap {    
    _springLoc = _tappedSpringLoc;
}

-(void)activate {
    if([BounceSettings instance].paneUnlocked) {
        _springLoc = _customSpringLoc;
    } else {
        _springLoc = _activeSpringLoc;
    }
}

-(void)deactivate {
    _springLoc = _inactiveSpringLoc;
}

-(void)step:(float)dt {    
    float spring_k = 150;
    float drag = .15;
    
    vec2 pos = [self position];
    
    pos += _vel*dt;
    vec2 a = -spring_k*(pos-_springLoc);
    
    _vel +=  a*dt-drag*_vel;
    
    [self setPosition:pos];
    [self setVelocity:_vel];
    
    float angSpringK = 300;
    float angDrag = .25;
    float angle = [self angle];
    
    angle += _angVel*dt;
    
    float dAngle = fmod(_springAngle-angle, 2*M_PI);
    if(dAngle > M_PI) {
        dAngle -= 2*M_PI;
    }
    
    float angAcc = angSpringK*(dAngle);
    _angVel += angAcc*dt-angDrag*_angVel;
    
    [self setAngle:angle];
    [self setAngVel:_angVel];
}

-(void)draw {
    vec2 pos = [self position];
    
    float top = _paneSize.height*.5;
    float bottom = -_paneSize.height*.5;
    float left = -_paneSize.width*.5;
    float right = _paneSize.width*.5;
    
    vec2 verts[4];
    verts[0] = vec2(right, top);
    verts[1] = vec2(left, top);
    verts[2] = vec2(left, bottom);
    verts[3] = vec2(right, bottom);
    
    float angle = self.angle;
    float cosangle = cos(-angle);
    float sinangle = sin(-angle);
    
    for(int i = 0; i < 4; ++i) {
        verts[i].rotate(cosangle, sinangle);
        verts[i] += pos;
    }
    
    unsigned int indices[6];
    
    FSAShader *shader = [[FSAShaderManager instance] getShader:@"ColorShader"];
    [shader setPtr:verts forAttribute:@"position"];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 0;
    indices[4] = 2;
    indices[5] = 3;
    
    vec4 color(0,0,0,1);
    [shader setPtr:&color forUniform:@"color"];
    
    [shader enable];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, indices);
    [shader disable];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 3;
    indices[4] = 0;
    [shader setPtr:&_color forUniform:@"color"];
    
    [shader enable];
    glDrawElements(GL_LINE_STRIP, 5, GL_UNSIGNED_INT, indices);
    [shader disable];
}
@end


@implementation BouncePane

@synthesize simulation = _simulation;
@synthesize object = _object;

-(id)initWithBounceSimulation:(MainBounceSimulation *)simulation {
    self = [super init];
    
    if(self) {
        BounceConstants *constants = [BounceConstants instance];
        
        _simulation = simulation;
        
        _upi = constants.unitsPerInch;
        _aspect = constants.aspect;
        _invaspect = 1./_aspect;
        
        _state = BOUNCE_PANE_DEACTIVATED;
        _object = [[BounceConfigurationPaneObject alloc] init];
        
        _simulations = [[NSMutableArray alloc] initWithCapacity:3];
        _simulationTabs = [[NSMutableArray alloc] initWithCapacity:3];
        _curSimulation = 0;
        _switchToSimulation = 0;
        
        CGSize size = _object.paneSize;
        _rect = CGRectMake(-size.width*.5, -size.height*.5, size.width, size.height);
        
        [simulation addToSpace:_object];
    }
    
    return self;
}

-(void)addSimulation:(BounceConfigurationSimulation *)sim {
    sim.pane = self;
    [_simulations addObject:sim];
}

-(void)setSimulation:(MainBounceSimulation *)simulation {
    _simulation = simulation;
    
    [_object removeFromSpace];
    [_object addToSpace:simulation.space];
    
    for(BounceConfigurationTab *tab in _simulationTabs) {
        [tab removeFromSimulation];
        [tab addToSimulation:simulation];
    }
    
    for(BounceConfigurationSimulation *sim in _simulations) {
        [sim setSimulation:simulation];
    }
}

-(void)randomizeShape {
    for(BounceConfigurationTab *tab in _simulationTabs) {
        tab.bounceShape = [[[BounceSettings instance] bounceShapeGenerator] bounceShape];
    }
}

-(void)randomizeColor {
    [_object randomizeColor];
    for(BounceConfigurationTab *tab in _simulationTabs) {
        vec4 color = [[[BounceSettings instance] colorGenerator] randomColor];
        [tab setColor:color];
    }
    for(BounceSimulation *sim in _simulations) {
        [sim randomizeColor];
    }
}

-(void)tabSingleTappedAt:(const vec2 &)loc index:(unsigned int)index {
    if(index == _curSimulation && _state == BOUNCE_PANE_ACTIVATED) {
        [self deactivate];
    } else {
        [self setCurrentSimulation:index];
    }
}

-(void)tabFlickedAt:(const vec2 &)loc withVelocity:(const vec2 &)vel index:(unsigned int)index {
    BouncePaneSideInfo info = [self.object getSideInfo];
    
    float dot = vel.dot(info.dir);
    if(dot > 0) {
        [self setCurrentSimulation:index];
    } else {
        [self deactivate];
    }
}

-(void)tabGrabbedAt:(const vec2 &)loc offset:(const vec2 &)offset index:(unsigned int)index {
    [self setCurrentSimulation:index];

    vec2 o = offset;
    o.rotate(-self.object.angle);
    
    vec2 pos = loc-o;
    BouncePaneSideInfo info = [self.object getSideInfo];
    
    vec2 v = pos-info.pos;
    
    float dot = v.dot(info.dir);
    
    vec2 parallel = dot*info.dir;
    
    if([BounceSettings instance].paneUnlocked) {
        _object.springLoc = info.pos+v;
    } else {
        _object.springLoc = info.pos+parallel;
    }
    _object.customSpringLoc = _object.springLoc;
    
}

-(void)tabGrabEnded:(unsigned int)index {
    BouncePaneSideInfo info = [self.object getSideInfo];
    
    vec2 v = self.object.position-info.pos;
    
    if(v.dot(info.dir) < 0) {
        [self deactivate];
    } else {
        [self activate];
        [self setCurrentSimulation:index];
    }
}

-(BOOL)isHandleAreaAt:(const vec2&)loc {
    BouncePaneSideInfo info = [self.object getSideInfo];
    CGSize size = [_object paneSize];
    
    float top = .5*_upi;
    float left = -.5*size.width;
    float right = .5*size.width;
    
    vec2 l = loc;
    l -= info.pos;
    l.rotate(info.angle);
    
    return _state == BOUNCE_PANE_DEACTIVATED &&
    l.y <= top && l.x >= left && l.x <= right;
}

-(void)addToVelocity:(const vec2&)v {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    [sim addToVelocity:v];
}

-(void)setBounciness:(float)b {
    for(BounceSimulation *sim in _simulations) {
        [sim setBounciness:b];
    }
}

-(void)setFriction:(float)friction {
    for(BounceSimulation *sim in _simulations) {
        [sim setFriction:friction];
    }
}

-(void)setVelocityLimit:(float)limit {
    for(BounceSimulation *sim in _simulations) {
        [sim setVelocityLimit:limit];
    }
}

-(void)setDamping:(float)damping {
    for(BounceSimulation *sim in _simulations) {
        [sim setDamping:damping];
    }
}

-(void)setGravityScale:(float)s {
    for(BounceSimulation *sim in _simulations) {
        [sim setGravityScale:s];
    }
}

-(void)setGravity:(vec2)gravity {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    [sim setGravity:gravity];
}

-(void)prepareCurrentSimulation {
    BounceConfigurationSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    [sim prepare];
}

-(void)setCurrentSimulation:(unsigned int)index {
    if(_state == BOUNCE_PANE_TAPPED || [BounceSettings instance].paneUnlocked) {        
        _switchToSimulation = index;
        _curSimulation = index;
        [self prepareCurrentSimulation];
        
        [self activate];
    } else {
        if(index != _curSimulation) {
            _switchToSimulation = index;
            
            [_object deactivate];
        }
    }
}

-(void)activate {
    _state = BOUNCE_PANE_ACTIVATED;
    [_object activate];
}
-(void)deactivate {
    _state = BOUNCE_PANE_DEACTIVATED;
    [_object deactivate];
}


-(BOOL)singleTap:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim singleTap:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)flick: (void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim flick:uniqueId at:loc inDirection:dir time:time];
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)longTouch:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim longTouch:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)beginDrag:(void*)uniqueId at:(const vec2&)loc {

    if([_object isPaneAt:loc]) {
        BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
        if(![sim objectAt:loc] && [_simulationTabs containsObject:[_simulation objectAt:loc]]) {
            return NO;
        }
        [sim beginDrag:uniqueId at:loc];
        return YES;
    }
    
    if([self isHandleAreaAt:loc]) {
        _state = BOUNCE_PANE_TAPPED;
        _time = 0;
        [_object tap];
        [self randomizeColor];
        
        return YES;
    }
    
    return NO;
}
-(BOOL)drag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim drag:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)endDrag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim endDrag:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim cancelDrag:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}


-(void)reset {
    switch (_state) {
        case BOUNCE_PANE_TAPPED:
            [_object tap];
            [self randomizeColor];
            break;
        case BOUNCE_PANE_ACTIVATED:
            if(_curSimulation != _switchToSimulation) {
                [_object deactivate];
            } else {
                [_object activate];
            }
            break;
        case BOUNCE_PANE_DEACTIVATED:
            [_object deactivate];
            break;
        default:
            NSAssert(NO, @"unknown bounce configuration state");
            break;
    }
}

-(void)step:(float)dt {
    if(_state == BOUNCE_PANE_TAPPED) {
        _time += dt;
        if(_time > 2) {
            [self deactivate];
        }
    }
    
    [_object step:dt];
    
    vec2 pos = _object.position;
    vec2 vel = _object.velocity;
    
    float angle = _object.angle;
    float angVel = _object.angVel;
    float cosangle = cos(-angle);
    float sinangle = sin(-angle);
    
    for(BounceConfigurationTab *tab in _simulationTabs) {
        vec2 offset = [tab offset];
        offset.rotate(cosangle,sinangle);
        offset += pos;
        [tab setPosition:offset];
        [tab setVelocity:vel];
        
        [tab setAngle:angle];
        [tab setAngVel:angVel];
    }
    
    BounceConfigurationSimulation *curSim = [_simulations objectAtIndex:_curSimulation];
    [curSim setPosition:pos];
    [curSim setVelocity:vel];
    [curSim setAngle:angle];
    [curSim setAngVel:angVel];
    
    for(BounceConfigurationSimulation *sim in _simulations) {
        if([sim isAnyObjectInBounds] || (curSim == sim && _state == BOUNCE_PANE_ACTIVATED)) {
            
            [sim step:dt];
        }
    }
    
    
  //  CGSize paneSize = [_object paneSize];
    
    if(_switchToSimulation != _curSimulation && [_object isHidden]) {
        _curSimulation = _switchToSimulation;
        if(_state == BOUNCE_PANE_ACTIVATED) {
            [_object activate];
            [self randomizeColor];
            [self prepareCurrentSimulation];
        }
        
    }
    
    BounceConfigurationTab *curTab = [_simulationTabs objectAtIndex:_curSimulation];
    if(curTab.intensity < .6) {
        curTab.intensity = .6;
    }
}


-(void)updateSettings {
    for(BounceConfigurationSimulation *sim in _simulations) {
        [sim updateSettings];
    }
}

-(void)drawRectangle {
    vec2 pos = self.object.position;
    
    CGSize dimensions = self.object.paneSize;
    
    float top = dimensions.height*.5;
    float bottom = -dimensions.height*.5;
    float left = -dimensions.width*.5;
    float right = dimensions.width*.5;
    
    vec2 verts[4];
    verts[0] = vec2(right, top);
    verts[1] = vec2(left, top);
    verts[2] = vec2(left, bottom);
    verts[3] = vec2(right, bottom);
    
    float angle = self.object.angle;
    float cosangle = cos(-angle);
    float sinangle = sin(-angle);
    
    for(int i = 0; i < 4; ++i) {
        verts[i].rotate(cosangle, sinangle);
        verts[i] += pos;
    }
    
    unsigned int indices[6];
    
    FSAShader *shader = [[FSAShaderManager instance] getShader:@"ColorShader"];
    [shader setPtr:verts forAttribute:@"position"];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 0;
    indices[4] = 2;
    indices[5] = 3;
    
    vec4 color(0,0,0,1);
    [shader setPtr:&color forUniform:@"color"];
    
    [shader enable];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, indices);
    [shader disable];
}

-(void)prepareStencilBuffer {
    glEnable(GL_STENCIL_TEST);
    
    glStencilFunc(GL_ALWAYS, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ZERO, GL_ONE);
    [self drawRectangle];
    glDisable(GL_BLEND);
    
    glStencilFunc(GL_EQUAL, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    glDisable(GL_STENCIL_TEST);
}

-(void)drawTabs {
    BounceConfigurationTab *curTab = [_simulationTabs objectAtIndex:_curSimulation];
    for(BounceConfigurationTab *tab in _simulationTabs) {
        if(curTab != tab) {
            [tab draw];
        }
    }
    [curTab draw];
}

-(void)draw {
    [self prepareStencilBuffer];
    [_object draw];
    
    glEnable(GL_STENCIL_TEST);
    [[_simulations objectAtIndex:_curSimulation] draw];
  //  for(BounceConfigurationSimulation *sim in _simulations) {
   //     [sim draw];
    //}
    glDisable(GL_STENCIL_TEST);
    
    [self drawTabs];
    
    for(BounceConfigurationSimulation *sim in _simulations) {
        [sim drawObjectsParticipatingInGestures];
    }
}
-(BouncePaneSide)side {
    return _object.side;
}
-(void)setSide:(BouncePaneSide)side {
    _object.side = side;
}

-(BouncePaneOrientation)orientation {
    return _object.orientation;
}
-(void)setOrientation:(BouncePaneOrientation)orientation {
    BOOL isHidden = _state == BOUNCE_PANE_DEACTIVATED && [_object isHidden];
    
    _object.orientation = orientation;
    
    if(isHidden) {
        _object.position = _object.inactiveSpringLoc;
        _object.angle = _object.springAngle;
    }

}

-(void)dealloc {
    for(BounceObject* obj in _simulationTabs) {
        [obj removeFromSimulation];
    }
    [_object removeFromSpace];
    [_simulationTabs release];
    
    [_simulations release];
    
    [super dealloc];
}

@end

//
//  BouncePane.h
//  ParticleSystem
//
//  Created by John Allwine on 9/7/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ChipmunkObject.h"
#import "BounceSimulation.h"
#import "BounceConfigurationTab.h"

@class BounceConfigurationSimulation;

typedef struct {
    vec2 pos;
    vec2 dir;
    float angle;
    float length;
} BouncePaneSideInfo;

typedef enum {
    BOUNCE_PANE_BOTTOM = 0, // used as indices in to bouncePaneSideInfo
    BOUNCE_PANE_LEFT = 1,
    BOUNCE_PANE_TOP = 2,
    BOUNCE_PANE_RIGHT = 3
} BouncePaneSide;

typedef enum {
    BOUNCE_PANE_PORTRAIT = 0, // used as indices in to bouncePaneSideInfo and bouncePaneAngles
    BOUNCE_PANE_LANDSCAPE_LEFT = 1,
    BOUNCE_PANE_PORTRAIT_UPSIDE_DOWN = 2,
    BOUNCE_PANE_LANDSCAPE_RIGHT = 3
} BouncePaneOrientation;

typedef enum {
    BOUNCE_PANE_DEACTIVATED,
    BOUNCE_PANE_TAPPED,
    BOUNCE_PANE_ACTIVATED
} BouncePaneState;

@interface BounceConfigurationPaneObject : ChipmunkObject {
    float _upi;
    float _aspect;
    float _invaspect;
    
    CGSize _paneSize;
        
    BouncePaneSide _side;
    BouncePaneOrientation _orientation;
    
    float _inactivePadding;
    
    vec2 _tappedSpringLoc;
    vec2 _activeSpringLoc;
    vec2 _inactiveSpringLoc;
    
    vec2 _customSpringLoc;
    
    vec2 _springLoc;
    vec2 _vel;
    vec4 _color;
    
    float _springAngle;
    float _angVel;
}

@property (nonatomic) float springAngle;
@property (nonatomic) float inactivePadding;
@property (nonatomic) BouncePaneOrientation orientation;
@property (nonatomic) BouncePaneSide side;
@property (nonatomic) const vec2& springLoc;
@property (nonatomic) const vec2& tappedSpringLoc;
@property (nonatomic) const vec2& inactiveSpringLoc;
@property (nonatomic) const vec2& activeSpringLoc;
@property (nonatomic) const vec2& customSpringLoc;
@property (nonatomic) vec4 color;
@property (nonatomic) CGSize paneSize;

-(BOOL)isPaneAt:(const vec2&)loc;
-(BOOL)isHidden;
-(void)randomizeColor;

-(BouncePaneSideInfo)getSideInfo;

-(void)tap;
-(void)activate;
-(void)deactivate;
-(void)step:(float)dt;

-(void)draw;
@end

@class MainBounceSimulation;

@interface BouncePane : NSObject {
    float _upi;
    float _aspect;
    float _invaspect;
    
    float _time;
    CGRect _rect;
    
    MainBounceSimulation *_simulation;
    
    BounceConfigurationPaneObject *_object;
    
    NSMutableArray *_simulations;
    NSMutableArray *_simulationTabs;
    
    unsigned int _curSimulation;
    unsigned int _switchToSimulation;
    
    BouncePaneState _state;
}

@property (nonatomic, assign) MainBounceSimulation* simulation;
@property (nonatomic) BouncePaneSide side;
@property (nonatomic) BouncePaneOrientation orientation;
@property (nonatomic,readonly) BounceConfigurationPaneObject* object;

-(id)initWithBounceSimulation:(MainBounceSimulation*)simulation;

-(void)setSimulation:(MainBounceSimulation*)simulation;
-(void)setCurrentSimulation:(unsigned int)index;
-(void)prepareCurrentSimulation;
-(void)unloadCurrentSimulation;

-(void)setFriction:(float)friction;
-(void)setDamping:(float)damping;
-(void)setGravityScale:(float)s;
-(void)setGravity:(vec2)gravity;
-(void)addToVelocity:(const vec2&)v;

-(void)randomizeColor;
-(void)randomizeShape;

-(void)setBounciness:(float)b;
-(void)setVelocityLimit:(float)limit;

-(void)addSimulation:(BounceConfigurationSimulation*)sim;

-(void)tabSingleTappedAt:(const vec2&)loc index:(unsigned int)index;
-(void)tabFlickedAt:(const vec2&)loc withVelocity:(const vec2&)vel index:(unsigned int)index;
-(void)tabGrabbedAt:(const vec2&)loc offset:(const vec2&)offset index:(unsigned int)index;
-(void)tabGrabEnded:(unsigned int)index;

-(BOOL)singleTap: (void*)uniqueId at:(const vec2&)loc;
-(BOOL)flick:(void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time;

-(BOOL)longTouch:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)beginDrag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)drag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)endDrag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)cancelDrag:(void*)uniqueId at:(const vec2&)loc;

-(void)updateSettings;

-(void)reset;
-(void)activate;
-(void)deactivate;

-(void)step:(float)dt;
-(void)draw;

@end

float getBouncePaneAngle(BouncePaneOrientation orientation);
BouncePaneOrientation getBouncePaneOrientation();
void updateBounceOrientation();
void updateBounceOrientation(UIInterfaceOrientation orientation);

BouncePaneSideInfo getBouncePaneSideInfo(BouncePaneSide side, BouncePaneOrientation orientation);

//
//  BounceConfigurationPane.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChipmunkObject.h"
#import "BounceSimulation.h"
#import "BounceConfigurationTab.h"

typedef enum {
    BOUNCE_CONFIGURATION_PANE_DEACTIVATED,
    BOUNCE_CONFIGURATION_PANE_TAPPPED,
    BOUNCE_CONFIGURATION_PANE_ACTIVATED
} BounceConfigurationPaneState;

@interface BounceConfigurationPaneObject : ChipmunkObject {
    float _upi;
    float _aspect;
    float _invaspect;
    
    CGSize _handleSize;
    CGSize _paneSize;
    
    vec2 _tappedSpringLoc;
    vec2 _activeSpringLoc;
    vec2 _inactiveSpringLoc;
    
    GLuint _handleShapeTexture;
    GLuint _handlePatternTexture;
    
    GLuint _paneShapeTexture;
    GLuint _panePatternTexture;
    
    float _intensity;
    
    vec2 _springLoc;
    vec2 _vel;
    vec4 _color;
}

@property (nonatomic) vec4 color;
@property (nonatomic) CGSize handleSize;
@property (nonatomic) CGSize paneSize;

-(BOOL)isHandleAt:(const vec2&)loc;
-(BOOL)isPaneAt:(const vec2&)loc;

-(void)randomizeColor;

-(void)tap;
-(void)activate;
-(void)deactivate;
-(void)step:(float)dt;

-(void)draw;
@end

@interface BounceConfigurationPane : NSObject {
    float _upi;
    float _aspect;
    float _invaspect;
    
    float _time;
    CGRect _rect;
    
    BounceSimulation *_simulation;
    
    BounceConfigurationPaneObject *_object;
        
    NSMutableArray *_simulations;
    NSMutableArray *_simulationTabs;
       
    unsigned int _curSimulation;
    unsigned int _switchToSimulation;
    
    BounceConfigurationPaneState _state;
}
-(id)initWithBounceSimulation:(BounceSimulation*)simulation;

-(void)setCurrentSimulation:(unsigned int)index;

-(void)setGravity:(vec2)gravity;
-(void)addToVelocity:(const vec2&)v;

-(void)setCurrentSimulation:(unsigned int)index;

-(BOOL)singleTap: (void*)uniqueId at:(const vec2&)loc;
-(BOOL)flick:(void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time;

-(BOOL)longTouch:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)beginDrag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)drag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)endDrag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)cancelDrag:(void*)uniqueId at:(const vec2&)loc;

-(void)step:(float)dt;
-(void)draw;

@end

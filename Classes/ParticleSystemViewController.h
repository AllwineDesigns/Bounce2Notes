//
//  ParticleSystemViewController.h
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CMMotionManager.h>
#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

//#import "BasicParticleShader.h"
//#import "FSAMultiGestureRecognizer.h"
#import "FSAMultiTapAndDragRecognizer.h"
//#import "ChipmunkSimulationShader.h"
//#import "ChipmunkSimulationStationaryShader.h"
//#import "BounceKillBoxShader.h"
#import "MainBounceSimulation.h"
#import "FSAAudioPlayer.h"

@interface ParticleSystemViewController : UIViewController
{
    EAGLContext *context;
    EAGLSharegroup *sharegroup;
    
    MainBounceSimulation *simulation;

    NSTimeInterval lastUpdate;
    CMMotionManager *motionManager;
    
    FSAMultiTapAndDragRecognizer *multiTapAndDragRecognizer;
    
    FSAShader *_objectShader;
    FSAShader *_stationaryShader;
    
    float aspect;
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
    
    NSOperationQueue *cacheQueue;
    
    UIAlertView *alertView;
    BOOL dismissAllUpgradeAlerts;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)pixels2sim: (vec2&) loc;
- (void)vectorPixels2sim: (vec2&) vec;
- (void)displayUpgradeAlert;


@end

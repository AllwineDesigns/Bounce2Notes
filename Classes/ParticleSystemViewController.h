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
#import "FSAGestureCurves.h"
#import "BounceSaveLoadPane.h"
#import "BounceLock.h"
#import "BounceLoadingObject.h"
#import "BounceMelodyPlayer.h"

@interface ParticleSystemViewController : UIViewController <BounceSaveLoadDelegate,UITextFieldDelegate>
{
    EAGLContext *context;
    
    MainBounceSimulation *simulation;
    BounceConfigurationPane *_configPane;
    BounceSaveLoadPane *_saveLoadPane;
    BounceLoadingObject *_loadingObject;
    BounceMelodyPlayer *_melodyPlayer;
    BounceMelodyPlayer *_harmonyPlayer;
    
    BounceLock *_bounceLock;
    
    float _dt;
    float _timeRemainder;
    NSTimeInterval lastUpdate;
    
    FSAGestureCurves *gestureCurves;
    
    CMMotionManager *motionManager;
    
    FSAMultiTapAndDragRecognizer *multiTapAndDragRecognizer;
    
    float aspect;
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
    
    BOOL _ready;
    
    UIAlertView *alertView;
    UIAlertView *saveView;
    UIAlertView *fileExistsView;
    UIAlertView *deleteFileView;
    UIAlertView *invalidFileView;
    
    NSString *_deleteFile;
    NSString *_saveFile;
    
    BOOL dismissAllUpgradeAlerts;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)resignActive;
- (void)pixels2sim: (vec2&) loc;
- (void)vectorPixels2sim: (vec2&) vec;
- (void)displayUpgradeAlert;


@end

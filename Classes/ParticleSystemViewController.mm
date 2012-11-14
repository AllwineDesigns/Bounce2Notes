//
//  ParticleSystemViewController.m
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ParticleSystemViewController.h"
#import "EAGLView.h"
#import "FSATextureManager.h"
#import "FSAShaderManager.h"
#import "FSASoundManager.h"
#import "BounceNoteManager.h"
#import "FSAUtil.h"
#import "MainBounceSimulation.h"
#import "fsa/Noise.hpp"
#import "FSABackgroundQueue.h"
#import "BounceSavedSimulation.h"
#import "BounceFileManager.h"
#import "BounceConstants.h"

#define BOUNCE_LITE_MAX_BALLS 15

@interface ParticleSystemViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end

@implementation ParticleSystemViewController

@synthesize animating, context, displayLink;

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
    NSLog(@"%@", [[UIDevice currentDevice] model]);
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"BounceContributors"];
        
    alertView = [[UIAlertView alloc] initWithTitle:@"Upgrade to full version" message:@"You must have the full version to create more balls." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Buy!", @"Dismiss All",  nil];
    
    saveView = [[UIAlertView alloc] initWithTitle:@"Save" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",  nil];
    saveView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [saveView textFieldAtIndex:0].delegate = self;
    
    fileExistsView = [[UIAlertView alloc] initWithTitle:@"Simulation exists!" message:@"Are you sure you want to overwrite this simulation?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",  nil];

    invalidFileView = [[UIAlertView alloc] initWithTitle:@"Invalid Simulation!" message:@"Cannot load file as its not a valid bounce simulation file." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    dismissAllUpgradeAlerts = NO;
    
    gestureCurves = [[FSAGestureCurves alloc] init];
    
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startAccelerometerUpdates];
    
    CGRect frame = [self.view frame];
    aspect = frame.size.width/frame.size.height;
    
    _dt = .02;
    
    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    
    FSAShader *objectShader = [shaderManager getShader:@"SingleObjectShader"];
    FSAShader *stationaryShader = [shaderManager getShader:@"SingleObjectStationaryShader"];
    FSAShader *killBoxShader = [shaderManager getShader:@"BounceKillBoxShader"];
    FSAShader *colorShader = [shaderManager getShader:@"ColorShader"];
    FSAShader *billboardShader = [shaderManager getShader:@"ColoredTextureShader"];
    FSAShader *gestureGlowShader = [shaderManager getShader:@"GestureGlowShader"];
    FSAShader *intensityShader = [shaderManager getShader:@"IntensityShader"];

    [objectShader setPtr:&aspect forUniform:@"aspect"];
    [stationaryShader setPtr:&aspect forUniform:@"aspect"];
    [killBoxShader setPtr:&aspect forUniform:@"aspect"];  
    [colorShader setPtr:&aspect forUniform:@"aspect"];    
    [billboardShader setPtr:&aspect forUniform:@"aspect"];  
    [gestureGlowShader setPtr:&aspect forUniform:@"aspect"];  
    [intensityShader setPtr:&aspect forUniform:@"aspect"];

    // initialize note manager
    [BounceNoteManager instance];
    FSABackgroundQueue *queue = [FSABackgroundQueue instance];
    
    [[FSATextureManager instance] addSmartTexture:@"ball.jpg"];
    [[FSATextureManager instance] addSmartTexture:@"stationary_ball.png"];
    
    queue.sharegroup = aContext.sharegroup;
    
    NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadResources) object:nil];
    [invocation setThreadPriority:0];
    [queue addOperation:invocation];
    [invocation release];

    multiTapAndDragRecognizer = [[FSAMultiTapAndDragRecognizer alloc] initWithTarget:self];
    multiTapAndDragRecognizer.view = self.view;
    
    animating = FALSE;
    animationFrameInterval = 2;
    self.displayLink = nil;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    updateBounceOrientation([self interfaceOrientation]);
    _loadingObject = [[BounceLoadingObject alloc] init];

    [NSThread setThreadPriority:1];
    NSLog(@"main thread: %@", [NSThread currentThread]);
 //   [[UIApplication sharedApplication] setStatusBarOrientation:
 //    UIInterfaceOrientationLandscapeRight];
}

#define ACCEPTABLE_CHARACTERS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!. "

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string length] == 0) {
        return YES;
    }
    NSCharacterSet *acceptedInput = [NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS];
    
    if ([string rangeOfCharacterFromSet:acceptedInput].location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if(_ready) {
        updateBounceOrientation();
        BouncePaneOrientation orientation  = getBouncePaneOrientation();
        _configPane.orientation = orientation;
        _bounceLock.orientation = orientation;
        switch (deviceOrientation) {
            case UIDeviceOrientationPortrait:
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown];
                break;
            case UIDeviceOrientationLandscapeRight:
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
                break;
            case UIDeviceOrientationLandscapeLeft:
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
                break;
            case UIDeviceOrientationFaceUp:
                break;
            case UIDeviceOrientationFaceDown:
                break;
                
            default:                
                break;
        }
    }

}

-(void)checkIfReady {
    if([[FSABackgroundQueue instance] operationCount] == 0) {
        _ready = YES;
        [_loadingObject release];
        /*
        BounceNoteDuration notes[] = {
            {BOUNCE_MIDI_C4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_E4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_F4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_C5, BOUNCE_QUARTER_NOTE}
        };
         */
        BounceNoteDuration notes[] = {
            // Page 1
            
            // Line 1
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            
            // Line 2
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D5, 1.5*BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            
            
            // Line 3
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D5, 1.5*BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_D5, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_D5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_EIGHTH_NOTE},
            
            // Line 4
            {BOUNCE_MIDI_D5, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_D5, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_D5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_EIGHTH_NOTE},
            
            {BOUNCE_MIDI_D5, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_D5, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_D5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_EIGHTH_NOTE},
            
            // Line 5
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            
            
            {0, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, 1.5*BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_QUARTER_NOTE},
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, 1.5*BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},

            // Page 2
            
            // Line 1
            {0, BOUNCE_QUARTER_NOTE},
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_C5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_QUARTER_NOTE},
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, 1.5*BOUNCE_EIGHTH_NOTE},
            
            // Line 2
            {0, BOUNCE_HALF_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_B4, 1.5*BOUNCE_QUARTER_NOTE},
            
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_C5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_QUARTER_NOTE},
            
            // Line 3
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, 1.5*BOUNCE_EIGHTH_NOTE},
            
            {0, BOUNCE_QUARTER_NOTE},
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, 1.5*BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            
            {0, 1.5*BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_C5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            
            // Line 4
            {0, 1.5*BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},

            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, 1.5*BOUNCE_QUARTER_NOTE},
            
            {0, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, 1.5*BOUNCE_QUARTER_NOTE},
            
            // Line 5
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_C5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_QUARTER_NOTE},

            
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_QUARTER_NOTE},
            {0, 1.5*BOUNCE_HALF_NOTE},
            
            // Line 6
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_E4, BOUNCE_EIGHTH_NOTE},

            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},

            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},

            // Page 3
            
            // Line 1
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},

            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_E4, BOUNCE_EIGHTH_NOTE},
            
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            
            // Line 2
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_QUARTER_NOTE},
            
            {BOUNCE_MIDI_G4, BOUNCE_HALF_NOTE},
            {0, BOUNCE_HALF_NOTE},
            
            {0, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, 1.5*BOUNCE_EIGHTH_NOTE},
            
            // Line 3
            {0, BOUNCE_HALF_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, 1.5*BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            
            {0, 1.5*BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_C5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            
            {0, 1.5*BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_QUARTER_NOTE},

            // Line 4
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, 1.5*BOUNCE_EIGHTH_NOTE},
            
    
            {0, 1.5*BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, 1.5*BOUNCE_QUARTER_NOTE},
            
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_C5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_QUARTER_NOTE},

            // Line 5
            {0, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, 1.5*BOUNCE_QUARTER_NOTE},
            
            {BOUNCE_MIDI_G4, BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_D4, 1.5*BOUNCE_EIGHTH_NOTE},

            {0, BOUNCE_HALF_NOTE},
            {BOUNCE_MIDI_B3, BOUNCE_SIXTEENTH_NOTE},
            {BOUNCE_MIDI_D4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, 1.5*BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            
            // Line 6
            {0, 1.5*BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_C5, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            
            {0, 1.5*BOUNCE_QUARTER_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_B4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_A4, BOUNCE_EIGHTH_NOTE},
            {BOUNCE_MIDI_G4, BOUNCE_EIGHTH_NOTE},



        };
        
        [_harmonyPlayer setSimulation:simulation];
  /*
        BounceMidiNumber g_chord[] = {BOUNCE_MIDI_G3, BOUNCE_MIDI_G4, BOUNCE_MIDI_B4, BOUNCE_MIDI_D5};
        BounceMidiNumber c_chord[] = {BOUNCE_MIDI_C3, BOUNCE_MIDI_C4, BOUNCE_MIDI_E4, BOUNCE_MIDI_G4};
        BounceMidiNumber d_chord[] = {BOUNCE_MIDI_D3, BOUNCE_MIDI_D4, BOUNCE_MIDI_F_SHARP4, BOUNCE_MIDI_A4};
        BounceMidiNumber e_chord[] = {BOUNCE_MIDI_E3, BOUNCE_MIDI_E4, BOUNCE_MIDI_G4, BOUNCE_MIDI_B4};
   */
        BounceMidiNumber g_chord[] = {BOUNCE_MIDI_G3, BOUNCE_MIDI_B3, BOUNCE_MIDI_D4};
        BounceMidiNumber c_chord[] = {BOUNCE_MIDI_C3, BOUNCE_MIDI_E3, BOUNCE_MIDI_G3};
        BounceMidiNumber d_chord[] = {BOUNCE_MIDI_D3, BOUNCE_MIDI_F_SHARP3, BOUNCE_MIDI_A3};
        BounceMidiNumber e_chord[] = {BOUNCE_MIDI_E3, BOUNCE_MIDI_G3, BOUNCE_MIDI_B3};
        BounceMidiNumber rest[] = {0};

        
        BounceMelody *harmony = [[BounceMelody alloc] init];
        
        // Page 1
        // Line 1
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        
        // Line 2
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        
        // Line 3
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        
        // Line 4
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];

        // Line 5
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        
        // Page 2
        
        // Line 1
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];

        // Line 2
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];

        // Line 3
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];

        // Line 4
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];

        // Line 5
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:rest numNotes:sizeof(rest)/sizeof(BounceMidiNumber) duration:8*BOUNCE_EIGHTH_NOTE];
        
        // Line 6
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];

        // Page 3
        
        // Line 1
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];


        // Line 2
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:8*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];

        // Line 3
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];

        // Line 4
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];

        // Line 5
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:d_chord numNotes:sizeof(d_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:e_chord numNotes:sizeof(e_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];

        // Line 6
        [harmony addChord:c_chord numNotes:sizeof(c_chord)/sizeof(BounceMidiNumber) duration:6*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:2*BOUNCE_EIGHTH_NOTE];
        [harmony addChord:g_chord numNotes:sizeof(g_chord)/sizeof(BounceMidiNumber) duration:7*BOUNCE_EIGHTH_NOTE];

        
       // [_harmonyPlayer playMelody:harmony];
        [harmony release];
       //  [_harmonyPlayer playMelody:[[[BounceMelody alloc] initWithMidiFile:@"callmemaybe2"] autorelease]];
       // [_melodyPlayer playMelody:[[[BounceMelody alloc] initWithMidiFile:@"callmemaybe2"] autorelease] ];

       // [_melodyPlayer playMelody:[[[BounceMelody alloc] initWithBounceNoteDurations:notes numNotes:sizeof(notes)/sizeof(BounceNoteDuration)] autorelease] ];
    } else {
        [_loadingObject makeProgess];
        [self performSelector:@selector(checkIfReady) withObject:nil afterDelay:.02];
    }
}

-(void)finishedLoadingResources {
    [_configPane issueContributorsRequest];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkIfReady];
    });

 //   if([[BounceFileManager instance] fileExists:@"Last Exit"]) {
 //       [self loadSimulation:@"Last Exit"];
 //   }
}

-(void)loadResources {
    EAGLSharegroup *sharegroup = [[FSABackgroundQueue instance] sharegroup];
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:sharegroup];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
    NSLog(@"free memory: %d\n", getFreeMemory());
    
    FSATextureManager *texture_manager = [FSATextureManager instance];
    
    NSArray *texturesToCache = [NSArray arrayWithObjects:@"spiral.jpg", 
     @"plasma.jpg",
     @"stripes.jpg", 
   //  @"checkered.jpg", 
     @"sections.jpg", 
    // @"squares.jpg", 
     @"weave.jpg", 
    // @"ball.jpg",
     @"square.jpg",
     @"triangle.jpg",
     @"pentagon.jpg",
     @"note.jpg",
    // @"stationary_ball.png",
     @"stationary_square.png",
     @"stationary_triangle.png",
     @"stationary_pentagon.png",
     @"stationary_note.png",
     @"glow.jpg",
     @"star.jpg",
     @"stationary_star.png",
     nil];
    for(NSString* texName in texturesToCache) {
        [texture_manager addSmartTexture:texName];
        [_loadingObject makeProgess];
    }
    
    //[texture_manager generateTextureForText:@"Contributors"];
    [texture_manager generateTextureForText:@"Contributors" forKey:@"Contributors" withFontSize:32 withOffset:vec2()];
    [_loadingObject makeProgess];
    [texture_manager generateTextureForText:@"Advanced" forKey:@"Advanced" withFontSize:32 withOffset:vec2()];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Save/Load" forKey:@"Save/Load" withFontSize:32 withOffset:vec2()];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Patterns" forKey:@"Patterns" withFontSize:40 withOffset:vec2()];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Shapes" forKey:@"Shapes" withFontSize:45 withOffset:vec2()];
    
    [_loadingObject makeProgess];


   // [texture_manager generateTextureForText:@"Shapes"];
  //  [texture_manager generateTextureForText:@"Patterns"];
    [texture_manager generateTextureForText:@"Sizes"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Colors"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Notes"];
   // [texture_manager generateTextureForText:@"Save/Load"];
  //  [texture_manager generateTextureForText:@"Advanced"];
    
    [_loadingObject makeProgess];
    
    [texture_manager generateTextureForText:@"Red"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Green"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Yellow"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Blue"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Orange"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Purple"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Pastel"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Gray"];
    
    [_loadingObject makeProgess];

    
    NSArray *labels = [NSArray arrayWithObjects:@"Teeny", @"Tiny", @"Small", @"Medium", @"Large", nil];
    for(NSString* str in labels) {
        [texture_manager generateTextureForText:str];
        [_loadingObject makeProgess];
    }

  //  [texture_manager generateTextureForText:@"Note" forKey:@"Note" withFontSize:28 withOffset:vec2(-43,105) ];
    [texture_manager generateTextureForText:@"Note"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Rectangle"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Capsule"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Circle"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Square"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Pentagon"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Star"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Triangle" forKey:@"Triangle" withFontSize:40 withOffset:vec2() ];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Random" forKey:@"Random" withFontSize:40 withOffset:vec2() ];
    [_loadingObject makeProgess];

    NSArray *notes = [NSArray arrayWithObjects:@"C", @"D", @"E", @"F", @"G", @"A", @"B", nil];
    for(NSString* str in notes) {
        [texture_manager generateTextureForText:[NSString stringWithFormat:@"%@%C", str, (unsigned short)0x266F]
                                         forKey:[NSString stringWithFormat:@"%@%@", str, @"sharp"] withFontSize:80 withOffset:vec2() ];
        [texture_manager generateTextureForText:[NSString stringWithFormat:@"%@%C", str, (unsigned short)0x266D]
                                         forKey:[NSString stringWithFormat:@"%@%@", str, @"flat"] withFontSize:80 withOffset:vec2() ];
        [texture_manager generateTextureForText:str forKey:str withFontSize:80 withOffset:vec2()];
        [_loadingObject makeProgess];
    }
    NSArray *flatminors = [NSArray arrayWithObjects:@"A", @"E", @"B",nil ];
    NSArray *minors = [NSArray arrayWithObjects:@"Fm", @"Cm", @"Gm", @"Dm", @"Am", @"Em", @"Bm",nil ]; 
    NSArray *sharpminors = [NSArray arrayWithObjects:@"F", @"C", @"G", @"D", @"A", nil];
    
    for(NSString *str in sharpminors) {
        [texture_manager generateTextureForText:[NSString stringWithFormat:@"%@%Cm", str, (unsigned short)0x266F]
                                         forKey:[NSString stringWithFormat:@"%@%@m", str, @"sharp"] withFontSize:80 withOffset:vec2() ];
        [_loadingObject makeProgess];
    }
    
    for(NSString *str in flatminors) {
        [texture_manager generateTextureForText:[NSString stringWithFormat:@"%@%Cm", str, (unsigned short)0x266D]
                                         forKey:[NSString stringWithFormat:@"%@%@m", str, @"flat"] withFontSize:80 withOffset:vec2() ];
        [_loadingObject makeProgess];
    }
    
    for(NSString *str in minors) {
        [texture_manager generateTextureForText:str forKey:str withFontSize:80 withOffset:vec2()];
        [_loadingObject makeProgess];
    }
    
    [texture_manager generateTextureForText:@"Copy"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Paste"];
    [_loadingObject makeProgess];

    
    [texture_manager generateTextureForText:@"Save"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"Load"];
    [_loadingObject makeProgess];

    [texture_manager generateTextureForText:@"X"];
    
    [_loadingObject makeProgess];
    
    [texture_manager generateTextureForText:@"Help"];
    [_loadingObject makeProgess];
    
    [_loadingObject makeProgess];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize size = screenSize();
    if(nextPowerOfTwo(size.width*upi*.3) > 128) {
        [texture_manager addTexture:@"256locked.jpg" forKey:@"locked.jpg"];
        [texture_manager addTexture:@"256unlocked.jpg" forKey:@"unlocked.jpg"];
    } else {
        [texture_manager addTexture:@"128locked.jpg" forKey:@"locked.jpg"];
        [texture_manager addTexture:@"128unlocked.jpg" forKey:@"unlocked.jpg"];
    }
    
    [_loadingObject makeProgess];
        
    simulation = [[MainBounceSimulation alloc] initWithAspect:aspect];
    simulation.delegate = self;
    
    lastUpdate = [[NSProcessInfo processInfo] systemUptime];
    [_loadingObject makeProgess];

    
    updateBounceOrientation();
    _configPane = [[BounceConfigurationPane alloc] initWithBounceSimulation:simulation];
    [_loadingObject makeProgess];
    
    //  _saveLoadPane = [[BounceSaveLoadPane alloc] initWithBounceSimulation:simulation];
    
    _bounceLock = [[BounceLock alloc] init];
    
    [_loadingObject makeProgess];

  //  NSLog(@"loaded textures in thread: %@\n", [NSThread currentThread]);
    
    glFlush();
    
    _melodyPlayer = [[BounceMelodyPlayer alloc] init];
    _harmonyPlayer = [[BounceMelodyPlayer alloc] init];

    
    [aContext release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self finishedLoadingResources];
    });    
}

-(void)saveSimulation {
    [saveView show];
}

-(void)deleteSimulation:(NSString *)file {
    BounceFileManager *fileManager = [BounceFileManager instance];

    if([fileManager fileExists:file]) {
        NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the simulation called %@?", file];
        deleteFileView = [[UIAlertView alloc] initWithTitle:@"Delete simulation?" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",  nil];
        _deleteFile = [file copy];
        [deleteFileView show];
    }
}

-(void)loadSimulation:(NSString *)file {
    BounceFileManager *fileManager = [BounceFileManager instance];

    if([fileManager fileExists:file]) {
        BounceSavedSimulation *load = [fileManager loadFile:file];
        if(load) {
            [[BounceSettings instance] updateSettings:load.settings];
            [_configPane updateSettings];
            [_bounceLock setLocked:[BounceSettings instance].bounceLocked];
            //[_saveLoadPane updateSettings];
            
            _configPane.simulation = load.simulation;
         //   _saveLoadPane.simulation = load.simulation;
            [simulation release];
            simulation = [load.simulation retain];
            simulation.delegate = self;
        } else {
            [invalidFileView show];
        }
    } else {
        // TODO do file does not exist, though this shouldn't get called unless a file is deleted without the interface being updated
    }
}

-(void)loadBuiltInSimulation:(NSString *)file {
    BounceFileManager *fileManager = [BounceFileManager instance];
    
    if([fileManager builtInFileExists:file]) {
        BounceSavedSimulation *load = [fileManager loadBuiltInFile:file];
        if(load) {
            [[BounceSettings instance] updateSettings:load.settings];
            [_configPane updateSettings];
            [_bounceLock setLocked:[BounceSettings instance].bounceLocked];

            //[_saveLoadPane updateSettings];
            
            _configPane.simulation = load.simulation;
            //   _saveLoadPane.simulation = load.simulation;
            [simulation release];
            simulation = [load.simulation retain];
            simulation.delegate = self;
        } else {
            [invalidFileView show];
        }
    } else {
        // TODO do file does not exist, though this shouldn't get called unless a file is deleted without the interface being updated
    }
}

- (void)dealloc
{
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [saveView release];
    [alertView release];
    [context release];
    [_configPane release];
   // [_saveLoadPane release];
    [simulation release];
    [gestureCurves release];
    
    [super dealloc];
}

-(void)pixels2sim:(vec2&)loc {
    float width = self.view.frame.size.width;
    loc /= .5*width;
    loc.y *= -1;
    loc.x -= 1;
    loc.y += 1./aspect;
}
-(void)vectorPixels2sim:(vec2&)loc {
    float width = self.view.frame.size.width;
    loc /= .5*width;
    loc.y *= -1;
}

-(void)singleTap:(FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    if(![_bounceLock singleTap:gesture at:loc] && ![_configPane singleTap:gesture at:loc]) {
        if([BounceSettings instance].playMode && [simulation gestureForKey:gesture] == nil) {
            
        } else {
            [simulation singleTap:gesture at:loc];
        }
    }
}

-(void)displayUpgradeAlert {
    if(!dismissAllUpgradeAlerts) {
        [alertView show];
    }
}

-(void)alertView: (UIAlertView*)view clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(view == alertView) {
        switch (buttonIndex) {
            case 2:
                dismissAllUpgradeAlerts = YES;
            case 0:    
                break;
                
            default:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/bounce!!/id530767513?ls=1&mt=8"]];
                break;
        }
    } else if(view == saveView) {
        BounceFileManager *fileManager = [BounceFileManager instance];
        switch (buttonIndex) {
            case 0:
                break;
                
            default:
                UITextField *text = [view textFieldAtIndex:0];
                NSString *file = text.text;
                if([file length] > 0) {
                    if([fileManager fileExists:file]) {
                        _saveFile = [file copy];
                        
                        [fileExistsView show];
                    } else {
                        [fileManager save:simulation withSettings:[BounceSettings instance] toFile:file];
                        [_configPane updateSavedSimulations];
                    }
                }
                break;
        }
    } else if(view == fileExistsView) {
        BounceFileManager *fileManager = [BounceFileManager instance];

        switch(buttonIndex) {
            case 0:
                break;
            default:
                [fileManager save:simulation withSettings:[BounceSettings instance] toFile:_saveFile];
                [_saveFile release];
                _saveFile = nil;
        }
    } else if(view == deleteFileView) {
        
        BounceFileManager *fileManager = [BounceFileManager instance];
        
        switch(buttonIndex) {
            case 0:
                break;
            default:
                [fileManager deleteFile:_deleteFile];
                [_deleteFile release];
                _deleteFile = nil;
                [_configPane updateSavedSimulations];
        }
    }
}

-(void)resignActive {
    [self didReceiveMemoryWarning];
    [[BounceFileManager instance] save:simulation withSettings:[BounceSettings instance] toFile:@"Last Exit"];
    [_configPane updateSavedSimulations];
}

-(void)beginThreeFingerDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.beginLocation);
    vec2 loc2(gesture.location);
    [self pixels2sim:loc];
    [self pixels2sim:loc2];
    
    switch(gesture.side) {
        case FSA_TOP:
            [simulation beginTopSwipe:gesture at:loc2.y];
            break;
        case FSA_BOTTOM:
            [simulation beginBottomSwipe:gesture at:loc.y];
            break;
        case FSA_LEFT:
            [simulation beginLeftSwipe:gesture at:loc2.x];
            break;
        case FSA_RIGHT:
            [simulation beginRightSwipe:gesture at:loc.x];
            break;
    }

}

-(void)threeFingerDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.beginLocation);
    vec2 loc2(gesture.location);
    [self pixels2sim:loc];
    [self pixels2sim:loc2];
    
    switch(gesture.side) {
        case FSA_TOP:
            [simulation topSwipe:gesture at:loc2.y];
            break;
        case FSA_BOTTOM:
            [simulation bottomSwipe:gesture at:loc.y];
            break;
        case FSA_LEFT:
            [simulation leftSwipe:gesture at:loc2.x];
            break;
        case FSA_RIGHT:
            [simulation rightSwipe:gesture at:loc.x];
            break;
    }
}

-(void)endThreeFingerDrag: (FSAMultiGesture*)gesture {

    switch(gesture.side) {
        case FSA_TOP:
            [simulation endTopSwipe:gesture];
            break;
        case FSA_BOTTOM:
            [simulation endBottomSwipe:gesture];
            break;
        case FSA_LEFT:
            [simulation endLeftSwipe:gesture];
            break;
        case FSA_RIGHT:
            [simulation endRightSwipe:gesture];
            break;
    }

}

-(void)cancelThreeFingerDrag: (FSAMultiGesture*)gesture {
    switch(gesture.side) {
        case FSA_TOP:
            [simulation endTopSwipe:gesture];
            break;
        case FSA_BOTTOM:
            [simulation endBottomSwipe:gesture];
            break;
        case FSA_LEFT:
            [simulation endLeftSwipe:gesture];
            break;
        case FSA_RIGHT:
            [simulation endRightSwipe:gesture];
            break;
    }
}


-(void)beginDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.beginLocation);
    [self pixels2sim:loc];
    
    [gestureCurves beginDrag:gesture at:loc];
    
    if(![_bounceLock beginDrag:gesture at:loc] && ![_configPane beginDrag:gesture at:loc]) {
        [simulation beginDrag:gesture at:loc];
    }
}

-(void)longTouch:(FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    if(![_configPane longTouch:gesture at:loc]) {
        [simulation longTouch:gesture at:loc];
    }
}

-(void)flick: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    vec2 loc2(gesture.beginLocation);
    [self pixels2sim:loc2];
    
    vec2 dir = loc-loc2;
    NSTimeInterval time = gesture.timestamp-gesture.beginTimestamp;
    if(![_bounceLock flick:gesture at:loc2 inDirection:dir time:time] && ![_configPane flick:gesture at:loc2 inDirection:dir time:time]) {
        [simulation flick:gesture at:loc2 inDirection:dir time:time];
    }
}

-(void)drag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    [gestureCurves drag:gesture at:loc];

    if(![_bounceLock drag:gesture at:loc] && ![_configPane drag:gesture at:loc]) {
        [simulation drag:gesture at:loc];
    }
}

-(void)endDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    [gestureCurves endDrag:gesture at:loc];

    if(![_bounceLock endDrag:gesture at:loc] && ![_configPane endDrag:gesture at:loc]) {
        [simulation endDrag:gesture at:loc];
    }
}

-(void)cancelDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.beginLocation);
    vec2 loc2(gesture.location);
    [self pixels2sim:loc];
    [self pixels2sim:loc2];
    
    [gestureCurves cancelDrag:gesture at:loc];

    if(![_bounceLock cancelDrag:gesture at:loc] && ![_configPane cancelDrag:gesture at:loc2]) {
        [simulation cancelDrag:gesture at:loc2];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self loadSimulation:@""];
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{

    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{    
	[super viewDidUnload];

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        CADisplayLink *aDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;

        lastUpdate = [[NSProcessInfo processInfo] systemUptime];
        
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}



- (void)drawFrame
{ 
    [(EAGLView *)self.view setFramebuffer];
    
    glClearColor(0.f, 0.f, 0.f, 0.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
    NSTimeInterval timeSinceLastDraw = now-lastUpdate;
    
    lastUpdate = now;

    if(!_ready) {
        float t = timeSinceLastDraw+_timeRemainder;
        if(t > 5*_dt) {
            t = 5*_dt;
        }
        
        while(t >= _dt) {
            [_loadingObject step:_dt];
            t -= _dt;
        }
        
        _timeRemainder = t;
        
        [_loadingObject draw];
    } else {        
        CMAccelerometerData *accelData = [motionManager accelerometerData];
        CMAcceleration acceleration = [accelData acceleration];
        
        vec2 accel(8*acceleration.x, 8*acceleration.y);
        
    #if TARGET_IPHONE_SIMULATOR
        accel = vec2(0,-8);
    #endif
        
        if(accel.length() > 8) {
            vec2 unit_accel = accel.unit();
            vec2 add_to_vel(accel);
            add_to_vel -= unit_accel*8;
            add_to_vel *= -.2;
            [simulation addToVelocity:add_to_vel];
            [_configPane addToVelocity:add_to_vel];
           // [_saveLoadPane addToVelocity:add_to_vel];
        }
        
        vec2 g(acceleration.x, acceleration.y);
        [simulation setGravity:g];
        [_configPane setGravity:g];
      //  [_saveLoadPane setGravity:g];
                
        float t = timeSinceLastDraw+_timeRemainder;
        if(t > 5*_dt) {
            t = 5*_dt;
        }
        
        while(t >= _dt) {
            [simulation step:_dt];
            [_configPane step:_dt];
            [_bounceLock step:_dt];
            //[_saveLoadPane step:_dt];
            t -= _dt;
        }
                
        _timeRemainder = t;

        [simulation draw];
       // [_saveLoadPane draw];
        [_configPane draw];
        [_bounceLock draw];
        
        [gestureCurves step:timeSinceLastDraw];
        [gestureCurves draw];
        
        //[_melodyPlayer step];
        //[_harmonyPlayer step];

    }

    [(EAGLView *)self.view presentFramebuffer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_ready) {
        [multiTapAndDragRecognizer touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_ready) {
        [multiTapAndDragRecognizer touchesMoved:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_ready) {
        [multiTapAndDragRecognizer touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_ready) {
        [multiTapAndDragRecognizer touchesCancelled:touches withEvent:event];
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [[FSATextureManager instance] memoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


@end

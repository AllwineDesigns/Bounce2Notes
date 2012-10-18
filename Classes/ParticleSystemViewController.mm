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
        
    alertView = [[UIAlertView alloc] initWithTitle:@"Upgrade to full version" message:@"You must have the full version to create more balls." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Buy!", @"Dismiss All",  nil];
    
    saveView = [[UIAlertView alloc] initWithTitle:@"Save" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",  nil];
    saveView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    fileExistsView = [[UIAlertView alloc] initWithTitle:@"Simulation exists!" message:@"Are you sure you want to overwrite this simulation?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",  nil];
    
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
    FSAShader *billboardShader = [shaderManager getShader:@"BillboardShader"];
    FSAShader *gestureGlowShader = [shaderManager getShader:@"GestureGlowShader"];
    FSAShader *intensityShader = [shaderManager getShader:@"IntensityShader"];


    [objectShader setPtr:&aspect forUniform:@"aspect"];
    [stationaryShader setPtr:&aspect forUniform:@"aspect"];
    [killBoxShader setPtr:&aspect forUniform:@"aspect"];  
    [colorShader setPtr:&aspect forUniform:@"aspect"];    
    [billboardShader setPtr:&aspect forUniform:@"aspect"];  
    [gestureGlowShader setPtr:&aspect forUniform:@"aspect"];  
    [intensityShader setPtr:&aspect forUniform:@"aspect"];   
    
    FSABackgroundQueue *queue = [FSABackgroundQueue instance];
    queue.sharegroup = aContext.sharegroup;

    NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadResources) object:nil];
    [queue addOperation:invocation];
    [invocation release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLoadingResources:) name:@"finishedLoadingResources" object:nil];
    
    // initialize note manager
    [BounceNoteManager instance];

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
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
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
 //   [[UIApplication sharedApplication] setStatusBarOrientation:
 //    UIInterfaceOrientationLandscapeRight];
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if(_ready) {
        switch (deviceOrientation) {
            case UIDeviceOrientationPortrait:
                _configPane.orientation = BOUNCE_PANE_PORTRAIT;
                _saveLoadPane.orientation = BOUNCE_PANE_PORTRAIT;
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                _configPane.orientation = BOUNCE_PANE_PORTRAIT_UPSIDE_DOWN;
                _saveLoadPane.orientation = BOUNCE_PANE_PORTRAIT_UPSIDE_DOWN;
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown];


                break;
            case UIDeviceOrientationLandscapeRight:
                _configPane.orientation = BOUNCE_PANE_LANDSCAPE_RIGHT;
                _saveLoadPane.orientation = BOUNCE_PANE_LANDSCAPE_RIGHT;
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];


                break;
            case UIDeviceOrientationLandscapeLeft:
                _configPane.orientation = BOUNCE_PANE_LANDSCAPE_LEFT;
                _saveLoadPane.orientation = BOUNCE_PANE_LANDSCAPE_LEFT;
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

-(void)finishedLoadingResources:(NSNotification*)notification {
    _ready = YES;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"lastexit.bounce"];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self loadSimulation:@"lastexit.bounce"];
    }
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
     @"ball.jpg",
     @"square.jpg",
     @"triangle.jpg",
     @"pentagon.jpg",
     @"note.jpg",
     @"stationary_ball.png",
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
    }
    [texture_manager generateTextureForText:@"John Allwine" forKey:@"John Allwine" withFontSize:40 withOffset:vec2() ];
 //   [texture_manager generateTextureForText:@"Travis Buck" forKey:@"Travis Buck" withFontSize:30 withOffset:vec2() ];
   // [texture_manager generateTextureForText:@"Kristen Wells" forKey:@"Kristen Wells" withFontSize:25 withOffset:vec2() ];
   // [texture_manager generateTextureForText:@"Bob Afifi" forKey:@"Bob Afifi" withFontSize:30 withOffset:vec2() ];
   // [texture_manager generateTextureForText:@"Scott Peterson" forKey:@"Scott Peterson" withFontSize:40 withOffset:vec2() ];
   // [texture_manager generateTextureForText:@"Jason Waltman" forKey:@"Jason Waltman" withFontSize:40 withOffset:vec2() ];
    //[texture_manager generateTextureForText:@"Nixon Hazard" forKey:@"Nixon Hazard" withFontSize:35 withOffset:vec2() ];

    
    [texture_manager generateTextureForText:@"Contributors"];

    [texture_manager generateTextureForText:@"Shapes"];
    [texture_manager generateTextureForText:@"Patterns"];
    [texture_manager generateTextureForText:@"Sizes"];
    [texture_manager generateTextureForText:@"Colors"];
    [texture_manager generateTextureForText:@"Notes"];
    [texture_manager generateTextureForText:@"Save/Load"];
    [texture_manager generateTextureForText:@"Advanced"];
    
    [texture_manager generateTextureForText:@"Red"];
    [texture_manager generateTextureForText:@"Green"];
    [texture_manager generateTextureForText:@"Yellow"];
    [texture_manager generateTextureForText:@"Blue"];
    [texture_manager generateTextureForText:@"Orange"];
    [texture_manager generateTextureForText:@"Purple"];
    [texture_manager generateTextureForText:@"Pastel"];
    [texture_manager generateTextureForText:@"Gray"];
    
    NSArray *bouncinessLabels = [NSArray arrayWithObjects:@"Bouncy", @"Springy", @"Squishy", @"Rigid", nil];
    for(NSString* str in bouncinessLabels) {
        [texture_manager generateTextureForText:str];
    }
    
    NSArray *labels = [NSArray arrayWithObjects:@"Octave 2", @"Octave 3", @"Octave 4", @"Octave 5", @"Octave 6", nil];
    for(NSString* str in labels) {
        [texture_manager generateTextureForText:str];
    }
    
   labels = [NSArray arrayWithObjects:@"Vacuum", @"Air", @"Water", @"Syrup", nil];
    for(NSString* str in labels) {
        [texture_manager generateTextureForText:str];
    }
    
   labels = [NSArray arrayWithObjects:@"Stopped", @"Slow", @"Fast", @"Very Fast", @"No Limit", nil];
    for(NSString* str in labels) {
        [texture_manager generateTextureForText:str];
    }
    
    labels = [NSArray arrayWithObjects:@"Frictionless", @"Smooth", @"Coarse", @"Rough", nil];
    for(NSString* str in labels) {
        [texture_manager generateTextureForText:str];
    }
    
    labels = [NSArray arrayWithObjects:@"Teeny", @"Tiny", @"Small", @"Medium", @"Large", nil];
    for(NSString* str in labels) {
        [texture_manager generateTextureForText:str];
    }

    NSArray *gravityLabels = [NSArray arrayWithObjects:@"Weightless", @"Airy", @"Floaty", @"Light", @"Normal", @"Heavy", nil];
    for(NSString* str in gravityLabels) {
        [texture_manager generateTextureForText:str];
    }
    

    
    [texture_manager generateTextureForText:@"Create Mode" forKey:@"Create Mode" withFontSize:40 withOffset:vec2() ];
    [texture_manager generateTextureForText:@"Play Mode" forKey:@"Play Mode" withFontSize:40 withOffset:vec2() ];

  //  [texture_manager generateTextureForText:@"Note" forKey:@"Note" withFontSize:28 withOffset:vec2(-43,105) ];
    [texture_manager generateTextureForText:@"Note"];
    [texture_manager generateTextureForText:@"Rectangle"];
    [texture_manager generateTextureForText:@"Capsule"];
    [texture_manager generateTextureForText:@"Circle"];
    [texture_manager generateTextureForText:@"Square"];
    [texture_manager generateTextureForText:@"Pentagon"];
    [texture_manager generateTextureForText:@"Star"];
    [texture_manager generateTextureForText:@"Triangle" forKey:@"Triangle" withFontSize:40 withOffset:vec2() ];

    [texture_manager generateTextureForText:@"Randomize"];
    [texture_manager generateTextureForText:@"Random" forKey:@"Random" withFontSize:40 withOffset:vec2() ];




    NSArray *notes = [NSArray arrayWithObjects:@"C", @"D", @"E", @"F", @"G", @"A", @"B", nil];
    for(NSString* str in notes) {
        [texture_manager generateTextureForText:[NSString stringWithFormat:@"%@%C", str, 0x266F] 
                                         forKey:[NSString stringWithFormat:@"%@%@", str, @"sharp"] withFontSize:80 withOffset:vec2() ];
        [texture_manager generateTextureForText:[NSString stringWithFormat:@"%@%C", str, 0x266D] 
                                         forKey:[NSString stringWithFormat:@"%@%@", str, @"flat"] withFontSize:80 withOffset:vec2() ];
        [texture_manager generateTextureForText:str forKey:str withFontSize:80 withOffset:vec2()];
    }
    NSArray *flatminors = [NSArray arrayWithObjects:@"A", @"E", @"B",nil ];
    NSArray *minors = [NSArray arrayWithObjects:@"Fm", @"Cm", @"Gm", @"Dm", @"Am", @"Em", @"Bm",nil ]; 
    NSArray *sharpminors = [NSArray arrayWithObjects:@"F", @"C", @"G", @"D", @"A", nil];
    
    for(NSString *str in sharpminors) {
        [texture_manager generateTextureForText:[NSString stringWithFormat:@"%@%Cm", str, 0x266F] 
                                         forKey:[NSString stringWithFormat:@"%@%@m", str, @"sharp"] withFontSize:80 withOffset:vec2() ];
    }
    
    for(NSString *str in flatminors) {
        [texture_manager generateTextureForText:[NSString stringWithFormat:@"%@%Cm", str, 0x266D] 
                                         forKey:[NSString stringWithFormat:@"%@%@m", str, @"flat"] withFontSize:80 withOffset:vec2() ];
    }
    
    for(NSString *str in minors) {
        [texture_manager generateTextureForText:str forKey:str withFontSize:80 withOffset:vec2()];
    }
    
    
    /*
    //NSString *rest_str = [NSString stringWithFormat:@"%C%C", 0xD834, 0xDD3D];
    NSString *rest_str = [NSString stringWithFormat:@"%C", 0x0001D13D];

    [texture_manager generateTextureForText:rest_str forKey:@"rest" withFontName:@"Symbola" withFontSize:80 withOffset:vec2() ];
    */
    [texture_manager generateTextureForText:@"Twinkle"];
    
    [texture_manager generateTextureForText:@"Copy"];
    [texture_manager generateTextureForText:@"Paste"];
    
    [texture_manager generateTextureForText:@"Major"];
    [texture_manager generateTextureForText:@"Minor"];
    
    [texture_manager generateTextureForText:@"Affect All"];
    [texture_manager generateTextureForText:@"Affect New"];
    
    [texture_manager generateTextureForText:@"Paint Mode"];
    [texture_manager generateTextureForText:@"Assign Mode"];
    
    [texture_manager generateTextureForText:@"Spin Mode"];
    [texture_manager generateTextureForText:@"Move Mode"];
    
    [texture_manager generateTextureForText:@"Pane Unlocked"];
    [texture_manager generateTextureForText:@"Pane Locked"];
    
    [texture_manager generateTextureForText:@"Save"];
    [texture_manager generateTextureForText:@"Load"];
     
    simulation = [[MainBounceSimulation alloc] initWithAspect:aspect];
    simulation.delegate = self;
    lastUpdate = [[NSProcessInfo processInfo] systemUptime];
    
    _configPane = [[BounceConfigurationPane alloc] initWithBounceSimulation:simulation];
    _saveLoadPane = [[BounceSaveLoadPane alloc] initWithBounceSimulation:simulation];

    NSLog(@"loaded textures and created simulation\n");
    
    glFlush();
    
    [aContext release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingResources" object:nil];
}

-(void)saveSimulation {
    [saveView show];
}

-(void)loadSimulation:(NSString *)file {
    BounceFileManager *fileManager = [BounceFileManager instance];
    
    if([fileManager fileExists:file]) {
        BounceSavedSimulation *load = [fileManager loadFile:file];
        if(load) {
            [[BounceSettings instance] updateSettings:load.settings];
            [_configPane updateSettings];
            [_saveLoadPane updateSettings];
            
            _configPane.simulation = load.simulation;
            _saveLoadPane.simulation = load.simulation;
            [simulation release];
            simulation = [load.simulation retain];
            simulation.delegate = self;
        } else {
            // TODO do invalid file
        }
    } else {
        // TODO do file does not exist
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
    [_saveLoadPane release];
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
    
    if(![_configPane singleTap:gesture at:loc] && ![_saveLoadPane singleTap:gesture at:loc]) {
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
                        // TODO do are you sure you want to overwrite?
                    } else {
                        [fileManager save:simulation withSettings:[BounceSettings instance] toFile:file];
                        [_saveLoadPane updateSavedSimulations];
                    }
                }
                break;
        }

    }
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
    
    if(![_configPane beginDrag:gesture at:loc] && ![_saveLoadPane beginDrag:gesture at:loc]) {
        [simulation beginDrag:gesture at:loc];
    }
}

-(void)longTouch:(FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    if(![_configPane longTouch:gesture at:loc] && ![_saveLoadPane longTouch:gesture at:loc]) {
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
    if(![_configPane flick:gesture at:loc2 inDirection:dir time:time] && ![_saveLoadPane flick:gesture at:loc2 inDirection:dir time:time]) {
        [simulation flick:gesture at:loc2 inDirection:dir time:time];
    }
}

-(void)drag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    [gestureCurves drag:gesture at:loc];

    if(![_configPane drag:gesture at:loc] && ![_saveLoadPane drag:gesture at:loc]) {
        [simulation drag:gesture at:loc];
    }
}

-(void)endDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    [gestureCurves endDrag:gesture at:loc];

    if(![_configPane endDrag:gesture at:loc] && ![_saveLoadPane endDrag:gesture at:loc]) {
        [simulation endDrag:gesture at:loc];
    }
}

-(void)cancelDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.beginLocation);
    vec2 loc2(gesture.location);
    [self pixels2sim:loc];
    [self pixels2sim:loc2];
    
    [gestureCurves cancelDrag:gesture at:loc];

    if(![_configPane cancelDrag:gesture at:loc2] && ![_saveLoadPane cancelDrag:gesture at:loc2]) {
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

    if(_ready) {
        NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
        NSTimeInterval timeSinceLastDraw = now-lastUpdate;

        lastUpdate = now;
        
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
            [_saveLoadPane addToVelocity:add_to_vel];
        }
        
        vec2 g(acceleration.x, acceleration.y);
        [simulation setGravity:g];
        [_configPane setGravity:g];
        [_saveLoadPane setGravity:g];
                
        float t = timeSinceLastDraw+_timeRemainder;
        if(t > 5*_dt) {
            t = 5*_dt;
        }
        
        while(t >= _dt) {
            [simulation step:_dt];
            [_configPane step:_dt];
            [_saveLoadPane step:_dt];
            t -= _dt;
        }
        
        _timeRemainder = t;
        
        [simulation draw];
        [_saveLoadPane draw];
        [_configPane draw];
        
        [gestureCurves step:timeSinceLastDraw];
        [gestureCurves draw];
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

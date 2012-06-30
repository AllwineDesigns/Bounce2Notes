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
#import "FSAUtil.h"
#import "MainBounceSimulation.h"

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
    sharegroup = aContext.sharegroup;
	[aContext release];
    NSLog(@"%@", [[UIDevice currentDevice] model]);
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
        
    alertView = [[UIAlertView alloc] initWithTitle:@"Upgrade to full version" message:@"You must have the full version to create more balls." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Buy!", @"Dismiss All",  nil];
    dismissAllUpgradeAlerts = NO;
    
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startAccelerometerUpdates];
    
    CGRect frame = [self.view frame];
    aspect = frame.size.width/frame.size.height;
    
    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    
    FSAShader *objectShader = [shaderManager getShader:@"SingleObjectShader"];
    FSAShader *stationaryShader = [shaderManager getShader:@"SingleObjectStationaryShader"];
    FSAShader *killBoxShader = [shaderManager getShader:@"BounceKillBoxShader"];
    FSAShader *colorShader = [shaderManager getShader:@"ColorShader"];

    [objectShader setPtr:&aspect forUniform:@"aspect"];
    [stationaryShader setPtr:&aspect forUniform:@"aspect"];
    [killBoxShader setPtr:&aspect forUniform:@"aspect"];  
    [colorShader setPtr:&aspect forUniform:@"aspect"];    

    cacheQueue = [[NSOperationQueue alloc] init];
    
    NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadTextures) object:nil];
    [cacheQueue addOperation:invocation];
    [invocation release];
    
    
    
//    FSAAudioPlayer *player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c_1", @"d_1", @"e_1", @"f_1", @"g_1", @"a_1", @"b_1", @"c_2", @"d_2", @"e_2", @"f_2", @"g_2", @"a_2", @"b_2", @"c_3", @"d_3", @"e_3", @"f_3", @"g_3", @"a_3", @"b_3", @"c_4", nil] volume:10];

    multiTapAndDragRecognizer = [[FSAMultiTapAndDragRecognizer alloc] initWithTarget:self];
    multiTapAndDragRecognizer.view = self.view;
    
    animating = FALSE;
    animationFrameInterval = 2;
    self.displayLink = nil;
}

-(void)loadTextures {
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
     @"checkered.jpg", 
     @"sections.jpg", 
     @"squares.jpg", 
     @"weave.jpg", 
     @"ball.jpg",
     @"square.jpg",
     @"triangle.jpg",
     @"pentagon.jpg",
     @"rectangle.jpg",
     @"stationary_ball.png",
     @"stationary_square.png",
     @"stationary_triangle.png",
     @"stationary_pentagon.png",
     nil];
    for(NSString* texName in texturesToCache) {
        [texture_manager addLargeTexture:texName];
    }
    
    [texture_manager getTexture:@"arrow.jpg"];
    [texture_manager getTexture:@"downarrow.jpg"];
     

    simulation = [[MainBounceSimulation alloc] initWithAspect:aspect];
    lastUpdate = [[NSDate alloc] init];

    NSLog(@"loaded textures and created simulation\n");
 //   while(1) {}
    
    [aContext release];
}

- (void)dealloc
{
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [alertView release];
    [lastUpdate release];
    [context release];
    [simulation release];
    
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
    
    [simulation singleTapAt:loc];
}

-(void)displayUpgradeAlert {
    if(!dismissAllUpgradeAlerts) {
        [alertView show];
    }
}

-(void)alertView: (UIAlertView*)view clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 2:
            dismissAllUpgradeAlerts = YES;
        case 0:    
            break;
            
        default:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/bounce!!/id530767513?ls=1&mt=8"]];
            break;
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
//    NSLog(@"cancel three finger drag\n");
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    /*
    switch(gesture.side) {
        case FSA_TOP:
            if(simulation->isRemovingBallsTop()) {
                simulation->endRemovingBallsTop();
            }
            break;
        case FSA_BOTTOM:
            if(simulation->isRemovingBallsBottom()) {
                simulation->endRemovingBallsBottom();
            }
            break;
        case FSA_LEFT:
            if(simulation->isRemovingBallsLeft()) {
                simulation->endRemovingBallsLeft();
            }
            break;
        case FSA_RIGHT:
            if(simulation->isRemovingBallsRight()) {
                simulation->endRemovingBallsRight();
            }
            break;
            
    }
     */

}


-(void)beginDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.beginLocation);
    [self pixels2sim:loc];
    [simulation beginDrag:gesture at:loc];

}

-(void)longTouch:(FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    [simulation longTouch:gesture at:loc];
}

-(void)flick: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    vec2 loc2(gesture.beginLocation);
    [self pixels2sim:loc2];
    
    vec2 dir = loc-loc2;
    NSTimeInterval time = gesture.timestamp-gesture.beginTimestamp;
    
    [simulation flickAt:loc2 inDirection:dir time:time];
}

-(void)drag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    [simulation drag:gesture at:loc];
}

-(void)endDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.beginLocation);
    [self pixels2sim:loc];
    
    [simulation endDrag:gesture at:loc];
}

-(void)cancelDrag: (FSAMultiGesture*)gesture {
    vec2 loc(gesture.beginLocation);
    [self pixels2sim:loc];

    [simulation cancelDrag:gesture at:loc];
}

- (void)viewWillAppear:(BOOL)animated
{
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

        [lastUpdate release];
        lastUpdate = [[NSDate alloc] init];
        
        
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
    glClear(GL_COLOR_BUFFER_BIT);

    if([cacheQueue operationCount] == 0) {
        NSTimeInterval timeSinceLastDraw = -[lastUpdate timeIntervalSinceNow];

        [lastUpdate release];
        lastUpdate = [[NSDate alloc] init];
        
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
        }
        [simulation setGravity:accel];
        [simulation step:timeSinceLastDraw];
        [simulation draw];
    }

    [(EAGLView *)self.view presentFramebuffer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if([cacheQueue operationCount] == 0) {
        [multiTapAndDragRecognizer touchesBegan:touches withEvent:event];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if([cacheQueue operationCount] == 0) {
        [multiTapAndDragRecognizer touchesMoved:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([cacheQueue operationCount] == 0) {
        [multiTapAndDragRecognizer touchesEnded:touches withEvent:event];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if([cacheQueue operationCount] == 0) {
        [multiTapAndDragRecognizer touchesCancelled:touches withEvent:event];
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


@end

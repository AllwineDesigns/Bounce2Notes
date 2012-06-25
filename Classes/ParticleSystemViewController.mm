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
//#import "BounceObjectShader.h"
#import "FSATextureManager.h"

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
    {
        aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
    NSLog(@"%@", [[UIDevice currentDevice] model]);
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    lastUpdate = [[NSDate alloc] init];
    
    alertView = [[UIAlertView alloc] initWithTitle:@"Upgrade to full version" message:@"You must have the full version to create more balls." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Buy!", @"Dismiss All",  nil];
    dismissAllUpgradeAlerts = NO;
    
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startAccelerometerUpdates];
    
    CGRect frame = [self.view frame];
    aspect = frame.size.width/frame.size.height;
        
//    psystem = new BasicParticleSystem();
//    shader = [[BasicParticleShader alloc] initWithParticleSystem:psystem];
//    simulation = new ChipmunkSimulation(aspect);
    float invaspect = 1./aspect;
    
    CGRect simulationRect = CGRectMake(-1,-invaspect, 2, 2*invaspect);
//    BounceObjectShader *objectShader = [[BounceObjectShader alloc] initWithAspect:aspect];
    
    _objectShader = [[FSAShader alloc] initWithShaderPaths:@"SingleObjectShader" fragShader:@"SingleObjectShader"];
    [_objectShader setPtr:&aspect forUniform:@"aspect"];
    
    _stationaryShader = [[FSAShader alloc] initWithShaderPaths:@"SingleObjectStationaryShader" fragShader:@"SingleObjectStationaryShader"];
    [_stationaryShader setPtr:&aspect forUniform:@"aspect"];
    
    simulation = [[BounceSimulation alloc] initWithRect:simulationRect audioDelegate:self objectShader:_objectShader stationaryShader:_stationaryShader];
    
//    [objectShader release];
    
//    shader = [[ChipmunkSimulationShader alloc] initWithChipmunkSimulation:simulation aspect:aspect];
//    stationaryShader = [[ChipmunkSimulationStationaryShader alloc] initWithChipmunkSimulation:simulation aspect:aspect];
    
//    killBoxShader = [[BounceKillBoxShader alloc] initWithChipmunkSimulation:simulation aspect:aspect];

//    multiGestureRecognizer = [[FSAMultiGestureRecognizer alloc] initWithTarget:self];
//    [self.view addGestureRecognizer:multiGestureRecognizer];
    
//    [multiGestureRecognizer release];
    
    FSATextureManager *texture_manager = [FSATextureManager instance];
    [texture_manager getTexture:@"ball.jpg"];
    [texture_manager getTexture:@"square.jpg"];
    [texture_manager getTexture:@"triangle.jpg"];
    [texture_manager getTexture:@"spiral.jpg"];
    [texture_manager getTexture:@"stationary_ball.png"];
    [texture_manager getTexture:@"stationary_square.png"];
    [texture_manager getTexture:@"stationary_triangle.png"];
    
    FSAAudioPlayer *player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c_1", @"d_1", @"e_1", @"f_1", @"g_1", @"a_1", @"b_1", @"c_2", @"d_2", @"e_2", @"f_2", @"g_2", @"a_2", @"b_2", @"c_3", @"d_3", @"e_3", @"f_3", @"g_3", @"a_3", @"b_3", @"c_4", nil] volume:10];

    
    multiTapAndDragRecognizer = [[FSAMultiTapAndDragRecognizer alloc] initWithTarget:self];
    multiTapAndDragRecognizer.view = self.view;
  //  [self.view addGestureRecognizer:multiTapAndDragRecognizer];
  //  [multiTapAndDragRecognizer release];
    
    animating = FALSE;
    animationFrameInterval = 2;
    self.displayLink = nil;
}

-(void)playSound: (int)note volume: (float)vol {
    NSLog(@"play sound %d at volume %f\n", note, vol);
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
    
//    [shader release];
//    [stationaryShader release];
//    [killBoxShader release];
//    delete psystem;
//    delete simulation;
    
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
//    NSLog(@"single tap\n");
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    [simulation singleTapAt:loc];

    /*
    if(!simulation->isBallParticipatingInGestureAt(loc)) {
        if(simulation->isBallAt(loc)) {
            simulation->removeBallAt(loc);
        } else {
            
#ifdef BOUNCE_LITE
            if(simulation->numBalls() < BOUNCE_LITE_MAX_BALLS) {
                simulation->addBallAt(loc);
            } else {
                [self displayUpgradeAlert];
            }
#else
            simulation->addBallAt(loc);
#endif
        }
    }
     */
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
    //NSLog(@"begin three finger drag\n");
    vec2 loc(gesture.location);
    vec2 loc2(gesture.beginLocation);
    [self pixels2sim:loc];
    [self pixels2sim:loc2];
/*
    if(!simulation->isRemovingBalls()) {
        switch(gesture.side) {
            case FSA_TOP:
                simulation->beginRemovingBallsTop(loc.y);
                break;
            case FSA_BOTTOM:
                simulation->beginRemovingBallsBottom(loc2.y);
                break;
            case FSA_LEFT:
                simulation->beginRemovingBallsLeft(loc.x);
                break;
            case FSA_RIGHT:
                simulation->beginRemovingBallsRight(loc2.x);
                break;
                
        }
    }
 */
}

-(void)threeFingerDrag: (FSAMultiGesture*)gesture {
  //  NSLog(@"three finger drag\n");
    vec2 loc(gesture.location);
    vec2 loc2(gesture.beginLocation);
    [self pixels2sim:loc];
    [self pixels2sim:loc2];

    /*
    switch(gesture.side) {
        case FSA_TOP:
            if(simulation->isRemovingBallsTop()) {
                simulation->updateRemovingBallsTop(loc.y);
            }
            break;
        case FSA_BOTTOM:
            if(simulation->isRemovingBallsBottom()) {
                simulation->updateRemovingBallsBottom(loc2.y);
            }
            break;
        case FSA_LEFT:
            if(simulation->isRemovingBallsLeft()) {
                simulation->updateRemovingBallsLeft(loc.x);
            }
            break;
        case FSA_RIGHT:
            if(simulation->isRemovingBallsRight()) {
                simulation->updateRemovingBallsRight(loc2.x);
            }
            break;
            
    }
     */

}

-(void)endThreeFingerDrag: (FSAMultiGesture*)gesture {
  //  NSLog(@"end three finger drag\n");
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
//    NSLog(@"begin drag\n");
    vec2 loc(gesture.beginLocation);
    [self pixels2sim:loc];
    [simulation beginDrag:gesture at:loc];
    /*
    if(simulation->isBallBeingCreatedOrGrabbedAt(loc)) {
        simulation->beginTransformingBallAt(loc, gesture);
    } else if(simulation->isBallAt(loc) && !simulation->isBallBeingTransformedAt(loc)) {
        simulation->beginGrabbingBallAt(loc, gesture);
    }
     */
}

-(void)longTouch:(FSAMultiGesture*)gesture {
//    NSLog(@"long hold\n");

    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    [simulation longTouch:gesture at:loc];
    
    /*
    if(simulation->isTransformingBall(gesture)) {
        simulation->makeTransformingBallStationary(loc, gesture);
    } else if(simulation->isGrabbingBall(gesture)) {
        simulation->grabbingBallAt(loc, vec2(0,0), gesture);
        simulation->makeStationary(loc, gesture);
    } else if(simulation->isCreatingBall(gesture)) {
        simulation->beginGrabbing(loc, gesture);
    } else {
        
#ifdef BOUNCE_LITE
        if(simulation->numBalls() < BOUNCE_LITE_MAX_BALLS) {
            simulation->createStationaryBallAt(loc, gesture);
        } else {
            [self displayUpgradeAlert];
        }
#else
        simulation->createStationaryBallAt(loc, gesture);
        
#endif
    }
     */
}

-(void)flick: (FSAMultiGesture*)gesture {
//    NSLog(@"flick\n");
    vec2 loc(gesture.location);
    [self pixels2sim:loc];
    
    vec2 loc2(gesture.beginLocation);
    [self pixels2sim:loc2];
    
    vec2 dir = loc-loc2;
    NSTimeInterval time = gesture.timestamp-gesture.beginTimestamp;
    
    [simulation flickAt:loc2 inDirection:dir time:time];

    /*
     vec2 vel = (loc-loc2);

    vel *= 100*(gesture.timestamp-gesture.beginTimestamp);
    if(simulation->isStationaryBallAt(loc2)) {
        simulation->addVelocityToBallAt(loc2, vel);
    } else if(simulation->anyBallsAt(loc2, .1)) {
        simulation->addVelocityToBallsAt(loc2, vel, .3);
    } else {
#ifdef BOUNCE_LITE
        if(simulation->numBalls() < BOUNCE_LITE_MAX_BALLS) {
            simulation->addBallWithVelocity(loc2, vel);
        } else {
            [self displayUpgradeAlert];
        }
#else
        simulation->addBallWithVelocity(loc2, vel);

#endif
    }
     */
}

-(void)drag: (FSAMultiGesture*)gesture {
//    NSLog(@"drag\n");
    vec2 loc(gesture.beginLocation);
    [self pixels2sim:loc];
    vec2 loc2(gesture.location);
    [self pixels2sim:loc2];
    vec2 endLoc(loc2);
    loc2 -= loc;
    
    [simulation drag:gesture at:endLoc];
    /*
    float radius = loc2.length() > 1 ? 1 : loc2.length();
    radius = radius <= .01 ? .01 : radius;
    
    vec2 vel(gesture.velocity);
    [self vectorPixels2sim:vel];
    
    vel *= 50;
    
    if(simulation->isTransformingBall(gesture)) {
        simulation->transformBallAt(endLoc, gesture);
    } else if(simulation->isGrabbingBall(gesture)) {
        simulation->grabbingBallAt(endLoc, vel, gesture);
    } else  {
#ifdef BOUNCE_LITE
        if(simulation->numBalls() < BOUNCE_LITE_MAX_BALLS || simulation->isCreatingBall(gesture)) {
            simulation->creatingBallAt(loc, endLoc, gesture);

        } else {
            [self displayUpgradeAlert];
        }
#else
        simulation->creatingBallAt(loc, endLoc, gesture);        
#endif
    }
     */

}

-(void)endDrag: (FSAMultiGesture*)gesture {
//    NSLog(@"end drag\n");
    vec2 loc(gesture.beginLocation);
    [self pixels2sim:loc];
    
    vec2 vel(gesture.velocity);
    [self vectorPixels2sim:vel];
    [simulation endDrag:gesture at:loc];
    /*
    vel *= 50;

    if(simulation->isTransformingBall(gesture)) {
        simulation->beginGrabbingTransformingBall(gesture);
    } else if(simulation->isCreatingBall(gesture)) {
        simulation->createBall(gesture);
    } else if(simulation->isGrabbingBall(gesture)) {
        simulation->releaseBall(vel, gesture);

    }
     */
}

-(void)cancelDrag: (FSAMultiGesture*)gesture {
 //   NSLog(@"cancel drag\n");
    vec2 loc(gesture.beginLocation);
    [self pixels2sim:loc];
    
    vec2 vel(gesture.velocity);
    [self vectorPixels2sim:vel];
    [simulation cancelDrag:gesture at:loc];
    /*
    vel *= 50;
    
    if(simulation->isTransformingBall(gesture)) {
        simulation->beginGrabbingTransformingBall(gesture);
    } else if(simulation->isCreatingBall(gesture)) {
        simulation->cancelBall(gesture);
    } else if(simulation->isGrabbingBall(gesture)) {
        simulation->releaseBall(vel, gesture);
    }
     */
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
//        simulation->addToVelocity(add_to_vel);
    }
    
//    psystem->setAcceleration(accel);
//    psystem->step(timeSinceLastDraw);
//    simulation->setGravity(accel);
//    simulation->step(timeSinceLastDraw);
    [simulation setGravity:accel];
    [simulation step:timeSinceLastDraw];
    [simulation draw];
    
//    [shader updateAndDraw];
//    [stationaryShader updateAndDraw];
//    [killBoxShader updateAndDraw];
    
    

    [(EAGLView *)self.view presentFramebuffer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [multiTapAndDragRecognizer touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [multiTapAndDragRecognizer touchesMoved:touches withEvent:event];

}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [multiTapAndDragRecognizer touchesEnded:touches withEvent:event];

}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [multiTapAndDragRecognizer touchesCancelled:touches withEvent:event];

}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


@end

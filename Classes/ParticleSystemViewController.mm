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
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    lastUpdate = [[NSDate alloc] init];
    
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startAccelerometerUpdates];
    
//    psystem = new BasicParticleSystem();
//    shader = [[BasicParticleShader alloc] initWithParticleSystem:psystem];
    simulation = new ChipmunkSimulation();
    shader = [[ChipmunkSimulationShader alloc] initWithChipmunkSimulation:simulation];

    animating = FALSE;
    animationFrameInterval = 2;
    self.displayLink = nil;
}

- (void)dealloc
{
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [lastUpdate release];
    [context release];
    [shader release];
//    delete psystem;
    delete simulation;
    
    [super dealloc];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"In touchesBegan - event: %@\n\n\n", event);
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"In touchesMoved - event: %@\n\n\n", event);
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"In touchesEnded - event: %@\n\n\n", event);
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"In touchesCancelled - event: %@\n\n\n", event);
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
        simulation->addToVelocity(add_to_vel);
    }
    
//    psystem->setAcceleration(accel);
//    psystem->step(timeSinceLastDraw);
    simulation->setGravity(accel);
    simulation->step(timeSinceLastDraw);
    [shader updateAndDraw];

    [(EAGLView *)self.view presentFramebuffer];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


@end

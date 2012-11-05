//
//  BounceSettingsSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 7/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSettingsSimulation.h"
#import "BounceConstants.h"
#import "FSAShaderManager.h"
#import "BounceNoteManager.h"
#import "FSATextureManager.h"
#import "BounceSettings.h"
#import "BounceShapeGenerator.h"
#import "BounceConfigurationObject.h"
#import "BounceSizeGenerator.h"
#import "FSAUtil.h"

@implementation BounceSettingsSimulation

-(void)setupMusicSliders {
    NSArray *labels = [NSArray arrayWithObjects:@"Cflat", @"Gflat", @"Dflat", @"Aflat", @"Eflat", @"Bflat", @"F", @"C", @"G", @"D", @"A", @"E", @"B", @"Fsharp", @"Csharp", nil];
    
    CGSize dimensions = self.arena.dimensions;
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels index:7];
    [slider.handle setPosition:vec2(-2,0)];
    slider.handle.bounceShape = BOUNCE_BALL;
    slider.handle.size = dimensions.height*.08;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    
    [slider.track setPosition:vec2(-2,0)];
    slider.track.size = dimensions.width*.375;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    
    slider.delegate = self;
    slider.selector = @selector(changedMusicSlider:);
    slider.padding = dimensions.width*.05;
    
    [slider addToSimulation:self];
    _keySlider = slider;
    
    labels = [NSArray arrayWithObjects:@"Major", @"Minor", nil];
    slider = [[BounceSlider alloc] initWithLabels:labels index:0];
    [slider.handle setPosition:vec2(-2,0)];
    slider.handle.bounceShape = BOUNCE_RECTANGLE;
    slider.handle.size = dimensions.height*.1;
    slider.handle.secondarySize = dimensions.height*.06;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    
    [slider.track setPosition:vec2(-2,0)];
    slider.track.size = dimensions.width*.05;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    [[FSATextureManager instance] addTextTexture:@"major_minor"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"major_minor"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    
    slider.delegate = self;
    slider.selector = @selector(changedMusicSlider:);
    slider.padding = dimensions.width*.02;
    
    
    [slider addToSimulation:self];
    _tonalitySlider = slider;
    
    labels = [NSArray arrayWithObjects:@"Play Mode", @"Create Mode", nil];
    slider = [[BounceSlider alloc] initWithLabels:labels index:1];
    [slider.handle setPosition:vec2(-2,0)];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = dimensions.height*.1;
    slider.handle.secondarySize = dimensions.height*.06;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    
    [slider.track setPosition:vec2(-2,0)];
    slider.track.size = dimensions.width*.05;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    [[FSATextureManager instance] addTextTexture:@"play_mode"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"play_mode"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    
    slider.delegate = self;
    slider.selector = @selector(changedMusicSlider:);
    slider.padding = dimensions.width*.02;
    
    [slider addToSimulation:self];
    _modeSlider = slider;
    
    
    labels = [NSArray arrayWithObjects:@"Octave 2", @"Octave 3", @"Octave 4", @"Octave 5", @"Octave 6", nil]; 
    NSArray *values = [NSArray arrayWithObjects:
                       [NSNumber numberWithUnsignedInt:2], 
                       [NSNumber numberWithUnsignedInt:3],
                       [NSNumber numberWithUnsignedInt:4], 
                       [NSNumber numberWithUnsignedInt:5], 
                       [NSNumber numberWithUnsignedInt:6], nil];
    slider = [[BounceSlider alloc] initWithLabels:labels values:values index:2];
    [slider.handle setPosition:vec2(-2,0)];
    slider.handle.bounceShape = BOUNCE_BALL;
    slider.handle.size = dimensions.height*.08;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    
    [slider.track setPosition:vec2(-2,0)];
    slider.track.size = dimensions.width*.375;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    [[FSATextureManager instance] addTextTexture:@"octave"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"octave"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    
    slider.delegate = self;
    slider.selector = @selector(changedMusicSlider:);
    slider.padding = dimensions.width*.05;
    
    [slider addToSimulation:self];
    _octaveSlider = slider;
    
}

-(void)setColor:(const vec4 &)color {
    [super setColor:color];
    for(BounceObject *obj in _noteConfigObjects) {
        [obj setColor:color];
    }
}

-(void)setupFrictionSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Frictionless", @"Smooth", @"Coarse", @"Rough", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],
                       [NSNumber numberWithFloat:.1],
                       [NSNumber numberWithFloat:.5],
                       [NSNumber numberWithFloat:.9], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:2];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .4*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    [[FSATextureManager instance] addTextTexture:@"friction"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"friction"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    slider.delegate = self;
    slider.selector = @selector(changedFrictionSlider:);
    slider.padding = .07*dimensions.width;
    
    _updatingSettings = NO;

    [slider addToSimulation:self];
    
    _frictionSlider = slider;
}

-(void)setupVelLimitSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Stopped", @"Slow", @"Fast", @"Very Fast", @"No Limit", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],
                       [NSNumber numberWithFloat:1],
                       [NSNumber numberWithFloat:10],
                       [NSNumber numberWithFloat:40],
                       [NSNumber numberWithFloat:999999], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:2];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .4*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    [[FSATextureManager instance] addTextTexture:@"vel_limit"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"vel_limit"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    slider.delegate = self;
    slider.selector = @selector(changedVelLimitSlider:);
    slider.padding = .07*dimensions.width;

    [slider addToSimulation:self];
    
    _velLimitSlider = slider;
}


-(void)setupDampingSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Vacuum", @"Air", @"Water", @"Syrup", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1],
                       [NSNumber numberWithFloat:.9],
                       [NSNumber numberWithFloat:.01],
                       [NSNumber numberWithFloat:.001], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:0];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .4*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    [[FSATextureManager instance] addTextTexture:@"damping"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"damping"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    slider.delegate = self;
    slider.selector = @selector(changedDampingSlider:);
    slider.padding = .07*dimensions.width;

    [slider addToSimulation:self];
    
    _dampingSlider = slider;
}

-(void)setupShapesSlider {
    CGSize dimensions = self.arena.dimensions;

    NSArray *labels = [NSArray arrayWithObjects:@"Circle", @"Square", @"Triangle", @"Pentagon", @"Star", @"Rectangle", @"Capsule", @"Note", @"Random", nil];
    NSArray *values = [NSArray arrayWithObjects:[[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_BALL],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_SQUARE],                     
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_TRIANGLE],                       
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_PENTAGON],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_STAR],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_RECTANGLE],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_CAPSULE],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_NOTE],
                       [[BounceRandomShapeGenerator alloc] init], nil];
    
    for(BounceShapeGenerator *v in values) {
        [v release];
    }
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    slider.handle.bounceShape = [slider.value bounceShape];
    slider.handle.size = .145*dimensions.height;
    slider.handle.secondarySize = .145*dimensions.height*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .4*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedShapesSlider:);
    slider.padding = .05*dimensions.width;

    [slider addToSimulation:self];
    
    _shapesSlider = slider;
}

-(void)setupColorSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Pastel", @"Red", @"Orange", @"Yellow", @"Green", @"Blue", @"Purple", @"Gray", @"Random", nil];
    NSArray *values = [NSArray arrayWithObjects:[[BouncePastelColorGenerator alloc] init],
                       [[BounceRedColorGenerator alloc] init],
                       [[BounceOrangeColorGenerator alloc] init],
                       [[BounceYellowColorGenerator alloc] init],
                       [[BounceGreenColorGenerator alloc] init],
                       [[BounceBlueColorGenerator alloc] init],
                       [[BouncePurpleColorGenerator alloc] init],
                       [[BounceGrayColorGenerator alloc] init], 
                       [[BounceRandomColorGenerator alloc] init], nil];
    
    for(BounceColorGenerator *c in values) {
        [c release];
    }
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    slider.handle.bounceShape = BOUNCE_BALL;
    slider.handle.size = .145*dimensions.height;
    slider.handle.secondarySize = .145*dimensions.height*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .4*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedColorSlider:);
    slider.padding = .05*dimensions.width;

    [slider addToSimulation:self];
    
    _colorSlider = slider;
}

-(void)setupPatternsSlider {
    CGSize dimensions = self.arena.dimensions;
    FSATextureManager *texManager = [FSATextureManager instance];
    
    NSArray *labels = [NSArray arrayWithObjects:@"", /*@"",*/ @"", @"", @"", @"", /*@"",*/ @"", @"", @"", nil];
    NSArray *values = [NSArray arrayWithObjects:
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"spiral.jpg"]],
                      // [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"checkered.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"plasma.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"sections.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"weave.jpg"]], 
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"stripes.jpg"]], 
                      // [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"squares.jpg"]],    
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"black.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"white.jpg"]], 
                       [[BounceRandomPatternGenerator alloc] init], nil];
    
    for(id v in values) {
        [v release];
    }
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    slider.handle.bounceShape = BOUNCE_BALL;
    slider.handle.size = .145*dimensions.height;
    slider.handle.secondarySize = .145*dimensions.height*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .4*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [slider.value patternTexture];
    slider.delegate = self;
    slider.selector = @selector(changedPatternsSlider:);
    slider.padding = .05*dimensions.width;

    
    [slider addToSimulation:self];
    
    _patternsSlider = slider;
}

-(void)setupSizeSlider {
    CGSize dimensions = self.arena.dimensions;
        
    NSArray *labels = [NSArray arrayWithObjects:@"Teeny", @"Tiny", @"Small", @"Medium", @"Large", @"Random", nil];
    NSArray *values;

    
    NSString *device = machineName();
    if([device hasPrefix:@"iPad"]) {
       values = [NSArray arrayWithObjects:[[BounceSizeGenerator alloc] initWithSize:.03],
           [[BounceSizeGenerator alloc] initWithSize:.05],
           [[BounceSizeGenerator alloc] initWithSize:.1],
           [[BounceSizeGenerator alloc] initWithSize:.15],
           [[BounceSizeGenerator alloc] initWithSize:.2],
           [[BounceRandomSizeGenerator alloc] init],
           nil];
    } else {
        float mult = 1.5;
        values = [NSArray arrayWithObjects:[[BounceSizeGenerator alloc] initWithSize:mult*.03],
                  [[BounceSizeGenerator alloc] initWithSize:mult*.05],
                  [[BounceSizeGenerator alloc] initWithSize:mult*.1],
                  [[BounceSizeGenerator alloc] initWithSize:mult*.15],
                  [[BounceSizeGenerator alloc] initWithSize:mult*.2],
                  [[BounceRandomSizeGenerator alloc] init],
                  nil];

    }
    
    for(NSObject *v in values) {
        [v release];
    }
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:5];
    slider.handle.bounceShape = BOUNCE_BALL;
    CGSize size = [(BounceSizeGenerator*)slider.value size];
    slider.handle.size = size.width;
    slider.handle.secondarySize = size.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .4*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedSizeSlider:);
    slider.padding = .05*dimensions.width;

    [slider addToSimulation:self];
    
    _sizeSlider = slider;
}

-(BounceSlider*)allNewSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Affect All", @"Affect New", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                       [NSNumber numberWithBool:NO], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    
    slider.handle.position = vec2(-2,0);
    slider.handle.bounceShape = BOUNCE_CAPSULE;    
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .1*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.padding = .015*dimensions.width;
    [[FSATextureManager instance] addTextTexture:@"all_new"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"all_new"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    slider.delegate = self;
    
    [slider addToSimulation:self];
    
    return slider;
}

-(void)changedAffectsAllObjectsSlider:(BounceSlider *)slider {
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    [BounceSettings instance].affectAllObjects = [slider.value boolValue];
    /*
    if([slider.value boolValue] && !_updatingSettings) {
        [self changedBouncinessSlider:_bouncinessSlider];
        [self changedColorSlider:_colorSlider];
        [self changedDampingSlider:_dampingSlider];
        [self changedFrictionSlider:_frictionSlider];
        [self changedGravitySlider:_gravitySlider];
        [self changedPatternsSlider:_patternsSlider];
        [self changedSizeSlider:_sizeSlider];
        [self changedVelLimitSlider:_velLimitSlider];
        [self changedShapesSlider:_shapesSlider];
    }*/
}

-(void)setupAllNewSliders {
    _affectsAllObjectsSlider = [self allNewSlider];
    _affectsAllObjectsSlider.selector = @selector(changedAffectsAllObjectsSlider:);
}

-(void)setupPaintModeSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Paint Mode", @"Assign Mode", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                       [NSNumber numberWithBool:NO], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    
    slider.handle.position = vec2(-2,0);
    slider.handle.bounceShape = BOUNCE_CAPSULE;    
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .1*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.padding = .015*dimensions.width;
    [[FSATextureManager instance] addTextTexture:@"paint_mode"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"paint_mode"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    slider.delegate = self;
    slider.selector = @selector(changedPaintModeSlider:);
    
    [slider addToSimulation:self];
    
    _paintModeSlider = slider;
}

-(void)setupGrabRotatesSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Spin Mode", @"Move Mode", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                       [NSNumber numberWithBool:NO], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    
    slider.handle.position = vec2(-2,0);
    slider.handle.bounceShape = BOUNCE_CAPSULE;    
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .1*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.padding = .015*dimensions.width;
    [[FSATextureManager instance] addTextTexture:@"spin_mode"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"spin_mode"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    slider.delegate = self;
    slider.selector = @selector(changedGrabRotatesSlider:);
    
    [slider addToSimulation:self];
    
    _grabRotatesSlider = slider;
}

-(void)setupPaneUnlockedSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Pane Locked", @"Pane Unlocked", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO],
                       [NSNumber numberWithBool:YES], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    
    slider.handle.position = vec2(-2,0);
    slider.handle.bounceShape = BOUNCE_CAPSULE;    
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .1*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.padding = .015*dimensions.width;
    [[FSATextureManager instance] addTextTexture:@"pane_locked"];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"pane_locked"];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];

    slider.delegate = self;
    slider.selector = @selector(changedPaneUnlockedSlider:);
    
    [slider addToSimulation:self];
    
    _paneUnlockedSlider = slider;
}

-(void)setupCopyPaste {
    FSATextureManager *texManager = [FSATextureManager instance];
    vec4 color = vec4(.5,.5,.5,1);

    BouncePasteConfigurationObject * pasteObject = [[BouncePasteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -2) withVelocity:vec2() withColor:color withSize:.15 withAngle:0];
    [pasteObject addToSimulation:self];
    pasteObject.patternTexture = [texManager getTexture:@"Paste"];
    [pasteObject release];
    _pasteObject = pasteObject;
    
    BounceCopyConfigurationObject *copyObject = [[BounceCopyConfigurationObject alloc] initWithPasteObject:pasteObject];
    
    copyObject.patternTexture = [texManager getTexture:@"Copy"];
    [copyObject addToSimulation:self];
    [copyObject release];
    _copyObject = copyObject;
    
    CGSize size = self.arena.dimensions;
    CGRect rect = CGRectMake(-size.width*.5, -size.height*.5, size.width, size.height);

    _copyPasteArena = [[BounceArena alloc] initWithRect:rect];
    [_copyPasteArena addToSpace:_space];
}

-(void)setupMusicBounceObjects {
    float size = .15;
    
    BounceSimulation *sim = self;
    BounceNoteManager *noteManager = [BounceNoteManager instance];
    FSATextureManager *texManager = [FSATextureManager instance];
    
    vec4 color;
    
    float small = .04;
    float big = .15;
    
    // float small = .06;
    // float big = .2;
    float t;
    int notes = 8;
    
    float aspect = [[BounceConstants instance] aspect];
    float invaspect = 1./aspect;
    
    NSMutableArray *noteConfigObjects = [[NSMutableArray alloc] initWithCapacity:8];
    
    BounceNoteConfigurationObject * configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    [configObject addToSimulation:sim];
    configObject.sound = [noteManager getNote:0];
    t = 0./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:configObject.sound.label];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    configObject.sound = [noteManager getNote:1];
    t = 1./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:configObject.sound.label];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    configObject.sound = [noteManager getNote:2];
    t = 2./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:configObject.sound.label];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    configObject.sound = [noteManager getNote:3];
    t = 3./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:configObject.sound.label];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    configObject.sound = [noteManager getNote:4];
    t = 4./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:configObject.sound.label];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    configObject.sound = [noteManager getNote:5];
    t = 5./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:configObject.sound.label];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    configObject.sound = [noteManager getNote:6];
    t = 6./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:configObject.sound.label];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    configObject.sound = [noteManager getNote:7];
    t = 7./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:configObject.sound.label];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [noteConfigObjects addObject:configObject];
    configObject.sound = [noteManager getRest];
    configObject.size = .08;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:@"rest.png"];
    // [configObject setPatternForTextureSheet:@"music_texture_sheet.jpg" row:4 col:1 numRows:5 numCols:5];
    [configObject addToSimulation:sim];

    [configObject release];
    
    _buffer = [[ChipmunkObject alloc] initStatic];
    [_buffer addSegmentShapeWithRadius:50 fromA:vec2(-50,0) toB:vec2(50,0)];
    [_buffer addToSpace:_space];
    
    CGSize s = self.arena.dimensions;
    CGRect rect = CGRectMake(-s.width*.5, -s.height*.5, s.width, s.height);
    _musicArena = [[BounceArena alloc] initWithRect:rect];
    [_musicArena addToSpace:_space];
     
    _noteConfigObjects = noteConfigObjects;
}


-(void)setupPages {
    CGSize dimensions = self.arena.dimensions;
    _pages = [[BouncePages alloc] initWithPageWidth:dimensions.width pageHeight:dimensions.height];
    float spacing = .15 *dimensions.height;
    float tspacing = .25 *dimensions.height;
    
    BouncePage *page = [[BouncePage alloc] init];
    [page addWidget:_shapesSlider offset:vec2(0,tspacing)];
    [page addWidget:_patternsSlider offset:vec2(0,-spacing)];
    cpLayers layers = (1 << [_pages count]);
    [_shapesSlider.handle setLayers:layers];
    [_shapesSlider.track setLayers:layers];
    [_patternsSlider.handle setLayers:layers];
    [_patternsSlider.track setLayers:layers];
    [_pages addPage:page];
    [page release];

    
    page = [[BouncePage alloc] init];
    [page addWidget:_colorSlider offset:vec2(0,tspacing)];
    [page addWidget:_sizeSlider offset:vec2(0, -spacing)];
    
    layers = (1 << [_pages count]);
    [_colorSlider.handle setLayers:layers];
    [_colorSlider.track setLayers:layers];
    [_sizeSlider.handle setLayers:layers];
    [_sizeSlider.track setLayers:layers];

    [_pages addPage:page];
    [page release];
     

    page = [[BouncePage alloc] init];
    [page addWidget:_bouncinessSlider offset:vec2(0,tspacing)];
    [page addWidget:_gravitySlider offset:vec2(0,-spacing)];
    layers = (1 << [_pages count]);
    [_bouncinessSlider.handle setLayers:layers];
    [_bouncinessSlider.track setLayers:layers];
    [_gravitySlider.handle setLayers:layers];
    [_gravitySlider.track setLayers:layers];    
    [_pages addPage:page];
    [page release];
  
    
    page = [[BouncePage alloc] init];
    [page addWidget:_dampingSlider offset:vec2(0,tspacing)];
    [page addWidget:_velLimitSlider offset:vec2(0,-spacing)];
    layers = (1 << [_pages count]);
    [_dampingSlider.handle setLayers:layers];
    [_dampingSlider.track setLayers:layers];
    [_velLimitSlider.handle setLayers:layers];
    [_velLimitSlider.track setLayers:layers];   
    [_pages addPage:page];
    [page release];

    page = [[BouncePage alloc] init];
    [page addWidget:_frictionSlider offset:vec2(0,tspacing)];
    layers = (1 << [_pages count]);
    [_frictionSlider.handle setLayers:layers];
    [_frictionSlider.track setLayers:layers];  
    [_pages addPage:page];
    [page release];
    
    page = [[BouncePage alloc] init];
    [page addWidget:_affectsAllObjectsSlider offset:vec2(-.2*dimensions.width,tspacing)];
    [page addWidget:_paneUnlockedSlider offset:vec2(.2*dimensions.width,tspacing)];
    [page addWidget:_paintModeSlider offset:vec2(-.2*dimensions.width,-spacing)];
    [page addWidget:_grabRotatesSlider offset:vec2(.2*dimensions.width,-spacing)];
    layers = (1 << [_pages count]);
    [_affectsAllObjectsSlider.handle setLayers:layers];
    [_affectsAllObjectsSlider.track setLayers:layers];  
    
    [_paneUnlockedSlider.handle setLayers:layers];
    [_paneUnlockedSlider.track setLayers:layers];  
    
    [_paintModeSlider.handle setLayers:layers];
    [_paintModeSlider.track setLayers:layers];  
    
    [_grabRotatesSlider.handle setLayers:layers];
    [_grabRotatesSlider.track setLayers:layers];  

    [_pages addPage:page];
    [page release];
    
    page = [[BouncePage alloc] init];
    [page addWidget:_copyPasteArena offset:vec2()];
    layers = (1 << [_pages count]);
    cpLayers copyPasteLayers = layers;
    [_copyPasteArena setLayers:layers];
    [_copyObject setLayers:layers];
    [_pasteObject setLayers:layers];
    [_pages addPage:page];
    [page release];
    
    float slideDown = -.07*dimensions.height;
    page = [[BouncePage alloc] init];
    layers = (1 << [_pages count]);
    cpLayers musicLayers = layers;
    [page addWidget:_musicArena offset:vec2()];
    [page addWidget:_buffer offset:vec2(0,50+dimensions.height*.2+slideDown)];
    [page addWidget:_keySlider offset:vec2(-.075*dimensions.width,dimensions.height*.2+slideDown)];
    [page addWidget:_octaveSlider offset:vec2(-.075*dimensions.width,dimensions.height*.4+slideDown)];
    [page addWidget:_tonalitySlider offset:vec2(.4*dimensions.width,dimensions.height*.2+slideDown)];
    [page addWidget:_modeSlider offset:vec2(.4*dimensions.width, dimensions.height*.4+slideDown)];
    
    [_musicArena setLayers:layers];
    [_buffer setLayers:layers];
    [_keySlider setLayers:layers];
    [_octaveSlider setLayers:layers];
    [_tonalitySlider setLayers:layers];
    [_modeSlider setLayers:layers];
    
    for(BounceObject *obj in _noteConfigObjects) {
        [obj setLayers:layers];
    }
    
    [_pages addPage:page];
    [page release];
    
    cpLayers mainArenaLayers = CP_ALL_LAYERS ^ copyPasteLayers ^ musicLayers;

    [_arena setLayers:mainArenaLayers];
}

-(void)updateConfigObjects {
    
    float small = .04;
    float big = .12;
    BounceNoteManager *noteManager = [BounceNoteManager instance];
    for(unsigned int i = 0; i < 8; i++) {
        BounceNoteConfigurationObject *obj = [_noteConfigObjects objectAtIndex:i];
        BounceNote *note = [noteManager getNote:i];
        
        if(note != [noteManager getRest]) {
            obj.sound = note;
            obj.patternTexture = [[FSATextureManager instance] getTexture:obj.sound.label];
            // float t = (float)(8*(noteManager.octave-2)+i)/(39);
            // t *= t;
            float t = (float)i/7;
            obj.size = (t*small+(1-t)*big)+(.04-(noteManager.octave-2)*.01);
            
            if(![obj hasBeenAddedToSimulation]) {
                [obj addToSimulation:self];
            }
        } else {
            if([obj hasBeenAddedToSimulation]) {
                [obj removeFromSimulation];
            }
        }
        
    }
}

-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    
    if(self) {
        CGSize dimensions = self.arena.dimensions;
        NSArray *bouncinessLabels = [NSArray arrayWithObjects:@"Rigid",  @"Squishy", @"Springy",@"Bouncy", nil];
        NSArray *bouncinessValues = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:.5], [NSNumber numberWithFloat:.9], [NSNumber numberWithFloat:1], nil];
        _bouncinessSlider = [[BounceSlider alloc] initContinuousWithLabels:bouncinessLabels values:bouncinessValues index:1];
        _bouncinessSlider.handle.bounceShape = BOUNCE_CAPSULE;
        _bouncinessSlider.handle.size = .2*dimensions.height;
        _bouncinessSlider.handle.secondarySize = .1*dimensions.height;
        _bouncinessSlider.handle.isStationary = NO;

        _bouncinessSlider.handle.sound = [[BounceNoteManager instance] getRest];

        _bouncinessSlider.track.position = vec2(-2,0);
        _bouncinessSlider.track.size = .4*dimensions.width;
        _bouncinessSlider.track.isStationary = NO;

        _bouncinessSlider.track.sound = [[BounceNoteManager instance] getRest];
        [[FSATextureManager instance] addTextTexture:@"bounciness"];
        _bouncinessSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"bounciness"];

        _bouncinessSlider.delegate = self;
        _bouncinessSlider.selector = @selector(changedBouncinessSlider:);
        _bouncinessSlider.padding = .07*dimensions.width;

        [_bouncinessSlider addToSimulation:self];
        
        NSArray *gravityLabels = [NSArray arrayWithObjects:@"Weightless", @"Airy", @"Floaty", @"Light", @"Normal", @"Heavy", nil];
        NSArray *gravityValues = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0], 
                                  [NSNumber numberWithFloat:.05], 
                                  [NSNumber numberWithFloat:1], 
                                  [NSNumber numberWithFloat:4], 


                                  [NSNumber numberWithFloat:10], 
                                  [NSNumber numberWithFloat:40],
                                  nil];
        _gravitySlider = [[BounceSlider alloc] initContinuousWithLabels:gravityLabels values:gravityValues index:4];
        _gravitySlider.handle.bounceShape = BOUNCE_CAPSULE;
        _gravitySlider.handle.size = .2*dimensions.height;
        _gravitySlider.handle.secondarySize = .1*dimensions.height;
        _gravitySlider.handle.sound = [[BounceNoteManager instance] getRest];
        _gravitySlider.handle.isStationary = NO;


        _gravitySlider.track.position = vec2(-2,0);
        _gravitySlider.track.size = .4*dimensions.width;
        _gravitySlider.track.sound = [[BounceNoteManager instance] getRest];
        _gravitySlider.track.isStationary = NO;

        [[FSATextureManager instance] addTextTexture:@"gravity"];
        _gravitySlider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"gravity"];
        
        _gravitySlider.delegate = self;
        _gravitySlider.selector = @selector(changedGravitySlider:);
        _gravitySlider.padding = .07*dimensions.width;

        [_gravitySlider addToSimulation:self];
        
        [self setupShapesSlider];
        [self setupPatternsSlider];
        [self setupDampingSlider];
        [self setupVelLimitSlider];
        [self setupFrictionSlider];
        [self setupColorSlider];
        [self setupSizeSlider];
        [self setupAllNewSliders];
        [self setupPaintModeSlider];
        [self setupGrabRotatesSlider];
        [self setupPaneUnlockedSlider];
        [self setupCopyPaste];
        [self setupMusicSliders];
        [self setupMusicBounceObjects];
        [self setupPages];
        
        unsigned int numPages = [_pages count];
        NSMutableArray *pageLabels = [NSMutableArray arrayWithCapacity:[_pages count]]; 
        for(int i = 0; i < numPages; i++) {
            [pageLabels addObject:@""];
        }
        _pageSlider = [[BounceSlider alloc] initWithLabels:pageLabels index:0];
        _pageSlider.handle.bounceShape = BOUNCE_CAPSULE;
        _pageSlider.handle.size = .04*dimensions.width;
        _pageSlider.handle.secondarySize = .04*[[BounceConstants instance] unitsPerInch];
        _pageSlider.handle.sound = [[BounceNoteManager instance] getRest];
        _pageSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
        _pageSlider.handle.isStationary = NO;
        
        _pageSlider.padding = _pageSlider.handle.size+.005;

        
        
        _pageSlider.track.position = vec2(-2,0);
        _pageSlider.track.size = .35*dimensions.width;
        _pageSlider.track.secondarySize = _pageSlider.handle.secondarySize*1.2;
        
        _pageSlider.track.sound = [[BounceNoteManager instance] getRest];
        _pageSlider.track.patternTexture = [[FSATextureManager instance] getTexture:@"black.jpg"];
        _pageSlider.track.isStationary = NO;
        _pageSlider.handle.renderable.blendMode = GL_ONE;
        _pageSlider.track.renderable.blendMode = GL_ONE;
        
        _pageSlider.delegate = self;
        _pageSlider.selector = @selector(changedPageSlider:);
        [_pageSlider addToSimulation:self];
        [_pageSlider.handle setLayers:CP_ALL_LAYERS];
        [_pageSlider.track setLayers:CP_ALL_LAYERS];

    }
    
    return self;
}

-(void)tapObject:(BounceObject *)obj at:(const vec2 &)loc {
    if([obj isKindOfClass:[BounceNoteConfigurationObject class]] && [BounceSettings instance].playMode) {
        [obj.sound play:.2];
        [obj singleTapAt:loc];
    } else {
        [super tapObject:obj at:loc];
    }
}

-(void)setAngle:(float)angle {
    [super setAngle:angle];
    [_pages setAngle:angle];
    [_pageSlider setAngle:angle];
}

-(void)setAngVel:(float)angVel {
    [super setAngVel:angVel];
    [_pages setAngVel:angVel];
    [_pageSlider setAngVel:angVel];
}

-(BOOL)respondsToGesture:(void *)uniqueId {
    if(_sliding == uniqueId) {
        return YES;
    }
    return [super respondsToGesture:uniqueId];
}

-(void)flick:(void *)uniqueId at:(const vec2 &)loc inDirection:(const vec2 &)dir time:(NSTimeInterval)time {
    
    if(_sliding == uniqueId) {
        
        BouncePaneSideInfo info = [_pane.object getSideInfo];
        
        vec2 v = dir;
        vec2 parallel = info.dir*info.dir.dot(v);
        vec2 perp = v-parallel;
        vec2 h = info.dir;
        h.rotate(M_PI_2);
        float horizontal = h.dot(perp);
        
        BOOL horizontalFlick = perp.length() > parallel.length();
        
        NSLog(@"horizontalFlick: %u\n", horizontalFlick);
        NSLog(@"horizontal: %f\n", horizontal);

        
        if(horizontalFlick) {
            if(horizontal > 0) {
                [_pages previousPage];
            } else if(horizontal < 0) {
                [_pages nextPage];
            }
        }
        _pageSlider.index = _pages.currentPage;
    }
    [super flick:uniqueId at:loc inDirection:dir time:time];
}

-(void)beginDrag:(void *)uniqueId at:(const vec2 &)loc {
    if(!_sliding && ![self objectAt:loc]) {
        _sliding = uniqueId;
        _beginSlidingPos = loc;
    }
    [super beginDrag:uniqueId at:loc];
}

-(void)drag:(void *)uniqueId at:(const vec2 &)loc {
    if(_sliding == uniqueId) {
        BouncePaneSideInfo info = [_pane.object getSideInfo];
        
        vec2 v = loc-_beginSlidingPos;
        vec2 parallel = info.dir*info.dir.dot(v);
        vec2 perp = v-parallel;
        vec2 h = info.dir;
        h.rotate(M_PI_2);
        float horizontal = h.dot(perp);
        _pages.touchOffset = horizontal;
    }

    [super drag:uniqueId at:loc];
}

-(void)endDrag:(void *)uniqueId at:(const vec2 &)loc {
    if(_sliding == uniqueId) {
        CGSize dimensions = self.arena.dimensions;
        
        BouncePaneSideInfo info = [_pane.object getSideInfo];
        
        vec2 v = loc-_beginSlidingPos;
        vec2 parallel = info.dir*info.dir.dot(v);
        vec2 perp = v-parallel;
        
        vec2 h = info.dir;
        h.rotate(M_PI_2);
        float horizontal = h.dot(perp);
        
        if(horizontal > dimensions.width*.5) {
            [_pages previousPage];
        } else if(horizontal < -dimensions.width*.5) {
            [_pages nextPage];
        }
        _pageSlider.index = _pages.currentPage;

        _pages.touchOffset = 0;
        _sliding = 0;
    }
    [super endDrag:uniqueId at:loc];
}

-(void)cancelDrag:(void *)uniqueId at:(const vec2 &)loc {
    if(_sliding == uniqueId) {
        _sliding = 0;
        _pages.touchOffset = 0;
    }
    [super cancelDrag:uniqueId at:loc];
}

-(void)changedBouncinessSlider:(BounceSlider *)slider {
    [BounceSettings instance].bounciness = [slider.value floatValue];
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation setBounciness:[slider.value floatValue]];
    }
    [_simulation.arena setBounciness:[slider.value floatValue]];
  //  [_pane setBounciness:[slider.value floatValue]];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    }
}

-(void)changedGravitySlider:(BounceSlider *)slider {
    [BounceSettings instance].gravityScale = [slider.value floatValue];
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation setGravityScale:[slider.value floatValue]];
    }
 //   [_pane setGravityScale:[slider.value floatValue]];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    }
}

-(void)changedPatternsSlider:(BounceSlider *)slider {
    BouncePatternGenerator *patternGen = slider.value;
    [BounceSettings instance].patternTextureGenerator = patternGen;
    [slider.handle.renderable burst:5];
    if([patternGen isKindOfClass:[BounceRandomPatternGenerator class]]) {
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"Random"];
    } else {
        slider.handle.patternTexture = [patternGen patternTexture];
    }
    
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation randomizePattern];
    }
}

-(void)changedShapesSlider:(BounceSlider *)slider {
    BounceShapeGenerator* shapeGen = slider.value;
    [BounceSettings instance].bounceShapeGenerator = shapeGen;
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    
    slider.handle.bounceShape = [shapeGen bounceShape];
    _patternsSlider.handle.bounceShape = [shapeGen bounceShape];
    _colorSlider.handle.bounceShape = [shapeGen bounceShape];
    _sizeSlider.handle.bounceShape = [shapeGen bounceShape];
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation randomizeShape];
    }
    [_pane randomizeShape];
}

-(void)changedDampingSlider:(BounceSlider *)slider {
    [BounceSettings instance].damping = [slider.value floatValue];
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation setDamping:[slider.value floatValue]];
    }
   // [_pane setDamping:[slider.value floatValue]];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    }
}

-(void)changedVelLimitSlider:(BounceSlider *)slider {
    [BounceSettings instance].velocityLimit = [slider.value floatValue];
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation setVelocityLimit:[slider.value floatValue]];
    }
  //  [_pane setVelocityLimit:[slider.value floatValue]];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    } 
}

-(void)changedFrictionSlider:(BounceSlider *)slider {
    [BounceSettings instance].friction = [slider.value floatValue];
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation setFriction:[slider.value floatValue]];
    }
    [_simulation.arena setFriction:[slider.value floatValue]];
   // [_pane setFriction:[slider.value floatValue]];
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    } 
}

-(void)changedColorSlider:(BounceSlider *)slider {
    [BounceSettings instance].colorGenerator = slider.value;
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    [slider.handle.renderable burst:5];
    [_pane randomizeColor];
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation randomizeColor];
    }
}

-(void)changedSizeSlider:(BounceSlider *)slider {
    [BounceSettings instance].sizeGenerator = slider.value;
    
    CGSize size = [(BounceSizeGenerator*)slider.value size];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.handle.size = size.width;
    slider.handle.secondarySize = size.height;
        
    if([BounceSettings instance].affectAllObjects && !_updatingSettings) {
        [_simulation randomizeSize];
    }
}

-(void)setVelocity:(const vec2 &)vel {
    [super setVelocity:vel];
    [_buffer setVelocity:vel];
    [_octaveSlider setVelocity:vel];
    [_keySlider setVelocity: vel];
    [_tonalitySlider setVelocity:vel];
    [_modeSlider setVelocity:vel];
    [_pageSlider.handle setVelocity:vel];
    [_pageSlider.track setVelocity:vel];
}

-(void)prepare {
    [self updateSettings];
    
    FSATextureManager *texManager = [FSATextureManager instance];
    
    [(FSATextTexture*)[texManager getTexture:@"major_minor"] setText:_tonalitySlider.label];
    [(FSATextTexture*)[texManager getTexture:@"play_mode"] setText:_modeSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"octave"] setText:_octaveSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"friction"] setText:_frictionSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"vel_limit"] setText:_velLimitSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"damping"] setText:_dampingSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"all_new"] setText:_affectsAllObjectsSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"paint_mode"] setText:_paintModeSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"spin_mode"] setText:_grabRotatesSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"pane_locked"] setText:_paneUnlockedSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"bounciness"] setText:_bouncinessSlider.label];
    [(FSATextTexture*)[texManager getTexture:@"gravity"] setText:_gravitySlider.label];
}

-(void)unload {
    FSATextureManager *texManager = [FSATextureManager instance];
    
    [(FSATextTexture*)[texManager getTexture:@"major_minor"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"play_mode"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"octave"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"friction"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"vel_limit"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"damping"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"all_new"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"paint_mode"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"spin_mode"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"pane_locked"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"bounciness"] setText:@""];
    [(FSATextTexture*)[texManager getTexture:@"gravity"] setText:@""];
}

-(void)updateSettings {
    _updatingSettings = YES;
    BounceSettings *settings = [BounceSettings instance];
    _affectsAllObjectsSlider.index = settings.affectAllObjects ? 0 : 1;
    
    _paneUnlockedSlider.index = settings.paneUnlocked ? 1 : 0;
    _grabRotatesSlider.index = settings.grabRotates ? 0 : 1;
    _paintModeSlider.index = settings.paintMode ? 0 : 1;
    
    _bouncinessSlider.value = [NSNumber numberWithFloat:settings.bounciness];
    _sizeSlider.value = settings.sizeGenerator;
    _shapesSlider.value = settings.bounceShapeGenerator;
    _patternsSlider.value = settings.patternTextureGenerator;
    _colorSlider.value = settings.colorGenerator;
    _dampingSlider.value = [NSNumber numberWithFloat:settings.damping];
    _gravitySlider.value = [NSNumber numberWithFloat:settings.gravityScale];
    _frictionSlider.value = [NSNumber numberWithFloat:settings.friction];
    _velLimitSlider.value = [NSNumber numberWithFloat:settings.velocityLimit]; 
    
    _modeSlider.index = settings.playMode ? 0 : 1;
    
    _updatingSettings = NO;
}

-(void)changedMusicSlider:(BounceSlider *)slider {
    
    BounceNoteManager *noteManager = [BounceNoteManager instance];
    [slider.handle.renderable burst:5];
    
    if(slider == _keySlider) {
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
        noteManager.key = slider.label;
        [self updateConfigObjects];
    } else if(slider == _tonalitySlider) {
        [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
        if([slider.label isEqualToString:@"Major"]) {
            [noteManager useMajorIntervals];
            NSArray *labels = [NSArray arrayWithObjects:@"Cflat", @"Gflat", @"Dflat", @"Aflat", @"Eflat", @"Bflat", @"F", @"C", @"G", @"D", @"A", @"E", @"B", @"Fsharp", @"Csharp", nil];
            [_keySlider setLabels:labels];
            
        } else if([slider.label isEqualToString:@"Minor"]) {
            [noteManager useMinorIntervals];
            NSArray *labels = [NSArray arrayWithObjects:@"Aflatm", @"Eflatm", @"Bflatm", @"Fm", @"Cm", @"Gm", @"Dm", @"Am", @"Em", @"Bm", @"Fsharpm", @"Csharpm", @"Gsharpm", @"Dsharpm", @"Asharpm", nil];
            [_keySlider setLabels:labels];
        }
    } else if(slider == _modeSlider) {
        [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
        [BounceSettings instance].playMode = [slider.value isEqualToString:@"Play Mode"];
    } else if(slider == _octaveSlider) {
        [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
        noteManager.octave = [slider.value unsignedIntValue];
        [self updateConfigObjects];  
    }
}

-(void)changedPageSlider:(BounceSlider *)slider {
    _pages.currentPage = slider.index;

}

-(void)changedPaintModeSlider:(BounceSlider*)slider {
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    [BounceSettings instance].paintMode = [slider.value boolValue];
}

-(void)changedGrabRotatesSlider:(BounceSlider*)slider {
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    [BounceSettings instance].grabRotates = [slider.value boolValue];
}

-(void)changedPaneUnlockedSlider:(BounceSlider*)slider {
    [(FSATextTexture*)slider.handle.patternTexture setText:slider.label];
    [BounceSettings instance].paneUnlocked = [slider.value boolValue];
    
    if([slider.value boolValue]) {
        _pane.object.springLoc = _pane.object.customSpringLoc;
    } else {
        _pane.object.springLoc = _pane.object.activeSpringLoc;
    }
}

-(void)changed: (BounceSlider*)slider {
    NSAssert(NO, @"all sliders in the settings simulation should have custom selectors\n");
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    
    CGSize dimensions = self.arena.dimensions;
    float spacing = .45 *dimensions.height;
    
    vec2 offset(0,-spacing);
    
    offset.rotate(-self.arena.angle);

    [_pageSlider setPosition:pos+offset];
     
    [_pages updatePositions:pos];

}

-(void)step:(float)dt {
    [_bouncinessSlider step:dt];
    [_gravitySlider step:dt];
    [_pageSlider step:dt];
    [_shapesSlider step:dt];
    [_patternsSlider step:dt];
    [_dampingSlider step:dt];
    [_velLimitSlider step:dt];
    [_frictionSlider step:dt];
    [_colorSlider step:dt];
    [_sizeSlider step:dt];
    [_affectsAllObjectsSlider step:dt];
    
    [_paintModeSlider step:dt];
    [_grabRotatesSlider step:dt];
    [_paneUnlockedSlider step:dt];
    
    [_octaveSlider step:dt];
    [_keySlider step:dt];
    [_tonalitySlider step:dt];
    [_modeSlider step:dt];

    BounceSettings *settings = [BounceSettings instance];

    vec2 l = _colorSlider.handle.position;
    float t = [[NSProcessInfo processInfo] systemUptime];
    _colorSlider.handle.color = [settings.colorGenerator perlinColorFromLocation:l time:t];
/*
    _timeSinceRandomsRefresh += _dt;
    
    if(_timeSinceRandomsRefresh > .5) {
        if([settings.bounceShapeGenerator isKindOfClass:[BounceRandomShapeGenerator class]]) {
            _shapesSlider.handle.bounceShape = [settings.bounceShapeGenerator bounceShape];
            _patternsSlider.handle.bounceShape = [settings.bounceShapeGenerator bounceShape];
            _colorSlider.handle.bounceShape = [settings.bounceShapeGenerator bounceShape];
        }
        _timeSinceRandomsRefresh = 0;
    } */
    [_pages step:dt];
    
    [super step:dt];
}

-(void)dealloc {
    [_bouncinessSlider release];
    [_gravitySlider release];
    [_pageSlider release];
    [_shapesSlider release];
    [_patternsSlider release];
    [_dampingSlider release];
    [_frictionSlider release];
    [_velLimitSlider release];
    [_colorSlider release];
    [_affectsAllObjectsSlider release];
    
    [_keySlider release];
    [_octaveSlider release];
    [_tonalitySlider release];
    [_modeSlider release];
    [_buffer removeFromSpace];
    [_buffer release];
    [_copyPasteArena removeFromSpace];
    [_copyPasteArena release];
    [_musicArena removeFromSpace];
    [_musicArena release];
    
    [_noteConfigObjects release];
    
    [_pages release];

    [super dealloc];
}
@end

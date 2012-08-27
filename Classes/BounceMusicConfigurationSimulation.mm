//
//  BounceMusicConfigurationSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 7/31/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceMusicConfigurationSimulation.h"
#import "BounceConfigurationObject.h"
#import "BounceConstants.h"
#import "BounceNoteManager.h"
#import "FSATextureManager.h"

@implementation BounceMusicConfigurationSimulation

-(void)setupRandomizeButton {
    CGSize dimensions = self.arena.dimensions;

    BounceButton *button = [[BounceButton alloc] init];
    button.patternTexture = [[FSATextureManager instance] getTexture:@"Randomize"];
    button.bounceShape = BOUNCE_CAPSULE;
    button.size = dimensions.width*.07;
    button.secondarySize = dimensions.height*.08;
    button.position = vec2(-2,0);
    button.sound = [[BounceNoteManager instance] getRest];
    
    button.delegate = self;
    
    [button addToSimulation:self];
    
    _randomizeButton = button;
}

-(void)setupSliders {
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
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    
    slider.delegate = self;
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
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    
    slider.delegate = self;
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
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    
    slider.delegate = self;
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

-(void)setupBounceObjects {
    float size = .15;
    
    BounceSimulation *sim = self;
    BounceNoteManager *noteManager = [BounceNoteManager instance];
    FSATextureManager *texManager = [FSATextureManager instance];
    
    vec4 color;
        
    float small = .04;
    float big = .15;
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
    configObject.sound = [noteManager getRest];
    configObject.size = .08;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:@"rest.png"];
   // [configObject setPatternForTextureSheet:@"music_texture_sheet.jpg" row:4 col:1 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
    
    _noteConfigObjects = noteConfigObjects;
}

-(void)tapObject:(BounceObject *)obj at:(const vec2 &)loc {
    if([obj isKindOfClass:[BounceNoteConfigurationObject class]] && _simulation.playMode) {
        [obj.sound play:.2];
        [obj singleTapAt:loc];
    } else {
        [super tapObject:obj at:loc];
    }
}

-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {
        
        [self setupBounceObjects];
        [self setupSliders];
        [self setupRandomizeButton];
        
        _buffer = [[ChipmunkObject alloc] initStatic];
        [_buffer addSegmentShapeWithRadius:50 fromA:vec2(-50,0) toB:vec2(50,0)];
        [_buffer addToSpace:_space];
        
    }
    return self;
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    CGSize dimensions = self.arena.dimensions;
    [_buffer setPosition:pos+vec2(0,50+dimensions.height*.2)];
    [_keySlider setPosition:pos+vec2(-.075*dimensions.width,dimensions.height*.2)]; 
    [_octaveSlider setPosition:pos+vec2(-.075*dimensions.width,dimensions.height*.4)];  

    [_tonalitySlider setPosition:pos+vec2(.4*dimensions.width,dimensions.height*.2)];
    [_modeSlider setPosition:pos+vec2(.4*dimensions.width, dimensions.height*.4)];
    [_randomizeButton setPosition:pos+vec2(.4*dimensions.width,0)];

}

-(void)setVelocity:(const vec2 &)vel {
    [super setVelocity:vel];
    [_buffer setVelocity:vel];
    [_octaveSlider setVelocity:vel];
    [_keySlider setVelocity: vel];
    [_tonalitySlider setVelocity:vel];
    [_modeSlider setVelocity:vel];
    [_randomizeButton setVelocity:vel];
}

-(void)next {
    [super next];
    [_octaveSlider step:_dt];
    [_keySlider step:_dt];
    [_tonalitySlider step:_dt];
    [_modeSlider step:_dt];
    [_randomizeButton step:_dt];
}

-(void)draw {
    [super draw];
    if([_simulation isInBounds:_octaveSlider.handle]) {
        [_keySlider draw];
        [_tonalitySlider draw];
        [_modeSlider draw];
        [_octaveSlider draw];
        [_randomizeButton draw];
    }

}

-(void)pressed:(BounceButton *)button {
    [_simulation randomizeNote];
}

-(void)changed:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    
    BounceNoteManager *noteManager = [BounceNoteManager instance];
    [slider.handle.renderable burst:5];

    if(slider == _keySlider) {
        noteManager.key = slider.label;
        [self updateConfigObjects];
    } else if(slider == _tonalitySlider) {
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
        _simulation.playMode = [slider.value isEqualToString:@"Play Mode"];
    } else if(slider == _octaveSlider) {
        noteManager.octave = [slider.value unsignedIntValue];
        [self updateConfigObjects];  
    }
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

-(void)dealloc {
    [_keySlider release];
    [_octaveSlider release];
    [_tonalitySlider release];
    [_modeSlider release];
    
    [_noteConfigObjects release];
    [_randomizeButton release];

    [super dealloc];
}

@end

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
#import "FSASoundManager.h"
#import "FSATextureManager.h"

@implementation BounceMusicConfigurationSimulation

-(void)setupSliders {
    NSArray *labels = [NSArray arrayWithObjects:@"Gflat", @"Dflat", @"Aflat", @"Eflat", @"Bflat", @"F", @"C", @"G", @"D", @"A", @"E", @"B", @"Fsharp", nil];
    
    CGSize dimensions = self.arena.dimensions;
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels index:6];
    [slider.handle setPosition:vec2(-2,0)];
    slider.handle.bounceShape = BOUNCE_BALL;
    slider.handle.size = dimensions.height*.08;
    slider.handle.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
    
    [slider.track setPosition:vec2(-2,0)];
    slider.track.size = dimensions.width*.4;
    slider.track.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    
    slider.delegate = self;
    slider.padding = dimensions.width*.1;
    
    [slider addToSimulation:self];
    _keySlider = slider;
    
    labels = [NSArray arrayWithObjects:@"Major", @"Minor", nil];
    slider = [[BounceSlider alloc] initWithLabels:labels index:0];
    [slider.handle setPosition:vec2(-2,0)];
    slider.handle.bounceShape = BOUNCE_SQUARE;
    slider.handle.size = dimensions.height*.08;
    slider.handle.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
    
    [slider.track setPosition:vec2(-2,0)];
    slider.track.size = dimensions.width*.2;
    slider.track.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    
    slider.delegate = self;
    slider.padding = dimensions.width*.1;

    
    [slider addToSimulation:self];
    _tonalitySlider = slider;
}

-(void)setupBounceObjects {
    float size = .15;
    
    BounceSimulation *sim = self;
    FSASoundManager *soundManager = [FSASoundManager instance];
    FSATextureManager *texManager = [FSATextureManager instance];
    
    vec4 color;
        
    float small = .08;
    float big = .15;
    float t;
    int notes = 8;
    
    float aspect = [[BounceConstants instance] aspect];
    float invaspect = 1./aspect;
    
    BounceNoteConfigurationObject * configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [configObject addToSimulation:sim];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"c_1" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    t = 0./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.patternTexture = [texManager getTexture:@"C"];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"d_1" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    t = 1./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.patternTexture = [texManager getTexture:@"D"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"e_1" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    t = 2./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.patternTexture = [texManager getTexture:@"E"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"f_1" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    t = 3./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.patternTexture = [texManager getTexture:@"F"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"g_1" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    t = 4./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.patternTexture = [texManager getTexture:@"G"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"a_1" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    t = 5./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.patternTexture = [texManager getTexture:@"A"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"b_1" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    t = 6./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.patternTexture = [texManager getTexture:@"B"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"c_2" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    t = 7./(notes-1);
    configObject.size = small*t+(1-t)*big;
    configObject.patternTexture = [texManager getTexture:@"C"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"rest" volume:BOUNCE_SOUND_VOLUME]] autorelease];
    configObject.size = small;
    [configObject setPatternForTextureSheet:@"music_texture_sheet.jpg" row:4 col:1 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
}

-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {
        
        [self setupBounceObjects];
        [self setupSliders];
        
    }
    return self;
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    CGSize dimensions = self.arena.dimensions;
    [_keySlider setPosition:pos+vec2(0,dimensions.height*.4)];  
    [_tonalitySlider setPosition:pos+vec2(0,dimensions.height*.2)];
}

-(void)setVelocity:(const vec2 &)vel {
    [super setVelocity:vel];
    [_keySlider setVelocity: vel];
    [_tonalitySlider setVelocity:vel];
}

-(void)next {
    [super next];
    [_keySlider step:_dt];
    [_tonalitySlider step:_dt];
}

-(void)draw {
    [super draw];
    [_keySlider draw];
    [_tonalitySlider draw];
}

-(void)changed:(BounceSlider *)slider {
    if(slider == _keySlider) {
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    } else if(slider == _tonalitySlider) {
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    }
}

-(void)dealloc {
    [_keySlider release];
    [_octaveSlider release];
    [_tonalitySlider release];
    [super dealloc];
}

@end

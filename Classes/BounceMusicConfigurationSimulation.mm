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
#import "BounceSettings.h"
#import "FSASoundManager.h"

@implementation BounceMusicConfigurationSimulation

-(void)setupBounceObjects {
    float size = .15;
    
    BounceSimulation *sim = self;
    FSATextureManager *texManager = [FSATextureManager instance];
    
    vec4 color;
    
    float aspect = [[BounceConstants instance] aspect];
    float invaspect = 1./aspect;
        
    BounceNoteConfigurationObject * configObject;
    
    FSASoundManager *soundManager = [FSASoundManager instance];
    NSArray *sounds = [NSArray arrayWithObjects:
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       nil];
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceSong alloc] initWithSounds:sounds label:@"Twinkle"] autorelease];
    configObject.size = .08;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:@"Twinkle"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    sounds = [NSArray arrayWithObjects:
              [soundManager getSound:@"c3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"c5.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"c6.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"d3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"d5.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"e3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"e5.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"g3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"g5.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"a3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"a5.caf" volume:BOUNCE_SOUND_VOLUME], 
          
                       nil];
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceRandomSounds alloc] initWithSounds:sounds label:@"Twinkle"] autorelease];
    configObject.size = .05;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:@"C"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceChordProgression alloc] init] autorelease];
    configObject.size = .15;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:@"C"];
    [configObject addToSimulation:sim];
    [configObject release];
}


-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {

        [self setupBounceObjects];
    }
    return self;
}

@end

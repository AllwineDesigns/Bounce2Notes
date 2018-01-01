//
//  BounceConfigurationPane.mm
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationPane.h"
#import "BounceConstants.h"
#import "FSAShaderManager.h"
#import "FSATextureManager.h"
#import "fsa/Noise.hpp"
#import "FSAUtil.h"
#import "BounceConfigurationSimulation.h"
#import "BounceConfigurationObject.h"
#import "FSASoundManager.h"
#import "BounceSettingsSimulation.h"
#import "BounceMusicConfigurationSimulation.h"
#import "BounceSettings.h"
#import "BounceSaveLoadSimulation.h"
#import "BounceHowToSimulation.h"
#import "BounceContributorsSimulation.h"

#define NUM_TABS 7

@implementation BounceConfigurationPane

-(void)addShapesSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceConfigurationSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    vec2 shapePos(0, -_invaspect-.5);
    float shapeSize = .15;
    float shapeSize2 = .09270476;
    
    BounceConfigurationObject *shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    shapeConfigObject.patternTexture = [texManager getTexture:@"Circle"];
    // [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:3 numRows:4 numCols:4];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_SQUARE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    // [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:1 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Square"];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_TRIANGLE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    //[shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:0 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Triangle"];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    
#ifndef BOUNCE_LITE
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_PENTAGON at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    //        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:2 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Pentagon"];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_STAR at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    //        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:2 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Star"];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_RECTANGLE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    shapeConfigObject.secondarySize = shapeSize2;
    shapeConfigObject.patternTexture = [[FSATextureManager instance] getTexture:@"Rectangle"];
    //   [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:1 col:0 numRows:4 numCols:4];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_CAPSULE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    shapeConfigObject.secondarySize = shapeSize2;
    //        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:1 col:1 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Capsule"];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
#endif
    
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_NOTE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    shapeConfigObject.patternTexture = [texManager getTexture:@"Note"];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    //NSLog(@"(%f, %f), (%f, %f)", [shapeConfigObject position].x, [shapeConfigObject position].y, [shapeConfigObject velocity].x, [shapeConfigObject velocity].y);
    
    //NSLog(@"in addShapesSimulation");
    [self addSimulation:sim];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, paneSize.width/NUM_TABS*GOLDEN_RATIO);
    
    vec2 offset(-1.5*tabSize.width-.1*paneSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Shapes"];
    [tab addToSimulation:_simulation];

    [_simulationTabs addObject:tab];
}

-(void)addPatternsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceConfigurationSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

    float shapeSize = .15;
    
    BouncePatternConfigurationObject * patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.2, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"black.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(.2, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"spiral.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
#ifndef BOUNCE_LITE
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(.5, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"stripes.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
#endif
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.4, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"white.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    /*
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"checkered.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
     */
    
#ifndef BOUNCE_LITE
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"plasma.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"sections.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"weave.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
#endif
    
    /*
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"squares.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
     */
    [self addSimulation:sim];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, paneSize.width/NUM_TABS*GOLDEN_RATIO);
    
    vec2 offset(-.5*tabSize.width-.1*paneSize.width, paneSize.height*.5+tabSize.height*.5);

    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    tab.patternTexture = [texManager getTexture:@"Patterns"];
    [tab addToSimulation:_simulation];
    [_simulationTabs addObject:tab];
}

-(void)addSizesSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceConfigurationSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

    
    BounceSizeConfigurationObject * configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() ];
    configObject.patternTexture = [texManager getTexture:@"Tiny"];
    configObject.size = .05;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];

    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.1, -_invaspect-.5) withVelocity:vec2() ];
    configObject.patternTexture = [texManager getTexture:@"Teeny"];
    configObject.size = .03;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.4, -_invaspect-.5) withVelocity:vec2() ];
    configObject.patternTexture = [texManager getTexture:@"Small"];

    configObject.size = .1;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(.4, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .15;
    configObject.patternTexture = [texManager getTexture:@"Medium"];

    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    configObject.patternTexture = [texManager getTexture:@"Large"];

    configObject.size = .2;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];
    
    [self addSimulation:sim];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, paneSize.width/NUM_TABS*GOLDEN_RATIO);

    vec2 offset(.5*tabSize.width+.1*paneSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Sizes"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addColorsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceConfigurationSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

    float size = .15;
    
    vec4 color = vec4(.8,0,0,1);
    BounceColorConfigurationObject * configObject = [[BounceRedColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [configObject addToSimulation:sim];
    configObject.patternTexture = [texManager getTexture:@"Red"];
    [configObject release];
    
    color = vec4(0,.5,0,1);
    configObject = [[BounceGreenColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Green"];

    [configObject addToSimulation:sim];
    [configObject release];
    
    color = vec4(0,0,.8,1);
    configObject = [[BounceBlueColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Blue"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    color = vec4(.8,.8,0,1);
    configObject = [[BounceYellowColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Yellow"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    color = vec4(.8,.4,0,1);
    configObject = [[BounceOrangeColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Orange"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    color = vec4(.6,0,.8,1);
    configObject = [[BouncePurpleColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Purple"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BouncePastelColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Pastel"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceGrayColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Gray"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    [self addSimulation:sim];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, paneSize.width/NUM_TABS*GOLDEN_RATIO);

    vec2 offset(1.5*tabSize.width+.1*paneSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Colors"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addContributorsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceConfigurationSimulation *sim = [[BounceContributorsSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    [self addSimulation:sim];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, paneSize.width/NUM_TABS*GOLDEN_RATIO);
    
    vec2 offset(-paneSize.width*.5-tabSize.width*.4, .5*tabSize.width);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Contributors"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addMusicSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    
    BounceConfigurationSimulation *sim = [[BounceMusicConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    [self addSimulation:sim];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/5, paneSize.width/5*GOLDEN_RATIO);

    vec2 offset(0, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Notes"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}


-(void)addSettingsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];

    BounceSettingsSimulation *sim = [[BounceSettingsSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    [self addSimulation:sim];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, paneSize.width/NUM_TABS*GOLDEN_RATIO);

    vec2 offset(paneSize.width*.5+tabSize.width*.4, .5*tabSize.width);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Advanced"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addSaveLoadSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    
    BounceConfigurationSimulation *sim = [[BounceSaveLoadSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    [self addSimulation:sim];
    [sim setPosition:self.object.position];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, paneSize.width/NUM_TABS*GOLDEN_RATIO);
    
    vec2 offset(paneSize.width*.5+tabSize.width*.4, -.5*tabSize.width);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Save/Load"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addHowToSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    
    BounceConfigurationSimulation *sim = [[BounceHowToSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    [self addSimulation:sim];
    [sim setPosition:self.object.position];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, paneSize.width/NUM_TABS*GOLDEN_RATIO);
    
    vec2 offset(-paneSize.width*.5-tabSize.width*.4, -.5*tabSize.width);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:(unsigned int)[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Help"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)updateSavedSimulations {
    [[_simulations objectAtIndex:6] updateSavedSimulations];
}

-(void)step:(float)dt {
    [super step:dt];
    
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
    int t = time;
    
    if(t%1 == 0 && _lastSwitch != t) {
        _lastSwitch = t;
        [(BounceMusicConfigurationSimulation*)[_simulations objectAtIndex:4] switchActiveChord];
    }
}


-(id)initWithBounceSimulation:(MainBounceSimulation *)simulation {
    self = [super initWithBounceSimulation:simulation];
    
    if(self) {
        [self addShapesSimulation];
        [self addPatternsSimulation];
        [self addSizesSimulation];
        [self addColorsSimulation];
        [self addMusicSimulation];
        [self addSettingsSimulation];
        [self addSaveLoadSimulation];
        [self addHowToSimulation];
        [self addContributorsSimulation];
        
        NSString *device = machineName();
        if(![device hasPrefix:@"iPad"]) {
            int i = 0;
            float scale = 1.3;
            for(BounceConfigurationTab *tab in _simulationTabs) {
                float size = tab.size;
                float size2 = tab.secondarySize;
                
                [tab setSize:size*scale secondarySize:size2*scale];
                
                vec2 offset = tab.offset;
                
                if(i < 5) {
                    offset.x *= scale;
                } else {
                    offset.y *= scale;
                }
                [tab setOffset:offset];
                i++;
            }
            
            i = 0;
            for(BounceSimulation *sim in _simulations) {
                if(i < 5) {
                    NSArray *objects = [sim objects];
                    for(BounceObject *obj in objects) {
                        float size = obj.size;
                        float size2 = obj.secondarySize;
                        if(i == 2 || i == 4) {
                            [obj setSize:size*1.5 secondarySize:size2*1.5];
                        } else {
                            [obj setSize:size*1.3 secondarySize:size2*1.3];
                        }
                    }
                }
                i++;
            }
        }

        
        [self setBounciness:.5];
    }
    
    return self;
}

-(void)issueContributorsRequest {
    [(BounceContributorsSimulation*)[_simulations objectAtIndex:8]  issueContributorsRequest];
}

-(void)prepareCurrentSimulation {
    [super prepareCurrentSimulation];
    
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    BounceSettings* settings = [BounceSettings instance];
    if(_curSimulation != 0 && _curSimulation != 5) {
        [sim setBounceShapesWithGenerator:settings.bounceShapeGenerator];
    }
    
  //  if(_curSimulation == 2) {
  //      [sim setPatternTexturesWithGenerator:settings.patternTextureGenerator];
  //  }
    
}

@end

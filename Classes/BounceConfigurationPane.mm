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

#define NUM_TABS 8

@implementation BounceConfigurationPaneObject 

@synthesize color = _color;
@synthesize paneSize = _paneSize;
@synthesize springLoc = _springLoc;
@synthesize tappedSpringLoc = _tappedSpringLoc;
@synthesize inactiveSpringLoc = _inactiveSpringLoc;
@synthesize activeSpringLoc = _activeSpringLoc;
@synthesize customSpringLoc = _customSpringLoc;

-(id)init {
    self = [super initStatic];
    if(self) {
        NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];

        BounceConstants *constants = [BounceConstants instance];
        
        _upi = constants.unitsPerInch;
        _aspect = constants.aspect;
        _invaspect = 1./_aspect;
        
        _paneSize.width = 1.8;
        _paneSize.height = _upi;
        
        NSString *device = machineName();
        if([device hasPrefix:@"iPad"]) {
            _paneSize.width = _upi*4;
            _paneSize.height = _upi*2.25;
        }
        
        vec4 color;
        HSVtoRGB(&(color.x), &(color.y), &(color.z), 
                 360.*random(64.28327*time), .4, .05*random(736.2827*time)+.75   );
        color.w = 1;
        _color = color;
        
        _tappedSpringLoc = vec2(0, -_invaspect-_paneSize.height*.5);
        _activeSpringLoc = vec2(0, -_invaspect+_paneSize.height*.5);
        _inactiveSpringLoc = vec2(0, -_invaspect-_paneSize.height);
        _customSpringLoc = _activeSpringLoc;
        
        _springLoc = _inactiveSpringLoc;
        
        [self setPosition:_inactiveSpringLoc];
        
        float top = _paneSize.height*.5;
        float bottom = -_paneSize.height*.5;
        float left = -_paneSize.width*.5;
        float right = _paneSize.width*.5;
        
        vec2 verts[4];
        verts[0] = vec2(right, top);
        verts[1] = vec2(right, bottom);
        verts[2] = vec2(left, bottom);
        verts[3] = vec2(left, top);
        
        [self addPolyShapeWithNumVerts:4 withVerts:verts withOffset:cpvzero];  
        
        cpShapeSetFriction(_shapes[0], .5);
        cpShapeSetElasticity(_shapes[0], .95);
        cpShapeSetCollisionType(_shapes[0], WALL_TYPE);
    }
    
    return self;
}

-(BOOL)isPaneAt:(const vec2&)loc {
    vec2 pos = self.position;
    
    float top = (pos.y+_paneSize.height*.5);
    float bottom = pos.y-_paneSize.height*.5;
    float left = pos.x-_paneSize.width*.5;
    float right = pos.x+_paneSize.width*.5;
    
    return loc.x >= left && loc.x <= right &&
    loc.y >= bottom && loc.y <= top;
}
-(void)randomizeColor {
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];

    _color = [[[BounceSettings instance] colorGenerator] randomColorFromTime:time];
}

-(void)tap {    
    _springLoc = _tappedSpringLoc;
}

-(void)activate {
    if([BounceSettings instance].paneUnlocked) {
        _springLoc = _customSpringLoc;
    } else {
        _springLoc = _activeSpringLoc;
    }
}

-(void)deactivate {
    _springLoc = _inactiveSpringLoc;
}

-(void)step:(float)dt {    
    float spring_k = 150;
    float drag = .15;
    
    vec2 pos = [self position];
    
    pos += _vel*dt;
    vec2 a = -spring_k*(pos-_springLoc);
    
    _vel +=  a*dt-drag*_vel;
    
    [self setPosition:pos];
    [self setVelocity:_vel];
}

-(void)draw {
    vec2 pos = [self position];
            
    float top = pos.y+_paneSize.height*.5;
    float bottom = pos.y-_paneSize.height*.5;
    float left = pos.x-_paneSize.width*.5;
    float right = pos.x+_paneSize.width*.5;
        
    vec2 verts[4];
    verts[0] = vec2(right, top);
    verts[1] = vec2(left, top);
    verts[2] = vec2(left, bottom);
    verts[3] = vec2(right, bottom);

    unsigned int indices[6];
    
    FSAShader *shader = [[FSAShaderManager instance] getShader:@"ColorShader"];
    [shader setPtr:verts forAttribute:@"position"];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 0;
    indices[4] = 2;
    indices[5] = 3;
    
    vec4 color(0,0,0,1);
    [shader setPtr:&color forUniform:@"color"];
    
    [shader enable];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, indices);
    [shader disable];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 3;
    indices[4] = 0;
    [shader setPtr:&_color forUniform:@"color"];

    [shader enable];
    glDrawElements(GL_LINE_STRIP, 5, GL_UNSIGNED_INT, indices);
    [shader disable];
}
@end

@implementation BounceConfigurationPane

@synthesize object = _object;

-(void)addShapesSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
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
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_NOTE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    shapeConfigObject.patternTexture = [texManager getTexture:@"Note"];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    [_simulations addObject:sim];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, .2*upi);
    
    vec2 offset(-paneSize.width*.5+tabSize.width*.5, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Shapes"];
    [tab addToSimulation:_simulation];

    [_simulationTabs addObject:tab];
}

-(void)addPatternsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

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
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(.5, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"stripes.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.4, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"white.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"checkered.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
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
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.secondarySize = patternConfigObject.size*GOLDEN_RATIO;
    patternConfigObject.patternTexture = [texManager getTexture:@"squares.jpg"];
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    [_simulations addObject:sim];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, .2*upi);
    
    vec2 offset(-paneSize.width*.5+1.5*tabSize.width, paneSize.height*.5+tabSize.height*.5);

    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    tab.patternTexture = [texManager getTexture:@"Patterns"];
    [tab addToSimulation:_simulation];
    [_simulationTabs addObject:tab];
}

-(void)addSizesSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

    
    BounceSizeConfigurationObject * configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .05;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];

    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.1, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .03;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.4, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .1;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(.4, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .15;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .2;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    [configObject addToSimulation:sim];
    [configObject release];
    
    [_simulations addObject:sim];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, .2*upi);

    vec2 offset(-paneSize.width*.5+2.5*tabSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Sizes"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addColorsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

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
    
    [_simulations addObject:sim];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, .2*upi);

    vec2 offset(paneSize.width*.5-4.5*tabSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Colors"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addMusicSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    
    BounceSimulation *sim = [[BounceMusicConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    [_simulations addObject:sim];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, .2*upi);

    vec2 offset(paneSize.width*.5-3.5*tabSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Notes"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addMiscSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    float size = .15;
    
    vec4 color = vec4(.5,.5,.5,1);
    BouncePasteConfigurationObject * pasteObject = [[BouncePasteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [pasteObject addToSimulation:sim];
    pasteObject.patternTexture = [texManager getTexture:@"Paste"];
    [pasteObject release];
    
    BounceCopyConfigurationObject *copyObject = [[BounceCopyConfigurationObject alloc] initWithPasteObject:pasteObject];
    
    copyObject.patternTexture = [texManager getTexture:@"Copy"];
    [copyObject addToSimulation:sim];
    [copyObject release];
    
    [_simulations addObject:sim];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, .2*upi);
    
    vec2 offset(paneSize.width*.5-2.5*tabSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Misc"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addSaveLoadSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    
//    BounceSettingsSimulation *sim = [[BounceSettingsSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

    [_simulations addObject:sim];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, .2*upi);
    
    vec2 offset(paneSize.width*.5-1.5*tabSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Save/Load"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addSettingsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];

    BounceSettingsSimulation *sim = [[BounceSettingsSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    sim.pane = self;
    
    [_simulations addObject:sim];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/NUM_TABS, .2*upi);

    vec2 offset(paneSize.width*.5-.5*tabSize.width, paneSize.height*.5+tabSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Settings"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}


-(id)initWithBounceSimulation:(BounceSimulation *)simulation {
    self = [super init];
    
    if(self) {
        BounceConstants *constants = [BounceConstants instance];
        
        _simulation = simulation;
        [simulation retain];

        _upi = constants.unitsPerInch;
        _aspect = constants.aspect;
        _invaspect = 1./_aspect;
        
        _state = BOUNCE_CONFIGURATION_PANE_DEACTIVATED;
        _object = [[BounceConfigurationPaneObject alloc] init];
        
        _simulations = [[NSMutableArray alloc] initWithCapacity:3];
        _simulationTabs = [[NSMutableArray alloc] initWithCapacity:3];
        _curSimulation = 0;
        _switchToSimulation = 0;
        
        CGSize size = _object.paneSize;
        _rect = CGRectMake(-size.width*.5, -size.height*.5, size.width, size.height);

        [self addShapesSimulation];
        [self addPatternsSimulation];
        [self addSizesSimulation];
        [self addColorsSimulation];
        [self addMusicSimulation];
        [self addMiscSimulation];
        [self addSaveLoadSimulation];
        [self addSettingsSimulation];

        
        [simulation addToSpace:_object];
    }
    
    return self;
}

-(void)randomizeShape {
    for(BounceConfigurationTab *tab in _simulationTabs) {
        tab.bounceShape = [[[BounceSettings instance] bounceShapeGenerator] bounceShape];
    }
}

-(void)randomizeColor {
    [_object randomizeColor];
    for(BounceConfigurationTab *tab in _simulationTabs) {
        vec4 color = [[[BounceSettings instance] colorGenerator] randomColor];
        [tab setColor:color];
    }
    BounceSimulation *miscSim = [_simulations objectAtIndex:5];
    for(BounceSimulation *sim in _simulations) {
        if(miscSim != sim) {
            [sim randomizeColor];
        }
    }
}

-(BOOL)isHandleAreaAt:(const vec2&)loc {
    CGSize s = [_object paneSize];
    return _state == BOUNCE_CONFIGURATION_PANE_DEACTIVATED &&
        loc.y < -_invaspect+.5*_upi && loc.x > -.5*s.width && loc.x < .5*s.width;
}

-(void)addToVelocity:(const vec2&)v {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    [sim addToVelocity:v];
}

-(void)setBounciness:(float)b {
    for(BounceSimulation *sim in _simulations) {
        [sim setBounciness:b];
    }
}

-(void)setFriction:(float)friction {
    for(BounceSimulation *sim in _simulations) {
        [sim setFriction:friction];
    }
}

-(void)setVelocityLimit:(float)limit {
    for(BounceSimulation *sim in _simulations) {
        [sim setVelocityLimit:limit];
    }
}

-(void)setDamping:(float)damping {
    for(BounceSimulation *sim in _simulations) {
        [sim setDamping:damping];
    }
}

-(void)setGravityScale:(float)s {
    for(BounceSimulation *sim in _simulations) {
        [sim setGravityScale:s];
    }
}

-(void)setGravity:(vec2)gravity {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    [sim setGravity:gravity];
}

-(void)prepareCurrentSimulation {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    BounceSettings* settings = [BounceSettings instance];
    
    if(_curSimulation != 0 && _curSimulation != 5) {
        [sim setBounceShapesWithGenerator:settings.bounceShapeGenerator];
    }
    
    if(_curSimulation == 2 && _curSimulation != 5) {
        [sim setPatternTexturesWithGenerator:settings.patternTextureGenerator];
    }
    
}

-(void)setCurrentSimulation:(unsigned int)index {
    if(_state == BOUNCE_CONFIGURATION_PANE_TAPPED) {        
        _switchToSimulation = index;
        _curSimulation = index;
        [self prepareCurrentSimulation];
        
        [self activate];
    } else {
        if(index != _curSimulation) {
            _switchToSimulation = index;
            
            [_object deactivate];
        }
    }
}

-(void)activate {
    _state = BOUNCE_CONFIGURATION_PANE_ACTIVATED;
    [_object activate];
}
-(void)deactivate {
    _state = BOUNCE_CONFIGURATION_PANE_DEACTIVATED;
    [_object deactivate];
}


-(BOOL)singleTap:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim singleTap:uniqueId at:loc];
            return YES;
        }
    }
    
    if([_object isPaneAt:loc]) {       
        BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
        [sim singleTap:uniqueId at:loc];
        return YES;
    }
    
    return NO;
}

-(BOOL)flick: (void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim flick:uniqueId at:loc inDirection:dir time:time];
            return YES;
        }
    }
    
    if([_object isPaneAt:loc]) {
        BounceSimulation *curSim = [_simulations objectAtIndex:_curSimulation];
        [curSim flick:uniqueId at:loc inDirection:dir time:time];
        return YES;
    }
    
    return NO;
}

-(BOOL)longTouch:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim longTouch:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    if([_object isPaneAt:loc]) {
        BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
        [sim beginDrag:uniqueId at:loc];
        return YES;
    }
    
    if([self isHandleAreaAt:loc]) {
        _state = BOUNCE_CONFIGURATION_PANE_TAPPED;
        _time = 0;
        [_object tap];
        [self randomizeColor];
        
        return YES;
    }
    
    return NO;
}
-(BOOL)drag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim drag:uniqueId at:loc];
            return YES;
        }
    }

    return NO;
}
-(BOOL)endDrag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim endDrag:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BOOL responds = [sim respondsToGesture:uniqueId];
        if(responds) {
            [sim cancelDrag:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}


-(void)reset {
    switch (_state) {
        case BOUNCE_CONFIGURATION_PANE_TAPPED:
            [_object tap];
            [self randomizeColor];
            break;
        case BOUNCE_CONFIGURATION_PANE_ACTIVATED:
            if(_curSimulation != _switchToSimulation) {
                [_object deactivate];
            } else {
                [_object activate];
            }
            break;
        case BOUNCE_CONFIGURATION_PANE_DEACTIVATED:
            [_object deactivate];
            break;
        default:
            NSAssert(NO, @"unknown bounce configuration state");
            break;
    }
}

-(void)step:(float)dt {
    if(_state == BOUNCE_CONFIGURATION_PANE_TAPPED) {
        _time += dt;
        if(_time > 2) {
            [self deactivate];
        }
    }
    
    [_object step:dt];

    vec2 pos = _object.position;
    vec2 vel = _object.velocity;
    
    for(BounceConfigurationTab *tab in _simulationTabs) {
        [tab setPosition:[tab offset]+pos];
        [tab setVelocity:vel];
    }
    
    BounceConfigurationSimulation *curSim = [_simulations objectAtIndex:_curSimulation];
    [curSim setPosition:pos];
    [curSim setVelocity:vel];
    
    for(BounceConfigurationSimulation *sim in _simulations) {
        if([sim isAnyObjectInBounds] || (curSim == sim && _state == BOUNCE_CONFIGURATION_PANE_ACTIVATED)) {

            [sim step:dt];
        }
    }
     
    
    CGSize paneSize = [_object paneSize];
    
    if(_switchToSimulation != _curSimulation && pos.y < -_invaspect-paneSize.height*.5) {
        _curSimulation = _switchToSimulation;
        if(_state == BOUNCE_CONFIGURATION_PANE_ACTIVATED) {
            [_object activate];
            [self randomizeColor];
            [self prepareCurrentSimulation];
        }

    }
    
    BounceConfigurationTab *curTab = [_simulationTabs objectAtIndex:_curSimulation];
    if(curTab.intensity < .6) {
        curTab.intensity = .6;
    }
}

-(void)draw {
    [_object draw];
    vec2 pos = _object.position;
    
    BounceConfigurationTab *curTab = [_simulationTabs objectAtIndex:_curSimulation];
    
    BounceSimulation *settingsSim = [_simulations objectAtIndex:7];
    // draw settings simulation before tabs
    [settingsSim draw];

    for(BounceConfigurationTab *tab in _simulationTabs) {
        if(curTab != tab) {
            [tab draw];
        }
    }
    [curTab draw];
    
    for(BounceSimulation *sim in _simulations) {
        if(sim != settingsSim) {
            [sim draw];
        }
    }

}

-(void)dealloc {
    for(BounceObject* obj in _simulationTabs) {
        [obj removeFromSimulation];
    }
    [_object removeFromSpace];
    [_simulationTabs release];

    [_simulation release];
    [_simulations release];
    
    [super dealloc];
}
@end

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

@implementation BounceConfigurationPaneObject 

@synthesize color = _color;
@synthesize paneSize = _paneSize;
@synthesize handleSize = _handleSize;

-(id)init {
    self = [super initStatic];
    if(self) {
        NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];

        BounceConstants *constants = [BounceConstants instance];
        
        _upi = constants.unitsPerInch;
        _aspect = constants.aspect;
        _invaspect = 1./_aspect;
        
        _handleSize.width = .3*_upi;
        _handleSize.height = .15*_upi;
        
        NSLog(@"handle size: %f, %f\n", _handleSize.width, _handleSize.height);
        
        _paneSize.width = 1.8;
        _paneSize.height = _upi;
        
        NSString *device = machineName();
        if([device hasPrefix:@"iPad"]) {
            _paneSize.width = _upi*4;
            _paneSize.height = _upi*2.25;
            _handleSize.width = .4*_upi;
            _handleSize.height = .2*_upi;
        }
        
        vec4 color;
        HSVtoRGB(&(color.x), &(color.y), &(color.z), 
                 360.*random(64.28327*time), .4, .05*random(736.2827*time)+.75   );
        color.w = 1;
        _color = color;
        
        FSATextureManager *texManager = [FSATextureManager instance];
        
        _handleShapeTexture = [texManager getTexture:@"rectangle.jpg"].name;
        _handlePatternTexture = [texManager getTexture:@"arrow.jpg"].name;
        
        _paneShapeTexture = [texManager getTexture:@"square.jpg"].name;
        _panePatternTexture = [texManager getTexture:@"black.jpg"].name;
        
        _tappedSpringLoc = vec2(0, -_invaspect-_paneSize.height*.5);
        _activeSpringLoc = vec2(0, -_invaspect+_paneSize.height*.5);
        _inactiveSpringLoc = vec2(0, -_invaspect-_paneSize.height*.8-_handleSize.height);
        
        _springLoc = _inactiveSpringLoc;
        
        [self setPosition:_inactiveSpringLoc];
        
        float top = _paneSize.height*.5;
        float bottom = -_paneSize.height*.5;
        float left = -_paneSize.width*.5;
        float right = _paneSize.width*.5;
        
        float handleTop = top+_handleSize.height;
        float handleBottom = top;
        float handleLeft = -_handleSize.width*.5;
        float handleRight = _handleSize.width*.5;
        
        vec2 verts[4];
        verts[0] = vec2(right, top);
        verts[1] = vec2(right, bottom);
        verts[2] = vec2(left, bottom);
        verts[3] = vec2(left, top);
        
        [self addPolyShapeWithNumVerts:4 withVerts:verts withOffset:cpvzero];  
        
        verts[0] = vec2(handleRight, handleTop);
        verts[1] = vec2(handleRight, handleBottom);
        verts[2] = vec2(handleLeft, handleBottom);
        verts[3] = vec2(handleLeft, handleTop);
        [self addPolyShapeWithNumVerts:4 withVerts:verts withOffset:cpvzero];  
        
        cpShapeSetFriction(_shapes[0], .5);
        cpShapeSetElasticity(_shapes[0], .95);
        cpShapeSetCollisionType(_shapes[0], WALL_TYPE);
        
        cpShapeSetFriction(_shapes[1], .5);
        cpShapeSetElasticity(_shapes[1], .95);
        cpShapeSetCollisionType(_shapes[1], WALL_TYPE);
    }
    
    return self;
}

-(BOOL)isHandleAt:(const vec2&)loc {
    vec2 pos = self.position;
    
    float top = (pos.y+_paneSize.height*.5+_handleSize.height);
    float bottom = pos.y+_paneSize.height*.5;
    float left = pos.x-_handleSize.width*.5;
    float right = pos.x+_handleSize.width*.5;
    
    return loc.x >= left && loc.x <= right &&
           loc.y >= bottom && loc.y <= top;
    
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

    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             360.*random(64.28327*time), .4, .05*random(736.2827*time)+.75   );
    color.w = 1;
    _color = color;
}

-(void)tap {
    [self randomizeColor];
    
    _springLoc = _tappedSpringLoc;
}

-(void)activate {
    _springLoc = _activeSpringLoc;
    _handlePatternTexture = [[FSATextureManager instance] getTexture:@"downarrow.jpg"].name;

}

-(void)deactivate {
    _springLoc = _inactiveSpringLoc;
    _handlePatternTexture = [[FSATextureManager instance] getTexture:@"arrow.jpg"].name;

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
    
    // draw handle
    shader = [[FSAShaderManager instance] getShader:@"SingleObjectShader"];

    float size = _handleSize.width;
        
    top = pos.y+_paneSize.height*.5+_handleSize.height*.5+size;
    bottom = pos.y+_paneSize.height*.5+_handleSize.height*.5-size;
    left = pos.x-size;
    right = pos.x+size;
        
    verts[0] = vec2(right, top);
    verts[1] = vec2(left, top);
    verts[2] = vec2(left, bottom);
    verts[3] = vec2(right, bottom);
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 0;
    indices[4] = 2;
    indices[5] = 3;
    
    [shader setPtr:verts forAttribute:@"position"];
    [shader setPtr:&_color forUniform:@"color"];
    
    _intensity = .5*_vel.length()*.4+.6*_intensity;
    
    [shader setPtr:&_intensity forUniform:@"intensity"];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _handleShapeTexture);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _handlePatternTexture);
    
    GLuint shape = 0;
    GLuint pattern = 1;
    
    [shader setPtr:&shape forUniform:@"shapeTexture"];
    [shader setPtr:&pattern forUniform:@"patternTexture"];
    
    vec2 shapeUV[4];
    vec2 patternUV[4];
    
    shapeUV[0] = vec2(1,0);
    shapeUV[1] = vec2(0,0);
    shapeUV[2] = vec2(0,1);
    shapeUV[3] = vec2(1,1);
    
    patternUV[0] = vec2(1,0);
    patternUV[1] = vec2(0,0);
    patternUV[2] = vec2(0,1);
    patternUV[3] = vec2(1,1);
    [shader setPtr:shapeUV forAttribute:@"shapeUV"];
    [shader setPtr:patternUV forAttribute:@"patternUV"];
    
    glEnable(GL_BLEND);
    [shader enable];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, indices);
    [shader disable];
    glDisable(GL_BLEND);
}
@end

@implementation BounceConfigurationPane

-(void)addShapesSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    vec2 shapePos(0, -_invaspect-.5);
    float shapeSize = .15;
    float shapeSize2 = .09270476;
    
    BounceConfigurationObject *shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    shapeConfigObject.patternTexture = [texManager getTexture:@"Circle"].name;
    // [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:3 numRows:4 numCols:4];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_SQUARE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    // [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:1 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Square"].name;
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_TRIANGLE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    //[shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:0 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Triangle"].name;
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_PENTAGON at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    //        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:2 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Pentagon"].name;
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_RECTANGLE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    shapeConfigObject.secondarySize = shapeSize2;
    shapeConfigObject.patternTexture = [[FSATextureManager instance] getTexture:@"Rectangle"].name;
    //   [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:1 col:0 numRows:4 numCols:4];
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_CAPSULE at:shapePos withVelocity:vec2() ];
    shapeConfigObject.size = shapeSize;
    shapeConfigObject.secondarySize = shapeSize2;
    //        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:1 col:1 numRows:4 numCols:4];
    shapeConfigObject.patternTexture = [texManager getTexture:@"Capsule"].name;
    [shapeConfigObject addToSimulation:sim];
    [shapeConfigObject release];
    
    [_simulations addObject:sim];
    
    CGSize handleSize = [_object handleSize];
    CGSize paneSize = [_object paneSize];
    
    float size = .1;
    vec2 offset(-paneSize.width*.5+size, paneSize.height*.5+handleSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = size;
    tab.secondarySize = handleSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Shapes"].name;
    [tab addToSimulation:_simulation];

    [_simulationTabs addObject:tab];
}

-(void)addPatternsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

    float shapeSize = .15;
    
    BouncePatternConfigurationObject * patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.2, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"black.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(.2, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"spiral.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(.5, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"stripes.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.4, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"white.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"checkered.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"plasma.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"sections.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"weave.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    patternConfigObject.size = shapeSize;
    patternConfigObject.patternTexture = [texManager getTexture:@"squares.jpg"].name;
    [patternConfigObject addToSimulation:sim];
    [patternConfigObject release];
    
    [_simulations addObject:sim];
    
    CGSize handleSize = [_object handleSize];
    CGSize paneSize = [_object paneSize];
    float size = .1;
    vec2 offset(-paneSize.width*.5+3*size, paneSize.height*.5+handleSize.height*.5);

    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    tab.size = size;
    tab.secondarySize = handleSize.height*.5;
    tab.patternTexture = [texManager getTexture:@"Patterns"].name;
    [tab addToSimulation:_simulation];
    [_simulationTabs addObject:tab];
}

-(void)addSizesSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];

    
    BounceSizeConfigurationObject * configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .05;
    [configObject addToSimulation:sim];
    [configObject release];

    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.1, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .03;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.4, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .1;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(.4, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .15;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceSizeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
    configObject.size = .2;
    [configObject addToSimulation:sim];
    [configObject release];
    
    [_simulations addObject:sim];
    
    CGSize handleSize = [_object handleSize];
    CGSize paneSize = [_object paneSize];
    float size = .1;
    vec2 offset(-paneSize.width*.5+5*size, paneSize.height*.5+handleSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = size;
    tab.secondarySize = handleSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Sizes"].name;
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
    configObject.patternTexture = [texManager getTexture:@"Red"].name;
    [configObject release];
    
    color = vec4(0,.5,0,1);
    configObject = [[BounceGreenColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Green"].name;

    [configObject addToSimulation:sim];
    [configObject release];
    
    color = vec4(0,0,.8,1);
    configObject = [[BounceBlueColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Blue"].name;
    [configObject addToSimulation:sim];
    [configObject release];
    
    color = vec4(.8,.8,0,1);
    configObject = [[BounceYellowColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Yellow"].name;
    [configObject addToSimulation:sim];
    [configObject release];
    
    color = vec4(.8,.4,0,1);
    configObject = [[BounceOrangeColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Orange"].name;
    [configObject addToSimulation:sim];
    [configObject release];
    
    color = vec4(.6,0,.8,1);
    configObject = [[BouncePurpleColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Purple"].name;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BouncePastelColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Pastel"].name;
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceGrayColorConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.patternTexture = [texManager getTexture:@"Gray"].name;
    [configObject addToSimulation:sim];
    [configObject release];
    
    [_simulations addObject:sim];
    
    CGSize handleSize = [_object handleSize];
    CGSize paneSize = [_object paneSize];
    float tsize = .1;
    vec2 offset(paneSize.width*.5-5*tsize, paneSize.height*.5+handleSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tsize;
    tab.secondarySize = handleSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Colors"].name;
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addMusicSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    FSASoundManager *soundManager = [FSASoundManager instance];
    
    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    float size = .15;
    
    vec4 color;
    
    NSString *textureSheet = @"music_texture_sheet.jpg";
    
    float small = .1;
    float big = .2;
    float t;
    int notes = 8;
    
    
    BounceNoteConfigurationObject * configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    [configObject addToSimulation:sim];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"c_1" volume:10]] autorelease];
    t = 0./(notes-1);
    configObject.size = small*t+(1-t)*big;
    [configObject setPatternForTextureSheet:textureSheet row:1 col:3 numRows:5 numCols:5];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"d_1" volume:10]] autorelease];
    t = 1./(notes-1);
    configObject.size = small*t+(1-t)*big;
    [configObject setPatternForTextureSheet:textureSheet row:2 col:1 numRows:5 numCols:5];    
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"e_1" volume:10]] autorelease];
    t = 2./(notes-1);
    configObject.size = small*t+(1-t)*big;
    [configObject setPatternForTextureSheet:textureSheet row:2 col:4 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"f_1" volume:10]] autorelease];
    t = 3./(notes-1);
    configObject.size = small*t+(1-t)*big;
    [configObject setPatternForTextureSheet:textureSheet row:3 col:2 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"g_1" volume:10]] autorelease];
    t = 4./(notes-1);
    configObject.size = small*t+(1-t)*big;
    [configObject setPatternForTextureSheet:textureSheet row:4 col:0 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"a_1" volume:10]] autorelease];
    t = 5./(notes-1);
    configObject.size = small*t+(1-t)*big;
    [configObject setPatternForTextureSheet:textureSheet row:0 col:2 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"b_1" volume:10]] autorelease];
    t = 6./(notes-1);
    configObject.size = small*t+(1-t)*big;
    [configObject setPatternForTextureSheet:textureSheet row:1 col:0 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"c_2" volume:10]] autorelease];
    t = 7./(notes-1);
    configObject.size = small*t+(1-t)*big;
    [configObject setPatternForTextureSheet:textureSheet row:1 col:3 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -_invaspect-.5) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceNote alloc] initWithSound:[soundManager getSound:@"rest" volume:10]] autorelease];
    configObject.size = small;
    [configObject setPatternForTextureSheet:textureSheet row:4 col:1 numRows:5 numCols:5];
    [configObject addToSimulation:sim];
    [configObject release];
    
    [_simulations addObject:sim];
    
    CGSize handleSize = [_object handleSize];
    CGSize paneSize = [_object paneSize];
    float tsize = .1;
    vec2 offset(paneSize.width*.5-3*tsize, paneSize.height*.5+handleSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tsize;
    tab.secondarySize = handleSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Music"].name;
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)addSettingsSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];

    BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    [_simulations addObject:sim];
    
    CGSize handleSize = [_object handleSize];
    CGSize paneSize = [_object paneSize];
    float tsize = .1;
    vec2 offset(paneSize.width*.5-tsize, paneSize.height*.5+handleSize.height*.5);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tsize;
    tab.secondarySize = handleSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Settings"].name;
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
        [self addSettingsSimulation];

        
        [simulation addToSpace:_object];
    }
    
    return self;
}

-(BOOL)isHandleAreaAt:(const vec2&)loc {
    return _state == BOUNCE_CONFIGURATION_PANE_DEACTIVATED &&
        loc.y < -_invaspect+.5*_upi && loc.x > -_upi*.5 && loc.x < _upi*.5;
}

-(void)addToVelocity:(const vec2&)v {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    [sim addToVelocity:v];
}

-(void)setGravity:(vec2)gravity {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    [sim setGravity:gravity];
}

-(void)setCurrentSimulation:(unsigned int)index {
    if(_state == BOUNCE_CONFIGURATION_PANE_TAPPPED) {
        _state = BOUNCE_CONFIGURATION_PANE_ACTIVATED;
        
        _switchToSimulation = index;
        _curSimulation = index;
        
        BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
        [sim setColor:_object.color];

        
        [_object activate];
    } else {
        if(index != _curSimulation) {
            _switchToSimulation = index;
            
            [_object deactivate];
        }
    }
}


-(BOOL)singleTap:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BounceGesture *gesture = [sim gestureForKey:uniqueId];
        if(gesture) {
            [sim singleTap:uniqueId at:loc];
            return YES;
        }
    }
    
    if([self isHandleAreaAt:loc]) {
        _state = BOUNCE_CONFIGURATION_PANE_TAPPPED;
        _time = 0;
        [_object tap];
        BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
        [sim setColor:_object.color];
        for(BounceConfigurationTab *tab in _simulationTabs) {
            [tab setColor:_object.color]; 
        }
        
        return YES;
    } else if([_object isHandleAt:loc]) {
        if(_state == BOUNCE_CONFIGURATION_PANE_TAPPPED) {
            _state = BOUNCE_CONFIGURATION_PANE_ACTIVATED;
            [_object activate];
        } else {
            _state = BOUNCE_CONFIGURATION_PANE_DEACTIVATED;
            [_object deactivate];
        }
        return YES;
    } else if([_object isPaneAt:loc]) {       
        // to single tap in current configuration bounce simulation
        BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
        [sim singleTap:uniqueId at:loc];
        return YES;
    }
    
    return NO;
}

-(BOOL)flick: (void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    for(BounceSimulation *sim in _simulations) {
        BounceGesture *gesture = [sim gestureForKey:uniqueId];
        if(gesture) {
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
        BounceGesture *gesture = [sim gestureForKey:uniqueId];
        if(gesture) {
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
    
    return NO;
}
-(BOOL)drag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BounceGesture *gesture = [sim gestureForKey:uniqueId];
        if(gesture) {
            [sim drag:uniqueId at:loc];
            return YES;
        }
    }

    return NO;
}
-(BOOL)endDrag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BounceGesture *gesture = [sim gestureForKey:uniqueId];
        if(gesture) {
            [sim endDrag:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    for(BounceSimulation *sim in _simulations) {
        BounceGesture *gesture = [sim gestureForKey:uniqueId];
        if(gesture) {
            [sim endDrag:uniqueId at:loc];
            return YES;
        }
    }
    
    return NO;
}

-(void)step:(float)dt {
    if(_state == BOUNCE_CONFIGURATION_PANE_TAPPPED) {
        _time += dt;
        if(_time > 2) {
            _state = BOUNCE_CONFIGURATION_PANE_DEACTIVATED;
            [_object deactivate];
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
    [curSim.arena setPosition:pos];
    [curSim.arena setVelocity:vel];
    
    for(BounceConfigurationSimulation *sim in _simulations) {
        if([sim isAnyObjectInBounds] || (curSim == sim
                                         && _state == BOUNCE_CONFIGURATION_PANE_ACTIVATED)) {

            [sim step:dt];
        }
    }
    
    
    
    CGSize paneSize = [_object paneSize];
    
    if(_switchToSimulation != _curSimulation && pos.y < -_invaspect-paneSize.height*.5) {
        _curSimulation = _switchToSimulation;
        [_object activate];
        [_object randomizeColor];
        for(BounceConfigurationTab *tab in _simulationTabs) {
            [tab setColor:_object.color];
        }
        for(BounceSimulation *sim in _simulations) {
            [sim setColor:_object.color];
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

    for(BounceConfigurationTab *tab in _simulationTabs) {
        if(curTab != tab) {
            [tab draw];
        }
    }
    [curTab draw];
    
    for(BounceSimulation *sim in _simulations) {
        [sim draw];
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

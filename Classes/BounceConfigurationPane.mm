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

-(void)tap {
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];

    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             360.*random(64.28327*time), .4, .05*random(736.2827*time)+.75   );
    color.w = 1;
    _color = color;
    
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

-(id)initWithBounceSimulation:(BounceSimulation *)simulation {
    self = [super init];
    
    if(self) {
        BounceConstants *constants = [BounceConstants instance];

        _upi = constants.unitsPerInch;
        _aspect = constants.aspect;
        _invaspect = 1./_aspect;
        
        _state = BOUNCE_CONFIGURATION_PANE_DEACTIVATED;
        _object = [[BounceConfigurationPaneObject alloc] init];
        
        NSMutableArray *simulations = [[NSMutableArray alloc] initWithCapacity:1];
        _curSimulation = 0;
        
        CGSize size = _object.paneSize;
        CGRect rect = CGRectMake(-size.width*.5, -size.height*.5, size.width, size.height);
        BounceSimulation *sim = [[BounceConfigurationSimulation alloc] initWithRect:rect bounceSimulation:simulation];
        
        vec2 shapePos(0, -_invaspect-.5);
        float shapeSize = .15;
        float shapeSize2 = .09270476;
        NSString *shapeTextureSheet = @"shapes_texture_sheet.jpg";
        
        BounceConfigurationObject *shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_BALL at:shapePos withVelocity:vec2() ];
        shapeConfigObject.size = shapeSize;
        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:3 numRows:4 numCols:4];
        [sim addObject:shapeConfigObject];
        [shapeConfigObject release];
        
        shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_SQUARE at:shapePos withVelocity:vec2() ];
        shapeConfigObject.size = shapeSize;
        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:1 numRows:4 numCols:4];

        [sim addObject:shapeConfigObject];
        [shapeConfigObject release];
        
        shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_TRIANGLE at:shapePos withVelocity:vec2() ];
        shapeConfigObject.size = shapeSize;
        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:0 numRows:4 numCols:4];

        [sim addObject:shapeConfigObject];
        [shapeConfigObject release];
        
        shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_PENTAGON at:shapePos withVelocity:vec2() ];
        shapeConfigObject.size = shapeSize;
        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:0 col:2 numRows:4 numCols:4];

        [sim addObject:shapeConfigObject];
        [shapeConfigObject release];
        
        shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_RECTANGLE at:shapePos withVelocity:vec2() ];
        shapeConfigObject.size = shapeSize;
        shapeConfigObject.secondarySize = shapeSize2;
        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:1 col:0 numRows:4 numCols:4];
        [sim addObject:shapeConfigObject];
        [shapeConfigObject release];
        
        shapeConfigObject = [[BounceShapeConfigurationObject alloc] initRandomObjectWithShape:BOUNCE_CAPSULE at:shapePos withVelocity:vec2() ];
        shapeConfigObject.size = shapeSize;
        shapeConfigObject.secondarySize = shapeSize2;
        [shapeConfigObject setPatternForTextureSheet:shapeTextureSheet row:1 col:1 numRows:4 numCols:4];
        [sim addObject:shapeConfigObject];
        [shapeConfigObject release];
        
        BouncePatternConfigurationObject * patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.2, -_invaspect-.5) withVelocity:vec2() ];
        patternConfigObject.size = shapeSize;
        patternConfigObject.patternTexture = [[FSATextureManager instance] getTexture:@"black.jpg"].name;
        [sim addObject:patternConfigObject];
        [patternConfigObject release];
        
        patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(.2, -_invaspect-.5) withVelocity:vec2() ];
        patternConfigObject.size = shapeSize;
        patternConfigObject.patternTexture = [[FSATextureManager instance] getTexture:@"spiral.jpg"].name;
        [sim addObject:patternConfigObject];
        [patternConfigObject release];
        
        patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(.5, -_invaspect-.5) withVelocity:vec2() ];
        patternConfigObject.size = shapeSize;
        patternConfigObject.patternTexture = [[FSATextureManager instance] getTexture:@"stripes.jpg"].name;
        [sim addObject:patternConfigObject];
        [patternConfigObject release];
        
        patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.4, -_invaspect-.5) withVelocity:vec2() ];
        patternConfigObject.size = shapeSize;
        patternConfigObject.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"].name;
        [sim addObject:patternConfigObject];
        [patternConfigObject release];
        
        patternConfigObject = [[BouncePatternConfigurationObject alloc] initRandomObjectAt:vec2(-.6, -_invaspect-.5) withVelocity:vec2() ];
        patternConfigObject.size = shapeSize;
        patternConfigObject.patternTexture = [[FSATextureManager instance] getTexture:@"checkered.jpg"].name;
        
      //  patternConfigObject.patternTexture = [[FSATextureManager instance] getTextureForText:@"hello" withColor:vec4(.5, .5, .5, 1) withFontSize:16];

        [sim addObject:patternConfigObject];
        [patternConfigObject release];
        
        [simulations addObject:sim];
        
        _simulations = simulations;
        
        [simulation addToSpace:_object];
    }
    
    return self;
}

-(BOOL)isHandleAreaAt:(const vec2&)loc {
    return _state == BOUNCE_CONFIGURATION_PANE_DEACTIVATED &&
        loc.y < -_invaspect+.25*_upi && loc.x > -_upi*.25 && loc.x < _upi*.25;
}

-(void)addToVelocity:(const vec2&)v {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    [sim addToVelocity:v];
}

-(void)setGravity:(vec2)gravity {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    [sim setGravity:gravity];
}


-(BOOL)singleTapAt:(const vec2&)loc {
    if([self isHandleAreaAt:loc]) {
        _state = BOUNCE_CONFIGURATION_PANE_TAPPPED;
        _time = 0;
        [_object tap];
        BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
        [sim setColor:_object.color];
        
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
        [sim singleTapAt:loc];
        return YES;
    }
    
    return NO;
}

-(BOOL)flickAt:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time {
    if([_object isPaneAt:loc]) {
        BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
        [sim flickAt:loc inDirection:dir time:time];
        return YES;
    }
    
    return NO;
}

-(BOOL)longTouch:(void*)uniqueId at:(const vec2&)loc {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];

    if([sim gestureForKey:uniqueId] != nil) {
        [sim longTouch:uniqueId at:loc];
        return YES;
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
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    if([sim gestureForKey:uniqueId] != nil) {
        [sim drag:uniqueId at:loc];
        return YES;
    }
    return NO;
}
-(BOOL)endDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    if([sim gestureForKey:uniqueId] != nil) {
        [sim endDrag:uniqueId at:loc];
        return YES;
    }
    return NO;
}
-(BOOL)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceSimulation *sim = [_simulations objectAtIndex:_curSimulation];
    
    if([sim gestureForKey:uniqueId] != nil) {
        [sim cancelDrag:uniqueId at:loc];
        return YES;
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
    
    BounceConfigurationSimulation *curSim = [_simulations objectAtIndex:_curSimulation];
    
    for(BounceConfigurationSimulation *sim in _simulations) {
        if([sim isAnyObjectInBounds] || (curSim == sim
                                         && _state == BOUNCE_CONFIGURATION_PANE_ACTIVATED)) {
            [sim.arena setPosition:pos];
            [sim.arena setVelocity:vel];
            [sim step:dt];
        }
    }
}

-(void)draw {
    [_object draw];
    vec2 pos = _object.position;
    
    for(BounceSimulation *sim in _simulations) {
        [sim draw];
    }
    /*
    FSATexture *tex = [[FSATextureManager instance] getTexture:@"Paint Mode"];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, tex.name);
    GLuint texture = 0;
    
    vec2 verts[4];
    vec2 uvs[4];
    unsigned int indices[6];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    
    indices[3] = 2;
    indices[4] = 3;
    indices[5] = 0;
    
    verts[0] = vec2(0,0);
    verts[1] = vec2(tex.aspect,0);
    verts[2] = vec2(tex.aspect,1);
    verts[3] = vec2(0,1);
    
    for(int i = 0; i < 4; i++) {
        verts[i] *= .2;
    }
    
    uvs[0] = vec2(0,0);
    uvs[1] = vec2(1,0);
    uvs[2] = vec2(1,1);
    uvs[3] = vec2(0,1);
    
    FSAShader *shader = [[FSAShaderManager instance] getShader:@"BillboardShader"];
    [shader setPtr:verts forAttribute:@"position"];
    [shader setPtr:uvs forAttribute:@"uv"];
    [shader setPtr:&texture forUniform:@"texture"];
    
    [shader enable];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, indices);
    [shader disable];
    
    
    BounceRenderableData data;
    BounceRenderableInputs inputs;
    
    inputs.intensity = &data.intensity;
    inputs.isStationary = &data.isStationary;
    inputs.color = &data.color;
    inputs.position = &data.position;
    inputs.size = &data.size;
    inputs.angle = &data.angle;
    inputs.patternTexture = &data.patternTexture;
    
    data.intensity = 2;
    data.isStationary = YES;
    data.color = vec4(.2, .6, .2, 1);
    data.position = vec2(0,0);
    data.size = .5;
    data.angle = 0;
    data.patternTexture = [[FSATextureManager instance] getTexture:@"spiral.jpg"].name;
    
    
    BounceRenderable *renderable = [[BounceRectangleRenderable alloc] initWithInputs:inputs aspect:1];
    
    [renderable draw];
    
    [renderable release];
    
    renderable = [[BounceRectangleRenderable alloc] initWithInputs:inputs aspect:1.61803399];

    [renderable draw];
    
    [renderable release];
    
    renderable = [[BounceRectangleRenderable alloc] initWithInputs:inputs aspect:2];
    
    [renderable draw];
    
    [renderable release];
    */
    
     
     
}
@end

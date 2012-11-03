//
//  BounceLoadingObject.m
//  ParticleSystem
//
//  Created by John Allwine on 10/30/12.
//
//

#import "BounceLoadingObject.h"
#import "FSATextureManager.h"
#import "BouncePane.h"
#import "FSAUtil.h"

@implementation BounceLoadingObject

@synthesize progressSpeed = _progressSpeed;

-(id)init {
    _progressSpeed = .007;
    _intensityTarget = 2.2;
    _data.color = vec4(.46,.68,.76,1);
    _data.intensity = 0;
    _data.size = .15;
    _angVel = 0;
    _t = 0;

    _data.patternTexture = [[[FSATextureManager instance] generateTemporaryTextureForText:@"Loading..." withFontSize:30 withOffset:vec2()] retain];
    
    _renderable = [[BounceBallRenderable alloc] initWithData:_data];
    
    CGSize size = screenSize();
    unsigned int imgWidth = nextPowerOfTwo(size.width*.66666667);
    if(imgWidth >= 1024) {
        _tex = [[[FSATextureManager instance] temporaryTexture:@"1024bounce2notes.png"] retain];
    //    NSLog(@"loaded 1024 loading screen image");
    } else if(imgWidth >= 512) {
        _tex = [[[FSATextureManager instance] temporaryTexture:@"512bounce2notes.png"] retain];
      //  NSLog(@"loaded 512 loading screen image");
    } else {
        _tex = [[[FSATextureManager instance] temporaryTexture:@"256bounce2notes.png"] retain];
       // NSLog(@"loaded 256 loading screen image");

    }
    
    _shader = [[FSAShaderManager instance] getShader:@"ColoredTextureShader"];
    _verts[0] = vec2(-.75,-.75);
    _verts[1] = vec2(-.75,.75);
    _verts[2] = vec2(.75,.75);
    _verts[3] = vec2(.75,-.75);
    _uvs[0] = vec2(0,1);
    _uvs[1] = vec2(0,0);
    _uvs[2] = vec2(1,0);
    _uvs[3] = vec2(1,1);
    _indices[0] = 0;
    _indices[1] = 1;
    _indices[2] = 3;
    _indices[3] = 2;
    _color = vec4(1,1,1,1);
    _rotationMult = 1;
    
    NSString *device = machineName();
    NSLog(@"%@", device);
    if([device hasPrefix:@"iPad3"]) {
        _rotationMult = .25;
    }
        
    BouncePaneOrientation orientation = getBouncePaneOrientation();
    float angle;
    switch(orientation) {
        case BOUNCE_PANE_LANDSCAPE_LEFT:
            angle = -M_PI_2;
            break;
        case BOUNCE_PANE_LANDSCAPE_RIGHT:
            angle = M_PI_2;
            break;
        case BOUNCE_PANE_PORTRAIT:
            angle = 0;
            break;
        case BOUNCE_PANE_PORTRAIT_UPSIDE_DOWN:
            angle = M_PI;

    }
    _data.angle = angle;
    
    for(int i = 0; i < 4; i++) {
        _verts[i].rotate(-angle);
    }
    
    return self;
}

-(void)step:(float)dt {
    _data.angle += _angVel*dt;
    for(int i = 0; i < 4; i++) {
        _verts[i].rotate(_rotationMult*_angVel*dt);
    }
}

-(void)makeProgess {
    _t = _t*(1-_progressSpeed)+1*_progressSpeed;

    float intT = powf(_t,1.5);
    _data.intensity = _intensityTarget*intT;
   // _angVel = ttt*-100;
    
    float angleT = fminf(1,fmaxf(0,(_t)/.6));
    angleT *= angleT*angleT*angleT;
    _angVel = angleT*-60;
    
    float alphat = fminf(1,fmaxf(0,(_t-.25)/.6));
    float alpha = 1-alphat*alphat;
    _color = vec4(alpha,alpha,alpha,alpha);
}

-(void)draw {    
    GLuint texId = 0;
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _tex.name);
    
    [_shader setPtr:&texId forUniform:@"texture"];
    [_shader setPtr:_verts forAttribute:@"position"];
    [_shader setPtr:_uvs forAttribute:@"uv"];
    [_shader setPtr:&_color forUniform:@"color"];

    [_shader enable];
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, _indices);
    [_shader disable];
    
    [_renderable draw];

    
}

-(void)dealloc {
    [_tex release];
    [_renderable dealloc];
    [_data.patternTexture release];
    [super dealloc];
}

@end

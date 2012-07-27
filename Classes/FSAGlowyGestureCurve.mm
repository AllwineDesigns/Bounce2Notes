//
//  FSAGlowyCurve.m
//  ParticleSystem
//
//  Created by John Allwine on 7/21/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSAGlowyGestureCurve.h"
#import "FSAShaderManager.h"
#import "FSATextureManager.h"
#import "BounceRenderable.h"
#import <vector>

@implementation FSAGlowyGestureCurve {
    BounceRenderableData _data;
    vec4 _color;
    BounceBallRenderable *_ballRenderable;
}

-(id)initWithColor: (const vec4&)color {
    self = [super init];
    if(self) {
        _color = color;
        _data.size = .05;
        _data.intensity = 1;
        _data.color = color;
        _data.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"].name;
        
        BounceRenderableInputs inputs;
        inputs.angle = &_data.angle;
        inputs.color = &_data.color;
        inputs.intensity = &_data.intensity;
        inputs.isStationary = &_data.isStationary;
        inputs.patternTexture = &_data.patternTexture;
        inputs.position = &_data.position;
        inputs.size = &_data.size;
        
        _ballRenderable = [[BounceBallRenderable alloc] initWithInputs:inputs];
        _ballRenderable.blendMode = GL_ONE;
    }
    return self;
}

-(void)draw {
    //[self resample];
    
    vec2 *points = [self points];
    float *times = [self times];
    float fadeTime = [self fadeTime];
    float currentTime = [self time];
    
    unsigned int numPoints = [self numPoints];
    
    std::vector<vec2> verts;
    std::vector<vec2> uvs;
    std::vector<float> intensities;
    
    std::vector<vec2> vectorVerts;
    
    float scale = .1;
    
    _data.color = _color;
    
    if(numPoints > 1) {
        float intensity = 0;
        vec2 P = points[0];
        vec2 T = (points[1]-points[0]).unit()*scale;
                
        vec2 N(T);
        
        N.rotate(0,1);
        
        verts.push_back(P+intensity*N-intensity*T);
        verts.push_back(P-intensity*N-intensity*T);
        
        intensities.push_back(intensity);
        intensities.push_back(intensity);
        float t = (currentTime-times[0])/fadeTime;
        t = t > 1 ? t = 1 : t;
        intensity = 1./(numPoints+1)*(1-t);
        
        verts.push_back(P+intensity*N);
        verts.push_back(P-intensity*N);
        
        uvs.push_back(vec2(0,0));
        uvs.push_back(vec2(0,1));
        uvs.push_back(vec2(.5,0));
        uvs.push_back(vec2(.5,1));
        
        intensities.push_back(intensity);
        intensities.push_back(intensity);
        
        for(int i = 1; i < numPoints-1; i++) {
            t = (currentTime-times[i])/fadeTime;
            t = t > 1 ? t = 1 : t;
            intensity = (float)(i+1)/(numPoints+1)*(1-t);
            P = points[i];
            T = (points[i]-points[i-1]).unit()*scale;
            N = T;
            N.rotate(0,1);
            
            verts.push_back(P+intensity*N);
            verts.push_back(P-intensity*N);
            
            uvs.push_back(vec2(.5,0));
            uvs.push_back(vec2(.5,1));
            
            intensities.push_back(intensity);
            intensities.push_back(intensity);
        }
        
        t = (currentTime-times[numPoints-1])/fadeTime;
        t = t > 1 ? t = 1 : t;
        intensity = (float)numPoints/(numPoints+1)*(1-t);
        P = points[numPoints-1];
        T = (points[numPoints-1]-points[numPoints-2]).unit()*scale;
        N = T;
        N.rotate(0,1);
        
        verts.push_back(P+intensity*N);
        verts.push_back(P-intensity*N);
        
        intensities.push_back(intensity);
        intensities.push_back(intensity);
        
        intensity = 1*(1-t);
        verts.push_back(P+intensity*N+intensity*T);
        verts.push_back(P-intensity*N+intensity*T);
        
        uvs.push_back(vec2(.5,0));
        uvs.push_back(vec2(.5,1));
        uvs.push_back(vec2(1,0));
        uvs.push_back(vec2(1,1));

        intensities.push_back(intensity);
        intensities.push_back(intensity);
    }
    
    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    FSAShader *shader = [shaderManager getShader:@"GestureGlowShader"];
    
    [shader setPtr:&verts[0] forAttribute:@"position"];
    [shader setPtr:&uvs[0] forAttribute:@"uv"];
    [shader setPtr:&intensities[0] forAttribute:@"intensity"];
    
    [shader setPtr:&_data.color forUniform:@"color"];
    
    GLuint texture = 0;
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [[FSATextureManager instance] getTexture:@"glow.jpg"].name);
    [shader setPtr:&texture forUniform:@"texture"];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    [shader enable];
    glDrawArrays(GL_TRIANGLE_STRIP, 0, verts.size());
  //  glDrawArrays(GL_LINE_STRIP, 0, verts.size());
    [shader disable];
    glDisable(GL_BLEND);
    
    /*
    shader = [shaderManager getShader:@"ColorShader"];
    [shader setPtr:&vectorVerts[0] forAttribute:@"position"];
    [shader setPtr:&color forUniform:@"color"];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    [shader enable];
    glDrawArrays(GL_LINES, 0, vectorVerts.size());
    [shader disable];
    glDisable(GL_BLEND);
     */
    
    [super draw];
    
    float t = (currentTime-times[numPoints-1])/(.7*fadeTime);
    t = t > 1 ? t = 1 : t;
    
    _data.color = (1-t)*_color;
    _data.size = (1-t)*.05;

    _data.position = points[numPoints-1];
    
    [_ballRenderable draw];

}

@end

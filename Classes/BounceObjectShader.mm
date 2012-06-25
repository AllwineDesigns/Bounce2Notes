//
//  BounceObjectShader.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceObjectShader.h"


enum {
    ATTRIB_VERTEX,
    ATTRIB_UV,
    NUM_ATTRIBUTES
};

@implementation BounceObjectShader

-(id)initWithAspect:(float)a {
    self = [super initWithShaderPaths:@"SingleObjectShader" fragShader:@"SingleObjectShader"];
    
    if(self) {
        _aspect = a;
        _indices[0] = 0;
        _indices[1] = 1;
        _indices[2] = 3;
        
        _indices[3] = 1;
        _indices[4] = 2;
        _indices[5] = 3;
    }
 
    return self;
}

-(void)setBounceObject:(BounceObject*)obj {
    _obj = obj;
}

-(void)getUniformLocations {
    textureLoc = glGetUniformLocation(program, "shapeTexture");
    patternLoc = glGetUniformLocation(program, "patternTexture");
    
    aspectLoc = glGetUniformLocation(program, "aspect");
    colorLoc = glGetUniformLocation(program, "color");
    intensityLoc = glGetUniformLocation(program, "intensity");
}

//do quads
-(void)updateAttributes {    
    float radius = 2*_obj.size;
    vec2 position(_obj.position);
    vec4 color(_obj.color);
    
    float angle = _obj.angle;
    float intensity = _obj.intensity;
    
    vec2 *vertOffsets = _obj.vertOffsets;
    vec2 *vertUVs = _obj.vertUVs;
    
    vec2 tr = vec2(radius, radius)+vertOffsets[0];
    vec2 tl = vec2(-radius, radius)+vertOffsets[1];
    vec2 bl = vec2(-radius, -radius)+vertOffsets[2];
    vec2 br = vec2(radius, -radius)+vertOffsets[3];
    
    float cosangle = cos(-angle);
    float sinangle = sin(-angle);
    
    tr.rotate(cosangle,sinangle);
    tl.rotate(cosangle,sinangle);
    bl.rotate(cosangle,sinangle);
    br.rotate(cosangle,sinangle);
    
    tr += position;
    tl += position;
    bl += position;
    br += position;
    
    _verts[0].position  = tr;
    _verts[1].position = tl;
    _verts[2].position = bl;
    _verts[3].position = br;    
    
    _verts[0].uv = vertUVs[0];
    _verts[1].uv = vertUVs[1];
    _verts[2].uv = vertUVs[2];
    _verts[3].uv = vertUVs[3];

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _obj.shapeTexture);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _obj.patternTexture);
    
    glUniform1i(textureLoc, 0);
    glUniform1i(patternLoc, 1);
    
    glUniform1f(aspectLoc, _aspect);
    glUniform1f(intensityLoc, intensity);
    glUniform4f(colorLoc, color.x, color.y, color.z, color.w);
    
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, sizeof(BounceObjectVertex), &_verts[0]);
    glVertexAttribPointer(ATTRIB_UV, 2, GL_FLOAT, 0, sizeof(BounceObjectVertex), (char*)(&_verts[0])+sizeof(vec2));
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_UV);
}

-(void)draw {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, &_indices[0]);
   // glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, &_indices[0]);

    glDisableVertexAttribArray(ATTRIB_VERTEX);
    glDisableVertexAttribArray(ATTRIB_UV);    
}

@end

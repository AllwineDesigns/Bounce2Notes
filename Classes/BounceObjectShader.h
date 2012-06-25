//
//  BounceObjectShader.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "Shader.h"
#import "BounceObject.h"

struct BounceObjectVertex {
    vec2 position;
    vec2 uv;
};

@interface BounceObjectShader : Shader {
    BounceObject *_obj;
    BounceObjectVertex _verts[4];
    unsigned int _indices[6];
    
    float _aspect;
    
    GLint patternLoc;
    GLint textureLoc; 
    GLint aspectLoc;
    GLint colorLoc;
    GLint intensityLoc;
}

-(id)initWithAspect:(float)aspect;
-(void)setBounceObject:(BounceObject*)obj;

@end

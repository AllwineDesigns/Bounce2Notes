//
//  BounceLoadingObject.h
//  ParticleSystem
//
//  Created by John Allwine on 10/30/12.
//
//

#import "BounceObject.h"
#import "FSAShaderManager.h"

@interface BounceLoadingObject : NSObject {
    float _progressSpeed;
    float _intensityTarget;
    float _angVel;
    float _t;
    
    BounceRenderableData _data;
    BounceBallRenderable *_renderable;
    
    FSATexture *_tex;
    FSAShader *_shader;
    vec2 _verts[4];
    vec2 _uvs[4];
    unsigned int _indices[4];
    float _alpha;
    vec4 _color;
    float _rotationMult;
}

@property (nonatomic, assign) float progressSpeed;
@property (nonatomic, assign) float intensityTarget;

-(void)step:(float)dt;
-(void)draw;
-(void)makeProgess;

@end

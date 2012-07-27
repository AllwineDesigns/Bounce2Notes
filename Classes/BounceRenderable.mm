//
//  BounceRenderable.m
//  ParticleSystem
//
//  Created by John Allwine on 7/2/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceRenderable.h"
#import "FSAShaderManager.h"
#import "FSATextureManager.h"

@implementation BounceRenderable

@synthesize blendMode = _blendMode;
@synthesize inputs = _inputs;
@synthesize bounciness = _bounciness;

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super init];
    if(self) {
        _inputs = inputs;
        _mode = GL_TRIANGLE_STRIP;
        _blendMode = GL_ONE_MINUS_SRC_ALPHA;
        _bounciness = .9;
    }
    return self;
}

-(void)draw {
    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    FSAShader *objectShader = [shaderManager getShader:@"SingleObjectShader"];
    FSAShader *stationaryShader = [shaderManager getShader:@"SingleObjectStationaryShader"];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, _blendMode);
    
    float size = *_inputs.size;
    float angle = *_inputs.angle;
    vec2 pos = *_inputs.position;
    BOOL isStationary = *_inputs.isStationary;
    GLuint patternTexture = *_inputs.patternTexture;
    
    size *= 2;
    
    float cosangle = cos(-angle);
    float sinangle = sin(-angle);
    
    for(int i = 0; i < _numVerts; i++) {
        _verts[i] = _vertsUntransformed[i]*size+_vertOffsets[i];
        _verts[i].rotate(cosangle,sinangle);
        _verts[i] += pos;
    }
    
    [objectShader setPtr:_inputs.intensity forUniform:@"intensity"];
    [objectShader setPtr:_inputs.color forUniform:@"color"];
    
    GLuint shapeTex = 0;
    GLuint patternTex = 1;
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _shapeTexture);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, patternTexture);
    
    [objectShader setPtr:&shapeTex forUniform:@"shapeTexture"];
    [objectShader setPtr:&patternTex forUniform:@"patternTexture"];
    
    [objectShader setPtr:_verts forAttribute:@"position"];
    [objectShader setPtr:_vertShapeUVs forAttribute:@"shapeUV"];
    [objectShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];
    
    [objectShader enable];
     glDrawElements(_mode, _numIndices, GL_UNSIGNED_INT, _indices);
    [objectShader disable];
    
    if(isStationary) {
        [stationaryShader setPtr:_inputs.color forUniform:@"color"];
        
        GLuint stationaryTex = 0;
        GLuint patternTex = 1;
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _stationaryTexture);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, patternTexture);
        [stationaryShader setPtr:&stationaryTex forUniform:@"texture"];
        [stationaryShader setPtr:&patternTex forUniform:@"pattern"];
        
        [stationaryShader setPtr:_verts forAttribute:@"position"];
        [stationaryShader setPtr:_vertShapeUVs forAttribute:@"uv"];
        [stationaryShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];
        
        [stationaryShader enable];
         glDrawElements(_mode, _numIndices, GL_UNSIGNED_INT, _indices);
        [stationaryShader disable];
    }
    
    glDisable(GL_BLEND);
}

-(void)burst:(float)scale {
    for(int i = 0; i < _numVerts; i++) {
        vec2 vert = _vertsUntransformed[i];
        _vertVels[i] += _bounciness*scale*vert;
    }
}

-(void)collideAt:(const vec2 &)pos withVelocity:(const vec2 &)vel {
    int closest_j = -1;
    int closest_j2 = -1;
    float min_dist = 9999;
    float min_dist2 = 9999;
    
    float size = *_inputs.size;
    
    for(int j = 0; j < _numVerts; j++) {
        vec2 vert = _vertsUntransformed[j]*size;
        float dist = (pos-vert).length();
        if(dist < min_dist) {
            closest_j = j;
            min_dist = dist;
            
            closest_j2 = closest_j;
            min_dist2 = min_dist;
        } else if(dist < min_dist2) {
            closest_j2 = j;
            min_dist2 = dist;
        }
    }
    
    _vertVels[closest_j] += (2*_bounciness)*vel;
    _vertVels[closest_j2] += (2*_bounciness)*vel;
}

-(void)drawSelected {
    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    FSAShader *objectShader = [shaderManager getShader:@"SingleObjectShader"];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    
    float s = *_inputs.size;
    float angle = *_inputs.angle;
    vec2 pos = *_inputs.position;
    
    float size = 2.4*s;
        
    float cosangle = cos(-angle);
    float sinangle = sin(-angle);
    
    for(int i = 0; i < _numVerts; i++) {
        _verts[i] = _vertsUntransformed[i]*size+_vertOffsets[i];
        _verts[i].rotate(cosangle,sinangle);
        _verts[i] += pos;
    }
    
    float intensity = 2;
    
    [objectShader setPtr:&intensity forUniform:@"intensity"];
    [objectShader setPtr:_inputs.color forUniform:@"color"];
    
    GLuint shapeTex = 0;
    GLuint patternTex = 1;
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _shapeTexture);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, [[FSATextureManager instance] getTexture:@"black.jpg"].name);
    
    [objectShader setPtr:&shapeTex forUniform:@"shapeTexture"];
    [objectShader setPtr:&patternTex forUniform:@"patternTexture"];
    
    [objectShader setPtr:_verts forAttribute:@"position"];
    [objectShader setPtr:_vertShapeUVs forAttribute:@"shapeUV"];
    [objectShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];
    
    [objectShader enable];
    glDrawElements(_mode, _numIndices, GL_UNSIGNED_INT, _indices);
    [objectShader disable];
    
    glDisable(GL_BLEND);
    
}

-(void)step:(float)dt {    
    float spring_k = 200;
    float drag = .2;
    
    float size = *_inputs.size;
    float c = size*.75;
    
    for(int i = 0; i < _numVerts; i++) {
        _vertOffsets[i] += _vertVels[i]*dt;
        vec2 a = -spring_k*_vertOffsets[i];
        
        _vertVels[i] +=  a*dt-drag*_vertVels[i];
        
        _vertOffsets[i].clamp(-c, c);
    }
}

-(void)setPatternUVsForTextureSheetAtRow:(unsigned int)row col:(unsigned int)col numRows:(unsigned int)rows numCols:(unsigned int)cols {
    
    vec2 scale(1./cols, 1./rows);
    vec2 offset((float)col/cols, (float)row/rows);
    
    for(int i = 0; i < _numVerts; i++) {
        vec2 uv = _vertsUntransformed[i];
        uv.x *= .5;
        uv.y *= -.5;
        uv += vec2(.5,.5);
        _vertPatternUVs[i] = uv*scale+offset;
    }
}

-(void)dealloc {
    free(_verts);
    free(_vertsUntransformed);
    free(_vertOffsets);
    free(_vertVels);
    free(_vertShapeUVs);
    free(_vertPatternUVs);
    free(_indices);
    
    [super dealloc];
}

@end

@implementation BounceBallRenderable

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 4;
        _numIndices = 4;
        _verts = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertVels = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _indices = (unsigned int*)malloc(_numIndices*sizeof(unsigned int));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _vertsUntransformed[0] = vec2(1,1);
        _vertsUntransformed[1] = vec2(-1,1);
        _vertsUntransformed[2] = vec2(-1,-1);
        _vertsUntransformed[3] = vec2(1,-1);
        
        _vertShapeUVs[0] = vec2(1,0);
        _vertShapeUVs[1] = vec2(0,0);
        _vertShapeUVs[2] = vec2(0,1);
        _vertShapeUVs[3] = vec2(1,1);
        
        _vertPatternUVs[0] = vec2(1,0);
        _vertPatternUVs[1] = vec2(0,0);
        _vertPatternUVs[2] = vec2(0,1);
        _vertPatternUVs[3] = vec2(1,1);
        
        _indices[0] = 0;
        _indices[1] = 1;
        _indices[2] = 3;
        _indices[3] = 2;
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"ball.jpg"].name;
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_ball.png"].name;
    }
    
    return self;
}

@end

/*
@implementation BounceBallRenderable

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 3;
        _numIndices = 3;
        _verts = (vec2*)realloc(_verts,_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)realloc(_vertsUntransformed, _numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)realloc(_vertOffsets,_numVerts*sizeof(vec2));
        _vertVels = (vec2*)realloc(_vertVels,_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)realloc(_vertShapeUVs,_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)realloc(_vertPatternUVs,_numVerts*sizeof(vec2));
        _indices = (unsigned int*)realloc(_indices,_numIndices*sizeof(unsigned int));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        float h = 1./sin(PI/6);
        float x = 1./tan(PI/6);
        
        _vertsUntransformed[0] = vec2(0,h);
        _vertsUntransformed[1] = vec2(-x,-1);
        _vertsUntransformed[2] = vec2(x,-1);
        
        for(int i = 0; i < _numVerts; i++) {
            vec2 uv = _vertsUntransformed[i];
            uv.x *= .5;
            uv.y *= -.5;
            uv += vec2(.5,.5);
            _vertShapeUVs[i] = uv;
            _vertPatternUVs[i] = uv;
        }
        
        _indices[0] = 0;
        _indices[1] = 1;
        _indices[2] = 2;
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"ball.jpg"].name;
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_ball.png"].name;
    }
    return self;
}

@end
*/


@implementation BounceTriangleRenderable

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 3;
        _numIndices = 3;
        _verts = (vec2*)realloc(_verts,_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)realloc(_vertsUntransformed, _numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)realloc(_vertOffsets,_numVerts*sizeof(vec2));
        _vertVels = (vec2*)realloc(_vertVels,_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)realloc(_vertShapeUVs,_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)realloc(_vertPatternUVs,_numVerts*sizeof(vec2));
        _indices = (unsigned int*)realloc(_indices,_numIndices*sizeof(unsigned int));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _vertsUntransformed[0] = vec2(0,1.3333333333);
        _vertsUntransformed[1] = vec2(-1.15470053838,-.66666666667);
        _vertsUntransformed[2] = vec2(1.1547005383,-.66666666667);
        
        _vertShapeUVs[0] = vec2(.5,-.166666666667);
        _vertShapeUVs[1] = vec2(-.07735026919,.83333333333);
        _vertShapeUVs[2] = vec2(1.07735026919,.83333333333);
        
        _vertPatternUVs[0] = vec2(.5,-.166666666667);
        _vertPatternUVs[1] = vec2(-.07735026919,.83333333333);
        _vertPatternUVs[2] = vec2(1.07735026919,.83333333333);
        
        _indices[0] = 0;
        _indices[1] = 1;
        _indices[2] = 2;
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"triangle.jpg"].name;
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_triangle.png"].name;
    }
    return self;
}

@end

@implementation BounceSquareRenderable

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 4;
        _numIndices = 4;
        _verts = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertVels = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _indices = (unsigned int*)malloc(_numIndices*sizeof(unsigned int));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _vertsUntransformed[0] = vec2(1,1);
        _vertsUntransformed[1] = vec2(-1,1);
        _vertsUntransformed[2] = vec2(-1,-1);
        _vertsUntransformed[3] = vec2(1,-1);
        
        _vertShapeUVs[0] = vec2(1,0);
        _vertShapeUVs[1] = vec2(0,0);
        _vertShapeUVs[2] = vec2(0,1);
        _vertShapeUVs[3] = vec2(1,1);
        
        _vertPatternUVs[0] = vec2(1,0);
        _vertPatternUVs[1] = vec2(0,0);
        _vertPatternUVs[2] = vec2(0,1);
        _vertPatternUVs[3] = vec2(1,1);
        
        _indices[0] = 0;
        _indices[1] = 1;
        _indices[2] = 3;
        _indices[3] = 2;
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"square.jpg"].name;
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_square.png"].name;
    }
    return self;
}

/*
-(void)step:(float)dt {
    //[super step:dt];
    
    _vertOffsets[0] = vec2(0,0);
    _vertOffsets[1] = vec2(-.2,.2);
    _vertOffsets[2] = vec2(0,0);
    _vertOffsets[3] = vec2(0,0);
}
*/


@end

@implementation BouncePentagonRenderable

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 6;
        _numIndices = 7;
        _mode = GL_TRIANGLE_FAN;
        
        _verts = (vec2*)realloc(_verts,_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)realloc(_vertsUntransformed, _numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)realloc(_vertOffsets,_numVerts*sizeof(vec2));
        _vertVels = (vec2*)realloc(_vertVels,_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)realloc(_vertShapeUVs,_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)realloc(_vertPatternUVs,_numVerts*sizeof(vec2));
        _indices = (unsigned int*)realloc(_indices,_numIndices*sizeof(unsigned int));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        float cos72 = .309016994375;
        float sin72 = .951056516295;
        vec2 vert = vec2(0,1.105572809);
        
        _vertsUntransformed[0] = vert;
        
        vert.rotate(cos72,sin72);
        _vertsUntransformed[1] = vert;
        
        vert.rotate(cos72,sin72);
        _vertsUntransformed[2] = vert;
        
        vert.rotate(cos72,sin72);
        _vertsUntransformed[3] = vert;
        
        vert.rotate(cos72,sin72);
        _vertsUntransformed[4] = vert;
        
        _vertsUntransformed[5] = vec2(0,0);
        
        for(int i = 0; i < _numVerts; i++) {
            vec2 uv = _vertsUntransformed[i];
            uv.x *= .5;
            uv.y *= -.5;
            uv += vec2(.5,.5);
            _vertShapeUVs[i] = uv;
            _vertPatternUVs[i] = uv;
        }
        
        _indices[0] = 5;
        _indices[1] = 0;
        _indices[2] = 1;
        _indices[3] = 2;
        _indices[4] = 3;
        _indices[5] = 4;
        _indices[6] = 0;
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"pentagon.jpg"].name;
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_pentagon.png"].name;
    }
    return self;
}

@end


@implementation BounceRectangleRenderable

-(id)initWithInputs:(BounceRenderableInputs)inputs aspect:(float)aspect {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 13;
        _numIndices = 24;
        _verts = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _indices = (unsigned int*)malloc(_numIndices*sizeof(unsigned int));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        
        _vertVels = (vec2*)malloc(4*sizeof(vec2));
        memset(_vertVels, 0, 4*sizeof(vec2));
        
        _aspect = aspect;
        
        [self setupVertData];
        
        _indices[0] = 2;
        _indices[1] = 3;
        _indices[2] = 9;
        _indices[3] = 4;
        _indices[4] = 10;
        _indices[5] = 5;
        _indices[6] = 12;
        _indices[7] = 6;
        _indices[8] = 11;
        _indices[9] = 7;
        _indices[10] = 8;
        _indices[11] = 0;
        _indices[12] = 1;
        _indices[13] = 1;
        _indices[14] = 8;
        _indices[15] = 12;
        _indices[16] = 11;
        _indices[17] = 11;
        _indices[18] = 1;
        _indices[19] = 1;
        _indices[20] = 2;
        _indices[21] = 12;
        _indices[22] = 9;
        _indices[23] = 10;
        
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"square.jpg"].name;
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_square.png"].name;  
    }
    return self;
}

-(void)setupVertData {
    NSAssert(_aspect >= 1, @"aspect ratio for rectangle bounce renderable must be >= 1");
    
    float texAspect = (_aspect+1)*.5; // correction for glow in texture
    
    float scale = texAspect/_aspect;
    float invTexAspect = 1./texAspect;
        
    float aspect_1 = (texAspect-1)*invTexAspect;
    
    float y = (1-aspect_1)*invTexAspect;
    
    _vertsUntransformed[0] = scale*vec2(1,invTexAspect);
    _vertsUntransformed[1] = scale*vec2(aspect_1, invTexAspect);
    _vertsUntransformed[2] = scale*vec2(-aspect_1, invTexAspect);
    _vertsUntransformed[3] = scale*vec2(-1,invTexAspect);
    
    _vertsUntransformed[4] = scale*vec2(-1,-invTexAspect);
    _vertsUntransformed[5] = scale*vec2(-aspect_1,-invTexAspect);
    _vertsUntransformed[6] = scale*vec2(aspect_1,-invTexAspect);
    _vertsUntransformed[7] = scale*vec2(1,-invTexAspect);
    
    _vertsUntransformed[8] = scale*vec2(aspect_1, invTexAspect-y);
    _vertsUntransformed[9] = scale*vec2(-aspect_1, invTexAspect-y);
    _vertsUntransformed[10] = scale*vec2(-aspect_1, -invTexAspect+y);
    _vertsUntransformed[11] = scale*vec2(aspect_1, -invTexAspect+y);
    _vertsUntransformed[12] = vec2(0, 0);
    
    _vertsUntransformedRectangle[0] = _vertsUntransformed[0];
    _vertsUntransformedRectangle[1] = _vertsUntransformed[3];
    _vertsUntransformedRectangle[2] = _vertsUntransformed[4];
    _vertsUntransformedRectangle[3] = _vertsUntransformed[7];
    
    _vertShapeUVs[0] = vec2(1,0);
    _vertShapeUVs[1] = vec2(.5,0);
    _vertShapeUVs[2] = vec2(.5,0);
    _vertShapeUVs[3] = vec2(0,0);
    
    _vertShapeUVs[4] = vec2(0,1);
    _vertShapeUVs[5] = vec2(.5,1);
    _vertShapeUVs[6] = vec2(.5,1);
    _vertShapeUVs[7] = vec2(1,1);
    
    float sv0 = y/(2*invTexAspect);
    float sv1 = (2*invTexAspect-y)/(2*invTexAspect);
    
    _vertShapeUVs[8] = vec2(.5, sv0);
    _vertShapeUVs[9] = vec2(.5, sv0);
    _vertShapeUVs[10] = vec2(.5, sv1);
    _vertShapeUVs[11] = vec2(.5, sv1);
    
    _vertShapeUVs[12] = vec2(.5,.5);
    
    float u0 = .5*aspect_1+.5;
    float u1 = -.5*aspect_1+.5;
    
    float v0 = .5*(1-invTexAspect);
    float v1 = .5*(1+invTexAspect);
    
    _vertPatternUVs[0] = vec2(1,v0);
    _vertPatternUVs[1] = vec2(u0,v0);
    _vertPatternUVs[2] = vec2(u1,v0);
    _vertPatternUVs[3] = vec2(0,v0);
    
    _vertPatternUVs[4] = vec2(0,v1);
    _vertPatternUVs[5] = vec2(u1,v1);
    _vertPatternUVs[6] = vec2(u0,v1);
    _vertPatternUVs[7] = vec2(1,v1);
    
    float pv0 = (1-sv0)*v0+sv0*v1;
    float pv1 = sv0*v0+(1-sv0)*v1;
    _vertPatternUVs[8] = vec2(u0, pv0);
    _vertPatternUVs[9] = vec2(u1, pv0);
    _vertPatternUVs[10] = vec2(u1, pv1);
    _vertPatternUVs[11] = vec2(u0, pv1);
    
    _vertPatternUVs[12] = vec2(.5, .5);
}

-(void)setAspect:(float)aspect {
    _aspect = aspect;
    
    [self setupVertData];
}
-(float)aspect {
    return _aspect;
}

-(void)burst: (float)scale {
    for(int i = 0; i < 4; i++) {
        vec2 vert = _vertsUntransformedRectangle[i];
        _vertVels[i] += _bounciness*scale*vert;
    }
}

-(void)step:(float)dt { 
    float texAspect = (_aspect+1)*.5;
    float invTexAspect = 1./texAspect;
    
    float spring_k = 200;
    float drag = .2;
    
    float size = *_inputs.size;
    float c = size*.75*invTexAspect;
    
    for(int i = 0; i < 4; i++) {
        _vertOffsetsRectangle[i] += _vertVels[i]*dt;
        vec2 a = -spring_k*_vertOffsetsRectangle[i];
        
        _vertVels[i] +=  a*dt-drag*_vertVels[i];
        
        _vertOffsetsRectangle[i].clamp(-c, c);
    }
    
    
    /*
     _vertOffsetsRectangle[0] = vec2(.2,.2);
     _vertOffsetsRectangle[1] = vec2(0,0);
     _vertOffsetsRectangle[2] = vec2(0,0);
     _vertOffsetsRectangle[3] = vec2(0,0);
     */
    
}

-(void)collideAt:(const vec2 &)pos withVelocity:(const vec2 &)vel {
    
    int closest_j = -1;
    int closest_j2 = -1;
    float min_dist = 9999;
    float min_dist2 = 9999;
    
    float size = *_inputs.size;
    
    for(int j = 0; j < 4; j++) {
        vec2 vert = _vertsUntransformedRectangle[j]*size;
        float dist = (pos-vert).length();
        if(dist < min_dist) {
            closest_j = j;
            min_dist = dist;
            
            closest_j2 = closest_j;
            min_dist2 = min_dist;
        } else if(dist < min_dist2) {
            closest_j2 = j;
            min_dist2 = dist;
        }
    }
    
    _vertVels[closest_j] += 2*_bounciness*vel;
    _vertVels[closest_j2] += 2*_bounciness*vel;
    
}

-(void)updateOffsets {
    
    float t = (_vertsUntransformed[1].x-_vertsUntransformedRectangle[0].x)/
    (_vertsUntransformedRectangle[1].x-_vertsUntransformedRectangle[0].x);
    
    float t2 = 1-t;
    
    vec2 verts[4];
    verts[0] = _vertsUntransformedRectangle[0]+_vertOffsetsRectangle[0];
    verts[1] = _vertsUntransformedRectangle[1]+_vertOffsetsRectangle[1];
    verts[2] = _vertsUntransformedRectangle[2]+_vertOffsetsRectangle[2];
    verts[3] = _vertsUntransformedRectangle[3]+_vertOffsetsRectangle[3];
    
    _vertOffsets[0] = _vertOffsetsRectangle[0];
    _vertOffsets[1] = verts[0]*t2+verts[1]*t-_vertsUntransformed[1];
    _vertOffsets[2] = verts[0]*t+verts[1]*t2-_vertsUntransformed[2];
    _vertOffsets[3] = _vertOffsetsRectangle[1];
    
    _vertOffsets[4] = _vertOffsetsRectangle[2];
    _vertOffsets[5] = verts[2]*t2+verts[3]*t-_vertsUntransformed[5];
    _vertOffsets[6] = verts[2]*t+verts[3]*t2-_vertsUntransformed[6];    
    _vertOffsets[7] = _vertOffsetsRectangle[3];
    
    t = (_vertsUntransformed[8]-_vertsUntransformedRectangle[0]).length()/
    (_vertsUntransformedRectangle[2]-_vertsUntransformedRectangle[0]).length();
    
    t2 = 1-t;
    
    vec2 center = verts[0]*.5+verts[2]*.5;
    
    _vertOffsets[8] = verts[0]*t2+verts[2]*t-_vertsUntransformed[8];
    _vertOffsets[10] = verts[2]*t2+verts[0]*t-_vertsUntransformed[10];
    _vertOffsets[12] = center-_vertsUntransformed[12];
    
    
    t = (_vertsUntransformed[9]-_vertsUntransformedRectangle[1]).length()/
    (_vertsUntransformed[12]-_vertsUntransformedRectangle[1]).length();
    t2 = 1-t;
    
    _vertOffsets[9] = verts[1]*t2+center*t-_vertsUntransformed[9];
    
    
    t = (_vertsUntransformed[11]-_vertsUntransformedRectangle[3]).length()/
    (_vertsUntransformed[12]-_vertsUntransformedRectangle[3]).length();
    t2 = 1-t;
    _vertOffsets[11] = verts[3]*t2+center*t-_vertsUntransformed[11];
    
    
}

-(void)draw {
    [self updateOffsets];
    [super draw];
}

-(void)drawSelected {
    [self updateOffsets];
    [super drawSelected];
}
@end

@implementation BounceCapsuleRenderable

-(id)initWithInputs:(BounceRenderableInputs)inputs aspect:(float)aspect {
    self = [super initWithInputs:inputs aspect:aspect];
    
    if(self) {
        _shapeTexture = [[FSATextureManager instance] getTexture:@"ball.jpg"].name;
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_ball.png"].name;  
    }
    return self;
}
@end


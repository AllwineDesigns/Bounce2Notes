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
#import "FSABufferManager.h"

@implementation BounceRenderable

@synthesize blendMode = _blendMode;
@synthesize inputs = _inputs;
@synthesize bounciness = _bounciness;
@synthesize shapeTexture = _shapeTexture;
@synthesize stationaryTexture = _stationaryTexture;

-(id)initWithData:(BounceRenderableData &)data {
    BounceRenderableInputs inputs;
    inputs.intensity = &data.intensity;
    inputs.isStationary = &data.isStationary;
    inputs.color = &data.color;
    inputs.position = &data.position;
    inputs.size = &data.size;
    inputs.angle = &data.angle;
    inputs.patternTexture = &data.patternTexture;
       
    return [self initWithInputs:inputs];
}
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
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, _blendMode);
    BOOL isStationary = *_inputs.isStationary;

    FSAShader *objectShader;
    if(isStationary) {
        objectShader = [shaderManager getShader:@"SingleObjectStationaryShader"];
    } else {
        objectShader = [shaderManager getShader:@"SingleObjectShader"];
    }
    
    float size = *_inputs.size;
    float angle = *_inputs.angle;
    vec2 pos = *_inputs.position;
    FSATexture* patternTexture = *_inputs.patternTexture;
    
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
    glBindTexture(GL_TEXTURE_2D, _shapeTexture.name);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, patternTexture.name);
    
    
    [objectShader setPtr:&shapeTex forUniform:@"shapeTexture"];
    [objectShader setPtr:&patternTex forUniform:@"patternTexture"];
    
    if(isStationary) {
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, _stationaryTexture.name);
        GLuint stationaryTex = 2;
        [objectShader setPtr:&stationaryTex forUniform:@"stationaryTex"];
    }

    [objectShader setPtr:_verts forAttribute:@"position"];
    [objectShader setPtr:_vertShapeUVs forAttribute:@"shapeUV"];
    [objectShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];
    
    [_indexBuffer bind];
    
    [objectShader enable];
     glDrawElements(_mode, _indexBuffer.count, GL_UNSIGNED_INT, 0);
    [objectShader disable];
    
    /*
    if(isStationary) {
        [stationaryShader setPtr:_inputs.color forUniform:@"color"];
        
        GLuint stationaryTex = 0;
        GLuint patternTex = 1;
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _stationaryTexture.name);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, patternTexture.name);
        [stationaryShader setPtr:&stationaryTex forUniform:@"texture"];
        [stationaryShader setPtr:&patternTex forUniform:@"pattern"];
        
        [stationaryShader setPtr:_verts forAttribute:@"position"];
        [stationaryShader setPtr:_vertShapeUVs forAttribute:@"uv"];
        [stationaryShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];
        
        [stationaryShader enable];
         glDrawElements(_mode, _indexBuffer.count, GL_UNSIGNED_INT, 0);
        [stationaryShader disable];
    }
     */
    [_indexBuffer unbind];
    glDisable(GL_BLEND);
}

-(void)scalePatternUVs:(const vec2 &)scale {
    for(int i = 0; i < _numVerts; i++) {
        _vertPatternUVs[i] *= scale;
    }
}

-(void)translatePatternUVs:(const vec2 &)translate {
    for(int i = 0; i < _numVerts; i++) {
        _vertPatternUVs[i] += translate;
    }
}

-(void)burst:(float)scale {
    for(int i = 0; i < _numVerts; i++) {
        vec2 vert = _vertsUntransformed[i];
        _vertVels[i] += scale*vert;
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
    
    _vertVels[closest_j] += (1.1111111111*_bounciness)*vel;
    _vertVels[closest_j2] += (1.1111111111*_bounciness)*vel;
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
    glBindTexture(GL_TEXTURE_2D, _shapeTexture.name);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, [[FSATextureManager instance] getTexture:@"black.jpg"].name);
    
    [objectShader setPtr:&shapeTex forUniform:@"shapeTexture"];
    [objectShader setPtr:&patternTex forUniform:@"patternTexture"];
    
    [objectShader setPtr:_verts forAttribute:@"position"];
    [objectShader setPtr:_vertShapeUVs forAttribute:@"shapeUV"];
    [objectShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];
    
    [_indexBuffer bind];
    
    [objectShader enable];
    glDrawElements(_mode, _indexBuffer.count, GL_UNSIGNED_INT, 0);
    [objectShader disable];
    
    [_indexBuffer unbind];
    
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
    
    [_indexBuffer release];
    
    [super dealloc];
}

@end

@implementation BounceBallRenderable

+(void)initialize {
    unsigned int indices[4];
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 3;
    indices[3] = 2;
    
    FSABuffer *ballBuffer = [[FSABuffer alloc] initElementArrayWithData:indices count:4];
    [[FSABufferManager instance] addBuffer:ballBuffer name:@"ballBuffer"];
}

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 4;
        _verts = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertVels = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
                
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _indexBuffer = [[FSABufferManager instance] getBuffer:@"ballBuffer"];
        [_indexBuffer retain];
        
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
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"ball.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_ball.png"];
    }
    
    return self;
}

@end

@implementation BounceGenericRenderable

+(void)initialize {
    unsigned int indices[4];
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 3;
    indices[3] = 2;
    
    FSABuffer *buffer = [[FSABuffer alloc] initElementArrayWithData:indices count:4];
    [[FSABufferManager instance] addBuffer:buffer name:@"lockedBuffer"];
}

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 4;
        _verts = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertVels = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _indexBuffer = [[FSABufferManager instance] getBuffer:@"lockedBuffer"];
        [_indexBuffer retain];
        
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
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
    }
    
    return self;
}

@end

@implementation BounceTriangleRenderable

+(void)initialize {
    unsigned int indices[3];
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    
    FSABuffer *buffer = [[FSABuffer alloc] initElementArrayWithData:indices count:3];
    [[FSABufferManager instance] addBuffer:buffer name:@"triangleBuffer"];
}

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 3;
        _verts = (vec2*)realloc(_verts,_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)realloc(_vertsUntransformed, _numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)realloc(_vertOffsets,_numVerts*sizeof(vec2));
        _vertVels = (vec2*)realloc(_vertVels,_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)realloc(_vertShapeUVs,_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)realloc(_vertPatternUVs,_numVerts*sizeof(vec2));

        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _indexBuffer = [[FSABufferManager instance] getBuffer:@"triangleBuffer"];
        [_indexBuffer retain];
        
        _vertsUntransformed[0] = vec2(0,1.3333333333);
        _vertsUntransformed[1] = vec2(-1.15470053838,-.66666666667);
        _vertsUntransformed[2] = vec2(1.1547005383,-.66666666667);
        
        _vertShapeUVs[0] = vec2(.5,-.166666666667);
        _vertShapeUVs[1] = vec2(-.07735026919,.83333333333);
        _vertShapeUVs[2] = vec2(1.07735026919,.83333333333);
        
        _vertPatternUVs[0] = vec2(.5,-.166666666667);
        _vertPatternUVs[1] = vec2(-.07735026919,.83333333333);
        _vertPatternUVs[2] = vec2(1.07735026919,.83333333333);
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"triangle.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_triangle.png"];
    }
    return self;
}

@end

@implementation BounceSquareRenderable

+(void)initialize {
    unsigned int indices[4];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 3;
    indices[3] = 2;
    
    FSABuffer *buffer = [[FSABuffer alloc] initElementArrayWithData:indices count:4];
    [[FSABufferManager instance] addBuffer:buffer name:@"squareBuffer"];
}

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 4;
        _verts = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertVels = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _indexBuffer = [[FSABufferManager instance] getBuffer:@"squareBuffer"];
        [_indexBuffer retain];
        
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
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"square.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_square.png"];
    }
    return self;
}

@end

@implementation BounceNoteRenderable

+(void)initialize {
    unsigned int indices[4];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 3;
    indices[3] = 2;
    
    FSABuffer *buffer = [[FSABuffer alloc] initElementArrayWithData:indices count:4];
    [[FSABufferManager instance] addBuffer:buffer name:@"noteBuffer"];
}

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 4;
        _verts = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertVels = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _indexBuffer = [[FSABufferManager instance] getBuffer:@"noteBuffer"];
        [_indexBuffer retain];
        
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
        
        for(int i = 0; i < 4; i++) {
            _vertPatternUVs[i] *= 1.7857142;
            _vertPatternUVs[i] += vec2(-.25,.25);
        }
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"note.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_note.png"];
    }
    return self;
}

-(void)drawSelected {
    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    FSAShader *objectShader = [shaderManager getShader:@"SingleObjectShader"];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    
    float s = *_inputs.size;
    float angle = *_inputs.angle;
    vec2 pos = *_inputs.position;
    
    float size = 2*s;
    
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
    glBindTexture(GL_TEXTURE_2D, _shapeTexture.name);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, [[FSATextureManager instance] getTexture:@"black.jpg"].name);
    
    [objectShader setPtr:&shapeTex forUniform:@"shapeTexture"];
    [objectShader setPtr:&patternTex forUniform:@"patternTexture"];
    
    [objectShader setPtr:_verts forAttribute:@"position"];
    [objectShader setPtr:_vertShapeUVs forAttribute:@"shapeUV"];
    [objectShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];
    
    [_indexBuffer bind];
    
    [objectShader enable];
    glDrawElements(_mode, _indexBuffer.count, GL_UNSIGNED_INT, 0);
    [objectShader disable];
    
    [_indexBuffer unbind];
    
    glDisable(GL_BLEND);
    
}

@end


@implementation BouncePentagonRenderable

+(void)initialize {
    unsigned int indices[7];
    
    indices[0] = 5;
    indices[1] = 0;
    indices[2] = 1;
    indices[3] = 2;
    indices[4] = 3;
    indices[5] = 4;
    indices[6] = 0;
    
    FSABuffer *buffer = [[FSABuffer alloc] initElementArrayWithData:indices count:7];
    [[FSABufferManager instance] addBuffer:buffer name:@"pentagonBuffer"];
}

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 6;
        _mode = GL_TRIANGLE_FAN;
        
        _verts = (vec2*)realloc(_verts,_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)realloc(_vertsUntransformed, _numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)realloc(_vertOffsets,_numVerts*sizeof(vec2));
        _vertVels = (vec2*)realloc(_vertVels,_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)realloc(_vertShapeUVs,_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)realloc(_vertPatternUVs,_numVerts*sizeof(vec2));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _indexBuffer = [[FSABufferManager instance] getBuffer:@"pentagonBuffer"];
        [_indexBuffer retain];
        
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

        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"pentagon.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_pentagon.png"];
    }
    return self;
}

@end

@implementation BounceStarRenderable

+(void)initialize {
    unsigned int indices[7];
    
    indices[0] = 5;
    indices[1] = 0;
    indices[2] = 1;
    indices[3] = 2;
    indices[4] = 3;
    indices[5] = 4;
    indices[6] = 0;
    
    FSABuffer *buffer = [[FSABuffer alloc] initElementArrayWithData:indices count:7];
    [[FSABufferManager instance] addBuffer:buffer name:@"starBuffer"];
}

-(id)initWithInputs:(BounceRenderableInputs)inputs {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 6;
        _mode = GL_TRIANGLE_FAN;
        
        _verts = (vec2*)realloc(_verts,_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)realloc(_vertsUntransformed, _numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)realloc(_vertOffsets,_numVerts*sizeof(vec2));
        _vertVels = (vec2*)realloc(_vertVels,_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)realloc(_vertShapeUVs,_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)realloc(_vertPatternUVs,_numVerts*sizeof(vec2));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        memset(_vertVels, 0, _numVerts*sizeof(vec2));
        
        _indexBuffer = [[FSABufferManager instance] getBuffer:@"starBuffer"];
        [_indexBuffer retain];
        
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
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"star.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_star.png"];
    }
    return self;
}

@end



@implementation BounceRectangleRenderable

+(void)initialize {
    unsigned int indices[24];
    
    indices[0] = 2;
    indices[1] = 3;
    indices[2] = 9;
    indices[3] = 4;
    indices[4] = 10;
    indices[5] = 5;
    indices[6] = 12;
    indices[7] = 6;
    indices[8] = 11;
    indices[9] = 7;
    indices[10] = 8;
    indices[11] = 0;
    indices[12] = 1;
    indices[13] = 1;
    indices[14] = 8;
    indices[15] = 12;
    indices[16] = 11;
    indices[17] = 11;
    indices[18] = 1;
    indices[19] = 1;
    indices[20] = 2;
    indices[21] = 12;
    indices[22] = 9;
    indices[23] = 10;
        
    FSABuffer *buffer = [[FSABuffer alloc] initElementArrayWithData:indices count:24];
    [[FSABufferManager instance] addBuffer:buffer name:@"rectangleBuffer"];
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


-(id)initWithInputs:(BounceRenderableInputs)inputs aspect:(float)aspect {
    self = [super initWithInputs:inputs];
    
    if(self) {
        _numVerts = 13;
        _verts = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        _vertShapeUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(_numVerts*sizeof(vec2));
        
        memset(_vertOffsets, 0, _numVerts*sizeof(vec2));
        
        _vertVels = (vec2*)malloc(4*sizeof(vec2));
        memset(_vertVels, 0, 4*sizeof(vec2));
        
        _indexBuffer = [[FSABufferManager instance] getBuffer:@"rectangleBuffer"];
        [_indexBuffer retain];
        
        _aspect = aspect;
        
        [self setupVertData];
        
        _shapeTexture = [[FSATextureManager instance] getTexture:@"square.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_square.png"];  
    }
    return self;
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
        _vertVels[i] += scale*vert;
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
    
    _vertVels[closest_j] += 1.1111111111*_bounciness*vel;
    _vertVels[closest_j2] += 1.1111111111*_bounciness*vel;
    
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

+(void)initialize {
    unsigned int indices[24];
    
    indices[0] = 2;
    indices[1] = 3;
    indices[2] = 9;
    indices[3] = 4;
    indices[4] = 10;
    indices[5] = 5;
    indices[6] = 12;
    indices[7] = 6;
    indices[8] = 11;
    indices[9] = 7;
    indices[10] = 8;
    indices[11] = 0;
    indices[12] = 1;
    indices[13] = 1;
    indices[14] = 8;
    indices[15] = 12;
    indices[16] = 11;
    indices[17] = 11;
    indices[18] = 1;
    indices[19] = 1;
    indices[20] = 2;
    indices[21] = 12;
    indices[22] = 9;
    indices[23] = 10;
    
    FSABuffer *buffer = [[FSABuffer alloc] initElementArrayWithData:indices count:24];
    [[FSABufferManager instance] addBuffer:buffer name:@"capsuleBuffer"];
}

-(id)initWithInputs:(BounceRenderableInputs)inputs aspect:(float)aspect {
    self = [super initWithInputs:inputs aspect:aspect];
    
    if(self) {
        _shapeTexture = [[FSATextureManager instance] getTexture:@"ball.jpg"];
        _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_ball.png"];  
    }
    return self;
}
@end


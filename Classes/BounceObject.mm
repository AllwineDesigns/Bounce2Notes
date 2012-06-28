//
//  BounceObject.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceObject.h"
#import <fsa/Noise.hpp>
#import "FSATextureManager.h"
#import "FSAShaderManager.h"
#import "FSAUtil.h"
#import "BounceSimulation.h"
#import <chipmunk/chipmunk_unsafe.h>

@implementation BounceObject

@synthesize isStationary = _isStationary;
@synthesize color = _color;
@synthesize shapeTexture = _shapeTexture;
@synthesize stationaryTexture = _stationaryTexture;
@synthesize patternTexture = _patternTexture;
@synthesize intensity = _intensity;
@synthesize age = _age;
@synthesize lastVelocity = _lastVelocity;
@synthesize sound = _sound;

+(id)randomObjectAt: (const vec2&)loc {
    BounceObject *obj = [[BounceObject alloc] initRandomObjectAt:loc];
    [obj autorelease];
    return obj;
}
+(id)randomObjectAt:(const vec2 &)loc withVelocity:(const vec2&)vel {
    BounceObject *obj = [[BounceObject alloc] initRandomObjectAt:loc withVelocity:vel];
    [obj autorelease];
    return obj;
}
+(id)randomObjectWithShape: (BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2&)vel {
    BounceObject *obj = [[BounceObject alloc] initRandomObjectWithShape:bounceShape at:loc withVelocity:vel];
    [obj autorelease];
    return obj;
}

+(id)objectWithShape: (BounceShape)bounceShape at:(const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color withSize:(float)size withAngle:(float)angle {
    BounceObject *obj = [[BounceObject alloc] initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle ];
    [obj autorelease];
    return obj;
}

-(id)initRandomObjectAt: (const vec2&)loc {
    vec2 vel;
    return [self initRandomObjectAt:loc withVelocity:vel];
}
-(id)initRandomObjectAt: (const vec2&)loc withVelocity:(const vec2&)vel {
    BounceShape bounceShape = BounceShape(random(loc*23.9273)*NUM_BOUNCE_SHAPES);
    return [self initRandomObjectWithShape:bounceShape at:loc withVelocity:vel];
}

-(id)initRandomObjectWithShape: (BounceShape)bounceShape at: (const vec2&)loc withVelocity:(const vec2&)vel {
    float size = random(loc*1.234)*.2+.05;
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             360.*random(64.28327*loc), .4, .05*random(736.2827*loc)+.75   );
    color.w = 1;
    float angle = 2*PI*random(34.2938*loc);
    
    return [self initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
}

-(id)initObjectWithShape: (BounceShape)bounceShape at:(const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color  withSize:(float)size withAngle:(float)angle {
    
    self = [super init];
    
    if(self) {
        _size = size;
        //_size = .1;
        _color = color;
        
        _isStationary = NO;
//        NSArray *textures = [NSArray arrayWithObjects:@"black.jpg", @"white.jpg", @"spiral.jpg", @"stripes.jpg", @"checkered.jpg", @"sections.jpg", @"squares.jpg", @"weave.jpg", @"plasma.jpg", nil];

//       NSString* texName = [textures objectAtIndex:(int)([textures count]*random(loc*.24952))];
        NSString* texName = @"spiral.jpg";
        _patternTexture = [[FSATextureManager instance] getTexture:texName];
        
        _verts = (vec2*)malloc(4*sizeof(vec2));
        _vertsUntransformed = (vec2*)malloc(4*sizeof(vec2));
        _vertOffsets = (vec2*)malloc(4*sizeof(vec2));
        _vertShapeUVs = (vec2*)malloc(4*sizeof(vec2));
        _vertPatternUVs = (vec2*)malloc(4*sizeof(vec2));
        _vertVels = (vec2*)malloc(4*sizeof(vec2));
        _indices = (unsigned int*)malloc(6*sizeof(unsigned int));
        _numVerts = 0;
        _numIndices = 0;
        
        _sound = [[BounceSound alloc] initWithBounceObject:self];
                
        [self setBounceShape:bounceShape];
        
        cpBodySetPos(_body, (const cpVect&)loc);
        cpBodySetVel(_body, (const cpVect&)vel);
        cpBodySetAngle(_body, angle);
        cpBodySetVelLimit(_body, 5);
        cpBodySetAngVelLimit(_body, 50);
        cpBodySetUserData(_body, self);
        
        for(int i = 0; i < _numShapes; i++) {
            cpShapeSetFriction(_shapes[i], .5);
            cpShapeSetElasticity(_shapes[i], .95);
            cpShapeSetCollisionType(_shapes[i], OBJECT_TYPE);
        }


  /*      
        _vertUVs[0] = vec2(1,1);
        _vertUVs[1] = vec2(0,1);
        _vertUVs[2] = vec2(0,0);
        _vertUVs[3] = vec2(1,0);
   */
        
        /*
        _vertShapeUVs[0] = vec2(1,0);
        _vertShapeUVs[1] = vec2(0,0);
        _vertShapeUVs[2] = vec2(0,1);
        _vertShapeUVs[3] = vec2(1,1);
        
        _vertPatternUVs[0] = vec2(1,0);
        _vertPatternUVs[1] = vec2(0,0);
        _vertPatternUVs[2] = vec2(0,1);
        _vertPatternUVs[3] = vec2(1,1);
         */
         
        
        /*
        int x = 5*random(loc*76.345);
        int y = 5*random(loc*23.29003);
        
        _vertPatternUVs[0] = vec2(.2*(x+1),.2*y);
        _vertPatternUVs[1] = vec2(.2*x,.2*y);
        _vertPatternUVs[2] = vec2(.2*x,.2*(y+1));
        _vertPatternUVs[3] = vec2(.2*(x+1),.2*(y+1));
         */

        /*
        _indices[0] = 0;
        _indices[1] = 1;
        _indices[2] = 3;
        
        _indices[3] = 1;
        _indices[4] = 2;
        _indices[5] = 3;
         */
    }
    
    return self;
}

-(void)clearShapes {
    for(int i = 0; i < _numShapes; i++) {
        cpSpaceRemoveShape(_space, _shapes[i]);
    }
}

-(BounceShape)bounceShape {
    return _bounceShape;
}

-(void)setBounceShape:(BounceShape)bounceShape {
    _bounceShape = bounceShape;
    [self removeAllShapes];
    switch(bounceShape) {
        case BOUNCE_BALL:
            [self setupBall];
            break;
        case BOUNCE_SQUARE:
            [self setupSquare];
            break;
        case BOUNCE_TRIANGLE:
            [self setupTriangle];
            break;
        case BOUNCE_PENTAGON:
            [self setupPentagon];
            break;
        default:
            NSAssert(NO, @"attempting to set unknown shape\n");
            break;
    }
}

-(float)size {
    return _size;
}

-(void)setSize:(float)s {
    float old_size = _size;
    _size = s;

    if(_size > 1) {
        _size = 1;
    } else if(_size < .01) {
        _size = .01;
    }
    
    [_sound resized:old_size];
    
    switch(_bounceShape) {
        case BOUNCE_BALL:
            [self resizeBall];
            break;
        case BOUNCE_SQUARE:
            [self resizeSquare];
            break;
        case BOUNCE_TRIANGLE:
            [self resizeTriangle];
            break;
        case BOUNCE_PENTAGON:
            [self resizePentagon];
            break;
        default:
            NSAssert(NO, @"resizing unknown shape\n");
            break;
    }
    if(_space != NULL) {
        cpSpaceReindexShapesForBody(_space, _body);
    }
}

-(void)setupSquareVerts {
    _numVerts = 4;
    _numIndices = 6;
    _verts = (vec2*)realloc(_verts,_numVerts*sizeof(vec2));
    _vertsUntransformed = (vec2*)realloc(_vertsUntransformed, _numVerts*sizeof(vec2));
    _vertOffsets = (vec2*)realloc(_vertOffsets,_numVerts*sizeof(vec2));
    _vertVels = (vec2*)realloc(_vertVels,_numVerts*sizeof(vec2));

    _vertShapeUVs = (vec2*)realloc(_vertShapeUVs,_numVerts*sizeof(vec2));
    _vertPatternUVs = (vec2*)realloc(_vertPatternUVs,_numVerts*sizeof(vec2));
    _indices = (unsigned int*)realloc(_indices,_numIndices*sizeof(unsigned int));
    
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
    
    _indices[3] = 1;
    _indices[4] = 2;
    _indices[5] = 3;
}

-(void)setupTriangleVerts {
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
}

-(void)setupPentagonVerts {
    _numVerts = 6;
    _numIndices = 15;
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
    
    _indices[0] = 0;
    _indices[1] = 1;
    _indices[2] = 5;
    
    _indices[3] = 1;
    _indices[4] = 2;
    _indices[5] = 5;
    
    _indices[6] = 2;
    _indices[7] = 3;
    _indices[8] = 5;
    
    _indices[9] = 3;
    _indices[10] = 4;
    _indices[11] = 5;
    
    _indices[12] = 4;
    _indices[13] = 0;
    _indices[14] = 5;
    
}

-(void)setupBall {
    [self setMass:100*_size*_size];
    [self setMoment:.02*cpMomentForCircle(_mass, 0, _size, cpvzero)];
    [self addCircleShapeWithRadius:_size withOffset:cpvzero];
    
    [self setupSquareVerts];
    
    _shapeTexture = [[FSATextureManager instance] getTexture:@"ball.jpg"];
    _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_ball.png"];
}

-(void)setupSquare {
    vec2 square_verts[4];
    square_verts[0].x = _size;
    square_verts[0].y = _size;
    
    square_verts[1].x = _size;
    square_verts[1].y = -_size;
    
    square_verts[2].x = -_size;
    square_verts[2].y = -_size;
    
    square_verts[3].x = -_size;
    square_verts[3].y = _size;
    
    [self setMass:(4/PI)*100*_size*_size];
    [self setMoment:5*cpMomentForBox(_mass, _size*2, _size*2)];
    
    [self addPolyShapeWithNumVerts:4 withVerts:square_verts withOffset:cpvzero];
    
    [self setupSquareVerts];
    
    _shapeTexture = [[FSATextureManager instance] getTexture:@"square.jpg"];
    _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_square.png"];

}

-(void)setupTriangle {
    float cos30 = .866025403784; // sqrt(3)/2
    float sin30 = .5;
    vec2 verts[3];
    verts[0].x = 0;
    verts[0].y = _size*1.333333;
    
    verts[1].x = _size*cos30*1.333333;
    verts[1].y = -_size*sin30*1.333333;
    
    verts[2].x = -_size*cos30*1.333333;
    verts[2].y = -_size*sin30*1.333333;
    
    [self setMass:.735105193893*100*_size*_size];
    [self setMoment:5*cpMomentForPoly(_mass, 3, (cpVect*)verts, cpvzero)];
    
    [self addPolyShapeWithNumVerts:3 withVerts:verts withOffset:cpvzero];
    
    [self setupTriangleVerts];
    
    _shapeTexture = [[FSATextureManager instance] getTexture:@"triangle.jpg"];
    _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_triangle.png"];

}

-(void)setupPentagon {
    float cos72 = .309016994375;
    float sin72 = .951056516295;
    
    vec2 vert(0, _size*1.05572809);
    
    vec2 verts[5];
    verts[0] = vert;
    
    vert.rotate(cos72,sin72);
    verts[1] = vert;
    
    vert.rotate(cos72,sin72);
    verts[2] = vert;
    
    vert.rotate(cos72,sin72);
    verts[3] = vert;
    
    vert.rotate(cos72,sin72);
    verts[4] = vert;
    
    [self setMass:.925062677588*100*_size*_size];
    [self setMoment:5*cpMomentForPoly(_mass, 5, (cpVect*)verts, cpvzero)];
    
    [self addPolyShapeWithNumVerts:5 withVerts:verts withOffset:cpvzero];
    
    [self setupPentagonVerts];
    
    _shapeTexture = [[FSATextureManager instance] getTexture:@"pentagon.jpg"];
    _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_pentagon.png"];
    
}

-(void)resizeBall {
    [self setMass:100*_size*_size];
    [self setMoment:.02*cpMomentForCircle(_mass, 0, _size, cpvzero)];
    cpCircleShapeSetRadius(_shapes[0], _size);
}

-(void)resizeSquare {    
    cpVect square_verts[4];
    square_verts[0].x = _size;
    square_verts[0].y = _size;
    
    square_verts[1].x = _size;
    square_verts[1].y = -_size;
    
    square_verts[2].x = -_size;
    square_verts[2].y = -_size;
    
    square_verts[3].x = -_size;
    square_verts[3].y = _size;
    
    [self setMass:(4/PI)*100*_size*_size];
    [self setMoment:5*cpMomentForBox(_mass, _size*2, _size*2)];
    
    cpPolyShapeSetVerts(_shapes[0], 4, square_verts, cpvzero);
}

-(void)resizeTriangle {
    float cos30 = .866025403784; // sqrt(3)/2
    float sin30 = .5;
    cpVect verts[3];
    verts[0].x = 0;
    verts[0].y = _size*1.333333;
    
    verts[1].x = _size*cos30*1.333333;
    verts[1].y = -_size*sin30*1.333333;
    
    verts[2].x = -_size*cos30*1.333333;
    verts[2].y = -_size*sin30*1.333333;
    
    [self setMass:(1.5*sqrt(3)/4)*100*_size*_size];
    [self setMoment:5*cpMomentForPoly(_mass, 3, (cpVect*)verts, cpvzero)];
    
    cpPolyShapeSetVerts(_shapes[0], 3, verts, cpvzero);
}

-(void)resizePentagon {
    float cos72 = .309016994375;
    float sin72 = .951056516295;
    
    vec2 vert(0, _size*1.05572809);
    
    vec2 verts[5];
    verts[0] = vert;
    
    vert.rotate(cos72,sin72);
    verts[1] = vert;
    
    vert.rotate(cos72,sin72);
    verts[2] = vert;
    
    vert.rotate(cos72,sin72);
    verts[3] = vert;
    
    vert.rotate(cos72,sin72);
    verts[4] = vert;
    
    [self setMass:.925062677588*100*_size*_size];
    [self setMoment:5*cpMomentForPoly(_mass, 5, (cpVect*)verts, cpvzero)];
    cpPolyShapeSetVerts(_shapes[0], 5, (cpVect*)verts, cpvzero);
}


-(void)step:(float)dt {
    _intensity *= .9;
    _age += dt;
    
    float spring_k = 200;
    float drag = .2;
    float c = _size*.75;

    for(int i = 0; i < _numVerts; i++) {
        _vertOffsets[i] += _vertVels[i]*dt;
        vec2 a = -spring_k*_vertOffsets[i];

        _vertVels[i] +=  a*dt-drag*_vertVels[i];
        
        _vertOffsets[i].clamp(-c, c);
    }
}

-(void)draw {
    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    FSAShader *objectShader = [shaderManager getShader:@"SingleObjectShader"];
    FSAShader *stationaryShader = [shaderManager getShader:@"SingleObjectStationaryShader"];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    float size = 2*_size;
    vec2 position(self.position);
    
    float angle = self.angle;
    
    float cosangle = cos(-angle);
    float sinangle = sin(-angle);
    
    for(int i = 0; i < _numVerts; i++) {
        _verts[i] = _vertsUntransformed[i]*size+_vertOffsets[i];
        _verts[i].rotate(cosangle,sinangle);
        _verts[i] += position;
    }
    
   // float intensity = 2.2;
            
    [objectShader setPtr:&_intensity forUniform:@"intensity"];
    [objectShader setPtr:&_color forUniform:@"color"];
    
    GLuint shapeTex = 0;
    GLuint patternTex = 1;
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _shapeTexture);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _patternTexture);

    [objectShader setPtr:&shapeTex forUniform:@"shapeTexture"];
    [objectShader setPtr:&patternTex forUniform:@"patternTexture"];
    
    [objectShader setPtr:_verts forAttribute:@"position"];
    [objectShader setPtr:_vertShapeUVs forAttribute:@"shapeUV"];
    [objectShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];
    
    [objectShader enable];
    glDrawElements(GL_TRIANGLES, _numIndices, GL_UNSIGNED_INT, _indices);
    [objectShader disable];
    
    if(_isStationary) {
        [stationaryShader setPtr:&_color forUniform:@"color"];
        
        GLuint stationaryTex = 0;
        GLuint patternTex = 1;

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _stationaryTexture);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, _patternTexture);
        [stationaryShader setPtr:&stationaryTex forUniform:@"texture"];
        [stationaryShader setPtr:&patternTex forUniform:@"pattern"];
        
        [stationaryShader setPtr:_verts forAttribute:@"position"];
        [stationaryShader setPtr:_vertShapeUVs forAttribute:@"uv"];
        [stationaryShader setPtr:_vertPatternUVs forAttribute:@"patternUV"];

        [stationaryShader enable];
        glDrawElements(GL_TRIANGLES, _numIndices, GL_UNSIGNED_INT, _indices);
        [stationaryShader disable];
    }
    
}

-(void)separate: (cpContactPointSet*)contactPoints {
    float size = _size;
    float angle = self.angle;  
    vec2 pos(self.position);
    vec2 vel(self.velocity);
    
    float cosangle = cos(angle);
    float sinangle = sin(angle);
    
    vel.rotate(cosangle,sinangle); 
    
    for(int i=0; i<contactPoints->count; i++){
        vec2 p(contactPoints->points[i].point);
        p -= pos;
        p.rotate(cosangle,sinangle);
        
        int closest_j = -1;
        int closest_j2 = -1;
        float min_dist = 9999;
        float min_dist2 = 9999;
        
        for(int j = 0; j < _numVerts; j++) {
            vec2 vert = _vertsUntransformed[j]*size;
            float dist = (p-vert).length();
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
        
        _vertVels[closest_j] += vel;
        _vertVels[closest_j2] += vel;

    }
    
}

-(void)dealloc {
    [_sound release];
    _sound = nil;
    [super dealloc];
}


@end


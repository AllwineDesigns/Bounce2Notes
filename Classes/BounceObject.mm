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
        _color = color;
        
        _isStationary = NO;
        _patternTexture = [[FSATextureManager instance] getTexture:@"spiral.jpg"];
//        _patternTexture = [[FSATextureManager instance] getTexture:@"music_texture_sheet.jpg"];
        
        [self setBounceShape:bounceShape];
        
        cpBodySetPos(_body, (const cpVect&)loc);
        cpBodySetVel(_body, (const cpVect&)vel);
        cpBodySetAngle(_body, angle);
        cpBodySetVelLimit(_body, 5);
        cpBodySetAngVelLimit(_body, 50);
        cpBodySetUserData(_body, self);
        
        for(int i = 0; i < _numShapes; i++) {
            cpShapeSetFriction(_shapes[i], .1);
            cpShapeSetElasticity(_shapes[i], .95);
            cpShapeSetCollisionType(_shapes[i], OBJECT_TYPE);
        }
  /*      
        _vertUVs[0] = vec2(1,1);
        _vertUVs[1] = vec2(0,1);
        _vertUVs[2] = vec2(0,0);
        _vertUVs[3] = vec2(1,0);
   */
        _vertShapeUVs[0] = vec2(1,0);
        _vertShapeUVs[1] = vec2(0,0);
        _vertShapeUVs[2] = vec2(0,1);
        _vertShapeUVs[3] = vec2(1,1);
        
        
        _vertPatternUVs[0] = vec2(1,0);
        _vertPatternUVs[1] = vec2(0,0);
        _vertPatternUVs[2] = vec2(0,1);
        _vertPatternUVs[3] = vec2(1,1);
         
        
        /*
        int x = 5*random(loc*76.345);
        int y = 5*random(loc*23.29003);
        
        _vertPatternUVs[0] = vec2(.2*(x+1),.2*y);
        _vertPatternUVs[1] = vec2(.2*x,.2*y);
        _vertPatternUVs[2] = vec2(.2*x,.2*(y+1));
        _vertPatternUVs[3] = vec2(.2*(x+1),.2*(y+1));
         */
        
        _indices[0] = 0;
        _indices[1] = 1;
        _indices[2] = 3;
        
        _indices[3] = 1;
        _indices[4] = 2;
        _indices[5] = 3;
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
        default:
            NSAssert(NO, @"attempting to set unknown shape\n");
            break;
    }
}

-(float)size {
    return _size;
}

-(void)setSize:(float)s {
    _size = s;

    if(_size > 1) {
        _size = 1;
    } else if(_size < .01) {
        _size = .01;
    }
    
    switch(_bounceShape) {
        case BOUNCE_BALL:
            [self resizeBall:s];
            break;
        case BOUNCE_SQUARE:
            [self resizeSquare:s];
            break;
        case BOUNCE_TRIANGLE:
            [self resizeTriangle:s];
            break;
        default:
            NSAssert(NO, @"resizing unknown shape\n");
            break;
    }
    cpSpaceReindexShapesForBody(_space, _body);
}

-(void)setupBall {
    [self setMass:100*_size*_size];
    [self setMoment:.02*cpMomentForCircle(_mass, 0, _size, cpvzero)];
    [self addCircleShapeWithRadius:_size withOffset:cpvzero];
    
    _shapeTexture = [[FSATextureManager instance] getTexture:@"ball.jpg"];
    _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_ball.png"];
}

-(void)setupSquare {
    [self setMass:(4/PI)*100*_size*_size];
    [self setMoment:5*cpMomentForBox(_mass, _size, _size)];
    vec2 square_verts[4];
    float inv_sqrt2 = .707106781188;
    square_verts[0].x = _size*inv_sqrt2;
    square_verts[0].y = _size*inv_sqrt2;
    
    square_verts[1].x = _size*inv_sqrt2;
    square_verts[1].y = -_size*inv_sqrt2;
    
    square_verts[2].x = -_size*inv_sqrt2;
    square_verts[2].y = -_size*inv_sqrt2;
    
    square_verts[3].x = -_size*inv_sqrt2;
    square_verts[3].y = _size*inv_sqrt2;
    
    [self addPolyShapeWithNumVerts:4 withVerts:square_verts withOffset:cpvzero];
    
    _shapeTexture = [[FSATextureManager instance] getTexture:@"square.jpg"];
    _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_square.png"];

}

-(void)setupTriangle {
    float cos30 = .866025403784; // sqrt(3)/2
    float sin30 = .5;
    vec2 verts[3];
    verts[0].x = 0;
    verts[0].y = _size*1.36;
    
    verts[1].x = _size*cos30*1.36;
    verts[1].y = -_size*sin30*1.36;
    
    verts[2].x = -_size*cos30*1.36;
    verts[2].y = -_size*sin30*1.36;
    
    [self setMass:(1.5*sqrt(3)/4)*100*_size*_size];
    [self setMoment:5*cpMomentForPoly(_mass, 3, (cpVect*)verts, cpvzero)];
    
    [self addPolyShapeWithNumVerts:3 withVerts:verts withOffset:cpvzero];
    _shapeTexture = [[FSATextureManager instance] getTexture:@"triangle.jpg"];
    _stationaryTexture = [[FSATextureManager instance] getTexture:@"stationary_triangle.png"];

}

-(void)resizeBall:(float)s {
    cpCircleShapeSetRadius(_shapes[0], s);
}

-(void)resizeSquare:(float)s {    
    cpVect square_verts[4];
    float inv_sqrt2 = .707106781188;
    square_verts[0].x = _size*inv_sqrt2;
    square_verts[0].y = _size*inv_sqrt2;
    
    square_verts[1].x = _size*inv_sqrt2;
    square_verts[1].y = -_size*inv_sqrt2;
    
    square_verts[2].x = -_size*inv_sqrt2;
    square_verts[2].y = -_size*inv_sqrt2;
    
    square_verts[3].x = -_size*inv_sqrt2;
    square_verts[3].y = _size*inv_sqrt2;
    
    cpPolyShapeSetVerts(_shapes[0], 4, square_verts, cpvzero);
}

-(void)resizeTriangle:(float)s {
    float cos30 = .866025403784; // sqrt(3)/2
    float sin30 = .5;
    cpVect verts[3];
    verts[0].x = 0;
    verts[0].y = _size*1.36;
    
    verts[1].x = _size*cos30*1.36;
    verts[1].y = -_size*sin30*1.36;
    
    verts[2].x = -_size*cos30*1.36;
    verts[2].y = -_size*sin30*1.36;
    
    cpPolyShapeSetVerts(_shapes[0], 3, verts, cpvzero);
}

-(void)addVelocity: (const vec2&)vel toVert: (unsigned int)i {
    _vertVels[i] += vel;
}

-(void)step:(float)dt {
    _intensity *= .9;
    _age += dt;
    
    _vertOffsets[0] += _vertVels[0]*dt;
    _vertOffsets[1] += _vertVels[1]*dt;
    _vertOffsets[2] += _vertVels[2]*dt;
    _vertOffsets[3] += _vertVels[3]*dt;
    
    float spring_k = 200;
    vec2 tra = -spring_k*_vertOffsets[0];
    vec2 tla = -spring_k*_vertOffsets[1];
    vec2 bla = -spring_k*_vertOffsets[2];
    vec2 bra = -spring_k*_vertOffsets[3];
    
    float drag = .2;
    _vertVels[0] += tra*dt-drag*_vertVels[0];
    _vertVels[1] += tla*dt-drag*_vertVels[1];
    _vertVels[2] += bla*dt-drag*_vertVels[2];
    _vertVels[3] += bra*dt-drag*_vertVels[3];
    
    float c = _size;
    
    _vertOffsets[0].clamp(-c, c);
    _vertOffsets[1].clamp(-c, c);
    _vertOffsets[2].clamp(-c, c);
    _vertOffsets[3].clamp(-c, c);

}

-(void)drawWithObjectShader: (FSAShader*)objectShader andStationaryShader: (FSAShader*)stationaryShader {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    float radius = 2*_size;
    vec2 position(self.position);
    
    float angle = self.angle;
    
    vec2 tr = vec2(radius, radius)+_vertOffsets[0];
    vec2 tl = vec2(-radius, radius)+_vertOffsets[1];
    vec2 bl = vec2(-radius, -radius)+_vertOffsets[2];
    vec2 br = vec2(radius, -radius)+_vertOffsets[3];
    
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
    
    _verts[0] = tr;
    _verts[1] = tl;
    _verts[2] = bl;
    _verts[3] = br;   
        
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
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, _indices);
    [objectShader disable];
    
    
    if(_isStationary) {
        [stationaryShader setPtr:&_color forUniform:@"color"];
        
        GLuint stationaryTex = 0;
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, _stationaryTexture);
        [stationaryShader setPtr:&stationaryTex forUniform:@"texture"];
        
        [stationaryShader setPtr:_verts forAttribute:@"position"];
        [stationaryShader setPtr:_vertShapeUVs forAttribute:@"uv"];
        
        [stationaryShader enable];
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, _indices);
        [stationaryShader disable];
    }
    
}


@end


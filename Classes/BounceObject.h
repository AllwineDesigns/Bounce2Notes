//
//  BounceObject.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "ChipmunkObject.h"
#import "FSAShader.h"
#import "BounceSound.h"

#define OBJECT_TYPE 1111

typedef enum {
    BOUNCE_BALL,
    BOUNCE_SQUARE,
    BOUNCE_TRIANGLE,
    BOUNCE_PENTAGON,
    NUM_BOUNCE_SHAPES
} BounceShape;

@interface BounceObject : ChipmunkObject { 
    id<BounceSound> _sound;
    
    BOOL _isStationary;
    
    vec4 _color;
    
    GLuint _shapeTexture;
    GLuint _patternTexture;
    GLuint _stationaryTexture;
    
    BounceShape _bounceShape;
    
    float _size;
    
    float _intensity;
    float _age;
    vec2 _lastVelocity;
    
    vec2 *_verts;
    vec2 *_vertsUntransformed;
    vec2 *_vertOffsets;
    vec2 *_vertVels;
    vec2 *_vertShapeUVs;
    vec2 *_vertPatternUVs;
    unsigned int *_indices;
    unsigned int _numVerts;
    unsigned int _numIndices;
}

@property (nonatomic) BOOL isStationary;
@property (nonatomic) const vec4& color;
@property (nonatomic, readonly) GLuint shapeTexture;
@property (nonatomic) GLuint patternTexture;
@property (nonatomic, readonly) GLuint stationaryTexture;
@property (nonatomic) float intensity;
@property (nonatomic) float age;
@property (nonatomic) const vec2& lastVelocity;
@property (nonatomic, retain) id<FSASoundDelegate> sound;

+(id)randomObjectAt: (const vec2&)loc;
+(id)randomObjectAt:(const vec2 &)loc withVelocity:(const vec2&)vel;
+(id)randomObjectWithShape: (BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2&)vel;

+(id)objectWithShape: (BounceShape)bounceShape at:(const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color withSize:(float)size withAngle:(float)angle;

-(id)initRandomObjectAt: (const vec2&)loc;
-(id)initRandomObjectAt: (const vec2&)loc withVelocity:(const vec2&)vel;
-(id)initRandomObjectWithShape: (BounceShape)bounceShape at:(const vec2&)loc withVelocity:(const vec2&)vel;
-(id)initObjectWithShape: (BounceShape)bounceShape at:(const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color withSize:(float)size withAngle:(float)angle;

-(BounceShape)bounceShape;
-(void)setBounceShape: (BounceShape)bounceShape;

-(void)separate: (cpContactPointSet*)contactPoints;

-(float)size;
-(void)setSize:(float)s;

-(void)setupSquareVerts;
-(void)setupPentagonVerts;
-(void)setupTriangleVerts;

-(void)setupBall;
-(void)setupSquare;
-(void)setupTriangle;
-(void)setupPentagon;

-(void)resizeBall;
-(void)resizeSquare;
-(void)resizeTriangle;
-(void)resizePentagon;

-(void)step: (float)dt;
-(void)draw;

@end

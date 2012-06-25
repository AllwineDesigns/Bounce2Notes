//
//  BounceObject.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "ChipmunkObject.h"
#import "FSAShader.h"

typedef enum {
    BOUNCE_BALL,
    BOUNCE_SQUARE,
    BOUNCE_TRIANGLE,
    NUM_BOUNCE_SHAPES
} BounceShape;

@interface BounceObject : ChipmunkObject {  
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
    
    vec2 _verts[4];
    vec2 _vertOffsets[4]; // 0: tr, 1: tl, 2: bl, 3: br
    vec2 _vertVels[4];
    vec2 _vertShapeUVs[4];
    vec2 _vertPatternUVs[4];
    unsigned int _indices[6];
}

@property (nonatomic) BOOL isStationary;
@property (nonatomic) const vec4& color;
@property (nonatomic, readonly) GLuint shapeTexture;
@property (nonatomic) GLuint patternTexture;
@property (nonatomic, readonly) GLuint stationaryTexture;
@property (nonatomic) float intensity;
@property (nonatomic) float age;
@property (nonatomic) const vec2& lastVelocity;

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

-(float)size;
-(void)setSize:(float)s;

-(void)setupBall;
-(void)setupSquare;
-(void)setupTriangle;

-(void)resizeBall:(float)s;
-(void)resizeSquare:(float)s;
-(void)resizeTriangle:(float)s;

-(void)addVelocity: (const vec2&)vel toVert: (unsigned int)i;

-(void)step: (float)dt;
-(void)drawWithObjectShader: (FSAShader*)objectShader andStationaryShader: (FSAShader*)stationaryShader;

@end

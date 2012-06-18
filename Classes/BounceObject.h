//
//  BounceObject.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "ChipmunkObject.h"

@interface BounceObject : ChipmunkObject {  
    BOOL _isStationary;
    
    vec4 _color;
    
    GLuint _shapeTexture;
    GLuint _patternTexture;
    
    float _size;
    
    float _intensity;
    float _age;
    
    vec2 _vertOffsets[4]; // 0: tr, 1: tl, 2: bl, 3: br
    vec2 _vertVels[4];
    vec2 _vertUVs[4];
}

@property (nonatomic) BOOL isStationary;
@property (nonatomic) vec4 color;
@property (nonatomic, setter = resize:) float size;
@property (nonatomic, readonly) GLuint shapeTexture;
@property (nonatomic) GLuint patternTexture;
@property (nonatomic) float intensity;
@property (nonatomic) float age;

+(id)bounceRandomObjectAt: (const vec2&)loc;
+(id)bounceRandomObjectAt: (const vec2&)loc withVelocity:(const vec2&)vel;
+(id)bounceObjectAt: (const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color withSize:(float)size;


-(id)initRandomObjectAt: (const vec2&)loc;
-(id)initRandomObjectAt: (const vec2&)loc withVelocity:(const vec2&)vel;
-(id)initObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color withSize:(float)size;

-(void)setupObject;
-(void)resize:(float)s;

-(vec2*)vertOffsets;
-(vec2*)vertVels;
-(vec2*)vertUVs;

@end

@interface BounceBall : BounceObject {
}
@end

@interface BounceSquare : BounceObject {
}
@end

@interface BounceTriangle : BounceObject {
}
@end

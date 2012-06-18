//
//  BounceObject.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceObject.h"

@implementation BounceObject

@synthesize isStationary = _isStationary;
@synthesize color = _color;
@synthesize size = _size;
@synthesize shapeTexture = _shapeTexture;
@synthesize patternTexture = _patternTexture;
@synthesize intensity = _intensity;
@synthesize age = _age;

+(id)bounceRandomObjectAt:(const vec2 &)loc {
    BounceObject *obj = [[BounceObject alloc] initRandomObjectAt:loc];
    [obj autorelease];
    
    return obj;
}

+(id)bounceRandomObjectAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    BounceObject *obj = [[BounceObject alloc] initRandomObjectAt:loc withVelocity:vel];
    [obj autorelease];
    
    return obj;
}
+(id)bounceObjectAt:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size {
    BounceObject *obj = [[BounceObject alloc] initObjectAt:loc withVelocity:vel withColor:color withSize:size];
    [obj autorelease];
    
    return obj;
}

-(id)initRandomObjectAt: (const vec2&)loc {
    vec2 vel;
    return [self initRandomObjectAt:loc withVelocity:vel];
}

-(id)initRandomObjectAt: (const vec2&)loc withVelocity:(const vec2&)vel {
    float size = random(loc*1.234)*.2+.05;
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             360.*random(64.28327*loc), .4, .05*random(736.2827*loc)+.75   );
    
    return [self initObjectAt:loc withVelocity:vel withColor:color withSize:size];
}

-(id)initObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color  withSize:(float)size {
    
    self = [super init];
    
    if(self) {
        _size = size;
        _color = color;
        
        _isStationary = NO;
        _patternTexture = [[FSATextureManager instance] getTexture:@"spiral.jpg"];
        
        [self setupObject];
        
        cpBodySetPos(_body, (const cpVect&)loc);
        cpBodySetVelLimit(_body, 5);
        cpBodySetUserData(_body, self);
        
        for(int i = 0; i < _numShapes; i++) {
            cpShapeSetFriction(_shapes[i], .1);
            cpShapeSetElasticity(_shapes[i], .95);
            cpShapeSetCollisionType(_shapes[i], OBJECT_TYPE);
        }
        
        _vertUVs[0] = vec2(1,1);
        _vertUVs[1] = vec2(0,1);
        _vertUVs[2] = vec2(0,0);
        _vertUVs[3] = vec2(1,0);
    }
    
    return self;
}

-(void)setupObject {
    NSAssert(NO, "setupObject must be implemented by a subclass of BounceObject\n");
}

-(void)resize:(float)s {
    NSAssert(NO, "resize must be implemented by a subclass of BounceObject\n");
}

-(vec2*)vertOffsets {
    return _vertOffsets;
}

-(vec2*)vertVels {
    return _vertVels;
}

-(vec2*)vertUVs {
    return _vertUVs;
}

-(void)dealloc {
    if(!cpBodyIsRogue(_body)) {
        cpSpaceRemoveBody(_space, _body);
    }
    for(int i = 0; i < _numShapes; i++) {
        cpSpaceRemoveShape(_space, _shapes[i]);
        cpShapeFree(_shapes[i]);
    }
    cpBodyFree(_body);
    free(_shapes);
    
    [super dealloc];
}


@end

@implementation BounceBall

-(void)setupObject {
    [self setMass:100*_size*_size];
    [self setMoment:.02*cpMomentForCircle(_mass, 0, _size, cpvzero)];
    [self addCircleShapeWithRadius:_size withOffset:cpvzero];
    
    _shapeTexture = [[FSATextureManager instance] getTexture:@"ball_nocenterglow.jpg"];
}

-(void)resize: (float)s {
    _size = s;
    cpCircleShapeSetRadius(_shapes[0], s);
}

@end

@implementation BounceSquare 

-(void)setupObject {
    [self setMass:(4/PI)*100*_size*_size];
    [self setMoment:.02*cpMomentForBox(_mass, _size, _size)];
    vec2 square_verts[4];
    square_verts[0].x = _size;
    square_verts[0].y = _size;
    
    square_verts[1].x = _size;
    square_verts[1].y = -_size;
    
    square_verts[2].x = -_size;
    square_verts[2].y = -_size;
    
    square_verts[3].x = -_size;
    square_verts[3].y = _size;
    
    [self addPolyShapeWithNumVerts:4 withVerts:square_verts withOffset:cpvzero];
    
    _shapeTexture = [[FSATextureManager instance] getTexture:@"square.jpg"];
}

-(void)resize:(float)s {
    _size = s;
    
    cpVect square_verts[4];
    square_verts[0].x = _size;
    square_verts[0].y = _size;
    
    square_verts[1].x = _size;
    square_verts[1].y = -_size;
    
    square_verts[2].x = -_size;
    square_verts[2].y = -_size;
    
    square_verts[3].x = -_size;
    square_verts[3].y = _size;
    
    cpPolyShapeSetVerts(_shapes[0], 4, square_verts, cpvzero);
}
@end

@implementation BounceTriangle

-(void)setupObject {
    float cos30 = .866025403784; // sqrt(3)/2
    float sin30 = .5;
    vec2 verts[3];
    verts[0].x = 0;
    verts[0].y = 0;
    
    verts[1].x = _size*cos30;
    verts[1].y = -_size*sin30;
    
    verts[2].x = -_size*cos30;
    verts[2].y = -_size*sin30;
    
    [self setMass:(1.5*sqrt(3)/4)*100*_size*_size];
    [self setMoment:.02*cpMomentForPoly(_mass, 3, (cpVect*)verts, cpvzero)];
    
    [self addPolyShapeWithNumVerts:3 withVerts:verts withOffset:cpvzero];
    _shapeTexture = [[FSATextureManager instance] getTexture:@"triangle.jpg"];
}

-(void)resize:(float)s {
    _size = s;
    float cos30 = .866025403784; // sqrt(3)/2
    float sin30 = .5;
    cpVect verts[3];
    verts[0].x = 0;
    verts[0].y = 0;
    
    verts[1].x = _size*cos30;
    verts[1].y = -_size*sin30;
    
    verts[2].x = -_size*cos30;
    verts[2].y = -_size*sin30;
    
    cpPolyShapeSetVerts(_shapes[0], 3, verts, cpvzero);
}

@end


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
#import "BounceRenderable.h"

#define OBJECT_TYPE 1111

@class BounceSimulation;

#define INVERSE_GOLDEN_RATIO 1.61803399
#define GOLDEN_RATIO 1./1.61803399

typedef enum {
    BOUNCE_BALL,
    BOUNCE_SQUARE,
    BOUNCE_TRIANGLE,
    BOUNCE_PENTAGON,
    BOUNCE_RECTANGLE,
    BOUNCE_CAPSULE,
    NUM_BOUNCE_SHAPES
} BounceShape;

@interface BounceObject : ChipmunkObject { 
    id<BounceSound> _sound;
    BounceShape _bounceShape;
    
    BOOL _isPreviewable;
    BOOL _isRemovable;
    BOOL _simulationWillDraw;
    
    BounceSimulation *_simulation;
        
    float _intensity;
    BOOL _isStationary;
    vec4 _color;
    GLuint _patternTexture;
    float _bounciness;
    
    float _size;
    float _size2;
    BOOL _hasSecondarySize;
    
    float _age;
    vec2 _lastVelocity;
    
    vec2 _springLoc;
    vec2 _vel;
    
    BOOL _beingGrabbed;
    BOOL _beingTransformed;
    
    BounceRenderable *_renderable;
    BounceRenderableInputs _inputs;
}

@property (nonatomic) BOOL simulationWillDraw;
@property (nonatomic) BOOL isPreviewable;
@property (nonatomic) BOOL isRemovable;
@property (nonatomic, retain) BounceSimulation* simulation;
@property (nonatomic, readonly) BOOL hasSecondarySize;
@property (nonatomic) BOOL isStationary;
@property (nonatomic) const vec4& color;
@property (nonatomic) GLuint patternTexture;
@property (nonatomic) float intensity;
@property (nonatomic) float age;
@property (nonatomic) const vec2& lastVelocity;
@property (nonatomic, retain) id<BounceSound> sound;

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

-(void)playSound: (float)volume;

-(float)bounciness;
-(void)setBounciness:(float)b;

-(void)separate: (cpContactPointSet*)contactPoints;

-(void)beginCreateCallback;
-(void)createCallbackWithSize: (float)size secondarySize:(float)size2;
-(void)endCreateCallback;
-(void)cancelCreateCallback;


-(void)beginGrabCallback:(const vec2&)loc;
-(void)grabCallbackWithPosition:(const vec2&)pos velocity:(const vec2&)vel angle:(float)angle angVel:(float)angVel stationary:(BOOL)stationary;
-(void)grabCallback:(const vec2&)loc;
-(void)endGrabCallback;
-(void)cancelGrabCallback;


-(void)beginTransformCallback;
-(void)transformCallbackWithPosition:(const vec2&)pos velocity:(const vec2&)vel angle:(float)angle angVel:(float)angVel size:(float)size secondarySize:(float)size2 doSecondarySize:(BOOL)_doSecondarySize;
-(void)endTransformCallback;
-(void)cancelTransformCallback;


-(void)randomizeSize;
-(void)randomizeColor;
-(void)randomizeShape;
-(float)size;
-(void)setSize:(float)s;
-(void)setSize:(float)s secondarySize:(float)s2;

-(void)singleTapAt:(const vec2&)loc;
-(void)flickAt:(const vec2&)loc withVelocity:(const vec2&)vel;

-(float)secondarySize;
-(void)setSecondarySize:(float)s;

-(void)setupBall;
-(void)setupSquare;
-(void)setupTriangle;
-(void)setupPentagon;
-(void)setupRectangle;
-(void)setupCapsule;

-(void)resizeBall;
-(void)resizeSquare;
-(void)resizeTriangle;
-(void)resizePentagon;
-(void)resizeRectangle;
-(void)resizeCapsule;

-(void)step: (float)dt;
-(void)draw;
-(void)drawSelected;

-(void)addToSimulation:(BounceSimulation*)sim;
-(void)removeFromSimulation;
-(void)postSolveRemoveFromSimulation;

-(BOOL)hasBeenAddedToSimulation;

-(void)setPatternForTextureSheet: (NSString*)name row:(unsigned int)row col:(unsigned int)col numRows:(unsigned int)rows numCols:(unsigned int)cols;

@end

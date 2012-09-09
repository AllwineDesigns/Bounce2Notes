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
    BOUNCE_STAR,
    BOUNCE_NOTE,
    NUM_BOUNCE_SHAPES
} BounceShape;

@interface BounceObject : ChipmunkObject <NSCoding> { 
    id<BounceSound> _sound;
    BounceShape _bounceShape;
        
    BOOL _isPreviewable;
    BOOL _isRemovable;
    BOOL _simulationWillDraw;
    BOOL _simulationWillArchive;
    
    NSTimeInterval _lastPlayed;
    
    @public BounceSimulation *_simulation;
        
    float _intensity;
    BOOL _isStationary;
    vec4 _color;
    FSATexture* _patternTexture;
    float _bounciness;
    float _velLimit;
    float _friction;
    
    float _size;
    float _size2;
    BOOL _hasSecondarySize;
    
    float _age;
    vec2 _lastVelocity;
    cpContactPointSet _contactPoints;
    
    vec2 _springLoc;
    vec2 _vel;
    
    BOOL _beingGrabbed;
    BOOL _beingTransformed;
    
    BounceRenderable *_renderable;
    BounceRenderableInputs _inputs;
    
    @public float _damping;
    @public float _gravityScale;
}

@property (nonatomic) NSTimeInterval lastPlayed;
@property (nonatomic) BOOL simulationWillDraw;
@property (nonatomic) BOOL simulationWillArchive;
@property (nonatomic) BOOL isPreviewable;
@property (nonatomic) BOOL isRemovable;
@property (nonatomic, assign) BounceSimulation* simulation;
@property (nonatomic, readonly) BOOL hasSecondarySize;
@property (nonatomic) BOOL isStationary;
@property (nonatomic) const vec4& color;
@property (nonatomic, retain) FSATexture* patternTexture;
@property (nonatomic) float intensity;
@property (nonatomic) float age;
@property (nonatomic) const vec2& lastVelocity;
@property (nonatomic, retain) id<BounceSound> sound;
@property (nonatomic, readonly) BounceRenderable* renderable;
@property (nonatomic) cpContactPointSet contactPoints;
@property (nonatomic) float damping;
@property (nonatomic) float gravityScale;

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
-(void)needsSize;

-(float)bounciness;
-(void)setBounciness:(float)b;

-(float)friction;
-(void)setFriction:(float)f;

-(float)velocityLimit;
-(void)setVelocityLimit:(float)limit;

-(void)separate;

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

-(void)randomizeNote;
-(void)randomizeSize;
-(void)randomizeColor;
-(void)randomizeShape;
-(void)randomizePattern;
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
-(void)setupStar;
-(void)setupNote;

-(void)resizeBall;
-(void)resizeSquare;
-(void)resizeTriangle;
-(void)resizePentagon;
-(void)resizeRectangle;
-(void)resizeCapsule;
-(void)resizeStar;
-(void)resizeNote;


-(void)step: (float)dt;
-(void)draw;
-(void)drawSelected;

-(void)addToSimulation:(BounceSimulation*)sim;
-(void)removeFromSimulation;
-(void)postSolveRemoveFromSimulation;

-(BOOL)hasBeenAddedToSimulation;

-(void)setPatternForTextureSheet: (NSString*)name row:(unsigned int)row col:(unsigned int)col numRows:(unsigned int)rows numCols:(unsigned int)cols;

@end

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
#import "FSASoundManager.h"
#import "BounceNoteManager.h"
#import "BounceSettings.h"

static void BounceVelocityFunction(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt) {
    BounceObject *obj = (BounceObject*)cpBodyGetUserData(body);
    
    float d = obj->_damping;
    float scale = obj->_gravityScale;
    vec2 g = scale*obj->_simulation->_gravity;
    
    /*
    float d = obj.damping;
    float scale = obj.gravityScale;
    vec2 g = scale*obj.simulation.gravity;
     */
	
	cpBodyUpdateVelocity(body, (cpVect&)g, d, dt);
}

@implementation BounceObject

@synthesize lastPlayed = _lastPlayed;
@synthesize simulationWillDraw = _simulationWillDraw;
@synthesize isPreviewable = _isPreviewable;
@synthesize isRemovable = _isRemovable;
@synthesize simulation = _simulation;
@synthesize hasSecondarySize = _hasSecondarySize;
@synthesize isStationary = _isStationary;
@synthesize color = _color;
@synthesize patternTexture = _patternTexture;
@synthesize intensity = _intensity;
@synthesize age = _age;
@synthesize lastVelocity = _lastVelocity;
@synthesize sound = _sound;
@synthesize renderable = _renderable;
@synthesize contactPoints = _contactPoints;
@synthesize gravityScale = _gravityScale;
@synthesize damping = _damping;

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
    BounceShape bounceShape = [[BounceSettings instance].bounceShapeGenerator randomBounceShapeWithLocation:loc];
    return [self initRandomObjectWithShape:bounceShape at:loc withVelocity:vel];
}

-(id)initRandomObjectWithShape: (BounceShape)bounceShape at: (const vec2&)loc withVelocity:(const vec2&)vel {
    float maxSize = [BounceSettings instance].maxSize;
    float minSize = [BounceSettings instance].maxSize;
    float sizeT = random(loc*1.234);
    float size = (1-sizeT)*minSize+sizeT*maxSize;
    vec4 color;
    color = [[[BounceSettings instance] colorGenerator] randomColorFromLocation:loc];
    float angle = 2*PI*random(34.2938*loc);
    
    return [self initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
}

-(id)initObjectWithShape: (BounceShape)bounceShape at:(const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color  withSize:(float)size withAngle:(float)angle {
    
    self = [super init];
    
    if(self) {
        _body->velocity_func = BounceVelocityFunction;
        _size = size;
        _size2 = _size*GOLDEN_RATIO;
        
        _isPreviewable = YES;
        _isRemovable = YES;
        _simulationWillDraw = YES;
        _velLimit = INFINITY;
        _color = color;
        _intensity = 2.2;
        _isStationary = NO;
        self.patternTexture = [[[BounceSettings instance] patternTextureGenerator] randomPatternTextureWithLocation:loc];
        
   //     unsigned int notes[] = { 0, 2,4,7};
        unsigned int notes[] = { 0,1, 2,4,5,7};

        unsigned int note = (unsigned int)6*random(loc*29.1863);
        _sound = [[BounceNoteManager instance] getNote:notes[note]];
        [_sound retain];
        
        _inputs.intensity = &_intensity;
        _inputs.isStationary = &_isStationary;
        _inputs.color = &_color;
        _inputs.size = &_size;

        _inputs.angle = &_body->a;
        _inputs.position = (vec2*)&_body->p;

        _inputs.patternTexture = &_patternTexture; 
                
        [self setBounceShape:bounceShape];
        
        cpBodySetPos(_body, (const cpVect&)loc);
        cpBodySetVel(_body, (const cpVect&)vel);
        cpBodySetAngle(_body, angle);
        
        cpBodySetVelLimit(_body, _velLimit);
        cpBodySetAngVelLimit(_body, 50);
    }
    
    return self;
}

/*
-(void)createNewBody {
    [super createNewBody];
    
    _inputs.position = (vec2*)&_body->p;
    _inputs.angle = &_body->a;
}
 */


-(void)setVelocity:(const vec2 &)vel {
    vec2 new_vel(vel);
    
    float len = new_vel.length();
    if(len > 10) {
        new_vel *= 10./len;
    }
    [super setVelocity:new_vel];
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
    _hasSecondarySize = NO;
    
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
        case BOUNCE_RECTANGLE:
            [self setupRectangle];
            break;
        case BOUNCE_CAPSULE:
            [self setupCapsule];
            break;
        case BOUNCE_STAR:
            [self setupStar];
            break;
        case BOUNCE_NOTE:
            [self setupNote];
            break;
        default:
            NSAssert(NO, @"attempting to set unknown shape\n");
            break;
    }
    
    [_renderable burst:5];
    
    for(int i = 0; i < _numShapes; i++) {
        cpShapeSetCollisionType(_shapes[i], OBJECT_TYPE);
    }
    [self setFriction:_friction];
    [self setBounciness:_bounciness];  
    [self needsSize];
}

-(float)friction {
    return _friction;
}

-(float)bounciness {
    return _bounciness;
}

-(void)needsSize {
    CGSize sSize = screenSize();
    float size = 2*sSize.width*_size;
    float size2 = size;
    if(_hasSecondarySize) {
        size2 = 2*sSize.width*_size2;
    }
    
    [self.patternTexture needsSize:size];
    [_renderable.shapeTexture needsSize:size2];
    [_renderable.stationaryTexture needsSize:size2];
}

-(float)velocityLimit {
    return _velLimit;
}

-(void)setVelocityLimit:(float)limit {
    _velLimit = limit;
    cpBodySetVelLimit(_body, limit);
}

-(void)setBounciness:(float)b {
    _bounciness = b;
    for(int i = 0; i < _numShapes; i++) {
        cpShapeSetElasticity(_shapes[i], .5*(1-b)+1*b);
    }
    _renderable.bounciness = b;
}

-(void)setFriction:(float)f {
    _friction = f;
    for(int i = 0; i < _numShapes; i++) {
        cpShapeSetFriction(_shapes[i], f);
    }
}

-(float)secondarySize {
    return _size2;
}

-(void)setSecondarySize:(float)s {
    _size2 = s;
    if(_size2 > 1) {
        _size2 = 1;
    } else if(_size2 < .01) {
        _size2 = .01;
    }
    
    if(_size2 > _size) {
        _size = _size2;
    }
    
    switch(_bounceShape) {
        case BOUNCE_RECTANGLE:
            [self resizeRectangle];
            break;
        case BOUNCE_CAPSULE:
            [self resizeCapsule];
            break;
        default:
            break;
    }
    if(_space != NULL) {
        cpSpaceReindexShapesForBody(_space, _body);
    }
    [self needsSize];
}

-(void)randomizeNote {
    vec2 loc = self.position;
//    unsigned int notes[] = { 0, 2,4,7};
    unsigned int notes[] = { 0, 1,2,4,5,7};

    unsigned int note = (unsigned int)6*random(loc*29.1863);
    self.sound = [[BounceNoteManager instance] getNote:notes[note]];
}

-(void)clampSize {
    float minSize = [BounceSettings instance].minSize;
    float maxSize = [BounceSettings instance].maxSize;
    
    float aspect = _size/_size2;
    float invaspect = 1./aspect;
    if(_size < minSize) {
        [self setSize:minSize secondarySize:invaspect*minSize];
    } else if(_size > maxSize) {
        [self setSize:maxSize secondarySize:invaspect*maxSize];
    }
}

-(void)randomizeSize {
    vec2 loc = self.position;
    float minSize = [BounceSettings instance].minSize;
    float maxSize = [BounceSettings instance].maxSize;
    float size = random(loc*1.234)*(maxSize-minSize)+minSize;
    _size2 = size*GOLDEN_RATIO;
    self.size = size;
}

-(void)randomizePattern {
    vec2 loc = self.position;
    
    self.patternTexture = [[[BounceSettings instance] patternTextureGenerator] randomPatternTextureWithLocation:loc];
}

-(void)randomizeColor {
    vec2 loc = self.position;
    
    _color = [[[BounceSettings instance] colorGenerator] randomColor];
}
-(void)randomizeShape {
    vec2 loc = self.position;

    self.bounceShape = [[[BounceSettings instance] bounceShapeGenerator] bounceShape];
    
}

-(float)size {
    return _size;
}
-(void)beginCreateCallback {
    
}
-(void)createCallbackWithSize: (float)size secondarySize:(float)size2 {
    if(size > 1) {
        size = 1;
        size2 = GOLDEN_RATIO;
    }
    self.secondarySize = size2;
    self.size = size;
}
-(void)endCreateCallback {
    
}
-(void)cancelCreateCallback {
    
}

-(void)beginGrabCallback:(const vec2&)loc {
    _beingGrabbed = YES;
    _springLoc = [self position];
    _vel = [self velocity];
}
-(void)grabCallbackWithPosition:(const vec2&)pos velocity:(const vec2&)vel angle:(float)angle angVel:(float)angVel stationary:(BOOL)stationary {
    
    self.angVel = angVel;
   // [self setVelocity:vel];
     self.angle = angle;
    _springLoc = pos;
   // [self setPosition:pos];
    self.isStationary = stationary;
}
-(void)grabCallback:(const vec2 &)loc {
    
}
-(void)endGrabCallback {
    _beingGrabbed = NO;
    
}
-(void)cancelGrabCallback {
    _beingGrabbed = NO;
}

-(void)beginTransformCallback {
    _beingTransformed = YES;
    _springLoc = [self position];
    _vel = [self velocity];
}
-(void)transformCallbackWithPosition:(const vec2&)pos velocity:(const vec2&)vel angle:(float)angle angVel:(float)angVel size:(float)size secondarySize:(float)size2 doSecondarySize:(BOOL)doSecondarySize {
    float curSize = self.size;
    float curSize2 = self.secondarySize;
    
    if(doSecondarySize) {
        if(curSize/size2 < INVERSE_GOLDEN_RATIO) {
            size = size2*INVERSE_GOLDEN_RATIO;
            if(size > 1) {
                size = 1;
                size2 = GOLDEN_RATIO;
            }
            self.size = size;
            self.secondarySize = size2;
        } else {
            self.secondarySize = size2;
        }
    } else {
        if(size/curSize2 < INVERSE_GOLDEN_RATIO) {
            size2 = size*GOLDEN_RATIO;
            if(size > 1) {
                size = 1;
                size2 = GOLDEN_RATIO;
            }
            self.size = size;
            self.secondarySize = size2;
        } else {
            self.size = size;
        }
    }
    
    [self.sound resized:curSize];
    
    self.angle = angle;
    self.angVel = angVel;
    
   // [self setPosition:pos];
    _springLoc = pos;
   // [self setVelocity:vel];
}
-(void)endTransformCallback {
    _beingTransformed = NO;
}
-(void)cancelTransformCallback {
    _beingTransformed = NO;
}

-(void)setSize:(float)s secondarySize:(float)s2 {
    _size = s;
    _size2 = s2;
    
    if(_size > 1) {
        _size = 1;
    } else if(_size < .01) {
        _size = .01;
    }
    
    if(_size2 > _size) {
        _size2 = _size;
    } else if(_size2 < .01) {
        _size2 = .01;
    }
    
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
        case BOUNCE_RECTANGLE:
            [self resizeRectangle];
            break;
        case BOUNCE_CAPSULE:
            [self resizeCapsule];
            break;
        case BOUNCE_STAR:
            [self resizeStar];
            break;
        case BOUNCE_NOTE:
            [self resizeNote];
            break;
        default:
            NSAssert(NO, @"resizing unknown shape\n");
            break;
    }
    if(_space != NULL) {
        cpSpaceReindexShapesForBody(_space, _body);
    }
    
    [self needsSize];

}


-(void)setSize:(float)s {
    _size = s;

    if(_size > 1) {
        _size = 1;
    } else if(_size < .01) {
        _size = .01;
    }
    
    if(_size2 > _size) {
        _size2 = _size;
    }

    //[_sound resized:old_size];
    
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
        case BOUNCE_RECTANGLE:
            [self resizeRectangle];
            break;
        case BOUNCE_CAPSULE:
            [self resizeCapsule];
            break;
        case BOUNCE_STAR:
            [self resizeStar];
            break;
        case BOUNCE_NOTE:
            [self resizeNote];
            break;
        default:
            NSAssert(NO, @"resizing unknown shape\n");
            break;
    }
    if(_space != NULL) {
        cpSpaceReindexShapesForBody(_space, _body);
    }
    [self needsSize];
}

-(void)setupBall {
    [self setMass:100*_size*_size];
    [self setMoment:.02*cpMomentForCircle(_mass, 0, _size, cpvzero)];
    [self addCircleShapeWithRadius:_size withOffset:cpvzero];
    
    [_renderable release];
    _renderable = [[BounceBallRenderable alloc] initWithInputs:_inputs];
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
    
    [_renderable release];
    _renderable = [[BounceSquareRenderable alloc] initWithInputs:_inputs];


}

-(void)setupNote {
    // Polygon 1
    unsigned int numPts1 = 7;
    vec2 poly1[] = {
        vec2(_size*0.029296875, _size*-0.705078125),
        vec2(_size*-0.09765625, _size*-0.98046875),
        vec2(_size*-0.462890625, _size*-1.12890625),
        vec2(_size*-0.705078125, _size*-0.998046875),
        vec2(_size*-0.681640625, _size*-0.7265625),
        vec2(_size*-0.4296875, _size*-0.5546875),
        vec2(_size*-0.087890625, _size*-0.580078125)
    };
    
    // Polygon 2
    unsigned int numPts2 = 5;
    vec2 poly2[] = {
        vec2(_size*-0.0234375, _size*1.1328125),
        vec2(_size*0.029296875, _size*1.041015625),
        vec2(_size*0.029296875, _size*-0.705078125),
        vec2(_size*-0.0859375, _size*-0.9375),
        vec2(_size*-0.0859375, _size*1.1328125)
    };
    
    // Polygon 3
    unsigned int numPts3 = 5;
    vec2 poly3[] = {
        vec2(_size*0.455078125, _size*0.611328125),
        vec2(_size*0.69921875, _size*0.298828125),
        vec2(_size*0.46484375, _size*0.388671875),
        vec2(_size*-0.0859375, _size*0.75),
        vec2(_size*-0.0859375, _size*1.1328125)
    };
    
    // Polygon 4
    unsigned int numPts4 = 4;
    vec2 poly4[] = {
        vec2(_size*0.69921875, _size*0.298828125),
        vec2(_size*0.716796875, _size*0.0390625),
        vec2(_size*0.619140625, _size*0.1015625),
        vec2(_size*0.43359375, _size*0.51171875)
    };
    
    // Polygon 5
    unsigned int numPts5 = 4;
    vec2 poly5[] = {
        vec2(_size*0.716796875, _size*0.0390625),
        vec2(_size*0.5859375, _size*-0.216796875),
        vec2(_size*0.521484375, _size*-0.19921875),
        vec2(_size*0.66015625, _size*0.3125)
    };
    
    // Polygon 6
    unsigned int numPts6 = 4;
    vec2 poly6[] = {
        vec2(_size*0.580078125, _size*-0.216796875),
        vec2(_size*0.310546875, _size*-0.466796875),
        vec2(_size*0.26953125, _size*-0.419921875),
        vec2(_size*0.583984375, _size*-0.091796875)
    };
    
    [self setMass:20*_size*_size];

    
    float moment = 5*(cpMomentForPoly(_mass, numPts1, (const cpVect*)poly1, cpvzero)+
                      cpMomentForPoly(_mass, numPts2, (const cpVect*)poly2, cpvzero)+
                      cpMomentForPoly(_mass, numPts3, (const cpVect*)poly3, cpvzero)+
                      cpMomentForPoly(_mass, numPts4, (const cpVect*)poly4, cpvzero)+
                      cpMomentForPoly(_mass, numPts5, (const cpVect*)poly5, cpvzero)+
                      cpMomentForPoly(_mass, numPts6, (const cpVect*)poly6, cpvzero));
    
    [self setMoment:moment];
    
    [self addPolyShapeWithNumVerts:numPts1 withVerts:poly1 withOffset:cpvzero];
    [self addPolyShapeWithNumVerts:numPts2 withVerts:poly2 withOffset:cpvzero];
    [self addPolyShapeWithNumVerts:numPts3 withVerts:poly3 withOffset:cpvzero];
    [self addPolyShapeWithNumVerts:numPts4 withVerts:poly4 withOffset:cpvzero];
    [self addPolyShapeWithNumVerts:numPts5 withVerts:poly5 withOffset:cpvzero];
    [self addPolyShapeWithNumVerts:numPts6 withVerts:poly6 withOffset:cpvzero];
    
    [_renderable release];
    _renderable = [[BounceNoteRenderable alloc] initWithInputs:_inputs];
}

-(void)setupRectangle {   
    _hasSecondarySize = YES;
    
    float aspect = _size/_size2;
    float invaspect = 1./aspect;
        
    vec2 verts[4];
    verts[0].x = _size;
    verts[0].y = invaspect*_size;
    
    verts[1].x = _size;
    verts[1].y = -invaspect*_size;
    
    verts[2].x = -_size;
    verts[2].y = -invaspect*_size;
    
    verts[3].x = -_size;
    verts[3].y = invaspect*_size;
    
    [self setMass:(4/PI)*invaspect*100*_size*_size];
    [self setMoment:5*cpMomentForBox(_mass, _size*2, _size*2*invaspect)];
    
    [self addPolyShapeWithNumVerts:4 withVerts:verts withOffset:cpvzero];
    
    [_renderable release];
    _renderable = [[BounceRectangleRenderable alloc] initWithInputs:_inputs aspect:aspect];
}

-(void)setupCapsule {
    float aspect = _size/_size2;
    float invaspect = 1./aspect;

    _hasSecondarySize = YES;
    
    vec2 verts[4];
    verts[0].x = _size*(1-invaspect);
    verts[0].y = invaspect*_size;
    
    verts[1].x = _size*(1-invaspect);
    verts[1].y = -invaspect*_size;
    
    verts[2].x = -_size*(1-invaspect);
    verts[2].y = -invaspect*_size;
    
    verts[3].x = -_size*(1-invaspect);
    verts[3].y = invaspect*_size;
    
    [self setMass:(4/PI)*invaspect*100*_size*_size];
    [self setMoment:5*cpMomentForBox(_mass, _size*2, _size*2*invaspect)];
    
    [self addPolyShapeWithNumVerts:4 withVerts:verts withOffset:cpvzero];
    [self addCircleShapeWithRadius:invaspect*_size withOffset:vec2(_size*(1-invaspect), 0)];
    [self addCircleShapeWithRadius:invaspect*_size withOffset:vec2(-_size*(1-invaspect), 0)];

    [_renderable release];
    _renderable = [[BounceCapsuleRenderable alloc] initWithInputs:_inputs aspect:aspect];
    
    
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
    
    [_renderable release];
    _renderable = [[BounceTriangleRenderable alloc] initWithInputs:_inputs];
}

-(void)setupPentagon {
    float cos72 = .309016994375;
    float sin72 = .951056516295;
    
    vec2 vert(0, _size*1.1056);
    
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
    
    [_renderable release];
    _renderable = [[BouncePentagonRenderable alloc] initWithInputs:_inputs];    
}

-(void)setupStar {
    float cos72 = .309016994375;
    float sin72 = .951056516295;
    
    float sin36 = .587785252292;
    float cos36 = .809016994375;
    
    vec2 vert(0, _size*1.1056);
    
    vec2 verts[4];
    verts[0] = vert;
    
    verts[1] = .5*vert;
    verts[1].rotate(cos36,sin36);
    
    verts[2] = vec2();
    
    verts[3] = .5*vert;
    verts[3].rotate(cos36,-sin36);
    
    verts[2] += .8*vec2(0,-1)*verts[1].length();
    verts[1] += .5*(verts[3]-verts[1]).length()*(verts[1]-verts[0]).unit();
    verts[3] += .5*(verts[3]-verts[1]).length()*(verts[3]-verts[0]).unit();
    
    [self setMass:.8*100*_size*_size];
    float moment = 5*cpMomentForPoly(.2*_mass, 4, (cpVect*)verts, cpvzero);
    [self addPolyShapeWithNumVerts:4 withVerts:verts withOffset:cpvzero];
 
    for(int i = 0; i < 4; i++) {
        for(int j = 0; j < 4; j++) {
            verts[j].rotate(cos72,sin72);
        }
        [self addPolyShapeWithNumVerts:4 withVerts:verts withOffset:cpvzero];
        moment += 5*cpMomentForPoly(.2*_mass, 4, (cpVect*)verts, cpvzero);
    }
    
    [self setMoment:moment];
    
    [_renderable release];
    _renderable = [[BounceStarRenderable alloc] initWithInputs:_inputs];    
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

-(void)resizeNote {    
    // Polygon 1
    unsigned int numPts1 = 7;
    vec2 poly1[] = {
        vec2(_size*0.029296875, _size*-0.705078125),
        vec2(_size*-0.09765625, _size*-0.98046875),
        vec2(_size*-0.462890625, _size*-1.12890625),
        vec2(_size*-0.705078125, _size*-0.998046875),
        vec2(_size*-0.681640625, _size*-0.7265625),
        vec2(_size*-0.4296875, _size*-0.5546875),
        vec2(_size*-0.087890625, _size*-0.580078125)
    };
    
    // Polygon 2
    unsigned int numPts2 = 5;
    vec2 poly2[] = {
        vec2(_size*-0.0234375, _size*1.1328125),
        vec2(_size*0.029296875, _size*1.041015625),
        vec2(_size*0.029296875, _size*-0.705078125),
        vec2(_size*-0.0859375, _size*-0.9375),
        vec2(_size*-0.0859375, _size*1.1328125)
    };
    
    // Polygon 3
    unsigned int numPts3 = 5;
    vec2 poly3[] = {
        vec2(_size*0.455078125, _size*0.611328125),
        vec2(_size*0.69921875, _size*0.298828125),
        vec2(_size*0.46484375, _size*0.388671875),
        vec2(_size*-0.0859375, _size*0.75),
        vec2(_size*-0.0859375, _size*1.1328125)
    };
    
    // Polygon 4
    unsigned int numPts4 = 4;
    vec2 poly4[] = {
        vec2(_size*0.69921875, _size*0.298828125),
        vec2(_size*0.716796875, _size*0.0390625),
        vec2(_size*0.619140625, _size*0.1015625),
        vec2(_size*0.43359375, _size*0.51171875)
    };
    
    // Polygon 5
    unsigned int numPts5 = 4;
    vec2 poly5[] = {
        vec2(_size*0.716796875, _size*0.0390625),
        vec2(_size*0.5859375, _size*-0.216796875),
        vec2(_size*0.521484375, _size*-0.19921875),
        vec2(_size*0.66015625, _size*0.3125)
    };
    
    // Polygon 6
    unsigned int numPts6 = 4;
    vec2 poly6[] = {
        vec2(_size*0.580078125, _size*-0.216796875),
        vec2(_size*0.310546875, _size*-0.466796875),
        vec2(_size*0.26953125, _size*-0.419921875),
        vec2(_size*0.583984375, _size*-0.091796875)
    };

    [self setMass:20*_size*_size];
    
    
    float moment = 5*(cpMomentForPoly(_mass, numPts1, (const cpVect*)poly1, cpvzero)+
                      cpMomentForPoly(_mass, numPts2, (const cpVect*)poly2, cpvzero)+
                      cpMomentForPoly(_mass, numPts3, (const cpVect*)poly3, cpvzero)+
                      cpMomentForPoly(_mass, numPts4, (const cpVect*)poly4, cpvzero)+
                      cpMomentForPoly(_mass, numPts5, (const cpVect*)poly5, cpvzero)+
                      cpMomentForPoly(_mass, numPts6, (const cpVect*)poly6, cpvzero));
    
    [self setMoment:moment];
    
    cpPolyShapeSetVerts(_shapes[0], numPts1, (cpVect*)poly1, cpvzero);
    cpPolyShapeSetVerts(_shapes[1], numPts2, (cpVect*)poly2, cpvzero);
    cpPolyShapeSetVerts(_shapes[2], numPts3, (cpVect*)poly3, cpvzero);
    cpPolyShapeSetVerts(_shapes[3], numPts4, (cpVect*)poly4, cpvzero);
    cpPolyShapeSetVerts(_shapes[4], numPts5, (cpVect*)poly5, cpvzero);
    cpPolyShapeSetVerts(_shapes[5], numPts6, (cpVect*)poly6, cpvzero);


}


-(void)resizeRectangle {
    float aspect = _size/_size2;
    float invaspect = 1./aspect;

    cpVect verts[4];
    verts[0].x = _size;
    verts[0].y = invaspect*_size;
    
    verts[1].x = _size;
    verts[1].y = -invaspect*_size;
    
    verts[2].x = -_size;
    verts[2].y = -invaspect*_size;
    
    verts[3].x = -_size;
    verts[3].y = invaspect*_size;
    
    [self setMass:(4/PI)*invaspect*100*_size*_size];
    [self setMoment:5*cpMomentForBox(_mass, _size*2, _size*2*invaspect)];
    
    cpPolyShapeSetVerts(_shapes[0], 4, verts, cpvzero);
    [(BounceRectangleRenderable*)_renderable setAspect:aspect];

}

-(void)resizeCapsule {
    float aspect = _size/_size2;
    float invaspect = 1./aspect;

    cpVect verts[4];
    verts[0].x = _size*(1-invaspect);
    verts[0].y = invaspect*_size;
    
    verts[1].x = _size*(1-invaspect);
    verts[1].y = -invaspect*_size;
    
    verts[2].x = -_size*(1-invaspect);
    verts[2].y = -invaspect*_size;
    
    verts[3].x = -_size*(1-invaspect);
    verts[3].y = invaspect*_size;
    
    [self setMass:(4/PI)*invaspect*100*_size*_size];
    [self setMoment:5*cpMomentForBox(_mass, _size*2, _size*2*invaspect)];
    
    cpPolyShapeSetVerts(_shapes[0], 4, verts, cpvzero);
    
    vec2 offset1(_size*(1-invaspect), 0);
    vec2 offset2(-_size*(1-invaspect), 0);

    cpCircleShapeSetOffset(_shapes[1], (const cpVect&)offset1);
    cpCircleShapeSetRadius(_shapes[1], invaspect*_size);
    
    cpCircleShapeSetOffset(_shapes[2], (const cpVect&)offset2);
    cpCircleShapeSetRadius(_shapes[2], invaspect*_size);
    [(BounceCapsuleRenderable*)_renderable setAspect:aspect];
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
    
    vec2 vert(0, _size*1.1056);
    
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

-(void)resizeStar {
    float cos72 = .309016994375;
    float sin72 = .951056516295;
    
    float sin36 = .587785252292;
    float cos36 = .809016994375;
    
    vec2 vert(0, _size*1.1056);
    
    vec2 verts[4];
    verts[0] = vert;
    
    verts[1] = .5*vert;
    verts[1].rotate(cos36,sin36);
    
    verts[2] = vec2();
    
    verts[3] = .5*vert;
    verts[3].rotate(cos36,-sin36);
    
    verts[2] += .8*vec2(0,-1)*verts[1].length();
    verts[1] += .5*(verts[3]-verts[1]).length()*(verts[1]-verts[0]).unit();
    verts[3] += .5*(verts[3]-verts[1]).length()*(verts[3]-verts[0]).unit();

    
    [self setMass:.8*100*_size*_size];
    float moment = 5*cpMomentForPoly(.2*_mass, 4, (cpVect*)verts, cpvzero);
    cpPolyShapeSetVerts(_shapes[0], 4, (cpVect*)verts, cpvzero);

    for(int i = 1; i < 5; i++) {
        for(int j = 0; j < 4; j++) {
            verts[j].rotate(cos72,sin72);
        }
        cpPolyShapeSetVerts(_shapes[i], 4, (cpVect*)verts, cpvzero);

        moment += 5*cpMomentForPoly(_mass, 4, (cpVect*)verts, cpvzero);
    }
    
    [self setMoment:moment];    
}



-(void)step:(float)dt {
    _intensity *= .9;
    _age += dt;
    
    if(_beingGrabbed || _beingTransformed) {
        float spring_k = 300;
        float drag = .25;
        
        vec2 pos = [self position];
        pos += _vel*dt;
        vec2 a = -spring_k*(pos-_springLoc);
        _vel +=  a*dt-drag*_vel;
        
        [self setPosition:pos];
        [self setVelocity:_vel];
    }
    
    [_renderable step:dt];
}

void ChipmunkDebugDrawPolygon(int count, cpVect *verts, const vec4& lineColor, const vec4& fillColor)
{	

    FSAShaderManager *shaderManager = [FSAShaderManager instance];
    FSAShader *shader = [shaderManager getShader:@"ColorShader"];
    
    [shader setPtr:verts forAttribute:@"position"];
    [shader setPtr:(vec4*)&fillColor forUniform:@"color"];
    [shader enable];
    glDrawArrays(GL_TRIANGLE_FAN, 0, count);
    [shader disable];
	
    [shader setPtr:(vec4*)&lineColor forUniform:@"color"];
    [shader enable];
    glDrawArrays(GL_LINE_LOOP, 0, count);
    [shader disable];
}

static void
drawShape(cpShape *shape, const vec4& color)
{	
	switch(CP_PRIVATE(shape->klass)->type){
		case CP_CIRCLE_SHAPE: {
			//cpCircleShape *circle = (cpCircleShape *)shape;
			//ChipmunkDebugDrawCircle(circle->tc, body->a, circle->r, vec4(1,1,1,1), color);
			break;
		}
		case CP_SEGMENT_SHAPE: {
			//cpSegmentShape *seg = (cpSegmentShape *)shape;
			//ChipmunkDebugDrawFatSegment(seg->ta, seg->tb, seg->r, vec4(1,1,1,1), color);
			break;
		}
		case CP_POLY_SHAPE: {
			cpPolyShape *poly = (cpPolyShape *)shape;
			ChipmunkDebugDrawPolygon(poly->numVerts, poly->tVerts, vec4(1,1,1,1), color);
			break;
		}
		default: break;
	}
}

-(void)draw {
    [_renderable draw];
   /* 
    for(int i = 0; i < _numShapes; i++) {
        drawShape(_shapes[i], _color);
    }*/
     
}

-(void)drawSelected {
    [_renderable drawSelected];
}


-(void)separate {
    float angle = self.angle;  
    vec2 pos(self.position);
    vec2 vel(self.velocity);
    
    float cosangle = cos(angle);
    float sinangle = sin(angle);
    
    vel.rotate(cosangle,sinangle); 
    
    for(int i=0; i < _contactPoints.count; i++){
        vec2 p(_contactPoints.points[i].point);
        p -= pos;
        p.rotate(cosangle,sinangle);
        
        [_renderable collideAt:p withVelocity:vel];
    }
    
}

-(void)setPatternTexture:(FSATexture *)patternTexture {
    [patternTexture retain];
    [_patternTexture release];
    _patternTexture = patternTexture;
    [self needsSize];
}

-(void)playSound:(float)volume {
    [_sound play:volume];
}

-(void)addToSimulation:(BounceSimulation*)sim {
    self.simulation = sim;
    [self addToSpace:sim.space];
    [sim addObject:self];
}
-(void)removeFromSimulation {
    [_simulation removeObject:self];
    [self removeFromSpace];
    self.simulation = nil;
}
-(void)postSolveRemoveFromSimulation {
    [_simulation postSolveRemoveObject:self];
}
-(BOOL)hasBeenAddedToSimulation {
    return _simulation != nil;
}

-(void)setPatternForTextureSheet: (NSString*)name row:(unsigned int)row col:(unsigned int)col numRows:(unsigned int)rows numCols:(unsigned int)cols {
    self.patternTexture = [[FSATextureManager instance] getTexture:name];

    [_renderable setPatternUVsForTextureSheetAtRow:row col:col numRows:rows numCols:cols];
}

-(void)singleTapAt:(const vec2 &)loc {

    if(_isStationary) {
        _isStationary = NO;
    } else if(_age > .5 && _simulation != nil) {
        [self playSound:.2];
        [self removeFromSimulation];
    }
}

-(void)flickAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    vec2 curVel = self.velocity;
    vec2 newVel = curVel+vel;
    [self setVelocity:newVel];
    
    if(_isStationary) {
        _isStationary = NO;
    } else {
        if(_simulation != nil) {
            NSSet *objects = [_simulation objectsAt:loc withinRadius:.3];
            for(BounceObject *obj in objects) {
                if(!obj.isStationary) {
                    curVel = obj.velocity;
                    newVel = curVel+vel;
                    obj.velocity = newVel;
                }
            }
        }
    }
}

-(void)dealloc {
    [_sound release];
    _sound = nil;
    [_renderable release];
    _renderable = nil;
    
    if(_simulation) {
        [self removeFromSimulation];
        [_simulation release];
    }

    [super dealloc];
}


@end


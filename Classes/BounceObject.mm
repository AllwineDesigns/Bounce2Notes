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

    float d = cpfpow(obj->_damping,dt);
//    float d = damping;
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

@synthesize order = _order;
@synthesize lastPlayed = _lastPlayed;
@synthesize simulationWillDraw = _simulationWillDraw;
@synthesize simulationWillArchive = _simulationWillArchive;
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
@synthesize bounceType = _bounceType;
@synthesize tempo = _tempo;

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
    float size = [[BounceSettings instance].sizeGenerator size].width;
    vec4 color;
    color = [[[BounceSettings instance] colorGenerator] randomColorFromLocation:loc];
    float angle = 2*PI*random(34.2938*loc);
    
    return [self initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    BounceShape bounceShape = BounceShape([aDecoder decodeInt32ForKey:@"BounceObjectShape"]);
    vec2 pos([aDecoder decodeFloatForKey:@"BounceObjectPositionX"], 
             [aDecoder decodeFloatForKey:@"BounceObjectPositionY"]);
    vec2 vel([aDecoder decodeFloatForKey:@"BounceObjectVelocityY"], 
             [aDecoder decodeFloatForKey:@"BounceObjectVelocityY"]);
    vec4 color([aDecoder decodeFloatForKey:@"BounceObjectColorR"],
               [aDecoder decodeFloatForKey:@"BounceObjectColorG"],
               [aDecoder decodeFloatForKey:@"BounceObjectColorB"],
               [aDecoder decodeFloatForKey:@"BounceObjectColorA"]);
    
    float size = [aDecoder decodeFloatForKey:@"BounceObjectSize"];
    float angle = [aDecoder decodeFloatForKey:@"BounceObjectAngle"];

    self = [self initObjectWithShape:bounceShape at:pos withVelocity:vel withColor:color withSize:size withAngle:angle];
    
    self.angVel = [aDecoder decodeFloatForKey:@"BounceObjectAngVel"];
    self.intensity = [aDecoder decodeFloatForKey:@"BounceObjectIntensity"];
    [self setSize:size secondarySize:[aDecoder decodeFloatForKey:@"BounceObjectSecondarySize"]];
    self.sound = [aDecoder decodeObjectForKey:@"BounceObjectSound"];
    self.patternTexture = [[FSATextureManager instance] getTexture:[aDecoder decodeObjectForKey:@"BounceObjectPatternTexture"]];
    
    self.bounciness = [aDecoder decodeFloatForKey:@"BounceObjectBounciness"];
    self.friction = [aDecoder decodeFloatForKey:@"BounceObjectFriction"];
    self.gravityScale = [aDecoder decodeFloatForKey:@"BounceObjectGravityScale"];
    self.damping = [aDecoder decodeFloatForKey:@"BounceObjectDamping"];
    self.velocityLimit = [aDecoder decodeFloatForKey:@"BounceObjectVelocityLimit"];
    
    self.isStationary = [aDecoder decodeBoolForKey:@"BounceObjectIsStationary"];
    if(self.isStationary) {
        [self makeStatic];
    }
    
    self.isPreviewable = [aDecoder decodeBoolForKey:@"BounceObjectIsPreviewable"];
    self.isRemovable = [aDecoder decodeBoolForKey:@"BounceObjectIsRemovable"];
    self.simulationWillDraw = [aDecoder decodeBoolForKey:@"BounceObjectSimulationWillDraw"];
    self.simulationWillArchive = [aDecoder decodeBoolForKey:@"BounceObjectSimulationWillArchive"];
    
    self.order = [aDecoder decodeInt32ForKey:@"BounceObjectOrder"];
    if(!self.order) self.order = 1;
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    vec2 pos = self.position;
    vec2 vel = self.velocity;
    float angle = self.angle;
    float angVel = self.angVel;
    
    [aCoder encodeInt32:_order forKey:@"BounceObjectOrder"];
    [aCoder encodeObject:_sound forKey:@"BounceObjectSound"];
    [aCoder encodeObject:_patternTexture.key forKey:@"BounceObjectPatternTexture"];
    
    [aCoder encodeInt32:_bounceShape forKey:@"BounceObjectShape"];
    [aCoder encodeFloat:pos.x forKey:@"BounceObjectPositionX"];
    [aCoder encodeFloat:pos.y forKey:@"BounceObjectPositionY"];
    [aCoder encodeFloat:vel.x forKey:@"BounceObjectVelocityX"];
    [aCoder encodeFloat:vel.y forKey:@"BounceObjectVelocityY"];
    [aCoder encodeFloat:angle forKey:@"BounceObjectAngle"];
    [aCoder encodeFloat:angVel forKey:@"BounceObjectAngVel"];
    [aCoder encodeFloat:_color.x forKey:@"BounceObjectColorR"];
    [aCoder encodeFloat:_color.y forKey:@"BounceObjectColorG"];
    [aCoder encodeFloat:_color.z forKey:@"BounceObjectColorB"];
    [aCoder encodeFloat:_color.w forKey:@"BounceObjectColorA"];
    [aCoder encodeFloat:_size forKey:@"BounceObjectSize"];
    [aCoder encodeFloat:_size2 forKey:@"BounceObjectSecondarySize"];
    [aCoder encodeFloat:_intensity forKey:@"BounceObjectIntensity"];
    
    [aCoder encodeFloat:_bounciness forKey:@"BounceObjectBounciness"];
    [aCoder encodeFloat:_friction forKey:@"BounceObjectFriction"];
    [aCoder encodeFloat:_gravityScale forKey:@"BounceObjectGravityScale"];
    [aCoder encodeFloat:_damping forKey:@"BounceObjectDamping"];
    [aCoder encodeFloat:_velLimit forKey:@"BounceObjectVelocityLimit"];
    
    [aCoder encodeBool:_isStationary forKey:@"BounceObjectIsStationary"];
    
    [aCoder encodeBool:_isPreviewable forKey:@"BounceObjectIsPreviewable"];
    [aCoder encodeBool:_isRemovable forKey:@"BounceObjectIsRemovable"];
    [aCoder encodeBool:_simulationWillDraw forKey:@"BounceObjectSimulationWillDraw"];
    [aCoder encodeBool:_simulationWillArchive forKey:@"BounceObjectSimulationWillArchive"];
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
        _simulationWillArchive = YES;
        _velLimit = INFINITY;
        _color = color;
        _intensity = 2.2;
        _tempo = 120;
        _bounceType = BOUNCE_NORMAL;
        
        self.patternTexture = [[[BounceSettings instance] patternTextureGenerator] randomPatternTextureWithLocation:loc];

        _sound = [BounceSettings instance].sound;
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
        
        if(self.isStationary) {
            [self makeStatic];
        }
    }
    
    return self;
}

-(void)makeSimulated {
    [super makeSimulated];
    
    [self setSensor:NO];
}

-(void)makeStatic {
    [super makeStatic];
    
    if(_bounceType == BOUNCE_CREATOR) {
        [self setSensor:YES];
    } else {
        [self setSensor:NO];
    }
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
      //  cpShapeSetElasticity(_shapes[i], 1*(1-b)+.5*b);

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
    self.sound = [BounceSettings instance].sound;
}

-(void)randomizeSize {
    CGSize size = [[BounceSettings instance].sizeGenerator size];
    [self setSize:size.width secondarySize:size.height];
}

-(void)randomizePattern {
    vec2 loc = self.position;
    
    self.patternTexture = [[[BounceSettings instance] patternTextureGenerator] randomPatternTextureWithLocation:loc];
}

-(void)randomizeColor {
    
    _color = [[[BounceSettings instance] colorGenerator] randomColor];
}
-(void)randomizeShape {

    self.bounceShape = [[[BounceSettings instance] bounceShapeGenerator] bounceShape];
    
}

-(float)size {
    return _size;
}
-(void)beginCreateCallback {
    
}
-(void)createCallbackWithSize: (float)size secondarySize:(float)size2 {
    switch(_bounceShape) {
        default:
            if(size > 1) {
                size = 1;
                size2 = GOLDEN_RATIO;
            }
            self.secondarySize = size2;
            self.size = size;
    }
}
-(void)createCallbackWithLoc1:(const vec2 &)loc1 loc2:(const vec2 &)loc2 {

    
}
-(void)endCreateCallback {
    
}
-(void)cancelCreateCallback {
}

-(void)beginGrabCallback:(const vec2&)loc {
    _beingGrabbed = YES;
    _springLoc = [self position];
    _vel = [self velocity];

    vec2 dir = vec2(1,0);
    dir.rotate(-self.angle);
}
-(void)grabCallbackWithPosition:(const vec2&)pos velocity:(const vec2&)vel angle:(float)angle angVel:(float)angVel stationary:(BOOL)stationary {

    switch(_bounceShape) {
        default:
            self.angVel = angVel;
             self.angle = angle;
            _springLoc = pos;
            self.isStationary = stationary;
            break;
    }
}
-(void)grabCallback:(const vec2 &)loc {
    vec2 loc1;
    vec2 loc2;
    
    if(_draggingRightSide) {
        loc2 = loc;
        loc1 = _begin;
    } else {
        loc1 = loc;
        loc2 = _begin;
    }
    
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
    [self setMoment:(float).02*cpMomentForCircle(_mass, 0, _size, cpvzero)];
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

    
    float moment = 5*(cpMomentForPoly(.4*_mass, numPts1, (const cpVect*)poly1, cpvzero)+
                      cpMomentForPoly(.2*_mass, numPts2, (const cpVect*)poly2, cpvzero)+
                      cpMomentForPoly(.1*_mass, numPts3, (const cpVect*)poly3, cpvzero)+
                      cpMomentForPoly(.1*_mass, numPts4, (const cpVect*)poly4, cpvzero)+
                      cpMomentForPoly(.1*_mass, numPts5, (const cpVect*)poly5, cpvzero)+
                      cpMomentForPoly(.1*_mass, numPts6, (const cpVect*)poly6, cpvzero));
    
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
    
    
    float moment = 5*(cpMomentForPoly(.4*_mass, numPts1, (const cpVect*)poly1, cpvzero)+
                      cpMomentForPoly(.2*_mass, numPts2, (const cpVect*)poly2, cpvzero)+
                      cpMomentForPoly(.1*_mass, numPts3, (const cpVect*)poly3, cpvzero)+
                      cpMomentForPoly(.1*_mass, numPts4, (const cpVect*)poly4, cpvzero)+
                      cpMomentForPoly(.1*_mass, numPts5, (const cpVect*)poly5, cpvzero)+
                      cpMomentForPoly(.1*_mass, numPts6, (const cpVect*)poly6, cpvzero));
    
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

-(void)creatorCallback:(float)dt {
    if(_bounceType == BOUNCE_CREATOR && self.simulation) {
        _lastBeat += dt;
        if(_lastBeat > 60./_tempo) {
            _lastBeat -= 60./_tempo;
            vec2 pos = [self pointInObject];
            BounceObject *newobj = [BounceObject randomObjectAt:pos];
            [self.simulation postSolveAddObject:newobj];
            [newobj playSound:.2];
        }
    }
}



-(void)step:(float)dt {
   // _intensity *= cpfpow(.005, dt);
    _intensity *= .9; // when dt = .02

    _age += dt;
    
    [self creatorCallback:dt];
    
    /*
    vec2 p = [self position];
    if(std::isnan(p.x) || std::isnan(p.y)) {
        NSLog(@"m: %f", _body->m);
        NSLog(@"m_inv: %f", _body->m_inv);
        NSLog(@"i: %f", _body->i);
        NSLog(@"i_inv: %f", _body->i_inv);
        NSLog(@"p: %f,%f", _body->p.x, _body->p.y);
        NSLog(@"v: %f,%f", _body->v.x, _body->v.y);
        NSLog(@"f: %f, %f", _body->f.x, _body->f.y);
        NSLog(@"a: %f", _body->a);
        NSLog(@"w: %f", _body->w);
        NSLog(@"t: %f", _body->t);
        NSLog(@"rot: %f,%f", _body->rot.x, _body->rot.y);

        NSLog(@"isnan - %@", [self class]);
        _body->p.x = 0;
        _body->p.y = 0;
        _body->v.x = 0;
        _body->v.y = 0;
        _body->a = 0;
        _body->w = 0;
        _body->rot.x = 1;
        _body->rot.y = 0;
     
        CP_PRIVATE(_body->w_bias) = 0;
        CP_PRIVATE(_body->v_bias) = cpvzero;
    }*/
    
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

-(void)collideWith:(BounceObject *)obj {
    if(_bounceType == BOUNCE_DESTROYER && self.simulation && obj.isRemovable) {
        [self.simulation postSolveRemoveObject:obj];
    }
    
    if(obj.bounceType == BOUNCE_DESTROYER && obj.simulation && self.isRemovable) {
        [obj.simulation postSolveRemoveObject:self];
    }
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
    [self removeFromSpace];
    [self retain];
    [_simulation removeObject:self];
    self.simulation = nil;
    [self release];
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
    } else if(_age > .5 && _isRemovable && _simulation != nil) {
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


static vec2 pointInShapes(cpShape **shapes, int numShapes) {
    float total_area = 0;
    
    float *area = (float*)malloc(sizeof(float)*numShapes);
    
    for(int i = 0; i < numShapes; i++) {
        cpShape *shape = shapes[i];
        switch(CP_PRIVATE(shape->klass)->type){
            case CP_CIRCLE_SHAPE: {
                cpCircleShape *circle = (cpCircleShape *)shape;
                total_area += cpAreaForCircle(circle->r, 0);
                break;
            }
            case CP_SEGMENT_SHAPE: {
                cpSegmentShape *seg = (cpSegmentShape *)shape;
                total_area += cpAreaForSegment(seg->a, seg->b, seg->r);
                break;
            }
            case CP_POLY_SHAPE: {
                cpPolyShape *poly = (cpPolyShape *)shape;
                total_area += cpAreaForPoly(poly->numVerts, poly->verts);
                
                break;
            }
            default:
                NSLog(@"pointInShapes not implemented for shape");
                break;
        }
        area[i] = total_area;
    }
    
    float a = RANDFLOAT*total_area;
    vec2 p;
    
    for(int i = 0; i < numShapes; i++) {
        if(a <= area[i]) {
            cpShape *shape = shapes[i];
            switch(CP_PRIVATE(shape->klass)->type){
                case CP_CIRCLE_SHAPE: {
                    cpCircleShape *circle = (cpCircleShape *)shape;
                    
                    float a = RANDFLOAT;
                    float r = sqrt(RANDFLOAT);
                    
                    p = vec2(r*circle->r*cos(a*2*PI), r*circle->r*sin(a*2*PI));
                    p += vec2(circle->tc);
                    break;
                }
                case CP_SEGMENT_SHAPE: {
                    cpSegmentShape *seg = (cpSegmentShape *)shape;
                    vec2 pt1(seg->a);
                    vec2 pt2(seg->b);
                    float len = (pt1-pt2).length();
                    float half_circle = PI*seg->r*seg->r*.5;
                    float rectangle = len*seg->r*2;
                    
                    float total = 2*half_circle+rectangle;
                    
                    half_circle /= total;
                    rectangle /= total;
                    
                    float which_shape = RANDFLOAT;
                    
                    if(which_shape < half_circle) {
                        float a = RANDFLOAT;
                        float r = sqrt(RANDFLOAT);
                        
                        p = vec2(r*seg->r*cos(a*PI+M_PI_2)-len*.5, r*seg->r*sin(a*PI+M_PI_2));
                    } else if(which_shape < 2*half_circle) {
                        float a = RANDFLOAT;
                        float r = sqrt(RANDFLOAT);
                        
                        p = vec2(r*seg->r*cos(a*PI-M_PI_2)+len*.5, r*seg->r*sin(a*PI-M_PI_2));
                    } else {
                        float x = RANDFLOAT;
                        float y = RANDFLOAT;
                        
                        p = vec2(.5*len*(2*x-1), seg->r*(2*y-1));
                    }
                    break;
                }
                case CP_POLY_SHAPE: {
                    cpPolyShape *poly = (cpPolyShape *)shape;
                    cpVect *pts = poly->verts;
                    float *poly_area = (float*)malloc(sizeof(float)*poly->numVerts);
                    float total_poly_area = 0;
                    for(int j = 0; j < poly->numVerts-2; j++) {
                        vec2 A(pts[0]);
                        vec2 B(pts[j+1]);
                        vec2 C(pts[j+2]);
                        
                        float tri = fabs(A.x*(B.y-C.y)+B.x*(C.y-A.y)+C.x*(A.y-B.y))*.5;
                        
                        total_poly_area += tri;
                        poly_area[j] = total_poly_area;
                    }
                    
                    float pa = RANDFLOAT*total_poly_area;
                    for(int j = 0; j < poly->numVerts-2; j++) {
                        if(pa <= poly_area[j]) {
                            vec2 A(pts[0]);
                            vec2 B(pts[j+1]);
                            vec2 C(pts[j+2]);
                            
                            float a = RANDFLOAT;
                            float b = sqrt(RANDFLOAT);
                            
                            vec2 v1 = B-A;
                            vec2 v2 = C-A;
                            
                            p = A+v1*(1-b)+v2*b*a;
                            
                            break;
                        }
                    }
                    free(poly_area);
                    
                    break;
                }
                default:
                    NSLog(@"pointInShapes not implemented for shape");
                    break;
            }
            break;
        }
    }
    
    free(area);
    
    return p;
}

-(vec2)pointInObject {
    vec2 p;
    switch(_bounceShape) {
        case BOUNCE_BALL: {
            float a = RANDFLOAT;
            float r = sqrt(RANDFLOAT);
            
            p = vec2(r*_size*cos(a*2*PI), r*_size*sin(a*2*PI));
        
            break;
        }
        case BOUNCE_CAPSULE: {
            float half_circle = PI*_size2*_size2*.5;
            float rectangle = (2*_size-2*_size2)*_size2*2;
            
            float total = 2*half_circle+rectangle;
            
            half_circle /= total;
            rectangle /= total;
            
            float which_shape = RANDFLOAT;
            
            if(which_shape < half_circle) {
                float a = RANDFLOAT;
                float r = sqrt(RANDFLOAT);
                
                p = vec2(r*_size2*cos(a*PI+M_PI_2)-_size+_size2, r*_size2*sin(a*PI+M_PI_2));
            } else if(which_shape < 2*half_circle) {
                float a = RANDFLOAT;
                float r = sqrt(RANDFLOAT);
                
                p = vec2(r*_size2*cos(a*PI-M_PI_2)+_size-_size2, r*_size2*sin(a*PI-M_PI_2));
            } else {
                float x = RANDFLOAT;
                float y = RANDFLOAT;
                
                p = vec2((_size-_size2)*(2*x-1), _size2*(2*y-1));
            }
            
            
            break;
        }
        case BOUNCE_RECTANGLE:
        {
            float x = RANDFLOAT;
            float y = RANDFLOAT;
            
            p = vec2(_size*(2*x-1), _size2*(2*y-1));
            
            break;
        }
        case BOUNCE_TRIANGLE: {
            float a = RANDFLOAT;
            float b = sqrt(RANDFLOAT);
            
            float cos30 = .866025403784; // sqrt(3)/2
            float sin30 = .5;
            
            vec2 verts[3];
            verts[0].x = 0;
            verts[0].y = _size*1.333333;
            
            verts[1].x = _size*cos30*1.333333;
            verts[1].y = -_size*sin30*1.333333;
            
            verts[2].x = -_size*cos30*1.333333;
            verts[2].y = -_size*sin30*1.333333;
            
            vec2 v1 = verts[2]-verts[1];
            vec2 v2 = verts[0]-verts[1];
            
            p = verts[1]+v1*(1-b)+v2*b*a;
            
            break;
        }
        case BOUNCE_SQUARE: {
            float x = RANDFLOAT;
            float y = RANDFLOAT;
            
            p = vec2(_size*(2*x-1), _size*(2*y-1));
            
            break;
        }
        case BOUNCE_PENTAGON: {
            float a = RANDFLOAT;
            float b = sqrt(RANDFLOAT);
            
            float cos72 = .309016994375;
            float sin72 = .951056516295;
            
            vec2 v1(0, _size*1.1056);
            vec2 v2 = v1;
            v2.rotate(cos72,sin72);
            
            p = v1*(1-b)+v2*b*a;
            
            unsigned int i = RANDFLOAT*5;
            
            p.rotate(i*72.*PI/180);
            
            break;
        }
        case BOUNCE_STAR: {
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
            
            vec2 A = verts[0];
            vec2 B = verts[1];
            vec2 C = verts[3];
            
            float tri1 = fabs(A.x*(B.y-C.y)+B.x*(C.y-A.y)+C.x*(A.y-B.y))*.5;
            
            A = verts[1];
            B = verts[2];
            C = verts[3];
            
            float tri2 = fabs(A.x*(B.y-C.y)+B.x*(C.y-A.y)+C.x*(A.y-B.y))*.5;
            
            float total = tri1+tri2;
            
            tri1 /= total;
            tri2 /= total;
            
            float which_tri = RANDFLOAT;
            
            vec2 v1;
            vec2 v2;
                        
            if(which_tri < tri1) {
                v1 = verts[0]-verts[1];
                v2 = verts[3]-verts[1];
            } else {
                v1 = verts[2]-verts[1];
                v2 = verts[3]-verts[1];
            }
            
            float a = RANDFLOAT;
            float b = sqrt(RANDFLOAT);

            p = verts[1]+v1*(1-b)+v2*b*a;

            unsigned int i = RANDFLOAT*5;
            
            p.rotate(i*72.*PI/180);
            
            break;
        }
        case BOUNCE_NOTE:
            p = pointInShapes(_shapes, _numShapes);
            break;
        default:
            break;
    }
    p.rotate(-self.angle);
    p += self.position;
    
    return p;
}

-(void)setBounceType:(BounceType)bounceType {
    _bounceType = bounceType;
    
    switch(bounceType) {
        case BOUNCE_NORMAL:
        case BOUNCE_DESTROYER:
            [self setSensor:NO];
            break;
        case BOUNCE_CREATOR:
            if(self.isStatic) {
                [self setSensor:YES];
            }
            break;
        default:
            break;
    }
}

-(void)dealloc {
    [_sound release];
    _sound = nil;
    [_renderable release];
    _renderable = nil;   
    [_patternTexture release];
    _patternTexture = nil;
    

    [super dealloc];
}


@end


//
//  BounceSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 5/13/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSimulation.h"
#import "FSAUtil.h"
#import "fsa/Noise.hpp"
#import <chipmunk/chipmunk_unsafe.h>
#import "FSATextureManager.h"

@implementation BounceObject

@synthesize color = _color;
@synthesize space = _space;
@synthesize numShapes = _numShapes;
@synthesize body = _body;
@synthesize shapes = _shapes;
@synthesize size = _size;
@synthesize shapeTexture = _shapeTexture;
@synthesize patternTexture = _patternTexture;
@synthesize isStationary = _isStationary;
@synthesize bounceShape = _bounceShape;

-(id)initRandomObjectAt: (const vec2&)loc inSpace: (cpSpace*)s {
    vec2 vel;
    return [self initRandomObjectAt:loc withVelocity:vel inSpace:s];
}

-(id)initRandomObjectAt: (const vec2&)loc withVelocity:(const vec2&)vel inSpace: (cpSpace*)s {
    float size = random(loc*1.234)*.2+.05;
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             360.*random(64.28327*loc), .4, .05*random(736.2827*loc)+.75   );
    
    BounceShape bounceShape = BounceShape(random(827.239*loc)*3);
    
    return [self initObject:bounceShape at:loc withVelocity:vel withColor:color withSize:size inSpace:s];
}

-(id)initObject:(BounceShape)bounceShape at:(const vec2&)loc withVelocity:(const vec2&)vel withColor:(const vec4&)color  withSize:(float)size inSpace:(cpSpace*)space {
    _size = size;
    cpFloat radius = _size;
    _space = space;
    _color = color;
    
    _isStationary = NO;
    
    _bounceShape = bounceShape;
    FSATextureManager *tex_manager = [FSATextureManager instance];
    
    _patternTexture = [tex_manager getTexture:@"spiral.jpg"];
    
    float mass, moment;
    switch(_bounceShape) {
        case BALL:
            mass = 100*radius*radius;
            moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
            _body = cpSpaceAddBody(_space, cpBodyNew(mass, moment));
            
            _numShapes = 1;
            _shapes = (cpShape**)malloc(_numShapes*sizeof(cpShape*));
            _shapes[0] = cpSpaceAddShape(_space, cpCircleShapeNew(_body, radius, cpvzero));
            _shapeTexture = [tex_manager getTexture:@"ball_nocenterglow.jpg"];
            
            break;
        case SQUARE:
            mass = (4/PI)*100*radius*radius;
            moment = .02*cpMomentForBox(mass, radius, radius);
            _body = cpBodyNew(mass, moment);
            cpVect square_verts[4];
            square_verts[0].x = radius;
            square_verts[0].y = radius;
            
            square_verts[1].x = radius;
            square_verts[1].y = -radius;
            
            square_verts[2].x = -radius;
            square_verts[2].y = -radius;
            
            square_verts[3].x = -radius;
            square_verts[3].y = radius;
            
            _numShapes = 1;
            _shapes = (cpShape**)malloc(_numShapes*sizeof(cpShape*));
            _shapes[0] = cpSpaceAddShape(_space, cpPolyShapeNew(_body, 4, square_verts, cpvzero));
            
            break;
        default: // case TRIANGLE
            float cos30 = cos(PI/6);
            float sin30 = .5;
            cpVect verts[3];
            verts[0].x = 0;
            verts[0].y = 0;
            
            verts[1].x = radius*cos30;
            verts[1].y = -radius*sin30;
            
            verts[2].x = -radius*cos30;
            verts[2].y = -radius*sin30;
            
            mass = (1.5*sqrt(3)/4)*100*radius*radius;
            moment = .02*cpMomentForPoly(mass, 3, verts, cpvzero);
            
            _numShapes = 1;
            _shapes = (cpShape**)malloc(_numShapes*sizeof(cpShape*));
            _shapes[0] = cpSpaceAddShape(_space, cpPolyShapeNew(_body, 3, verts, cpvzero));
            
            break;
    }
    
    cpBodySetPos(_body, (const cpVect&)loc);
    cpBodySetVelLimit(_body, 5);
    cpBodySetUserData(_body, self);
        
    for(int i = 0; i < _numShapes; i++) {
        cpShapeSetFriction(_shapes[i], .1);
        cpShapeSetElasticity(_shapes[i], .95);
        cpShapeSetCollisionType(_shapes[i], OBJECT_TYPE);
    }
    
    return self;
}

-(void)resize:(float)s {
    _size = s;
    float radius = s;
    
    switch(_bounceShape) {
        case BALL:
            cpCircleShapeSetRadius(_shapes[0], radius);
            break;
        case SQUARE:
            cpVect square_verts[4];
            square_verts[0].x = radius;
            square_verts[0].y = radius;
            
            square_verts[1].x = radius;
            square_verts[1].y = -radius;
            
            square_verts[2].x = -radius;
            square_verts[2].y = -radius;
            
            square_verts[3].x = -radius;
            square_verts[3].y = radius;
            
            cpPolyShapeSetVerts(_shapes[0], 4, square_verts, cpvzero);
            
            break;
        default: // case TRIANGLE
            float cos30 = cos(PI/6);
            float sin30 = .5;
            cpVect verts[3];
            verts[0].x = 0;
            verts[0].y = 0;
            
            verts[1].x = radius*cos30;
            verts[1].y = -radius*sin30;
            
            verts[2].x = -radius*cos30;
            verts[2].y = -radius*sin30;
            
            cpPolyShapeSetVerts(_shapes[0], 3, verts, cpvzero);
            
            break;
    }
}

-(const vec2)velocity {
    vec2 vel(cpBodyGetVel(_body));
    
    return vel;
}
-(void)setVelocity:(const vec2&)vel {
    cpBodySetVel(_body, (const cpVect&)vel);
}

-(const vec2)position {
    vec2 pos(cpBodyGetPos(_body));
    
    return pos;
}
-(void)setPosition:(const vec2&)loc {
    cpBodySetPos(_body, (const cpVect&)loc);
}

-(float)angle {
    return cpBodyGetAngle(_body);
}
-(void)setAngle:(float)a {
    cpBodySetAngle(_body, a);
}

-(float)angVel {
    return cpBodyGetAngVel(_body);
}

-(void)setAngVel:(float)a {
    cpBodySetAngVel(_body, a);
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

@implementation BounceSimulation
-(id)initWithAspect: (float)a audioDelegate:(id<FSAAudioDelegate>*)delegate {
    _gestures = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    _space = cpSpaceNew();
    cpSpaceSetCollisionSlop(_space, .02);
        
//    cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, OBJECT_TYPE, collisionBegin, preSolve, postSolve, separate, this);
//    cpSpaceAddCollisionHandler(space, OBJECT_TYPE, WALL_TYPE, collisionBegin, preSolve, postSolve, separate, this);
    
    _audioDelegate = delegate;
    _aspect = a;
    _inv_aspect = 1./aspect;
    
    bottom = cpSegmentShapeNew(space->staticBody, cpv(-1, -inv_aspect-1.1), cpv(1, -inv_aspect-1.1), 1.11);
    top = cpSegmentShapeNew(space->staticBody, cpv(-1, inv_aspect+1.1), cpv(1, inv_aspect+1.1), 1.11);
    right = cpSegmentShapeNew(space->staticBody, cpv(2.1, inv_aspect), cpv(2.1, -inv_aspect), 1.11);
    left = cpSegmentShapeNew(space->staticBody, cpv(-2.1, inv_aspect), cpv(-2.1, -inv_aspect), 1.11);
    
    killBody = cpBodyNew(9999, 99999);
    
    killTopShape = cpSegmentShapeNew(killBody, cpv(-1, inv_aspect), cpv(1,inv_aspect), 0);
    killBottomShape = cpSegmentShapeNew(killBody, cpv(-1, -inv_aspect), cpv(1,-inv_aspect), 0);
    killLeftShape = cpSegmentShapeNew(killBody, cpv(-1, inv_aspect), cpv(-1,-inv_aspect), 0);
    killRightShape = cpSegmentShapeNew(killBody, cpv(1, inv_aspect), cpv(1,-inv_aspect), 0);
    
    killTop = false;
    killBottom = false;
    killLeft = false;
    killRight = false;
    
    cpShapeSetSensor(killTopShape, true);
    cpShapeSetSensor(killBottomShape, true);
    cpShapeSetSensor(killRightShape, true);
    cpShapeSetSensor(killLeftShape, true);
    
    cpShapeSetCollisionType(killTopShape,KILL_TOP_TYPE);
    cpShapeSetCollisionType(killBottomShape, KILL_BOTTOM_TYPE);
    cpShapeSetCollisionType(killLeftShape, KILL_LEFT_TYPE);
    cpShapeSetCollisionType(killRightShape, KILL_RIGHT_TYPE);
    
    cpShapeSetFriction(bottom,.1);
    cpShapeSetFriction(top, .1);
    cpShapeSetFriction(right, .1);
    cpShapeSetFriction(left, .1);
    
    cpShapeSetElasticity(bottom,1.);
    cpShapeSetElasticity(top, 1.);
    cpShapeSetElasticity(right, 1.);
    cpShapeSetElasticity(left, 1.);
    
    cpShapeSetCollisionType(bottom,WALL_TYPE);
    cpShapeSetCollisionType(top, WALL_TYPE);
    cpShapeSetCollisionType(right, WALL_TYPE);
    cpShapeSetCollisionType(left, WALL_TYPE);
    
    cpSpaceAddShape(space, bottom);
    cpSpaceAddShape(space, top);
    cpSpaceAddShape(space, right);
    cpSpaceAddShape(space, left);
    
    cpSpaceAddShape(space, killBottomShape);
    cpSpaceAddShape(space, killTopShape);
    cpSpaceAddShape(space, killRightShape);
    cpSpaceAddShape(space, killLeftShape);
    
    //audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c_1", @"d_1", @"e_1", @"f_1", @"g_1", @"a_1", @"b_1", @"c_2", @"d_2", @"e_2", @"f_2", @"g_2", @"a_2", @"b_2", @"c_3", @"d_3", @"e_3", @"f_3", @"g_3", @"a_3", @"b_3", @"c_4", nil] volume:10];
    
#define NOTES 81
    int notes[NOTES] = {11,6,8,11,8,6,6,8,13,11,11,13,14,13,11,11,13,12,12,11, 
        11,6,8,11,8,6,6,8,13,11,11,13,14,13,11,11,13,12,12,11,
        11,6,8,11,8,6,6,8,13,11,11,13,14,13,11,11,13,12,12,11,
        11,6,8,11,11,8,6,6,8,13,11,11,13,14,13,11,11,13,12,12,11};
    
    //    for(int i = 0; i < 300; i++) {
    for(int i = 0; i < NOTES; i++) {
        
        //  cpFloat radius = 1.5*(random(i*1.234)*.075+.05);
        //cpFloat radius = (random(i*1.234)*.075+.05);
        
        cpFloat radius = .02;
        cpFloat mass = 100*radius*radius;
        
        cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
        
        HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), BOUNCE_DEFAULT_HUE, BOUNCE_DEFAULT_SATURATION, BOUNCE_DEFAULT_VALUE   );
        // ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
        ballData->note = notes[i];
        
        ballData->stationary = true;
        
        //        ballData->color = vec4((ballData->color.x+1)*.4,(ballData->color.y+1)*.4,(ballData->color.z+1)*.4,1);
        //        sqrt( 0.241*R^2 + 0.691*G^2 + 0.068*B^2 )
        /*
         HSVtoRGB(&(ballData->color.x), &(ballData->color.x), &(ballData->color.x), 360.*random(64.28327*i), .5*random(273.2932*i), 1   );
         
         float lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
         int tries = 1;
         while((lum < .25 || lum > .75) && tries < 100) {
         //            col = vec3(random(64.7263*i+7.2893*tries), random(91.23819*i+928.233588*tries), random(342.123*i+316.1928274*tries));
         //            lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
         ++tries;
         }
         */
        /*
         ballData->color.x = col.x;
         ballData->color.y = col.y;
         ballData->color.z = col.z;
         */
        //        HSVtoRGB(&(ballData->color.x), &(ballData->color.x), &(ballData->color.x), 360.*random(64.28327*i), .5*random(273.2932*i), 1   );
        cpBody *ballBody = cpSpaceAddBody(space, cpBodyNew(mass, moment));
        //        cpBodySetPos(ballBody, cpv(random(2.3234*i)-.5, random(4.59234*i)-.5));
        
        float t = (float)i/(NOTES-1);
        
        float xt = (float)ballData->note/([audio_player numSounds]-1);
        cpBodySetPos(ballBody, cpv(-(1-xt)+xt, 1.2*t-1.2*(1-t)));
        
        // cpBodySetVel(ballBody, cpv(5*(random(92.11234*i)-.5), 5*(random(23.234934*i)-.5)));
        cpBodySetVelLimit(ballBody, 5);
        cpBodySetAngVelLimit(ballBody, 50);
        
        cpBodySetUserData(ballBody, ballData);
        
        cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
        cpShapeSetFriction(ballShape, .1);
        cpShapeSetElasticity(ballShape, .95);
        cpShapeSetCollisionType(ballShape, BALL_TYPE);
        
        bodies.push_back(ballBody);
        shapes.push_back(ballShape);
        
        makeStatic(ballShape);
    }
    
}
-(void)addObject: (BounceObject*)object {
    
}
-(void)removeObject: (BounceObject*)object {
    
}
-(void)postSolveRemoveObject: (BounceObject*)object {
    
}
-(void)containsObject: (BounceObject*)object {
    
}

-(void)step: (float)t {
    
}
-(void)next {
    
}

-(void)addVelocity: (const vec2&)vel toObjectsAt:(const vec2&)loc  withinRadius:(float) radius {
    
}
-(void)addVelocity: (const vec2&)vel toObjectAt:(const vec2&)loc {
    
}

-(void)removeObjectAt:(const vec2&)loc {
    
}
-(void)addObjectAt:(const vec2&)loc {
    
}
-(void)addObjectAt:(const vec2&)loc withVelocity:(const vec2&)vel {
    
}
-(BOOL)isObjectAt:(const vec2&)loc {
    
}
-(BOOL)anyObjectsAt:(const vec2&)loc withinRadius:(float)radius {
    
}
-(void)setGravity:(const vec2&)g {
    
}
-(void)addToVelocity:(const vec2&)v {
    
}

-(BOOL)isObjectParticipatingInGestureAt: (const vec2&)loc {
    
}
-(BOOL)isObjectBeingCreatedOrGrabbedAt:(const vec2&)loc {
    
}
-(BOOL)isBallBeingTransformedAt:(const vec2&)loc {
    
}
-(BOOL)isStationaryBallAt:(const vec2&)loc {
    
}

-(void)makeObjectStationaryAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}

-(BOOL)isCreatingObjectForGesture:(void*)uniqueId {
    
}
-(void)creatingObjectFrom:(const vec2&)from to:(const vec2&)to forGesture:(void*)uniqueId {
    
}
-(void)createObjectForGesture:(void*)uniqueId {
    
}
-(void)cancelCreatingObjectForGesture:(void*)uniqueId {
    
}

-(void)beginGrabbingCreatedObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)createStationaryObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}

-(BOOL)isGrabbingObjectForGesture:(void*)uniqueId {
    
}
-(void)beginGrabbingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)grabbingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)releaseObjectForGesture:(void*)uniqueId {
    
}

-(BOOL)isTransformingObject:(void*)uniqueId {
    
}
-(void)beginTransformingObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)transformObjectAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)makeTransformingObjectStationaryAt:(const vec2&)loc forGesture:(void*)uniqueId {
    
}
-(void)beginGrabbingTransformingObjectForGesture:(void*)uniqueId {
    
}

-(void)beginRemovingBallsTop:(float)y {
    
}
-(void)updateRemovingBallsTop:(float)y {
    
}
-(void)endRemovingBallsTop {
    
}

-(void)beginRemovingBallsBottom:(float)y {
    
}
-(void)updateRemovingBallsBottom:(float)y {
    
}
-(void)endRemovingBallsBottom {
    
}

-(void)beginRemovingBallsLeft:(float)x {
    
}
-(void)updateRemovingBallsLeft:(float)x {
    
}
-(void)endRemovingBallsLeft {
    
}

-(void)beginRemovingBallsRight:(float)x {
    
}
-(void)updateRemovingBallsRight:(float)x {
    
}
-(void)endRemovingBallsRight {
    
}

-(BOOL)isRemovingBalls {
    
}
-(BOOL)isRemovingBallsTop {
    
}
-(BOOL)isRemovingBallsBottom {
    
}
-(BOOL)isRemovingBallsLeft {
    
}
-(BOOL)isRemovingBallsRight {
    
}

-(float)removingBallsTopY {
    
}
-(float)removingBallsBottomY {
    
}
-(float)removingBallsLeftX {
    
}
-(float)removingBallsRightX {
    
}


@end

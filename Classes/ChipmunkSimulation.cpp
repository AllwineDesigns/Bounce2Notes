//
//  ChipmunkSimulation.cpp
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#include "ChipmunkSimulation.h"
#include <fsa/Noise.hpp>

int collisionBegin(cpArbiter *arb, cpSpace *space, void *data) {
    return 1;
}
int preSolve(cpArbiter *arb, cpSpace *space, void *data) {
    return 1;
}
void postSolve(cpArbiter *arb, cpSpace *space, void *data) {
    ChipmunkSimulation *simulation = (ChipmunkSimulation*)data;
    unsigned int numBalls = simulation->numBalls();
    cpBody *body1;
    cpBody *body2;
    cpShape *shape1;
    cpShape *shape2;
    cpArbiterGetBodies(arb, &body1, &body2);
    cpArbiterGetShapes(arb, &shape1, &shape2);
    
    cpCollisionType t1 = cpShapeGetCollisionType(shape1);
    cpCollisionType t2 = cpShapeGetCollisionType(shape2);

    cpVect impulse = cpArbiterTotalImpulseWithFriction(arb);
    vec2 imp(impulse.x, impulse.y);
    float ke = .05*imp.length()/sqrt(numBalls)*15; 
//    float ke = .1*cpArbiterTotalKE(arb);
    
    if(t1 == BALL_TYPE && t2 == BALL_TYPE) {
        ke *= .5;
    }
    
    if(t1 == BALL_TYPE) {
        BallData* ballData = (BallData*)cpBodyGetUserData(body1);
        cpVect vel = cpBodyGetVel(body1);
        vec2 v(vel.x, vel.y);
        
//        float mag = .3*v.length();
        
//        ballData->intensity = .5*(ballData->intensity+mag);
        ballData->intensity += ke;
        
    }

    if(t2 == BALL_TYPE) {
        BallData* ballData = (BallData*)cpBodyGetUserData(body2);
        cpVect vel = cpBodyGetVel(body2);
        vec2 v(vel.x, vel.y);
        
//        float mag = .3*v.length();
        
//        ballData->intensity = .5*(ballData->intensity+mag);
        ballData->intensity += ke;
        
    }
}
void separate(cpArbiter *arb, cpSpace *space, void *data) {
    
}

ChipmunkSimulation::ChipmunkSimulation() : dt(.02), time_remainder(0) {
    space = cpSpaceNew();
    cpSpaceSetGravity(space, *((cpVect*)(&gravity)));
//    cpSpaceSetDamping(space, .5);
    
    cpSpaceUseSpatialHash(space, .3, 3000);
    
    cpSpaceSetDefaultCollisionHandler(space, collisionBegin, preSolve, postSolve, separate, this);

    bottom = cpSegmentShapeNew(space->staticBody, cpv(-1, -2.6), cpv(1, -2.6), 1.11);
    top = cpSegmentShapeNew(space->staticBody, cpv(-1, 2.6), cpv(1, 2.6), 1.11);
    right = cpSegmentShapeNew(space->staticBody, cpv(2.1, 1.5), cpv(2.1, -1.5), 1.11);
    left = cpSegmentShapeNew(space->staticBody, cpv(-2.1, 1.5), cpv(-2.1, -1.5), 1.11);
    
    cpShapeSetFriction(bottom,0.);
    cpShapeSetFriction(top, 0.);
    cpShapeSetFriction(right, 0.);
    cpShapeSetFriction(left, 0.);
    
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
    
    for(int i = 0; i < 300; i++) {
        cpFloat radius = .5*(random(i*1.234)*.075+.05);
        cpFloat mass = 100*radius*radius;

        cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
        
        vec3 col(ballData->color.xyz());
//        sqrt( 0.241*R^2 + 0.691*G^2 + 0.068*B^2 )
        float lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
        int tries = 1;
        while((lum < .25 || lum > .75) && tries < 100) {
            col = vec3(random(64.7263*i+7.2893*tries), random(91.23819*i+928.233588*tries), random(342.123*i+316.1928274*tries));
            lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);

            ++tries;
        }
        ballData->color.x = col.x;
        ballData->color.y = col.y;
        ballData->color.z = col.z;
        
        cpBody *ballBody = cpSpaceAddBody(space, cpBodyNew(mass, moment));
        cpBodySetPos(ballBody, cpv(random(2.3234*i)-.5, random(4.59234*i)-.5));
        cpBodySetVel(ballBody, cpv(5*(random(92.11234*i)-.5), 5*(random(23.234934*i)-.5)));
        cpBodySetVelLimit(ballBody, 5);
        cpBodySetUserData(ballBody, ballData);

        cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
        cpShapeSetFriction(ballShape, 0.);
        cpShapeSetElasticity(ballShape, .95);
        cpShapeSetCollisionType(ballShape, BALL_TYPE);
        
        bodies.push_back(ballBody);
        shapes.push_back(ballShape);
    }
    
}

void ChipmunkSimulation::next() {
    cpSpaceStep(space, dt);
    
    std::vector<cpBody*>::iterator itr = bodies.begin();
    while(itr != bodies.end()) {
        BallData* ballData = (BallData*)cpBodyGetUserData(*itr);
        ballData->intensity *= .9;
//        cpVect v = cpBodyGetVel(*itr);
//        vec2 vel(v.x,v.y);
//        ballData->intensity = .2*vel.length();
        ++itr;
    }
    
}

void ChipmunkSimulation::addToVelocity(const vec2& v) {
    std::vector<cpBody*>::iterator itr = bodies.begin();
    while(itr != bodies.end()) {
        cpVect vel = cpBodyGetVel(*itr);
        vel.x += v.x;
        vel.y += v.y;
        cpBodySetVel(*itr, vel);
        ++itr;
    }
}

void ChipmunkSimulation::step(float t) {
    t += time_remainder;
    
    while(t > dt) {
        next();
        t -= dt;
    }
    
    time_remainder = t;
}

void ChipmunkSimulation::setGravity(const vec2& accel) {
    cpSpaceSetGravity(space, *((cpVect*)(&accel)));
}

unsigned int ChipmunkSimulation::numBalls() {
    return bodies.size();
}

cpShape* const* ChipmunkSimulation::shapesPointer() {
    return &shapes[0];
}

cpBody* const* ChipmunkSimulation::bodiesPointer() {
    return &bodies[0];
}

ChipmunkSimulation::~ChipmunkSimulation() {
    cpShapeFree(bottom);
    cpShapeFree(top);
    cpShapeFree(right);
    cpShapeFree(left);
    
    std::vector<cpShape*>::iterator shape_itr = shapes.begin();
    while(shape_itr != shapes.end()) {
        cpShapeFree(*shape_itr);
        ++shape_itr;
    }
    
    std::vector<cpBody*>::iterator body_itr = bodies.begin();
    while(body_itr != bodies.end()) {
        cpBodyFree(*body_itr);
        ++body_itr;
    }
    
    cpSpaceFree(space);

}


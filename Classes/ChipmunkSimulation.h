//
//  ChipmunkSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#pragma once

#include <chipmunk/chipmunk.h>
#include <fsa/Vector.hpp>
#include <vector>

using namespace fsa;

enum {
    WALL_TYPE,
    BALL_TYPE
};

struct BallData {
    vec4 color;
    float intensity;
    
    BallData(vec4 c) : color(c), intensity(0.) {}
};

class ChipmunkSimulation {
protected:
    float dt;
    float time_remainder;
    cpSpace* space;
    cpShape* bottom;
    cpShape* top;
    cpShape* left;
    cpShape* right;
    std::vector<cpShape*> shapes;
    std::vector<cpBody*> bodies;
    
//    std::vector<cpBody*> grabberBodies;
//    std::vector<cpShape*> grabberShapes;
    
//    std::vector<cpBody*> creatingBodies;
//    std::vector<cpShape*> creatingShapes;

    vec2 gravity;
    void next();

public:
    ChipmunkSimulation();
    ~ChipmunkSimulation();
    
    void setGravity(const vec2& g);
    void addToVelocity(const vec2& v);
    void step(float t);
    unsigned int numBalls();
    cpShape* const* shapesPointer();
    cpBody* const* bodiesPointer();
    
};

int collisionBegin(cpArbiter *arb, cpSpace *space, void *data);
int preSolve(cpArbiter *arb, cpSpace *space, void *data);
void postSolve(cpArbiter *arb, cpSpace *space, void *data);
void separate(cpArbiter *arb, cpSpace *space, void *data);

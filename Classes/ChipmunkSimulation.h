//
//  ChipmunkSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#pragma once
//#import "SoundManager.h"
#import "FSAAudioPlayer.h"
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
    vec2 last_vel;
    int note;
    
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
    
    CFMutableDictionaryRef creating;
    CFMutableDictionaryRef grabbing;
    
   // SoundManager* sound_manager;
    FSAAudioPlayer *audio_player;
    

    vec2 gravity;
    void next();
    
    cpShape* getShapeAt(const vec2& v);

public:
    ChipmunkSimulation(float aspect);
    ~ChipmunkSimulation();
    
    void addVelocityToBallsAt(const vec2& loc, const vec2& vel, float radius);
    void removeBallAt(const vec2& loc);
    void toggleStaticAt(const vec2& loc);
    void addStaticBallAt(const vec2& loc);
    void addBallAt(const vec2& loc);
    void addBallWithVelocity(const vec2& loc, const vec2& vel);
    bool isBallAt(const vec2& loc);
    bool anyBallsAt(const vec2& loc, float radius);
    void setGravity(const vec2& g);
    void addToVelocity(const vec2& v);
    void step(float t);
    
    bool isCreatingBall(void* uniqueId);
    void creatingBallAt(const vec2& loc, float radius, void* uniqueId);
    void createBall(void* uniqueId);
    void cancelBall(void* uniqueId);
    
    bool isGrabbingBall(void* uniqueId);
//    void grabbingBallAt(const vec2& loc, void* uniqueId);
    void grabbingBallAt(const vec2& loc, const vec2& vel, void* uniqueId);
    void releaseBall(const vec2& vel, void* uniqueId);

//    void releaseBall(void* uniqueId);
    
        
 //   SoundManager* getSoundManager();
    FSAAudioPlayer* getAudioPlayer();
    
    unsigned int numBalls();
    cpShape* const* shapesPointer();
    cpBody* const* bodiesPointer();
    
};

int collisionBegin(cpArbiter *arb, cpSpace *space, void *data);
int preSolve(cpArbiter *arb, cpSpace *space, void *data);
void postSolve(cpArbiter *arb, cpSpace *space, void *data);
void separate(cpArbiter *arb, cpSpace *space, void *data);

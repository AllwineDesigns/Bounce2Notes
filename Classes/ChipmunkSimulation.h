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
    BALL_TYPE,
    KILL_TOP_TYPE,
    KILL_BOTTOM_TYPE,
    KILL_LEFT_TYPE,
    KILL_RIGHT_TYPE
};

struct GestureData {
    cpShape* shape;
    vec2 offset;
    float ball_angle;
    float offset_angle;
    float offset_r;
    
    vec2 P1; // begin transforming point 1
    vec2 P2; // begin transforming point 2
    vec2 P1p;
    vec2 P2p;
    vec2 C;  
    float radius;
    float rotation;
    struct GestureData* gdata1;
    struct GestureData* gdata2;
    
    bool creating;
    bool grabbing;
    bool transforming;
};

struct BallData {
    vec4 color;
    float intensity;
    vec2 last_vel;
    int note;
    float age;
    
    bool stationary;
    
    vec2 tl;
    vec2 tr;
    vec2 bl;
    vec2 br;
    
    vec2 tlv;
    vec2 trv;
    vec2 blv;
    vec2 brv;
    
    BallData(vec4 c) : color(c), intensity(0.), age(0.), stationary(false) {}
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
    
    cpShape* killTopShape;
    cpShape* killBottomShape;
    cpShape* killLeftShape;
    cpShape* killRightShape;
    
    cpBody* killBody;
    
    bool killTop;
    bool killBottom;
    bool killLeft;
    bool killRight;
    
    float topY;
    float bottomY;
    float leftX;
    float rightX;
    
    float aspect;
    float inv_aspect;
    
    std::vector<cpShape*> shapes;
    std::vector<cpBody*> bodies;
    
    std::vector<cpShape*> removeShapesQueue;
    
    CFMutableDictionaryRef gestures;
    
   // SoundManager* sound_manager;
    FSAAudioPlayer *audio_player;

    vec2 gravity;
    
    void next();
    
    cpShape* getShapeAt(const vec2& v);
    GestureData* getGestureDataWithParticipatingShape(cpShape* shape);
    
    void makeStatic(cpShape* shape);
    void makeSimulated(cpShape* shape);
    void makeHeavyRogue(cpShape* shape);
    
    bool isShapeParticipatingInGesture(cpShape* shape);
    bool isShapeBeingCreatedOrGrabbed(cpShape* shape);
    bool isShapeBeingTransformed(cpShape* shape);
    
    void removeBall(cpShape *shape);
    void queueRemoveBall(cpShape *shape);
    
public:
    ChipmunkSimulation(float aspect);
    ~ChipmunkSimulation();
    
    void addVelocityToBallsAt(const vec2& loc, const vec2& vel, float radius);
    void addVelocityToBallAt(const vec2& loc, const vec2& vel);

    void removeBallAt(const vec2& loc);
    void addBallAt(const vec2& loc);
    void addBallWithVelocity(const vec2& loc, const vec2& vel);
    bool isBallAt(const vec2& loc);
    bool anyBallsAt(const vec2& loc, float radius);
    void setGravity(const vec2& g);
    void addToVelocity(const vec2& v);
    void step(float t);

    bool isBallParticipatingInGestureAt(const vec2& loc);
    bool isBallBeingCreatedOrGrabbedAt(const vec2& loc);
    bool isBallBeingTransformedAt(const vec2& loc);
    bool isStationaryBallAt(const vec2& loc);
    
    void makeStationary(const vec2& loc, void* uniqueId);
    
    bool isCreatingBall(void* uniqueId);
    void creatingBallAt(const vec2& loc, const vec2& loc2, void* uniqueId);
    void createBall(void* uniqueId);
    void cancelBall(void* uniqueId);
    
    void beginGrabbing(const vec2& loc, void* uniqueId);
    void createStationaryBallAt(const vec2& loc, void* uniqueId);
    
    bool isGrabbingBall(void* uniqueId);
    void beginGrabbingBallAt(const vec2& loc, void* uniqueId);
    void grabbingBallAt(const vec2& loc, const vec2& vel, void* uniqueId);
    void releaseBall(const vec2& vel, void* uniqueId);
    
    bool isTransformingBall(void* uniqueId);
    void beginTransformingBallAt(const vec2& loc, void* uniqueId);
    void transformBallAt(const vec2& loc, void* uniqueId);
    void makeTransformingBallStationary(const vec2& loc, void* uniqueId);
    void beginGrabbingTransformingBall(void* uniqueId);
    
    void beginRemovingBallsTop(float y);
    void updateRemovingBallsTop(float y);
    void endRemovingBallsTop();
    
    void beginRemovingBallsBottom(float y);
    void updateRemovingBallsBottom(float y);
    void endRemovingBallsBottom();
    
    void beginRemovingBallsLeft(float x);
    void updateRemovingBallsLeft(float x);
    void endRemovingBallsLeft();
    
    void beginRemovingBallsRight(float x);
    void updateRemovingBallsRight(float x);
    void endRemovingBallsRight();
    
    bool isRemovingBalls();
    bool isRemovingBallsTop();
    bool isRemovingBallsBottom();
    bool isRemovingBallsLeft();
    bool isRemovingBallsRight();
    
    float removingBallsTopY();
    float removingBallsBottomY();
    float removingBallsLeftX();
    float removingBallsRightX();
            
 //   SoundManager* getSoundManager();
    FSAAudioPlayer* getAudioPlayer();
    
    unsigned int numBalls();
    cpShape* const* shapesPointer();
    cpBody* const* bodiesPointer();
    
    friend int presolve_kill(cpArbiter *arb, cpSpace *space, void *data);
    
};

int collisionBegin(cpArbiter *arb, cpSpace *space, void *data);
int preSolve(cpArbiter *arb, cpSpace *space, void *data);
void postSolve(cpArbiter *arb, cpSpace *space, void *data);
void separate(cpArbiter *arb, cpSpace *space, void *data);

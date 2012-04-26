#pragma once

#include "ParticleSystem.h"
using namespace fsa;

class BasicParticle {
public:
    vec2 position;
    vec4 color;
    vec2 velocity;
    float size;
    float intensity;
};

class BasicParticleSystem : public ParticleSystem<BasicParticle> {
protected:
    virtual void next();
    vec2 acceleration;
    
public:
    BasicParticleSystem();
    ~BasicParticleSystem();  
    
    void setAcceleration(vec2 accel);
};
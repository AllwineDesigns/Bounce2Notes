#pragma once

#include <fsa/Vector.hpp>
#include <vector>

template <class T>
class ParticleSystem {
protected:
    std::vector<T> particles;
    float time_remainder;
    float dt;
    
    virtual void next() = 0; // steps the simulation by dt seconds

public:    
    ParticleSystem(float dt);
    ~ParticleSystem();
    
    unsigned int numParticles(); // returns the number of particles in the particle system
    const T* pointer(); // returns a pointer to the first particle
    void step(float t); // step the simulation t milliseconds forward,
                        // executing the necessary number of calls to next() and storing the
                        // remainder of time in time_remainder
};

template <class T>
ParticleSystem<T>::ParticleSystem(float dt) : dt(dt), time_remainder(0.f) {
}

template <class T>
unsigned int ParticleSystem<T>::numParticles() {
    return particles.size();
}

template <class T>
const T* ParticleSystem<T>::pointer() {
    return &particles[0];
}

template <class T>
void ParticleSystem<T>::step(float t) {
    t += time_remainder;
    
    while(t > dt) {
        next();
        t -= dt;
    }
    
    time_remainder = t;
}


template <class T>
ParticleSystem<T>::~ParticleSystem() {}



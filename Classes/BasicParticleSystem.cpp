#include "BasicParticleSystem.h"
#include "fsa/Noise.hpp"

BasicParticleSystem::BasicParticleSystem() : ParticleSystem<BasicParticle>(.03) {

    particles.reserve(1000);
    for(int i = 0; i < 30; i++) {
        BasicParticle p;
        p.position = vec2(random(i*1.923)-.5, random(i*4.545)-.5)*1.5;
        p.velocity = vec2(random(i*92.3)-.5, (random(i*82.323114)-.5)*.666667)*5;
        
        p.color = vec4(random(i*8.2939), random(i*2.2192), random(i*63.34), 1.);
        p.size = random(i*723.221)*.15+.1;
        
        particles.push_back(p);
    }
}

BasicParticleSystem::~BasicParticleSystem() {}   

void BasicParticleSystem::setAcceleration(vec2 accel) {
    acceleration = accel;
}
void BasicParticleSystem::next() {
    std::vector<BasicParticle>::iterator itr = particles.begin();
    while(itr != particles.end()) {
        itr->position += itr->velocity*dt;
        itr->velocity += acceleration*dt;
        itr->intensity *= .9;
        
        float mag = .15*sqrt(itr->velocity.dot(itr->velocity));
        
        if(itr->position.x+.5*itr->size > 1) {
            itr->velocity.x *= -.8;
            itr->intensity = mag;
            itr->position.x = 1-.5*itr->size;
        } else if(itr->position.x-.5*itr->size < -1) {
            itr->velocity.x *= -.8;
            itr->intensity = mag;
            itr->position.x = -1+.5*itr->size;
        }
        if(itr->position.y+.5*itr->size > 1.5) {
            itr->velocity.y *= -.8;
            itr->intensity = mag;
            itr->position.y = 1.5-.5*itr->size;
        } else if(itr->position.y-.5*itr->size < -1.5) {
            itr->velocity.y *= -.8;
            itr->intensity = mag;
            itr->position.y = -1.5+.5*itr->size;
        }

        ++itr;
    }
}    
 

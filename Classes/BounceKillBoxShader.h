//
//  BounceKillBoxShader.h
//  ParticleSystem
//
//  Created by John Allwine on 6/9/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "Shader.h"
#include <fsa/Vector.hpp>
#include "ChipmunkSimulation.h"

using namespace fsa;

@interface BounceKillBoxShader : Shader {
    vec2 vertices[5];
    ChipmunkSimulation *simulation;
    float aspect;
    GLint aspectLoc;

}
-(id)initWithChipmunkSimulation: (ChipmunkSimulation*)s aspect:(float)aspect;

@end

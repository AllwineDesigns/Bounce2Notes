//
//  FSAUtil.h
//  ParticleSystem
//
//  Created by John Allwine on 6/16/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#ifndef ParticleSystem_FSAUtil_h
#define ParticleSystem_FSAUtil_h

#ifdef __cplusplus
extern "C" {
#endif
    
#define RANDFLOAT ((float)arc4random()/4294967295)

//from bit twiddling hacks
inline uint32_t nextPowerOfTwo(uint32_t v)
{
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;
    return v;
}
    void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );
NSString* machineName();
natural_t getFreeMemory();
CGSize screenSize();
    
    
#ifdef __cplusplus
}
#endif

#endif

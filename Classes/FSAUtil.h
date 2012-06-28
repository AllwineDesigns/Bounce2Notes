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

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );
NSString* machineName();
natural_t getFreeMemory();
CGSize screenSize();
    
    
#ifdef __cplusplus
}
#endif

#endif

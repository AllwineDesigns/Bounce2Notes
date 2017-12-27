//
//  FSACurve.h
//  ParticleSystem
//
//  Created by John Allwine on 7/21/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fsa/Vector.hpp"

using namespace fsa;

inline fsaFloat tFromLength(fsaFloat length, fsaFloat *lengths, int numPoints) {
    if(numPoints < 2) {
        return 0;
    }
    int i = 0;
    while(i < numPoints && lengths[i] < length) {
        ++i;
    }
    
    if(i >= numPoints-1) {
        return 1;
    }
    
    fsaFloat length0 = lengths[i];
    fsaFloat length1 = lengths[i+1];
    
    fsaFloat t = ((fsaFloat)i+(length-length0)/(length1-length0))/(numPoints-1);
    return t;
}

inline vec2 pointAt(vec2 *points, unsigned int numPoints, float t) {
    if(t <= 0) {
        return points[0];
    }
    if(t >= 1) {
        return points[numPoints-1];
    }
    int i0 = (numPoints-1)*t;
    int i1 = i0+1;
    
    float t0 = (float)i0/(numPoints-1);
    float t1 = (float)i1/(numPoints-1);
    
    float tt = (t-t0)/(t1-t0);
    
    return points[i0]*(1-tt)+points[i1]*tt;
}

inline float valueAt(float *values, unsigned int numPoints, float t) {
    if(t <= 0) {
        return values[0];
    }
    if(t >= 1) {
        return values[numPoints-1];
    }
    int i0 = numPoints*t;
    int i1 = numPoints*t+1;
    
    float t0 = (float)i0/(numPoints-1);
    float t1 = (float)i1/(numPoints-1);
    
    float tt = (t-t0)/(t1-t0);
    
    return values[i0]*(1-tt)+values[i1]*tt;
}


@interface FSACurve : NSObject

-(void)addPoint: (vec2)pt;
-(unsigned int)numPoints;
-(vec2*)points;

@end

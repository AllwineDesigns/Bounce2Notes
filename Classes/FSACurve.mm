//
//  FSACurve.m
//  ParticleSystem
//
//  Created by John Allwine on 7/21/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSACurve.h"
#import "fsa/Vector.hpp"

#import <vector>

using namespace fsa;

@implementation FSACurve {
    std::vector<vec2> _points;
}

-(void)addPoint:(vec2)pt {
    _points.push_back(pt);
}

-(unsigned int)numPoints {
    return _points.size();
}

-(vec2*)points {
    return &_points[0];
}

@end

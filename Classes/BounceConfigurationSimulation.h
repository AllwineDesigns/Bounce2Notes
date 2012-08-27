//
//  BounceConfigurationSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "MainBounceSimulation.h"

@interface BounceConfigurationSimulation : BounceSimulation {
    MainBounceSimulation *_simulation;
}

-(id)initWithRect:(CGRect)rect bounceSimulation: (BounceSimulation*)sim;

-(BOOL)isObjectBeingPreviewed:(BounceObject*)obj;
-(BOOL)isAnyObjectBeingPreviewed;
-(BOOL)isAnyObjectInBounds;


@end

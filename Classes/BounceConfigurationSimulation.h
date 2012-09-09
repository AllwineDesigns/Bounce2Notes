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
    
    BouncePane *_pane;
}

@property (nonatomic, assign) BouncePane* pane;

-(id)initWithRect:(CGRect)rect bounceSimulation: (MainBounceSimulation*)sim;
-(void)setSimulation:(MainBounceSimulation*)sim;
-(BOOL)isObjectBeingPreviewed:(BounceObject*)obj;
-(BOOL)isAnyObjectBeingPreviewed;
-(BOOL)isAnyObjectInBounds;

-(void)updateSettings;
-(void)drawObjectsParticipatingInGestures;
-(void)prepare;


@end

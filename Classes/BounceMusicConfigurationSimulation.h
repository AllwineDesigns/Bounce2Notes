//
//  BounceMusicConfigurationSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 7/31/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationSimulation.h"
#import "BounceSimulation.h"
#import "BounceConfigurationSimulation.h"
#import "BounceSlider.h"
#import "BounceButton.h"
#import "BouncePages.h"
#import "BounceConfigurationObject.h"

@interface BounceMusicConfigurationSimulation : BounceConfigurationSimulation {
    BouncePages* _pages;
    NSArray *_chordConfigObjects;
    BounceChordConfigurationObject *_activeChord;
    NSMutableSet *_playGestures;
}

@property (nonatomic, assign) BounceChordConfigurationObject* activeChord;

-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation*)sim;
-(void)setActiveChord:(BounceChordConfigurationObject *)activeChord;
-(void)switchActiveChord;

@end
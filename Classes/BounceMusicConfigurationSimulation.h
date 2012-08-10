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

@interface BounceMusicConfigurationSimulation : BounceConfigurationSimulation <BounceSliderDelegate> {
    BounceSlider *_keySlider;
    BounceSlider *_octaveSlider;
    BounceSlider *_tonalitySlider;
}
-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation*)sim;
@end
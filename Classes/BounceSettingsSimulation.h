//
//  BounceSettingsSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 7/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSimulation.h"
#import "BounceConfigurationSimulation.h"
#import "BounceSlider.h"

@interface BounceSettingsSimulation : BounceConfigurationSimulation <BounceSliderDelegate> {
    BounceSlider *_bouncinessSlider;
    BounceSlider *_gravitySlider;
    
    BounceSlider *_pageSlider;
}
-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation*)sim;
@end

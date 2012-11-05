//
//  BounceHowToSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 10/24/12.
//
//

#import "BounceConfigurationSimulation.h"
#import "BounceButton.h"

@interface BounceHowToSimulation : BounceConfigurationSimulation <BounceButtonDelegate> {
    BounceButton *_instructions;
    BounceButton *_howto;
    BounceButton *_faq;
}

@end

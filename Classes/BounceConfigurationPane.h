//
//  BounceConfigurationPane.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BouncePane.h"

@interface BounceConfigurationPane : BouncePane {
    int _lastSwitch;
}

-(void)updateSavedSimulations;
-(void)issueContributorsRequest;

@end

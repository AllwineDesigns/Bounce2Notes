//
//  BounceConfigurationPane.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChipmunkObject.h"
#import "BounceSimulation.h"

@interface BounceConfigurationPane : NSObject {
    ChipmunkObject *_object;
    NSArray *_simulations;
}

-(BOOL)isActive;
-(void)activate;
-(void)deactivate;

@end

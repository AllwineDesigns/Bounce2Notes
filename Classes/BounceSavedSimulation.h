//
//  BounceSavedSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 9/2/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainBounceSimulation.h"
#import "BounceSettings.h"

#define BOUNCE_SAVED_MAJOR_VERSION 1
#define BOUNCE_SAVED_MINOR_VERSION 0

@interface BounceSavedSimulation : NSObject <NSCoding> {
    MainBounceSimulation *_simulation;
    BounceSettings *_settings;
    unsigned int _majorVersion;
    unsigned int _minorVersion;
}

@property (nonatomic, retain) MainBounceSimulation* simulation;
@property (nonatomic, retain) BounceSettings* settings;
@property (nonatomic, readonly) unsigned int majorVersion;
@property (nonatomic, readonly) unsigned int minorVersion;

-(id)initWithBounceSimulation:(MainBounceSimulation*)sim withSettings:(BounceSettings*)settings;

@end

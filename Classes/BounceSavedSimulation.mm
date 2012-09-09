//
//  BounceSavedSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 9/2/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSavedSimulation.h"

@implementation BounceSavedSimulation

@synthesize simulation = _simulation;
@synthesize settings = _settings;
@synthesize majorVersion = _majorVersion;
@synthesize minorVersion = _minorVersion;

-(id)initWithBounceSimulation:(MainBounceSimulation*)sim withSettings:(BounceSettings *)settings {
    self = [super init];
    if(self) {
        _majorVersion = BOUNCE_SAVED_MAJOR_VERSION;
        _minorVersion = BOUNCE_SAVED_MINOR_VERSION;
        _simulation = [sim retain];
        _settings = [settings copy];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    _majorVersion = [aDecoder decodeInt32ForKey:@"BounceSavedSimulationMajorVersion"];
    _minorVersion = [aDecoder decodeInt32ForKey:@"BounceSavedSimulationMinorVersion"];
    _simulation = [[aDecoder decodeObjectForKey:@"BounceSavedSimulationSimulation"] retain];
    _settings = [[aDecoder decodeObjectForKey:@"BounceSavedSimulationSettings"] retain];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:_majorVersion forKey:@"BounceSavedSimulationMajorVersion"];
    [aCoder encodeInt32:_minorVersion forKey:@"BounceSavedSimulationMinorVersion"];
    [aCoder encodeObject:_simulation forKey:@"BounceSavedSimulationSimulation"];
    [aCoder encodeObject:_settings forKey:@"BounceSavedSimulationSettings"];
}

-(void)dealloc {
    [_simulation release];
    [_settings release];
    [super dealloc];
}

@end

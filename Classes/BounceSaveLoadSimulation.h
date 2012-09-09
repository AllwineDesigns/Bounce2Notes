//
//  BounceSaveLoadSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 9/2/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationSimulation.h"
#import "BounceButton.h"

@interface BounceLoadObject : BounceObject {
    NSString *_file;
}

@property (nonatomic, readonly) NSString *file;

-(id)initWithFile:(NSString*)file;
@end

@interface BounceSaveLoadSimulation : BounceConfigurationSimulation <BounceButtonDelegate> {
    BounceButton *_save;
}

-(void)updateSavedSimulations;

@end

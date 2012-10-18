//
//  BounceSaveLoadPane.m
//  ParticleSystem
//
//  Created by John Allwine on 9/14/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSaveLoadPane.h"
#import "BounceSaveLoadSimulation.h"
#import "FSATextureManager.h"
#import "BounceConfigurationTab.h"

@implementation BounceSaveLoadPane

-(void)addSaveLoadSimulation {
    FSATextureManager *texManager = [FSATextureManager instance];
    
    BounceConfigurationSimulation *sim = [[BounceSaveLoadSimulation alloc] initWithRect:_rect bounceSimulation:_simulation];
    
    [self addSimulation:sim];
    [sim setPosition:self.object.position];
    
    CGSize paneSize = [_object paneSize];
    CGSize tabSize = CGSizeMake(paneSize.width/7, paneSize.width/7*GOLDEN_RATIO);
    
    vec2 offset(0, -paneSize.height*.5-.5*tabSize.height);
    
    BounceConfigurationTab *tab = [[BounceConfigurationTab alloc] initWithPane:self index:[_simulations count]-1 offset:offset];
    
    tab.size = tabSize.width*.5;
    tab.secondarySize = tabSize.height*.5;
    
    tab.patternTexture = [texManager getTexture:@"Save/Load"];
    [tab addToSimulation:_simulation];
    
    [_simulationTabs addObject:tab];
}

-(void)updateSavedSimulations {
    [[_simulations objectAtIndex:0] updateSavedSimulations];
}


-(id)initWithBounceSimulation:(MainBounceSimulation *)simulation {
    self = [super initWithBounceSimulation:simulation];
    
    if(self) {
        self.side = BOUNCE_PANE_TOP;
        self.object.position = self.object.inactiveSpringLoc;

        [self addSaveLoadSimulation];
        
    }
    
    return self;
}

@end

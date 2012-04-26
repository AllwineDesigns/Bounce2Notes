//
//  ParticleSystemAppDelegate.h
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ParticleSystemViewController;

@interface ParticleSystemAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ParticleSystemViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ParticleSystemViewController *viewController;

@end


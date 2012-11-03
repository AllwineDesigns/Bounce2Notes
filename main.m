//
//  main.m
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticleSystemAppDelegate.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
   // int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([ParticleSystemAppDelegate class]));
    int retVal = UIApplicationMain(argc, argv, nil, nil);

    [pool release];
    return retVal;
}

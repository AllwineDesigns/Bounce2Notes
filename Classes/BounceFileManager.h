//
//  BounceFileManager.h
//  ParticleSystem
//
//  Created by John Allwine on 9/4/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BounceSavedSimulation.h"

@interface BounceFileManager : NSObject {
}

-(NSString*)pathToFile:(NSString*)file;
-(NSArray*)allFiles;
-(void)deleteFile:(NSString*)file;
-(BOOL)fileExists:(NSString*)file;
-(BounceSavedSimulation*)loadFile:(NSString*)file;
-(void)save:(MainBounceSimulation*)saved withSettings:(BounceSettings*)settings toFile:(NSString*)file;

+(BounceFileManager*)instance;

@end
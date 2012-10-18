//
//  BounceFileManager.m
//  ParticleSystem
//
//  Created by John Allwine on 9/4/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceFileManager.h"

static BounceFileManager* bounceFileManager;

@implementation BounceFileManager

-(NSString*)pathToFile:(NSString*)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bounce", file]];
    
    return filePath;
}

-(NSArray*)allFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *longfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:[paths count]];
    for(NSString* longfile in longfiles) {
        [files addObject:[longfile stringByReplacingOccurrencesOfString:@".bounce" withString:@""]];
    }
        
    return files;
    
}
-(void)deleteFile:(NSString*)file {
    [[NSFileManager defaultManager] removeItemAtPath:[self pathToFile:file] error:nil];
    
}
-(BOOL)fileExists:(NSString*)file {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self pathToFile:file]];
    
}
-(BounceSavedSimulation*)loadBuiltInFile:(NSString*)file {
}
-(BounceSavedSimulation*)loadFile:(NSString*)file {
    if(![self fileExists:file]) {
        return nil;
    }
    
    @try {
        BounceSavedSimulation *load = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathToFile:file]];
        
        if(load.simulation && load.settings && load.majorVersion == BOUNCE_SAVED_MAJOR_VERSION &&
           load.minorVersion == BOUNCE_SAVED_MINOR_VERSION) {
            return load;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception happened during load: %@\n", exception);
    }

    return nil;
}
-(void)save:(MainBounceSimulation*)sim withSettings:(BounceSettings *)settings toFile:(NSString *)file {
    BounceSavedSimulation *saved = [[BounceSavedSimulation alloc] initWithBounceSimulation:sim withSettings:settings];
    
    [NSKeyedArchiver archiveRootObject:saved toFile:[self pathToFile:file]];
}

+(BounceFileManager*)instance {
    return bounceFileManager;
}

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        bounceFileManager = [[BounceFileManager alloc] init];
    }
}
@end

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

-(NSString*)pathToBuiltInFile:(NSString*)file {
    NSString *dir = [[NSBundle mainBundle] resourcePath];
    dir = [dir stringByAppendingPathComponent:@"Saves"];
    NSString *filePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bounce", file]];
    
    return filePath;
}

-(NSString*)pathToFile:(NSString*)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bounce", file]];
    
    return filePath;
}

-(NSArray*)allBuiltInFiles {
    NSString *dir = [[NSBundle mainBundle] resourcePath];
    dir = [dir stringByAppendingPathComponent:@"Saves"];
    
    NSArray *longfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil];
    
    NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:[longfiles count]];
    for(NSString* longfile in longfiles) {
        [files addObject:[longfile stringByReplacingOccurrencesOfString:@".bounce" withString:@""]];
    }
    
    return [files autorelease];
    
}

-(NSArray*)allFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *longfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    NSMutableArray *files = [[NSMutableArray alloc] initWithCapacity:[longfiles count]];
    for(NSString* longfile in longfiles) {
        [files addObject:[longfile stringByReplacingOccurrencesOfString:@".bounce" withString:@""]];
    }
        
    return [files autorelease];
    
}
-(void)deleteFile:(NSString*)file {
    [[NSFileManager defaultManager] removeItemAtPath:[self pathToFile:file] error:nil];
    
}
-(BOOL)builtInFileExists:(NSString*)file {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self pathToBuiltInFile:file]];

}
-(BOOL)fileExists:(NSString*)file {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self pathToFile:file]];
    
}
-(BounceSavedSimulation*)loadSimulationWithPath:(NSString*)path {
    @try {
        BounceSavedSimulation *load = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
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
-(BounceSavedSimulation*)loadBuiltInFile:(NSString*)file {
    if(![self builtInFileExists:file]) {
        return nil;
    }
    
    return [self loadSimulationWithPath:[self pathToBuiltInFile:file]];
}
-(BounceSavedSimulation*)loadFile:(NSString*)file {
    if(![self fileExists:file]) {
        return nil;
    }
    
    return [self loadSimulationWithPath:[self pathToFile:file]];
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

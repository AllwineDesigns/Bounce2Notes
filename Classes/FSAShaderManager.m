//
//  FSAShaderManager.m
//  ParticleSystem
//
//  Created by John Allwine on 6/16/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSAShaderManager.h"

static FSAShaderManager* fsaShaderManager;

@implementation FSAShaderManager

-(id)init {
    self = [super init];
    
    if(self) {
        shaders = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    
    return self;
}

-(FSAShader*)getShader:(NSString *)name {
    FSAShader *shader = [shaders objectForKey:name];
    if(shader == nil) {
        shader = [[FSAShader alloc] initWithShaderPaths:name fragShader:name];
        [shaders setObject:shader forKey:name];
        [shader release];
    }
    
    return shader;
}

-(void)dealloc {
    [shaders release]; shaders = nil;
    [super dealloc];
}

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        fsaShaderManager = [[FSAShaderManager alloc] init];
    }
}

+(FSAShaderManager*)instance {
    return fsaShaderManager;
}



@end

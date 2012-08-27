//
//  FSABufferManager.m
//  ParticleSystem
//
//  Created by John Allwine on 8/12/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSABufferManager.h"

static FSABufferManager* fsaBufferManager;

@implementation FSABufferManager

-(id)init {
    self = [super init];
    
    if(self) {
        _buffers = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    
    return self;
}

-(FSABuffer*)getBuffer:(NSString *)name {
    FSABuffer *buffer = [_buffers objectForKey:name];
    
    return buffer;
}

-(void)addBuffer:(FSABuffer *)buffer name:(NSString *)name {
    [_buffers setObject:buffer forKey:name];
}

-(void)dealloc {
    [_buffers release]; _buffers = nil;
    [super dealloc];
}

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        fsaBufferManager = [[FSABufferManager alloc] init];
    }
}

+(FSABufferManager*)instance {
    return fsaBufferManager;
}



@end

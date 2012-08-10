//
//  BounceBackgroundQueue.m
//  ParticleSystem
//
//  Created by John Allwine on 8/7/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSABackgroundQueue.h"

static FSABackgroundQueue* fsaBackgroundQueue;

@implementation FSABackgroundQueue

@synthesize sharegroup = _sharegroup;

-(id)init {
    self = [super init];
    if(self) {
        [self setMaxConcurrentOperationCount:1];
    }
    return self;
}

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        fsaBackgroundQueue = [[FSABackgroundQueue alloc] init];
        
    }
}

+(FSABackgroundQueue*)instance {
    return fsaBackgroundQueue;
}
@end


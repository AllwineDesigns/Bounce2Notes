//
//  BounceConstants.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConstants.h"
#import "FSAUtil.h"

static BounceConstants *bounceConstants;

@implementation BounceConstants

@synthesize unitsPerInch = _unitsPerInch;

-(id)init {
    self = [super init];
    if(self) {
        NSString *device = machineName();
        
        if([device hasPrefix:@"iPad"]) {
            _unitsPerInch = .34375;
        } else {
            _unitsPerInch = 1.01875;
        }
    }
    
    return self;
}
+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        bounceConstants = [[BounceConstants alloc] init];
    }
}

+(BounceConstants*)instance {
    return bounceConstants;
}
@end

//
//  FSABufferManager.h
//  ParticleSystem
//
//  Created by John Allwine on 8/12/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSABuffer.h"

@interface FSABufferManager : NSObject {
    NSMutableDictionary *_buffers;
}

-(id)init;
-(FSABuffer*)getBuffer: (NSString*)name;
-(void)addBuffer: (FSABuffer*)buffer name:(NSString*)name;
+(FSABufferManager*)instance;


@end

//
//  BounceBackgroundQueue.h
//  ParticleSystem
//
//  Created by John Allwine on 8/7/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSABackgroundQueue : NSOperationQueue {
    EAGLSharegroup *_sharegroup;
}

@property (nonatomic, retain) EAGLSharegroup* sharegroup;

-(void)resume;
-(void)suspendFor:(NSTimeInterval)seconds;
+(FSABackgroundQueue*)instance;

@end


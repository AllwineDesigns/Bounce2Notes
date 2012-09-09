//
//  BounceSizeGenerator.h
//  ParticleSystem
//
//  Created by John Allwine on 9/8/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BounceSizeGenerator : NSObject <NSCoding>

@property (nonatomic, readonly) CGSize size;

-(id)initWithSize: (float)size;

-(float)interp:(id)b x:(id)x; // returns t such that [a lerp:b param:t] returns x
-(id)lerp:(id)n param:(float)t;

@end

@interface BounceRandomSizeGenerator : BounceSizeGenerator
@end

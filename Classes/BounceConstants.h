//
//  BounceConstants.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BounceConstants : NSObject {
    float _unitsPerInch;
    float _aspect;
}
@property (nonatomic, readonly) float unitsPerInch;
@property (nonatomic, readonly) float aspect;

-(id)init;
+(BounceConstants*)instance;

@end

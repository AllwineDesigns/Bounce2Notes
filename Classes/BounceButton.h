//
//  BounceButton.h
//  ParticleSystem
//
//  Created by John Allwine on 8/19/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BounceObject.h"
#import "BouncePages.h"

@class BounceButton;

@protocol BounceButtonDelegate <NSObject>

-(void)pressed: (BounceButton*)button;

@end

@interface BounceButton : BounceObject <BounceWidget> {
    id<BounceButtonDelegate> _delegate;
}

@property (nonatomic, retain) id<BounceButtonDelegate> delegate;

@end

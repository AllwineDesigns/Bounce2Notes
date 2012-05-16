//
//  BounceSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 5/13/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <chipmunk/chipmunk.h>

@interface BounceObject : NSObject {
    BOOL isStatic;
    cpBody *body;
    cpShape **shapes;
}

@end

@interface Ball : BounceObject {
    
}

@end

@interface BounceSimulation : NSObject

@end

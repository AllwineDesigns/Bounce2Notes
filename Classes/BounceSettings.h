//
//  BounceSettings.h
//  ParticleSystem
//
//  Created by John Allwine on 8/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BounceObject.h"
#import "BounceColorGenerator.h"
#import "BounceShapeGenerator.h"
#import "BouncePatternGenerator.h"

@interface BounceSettings : NSObject {
    BounceShapeGenerator *_bounceShapeGenerator; 
    BouncePatternGenerator *_patternTextureGenerator;
    BounceColorGenerator *_colorGenerator;
    
}
@property (nonatomic, retain) BounceShapeGenerator* bounceShapeGenerator;
@property (nonatomic, retain) BouncePatternGenerator* patternTextureGenerator;
@property (nonatomic, retain) BounceColorGenerator* colorGenerator;


-(id)init;
+(BounceSettings*)instance;

@end

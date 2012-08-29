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

@interface BounceSettings : NSObject <NSCoding> {
    BounceShapeGenerator *_bounceShapeGenerator; 
    BouncePatternGenerator *_patternTextureGenerator;
    BounceColorGenerator *_colorGenerator;
    float _minSize;
    float _maxSize;
    float _bounciness;
    float _friction;
    float _velLimit;
    float _damping;
    float _gravityScale;
    
    BOOL _paintMode;
    BOOL _grabRotates;
    BOOL _paneUnlocked;
    
}
@property (nonatomic, retain) BounceShapeGenerator* bounceShapeGenerator;
@property (nonatomic, retain) BouncePatternGenerator* patternTextureGenerator;
@property (nonatomic, retain) BounceColorGenerator* colorGenerator;
@property (nonatomic) float minSize;
@property (nonatomic) float maxSize;
@property (nonatomic) float bounciness;
@property (nonatomic) float friction;
@property (nonatomic) float velocityLimit;
@property (nonatomic) float damping;
@property (nonatomic) float gravityScale;
@property (nonatomic) BOOL grabRotates;
@property (nonatomic) BOOL paintMode;
@property (nonatomic) BOOL paneUnlocked;


-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(id)init;
+(BounceSettings*)instance;

@end

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
#import "BounceSizeGenerator.h"

@interface BounceSettings : NSObject <NSCoding, NSCopying> {
    BounceShapeGenerator *_bounceShapeGenerator; 
    BouncePatternGenerator *_patternTextureGenerator;
    BounceColorGenerator *_colorGenerator;
    BounceSizeGenerator *_sizeGenerator;
    id<BounceSound> _sound;
    
    BOOL _bounceLocked;
    
    float _bounciness;
    float _friction;
    float _velLimit;
    float _damping;
    float _gravityScale;
    
    BOOL _affectAllObjects;
    
    BOOL _paintMode;
    BOOL _grabRotates;
    BOOL _paneUnlocked;
    
    BOOL _playMode;
    
}
@property (nonatomic, retain) BounceShapeGenerator* bounceShapeGenerator;
@property (nonatomic, retain) BouncePatternGenerator* patternTextureGenerator;
@property (nonatomic, retain) BounceColorGenerator* colorGenerator;
@property (nonatomic, retain) BounceSizeGenerator* sizeGenerator;
@property (nonatomic, retain) id<BounceSound> sound;

@property (nonatomic) BOOL bounceLocked;

@property (nonatomic) float bounciness;
@property (nonatomic) float friction;
@property (nonatomic) float velocityLimit;
@property (nonatomic) float damping;
@property (nonatomic) float gravityScale;

@property (nonatomic) BOOL affectAllObjects;

@property (nonatomic) BOOL grabRotates;
@property (nonatomic) BOOL paintMode;
@property (nonatomic) BOOL paneUnlocked;
@property (nonatomic) BOOL playMode;

-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(id)init;
-(void)updateSettings:(BounceSettings*)settings;
+(BounceSettings*)instance;

@end

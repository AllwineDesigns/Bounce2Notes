//
//  BounceSettings.m
//  ParticleSystem
//
//  Created by John Allwine on 8/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSettings.h"
#import "FSATextureManager.h"

static BounceSettings *bounceSettings;

@implementation BounceSettings

@synthesize bounceShapeGenerator = _bounceShapeGenerator;
@synthesize patternTextureGenerator = _patternTextureGenerator;
@synthesize colorGenerator = _colorGenerator;
@synthesize minSize = _minSize;
@synthesize maxSize = _maxSize;
@synthesize friction = _friction;
@synthesize velocityLimit = _velLimit;
@synthesize damping = _damping;
@synthesize gravityScale = _gravityScale;
@synthesize bounciness = _bounciness;
@synthesize paintMode = _paintMode;
@synthesize grabRotates = _grabRotates;
@synthesize paneUnlocked = _paneUnlocked;

-(id)initWithCoder:(NSCoder *)aDecoder {
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    
}

-(id)init {
    self = [super init];
    if(self) {
        _bounceShapeGenerator = [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_BALL];
        _patternTextureGenerator = [[BouncePatternGenerator alloc] initWithPatternTexture:[[FSATextureManager instance] getTexture:@"spiral.jpg"]];
        _colorGenerator = [[BouncePastelColorGenerator alloc] init];
        _minSize = .05;
        _maxSize = .25;
        _friction = .5;
        _damping = 1;
        _gravityScale = 9.789;
        _bounciness = .9;
        _velLimit = 10;
        _paintMode = YES;
        _grabRotates = YES;
    }
    
    return self;
}
-(void)dealloc {
    [_bounceShapeGenerator release];
    [_patternTextureGenerator release];
    [_colorGenerator release];
    [super dealloc];
}
+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        bounceSettings = [[BounceSettings alloc] init];
    }
}

+(BounceSettings*)instance {
    return bounceSettings;
}
@end

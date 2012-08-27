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

-(id)init {
    self = [super init];
    if(self) {
        _bounceShapeGenerator = [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_BALL];
        _patternTextureGenerator = [[BouncePatternGenerator alloc] initWithPatternTexture:[[FSATextureManager instance] getTexture:@"spiral.jpg"]];
        _colorGenerator = [[BouncePastelColorGenerator alloc] init];
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

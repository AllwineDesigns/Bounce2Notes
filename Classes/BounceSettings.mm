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
@synthesize sizeGenerator = _sizeGenerator;

@synthesize friction = _friction;  
@synthesize velocityLimit = _velLimit;
@synthesize damping = _damping;
@synthesize gravityScale = _gravityScale;
@synthesize bounciness = _bounciness;

@synthesize affectAllObjects = _affectAllObjects;

@synthesize paintMode = _paintMode;
@synthesize grabRotates = _grabRotates;
@synthesize paneUnlocked = _paneUnlocked;
@synthesize playMode = _playMode;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self.bounceShapeGenerator = [aDecoder decodeObjectForKey:@"BounceSettingsShapeGenerator"];
    self.patternTextureGenerator = [aDecoder decodeObjectForKey:@"BounceSettingsPatternTextureGenerator"];
    self.colorGenerator = [aDecoder decodeObjectForKey:@"BounceSettingsColorGenerator"];
    self.sizeGenerator = [aDecoder decodeObjectForKey:@"BounceSettingsSizeGenerator"];
    
    self.friction = [aDecoder decodeFloatForKey:@"BounceSettingsFriction"];
    self.damping = [aDecoder decodeFloatForKey:@"BounceSettingsDamping"];
    self.gravityScale = [aDecoder decodeFloatForKey:@"BounceSettingsGravityScale"];
    self.bounciness = [aDecoder decodeFloatForKey:@"BounceSettingsBounciness"];
    self.velocityLimit = [aDecoder decodeFloatForKey:@"BounceSettingsVelocityLimit"];
    
    self.affectAllObjects = [aDecoder decodeBoolForKey:@"BounceSettingsAffectAllObjects"];
    
    self.paintMode = [aDecoder decodeBoolForKey:@"BounceSettingsPaintMode"];
    self.grabRotates = [aDecoder decodeBoolForKey:@"BounceSettingsGrabRotates"];
    self.paneUnlocked = [aDecoder decodeBoolForKey:@"BounceSettingsPaneUnlocked"];
    self.playMode = [aDecoder decodeBoolForKey:@"BounceSettingsPlayMode"];
        
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_bounceShapeGenerator forKey:@"BounceSettingsShapeGenerator"];
    [aCoder encodeObject:_patternTextureGenerator forKey:@"BounceSettingsPatternTextureGenerator"];
    [aCoder encodeObject:_colorGenerator forKey:@"BounceSettingsColorGenerator"];
    [aCoder encodeObject:_sizeGenerator forKey:@"BounceSettingsSizeGenerator"];
    
    [aCoder encodeFloat:_friction forKey:@"BounceSettingsFriction"];
    [aCoder encodeFloat:_damping forKey:@"BounceSettingsDamping"];
    [aCoder encodeFloat:_gravityScale forKey:@"BounceSettingsGravityScale"];
    [aCoder encodeFloat:_bounciness forKey:@"BounceSettingsBounciness"];
    [aCoder encodeFloat:_velLimit forKey:@"BounceSettingsVelocityLimit"];
    [aCoder encodeBool:_paintMode forKey:@"BounceSettingsPaintMode"];
    [aCoder encodeBool:_grabRotates forKey:@"BounceSettingsGrabRotates"];
    [aCoder encodeBool:_paneUnlocked forKey:@"BounceSettingsPaneUnlocked"];
    [aCoder encodeBool:_playMode forKey:@"BounceSettingsPlayMode"];
    
    [aCoder encodeBool:_affectAllObjects forKey:@"BounceSettingsAffectAllObjects"];
}

-(id)copyWithZone:(NSZone *)zone {
    BounceSettings *settings = [[BounceSettings allocWithZone:zone] init];
    settings.bounceShapeGenerator = self.bounceShapeGenerator;
    settings.patternTextureGenerator = self.patternTextureGenerator;
    settings.colorGenerator = self.colorGenerator;
    settings.sizeGenerator = self.sizeGenerator;
    settings.friction = self.friction;
    settings.damping = self.damping;
    settings.gravityScale = self.gravityScale;
    settings.bounciness = self.bounciness;
    settings.velocityLimit = self.velocityLimit;
    settings.paintMode = self.paintMode;
    
    settings.affectAllObjects = self.affectAllObjects;
    
    settings.grabRotates = self.grabRotates;
    settings.paneUnlocked = self.paneUnlocked;
    settings.playMode = self.playMode;
    
    return settings;
}

-(id)init {
    self = [super init];
    if(self) {
        _bounceShapeGenerator = [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_BALL];
        _patternTextureGenerator = [[BouncePatternGenerator alloc] initWithPatternTexture:[[FSATextureManager instance] getTexture:@"spiral.jpg"]];
        _colorGenerator = [[BouncePastelColorGenerator alloc] init];
        _sizeGenerator = [[BounceRandomSizeGenerator alloc] init];
        _friction = .5;
        _damping = 1;
        _gravityScale = 9.789;
        _bounciness = .9;
        _velLimit = 10;
        _paintMode = YES;
        _grabRotates = YES;
        _paneUnlocked = NO;
        _playMode = NO;
        
        _affectAllObjects = YES;
    }
    
    return self;
}
-(void)updateSettings:(BounceSettings *)settings {
    self.bounceShapeGenerator = settings.bounceShapeGenerator;
    self.patternTextureGenerator = settings.patternTextureGenerator;
    self.colorGenerator = settings.colorGenerator;
    self.sizeGenerator = settings.sizeGenerator;
    self.friction = settings.friction;
    self.damping = settings.damping;
    self.gravityScale = settings.gravityScale;
    self.bounciness = settings.bounciness;
    self.velocityLimit = settings.velocityLimit;
    
    self.affectAllObjects = settings.affectAllObjects;
    
    self.paintMode = settings.paintMode;
    self.grabRotates = settings.grabRotates;
    self.paneUnlocked = settings.paneUnlocked;
    self.playMode = settings.playMode;
}
-(void)dealloc {
    [_bounceShapeGenerator release];
    [_patternTextureGenerator release];
    [_colorGenerator release];
    [_sizeGenerator release];
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

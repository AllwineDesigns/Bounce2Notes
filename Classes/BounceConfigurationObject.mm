//
//  BounceConfigurationObject.m
//  ParticleSystem
//
//  Created by John Allwine on 6/30/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationObject.h"
#import "FSASoundManager.h"
#import "BounceNoteManager.h"
#import "fsa/Noise.hpp"
#import "FSAUtil.h"
#import "BounceSettings.h"

@implementation BounceConfigurationObject

@synthesize painting = _painting;
@synthesize timeSinceLastCreate = _timeSinceLastCreate;

-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle  {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    
    if(self) {
        [_sound release];
        _sound = [[[BounceNoteManager instance] getRest] retain];
        
        _previewObjects = [[NSMutableSet alloc] initWithCapacity:10];
        _originals = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    return self;
}

-(void)randomizeColor {
    vec2 loc = self.position;
    float t = [[NSProcessInfo processInfo] systemUptime]*loc.x*loc.y;
    _color = [[[BounceSettings instance] colorGenerator] randomColorFromTime:t];
}

-(void)step:(float)dt {
    [super step:dt];
    
    _timeSinceLastCreate += dt;
}

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    NSAssert(NO, @"setConfigurationValueForObject: must be implemented by subclass\n");
}
-(id)originalValueForObject:(BounceObject *)objj {
    NSAssert(NO, @"originalValueForObject: must be implemented by subclass\n");
    return nil;
}
-(void)setValue:(id)val forObject:(BounceObject *)obj {
    NSAssert(NO, @"setValue:forObject: must be implemented by subclass\n");
}

-(void)cancelChanges {
    for(BounceObject *obj in _previewObjects) {
        NSValue *val = [NSValue valueWithNonretainedObject:obj];
        [self setValue:[_originals objectForKey:val] forObject:obj];
    }
    [_originals removeAllObjects];
    [_previewObjects removeAllObjects];
}

-(void)finalizeChanges {
    [_originals removeAllObjects];
    [_previewObjects removeAllObjects];
}

-(void)setPreviewObject:(BounceObject*)obj {
    if(obj == nil) {
        [self setPreviewObjects:[NSSet set]];
    } else {
        [self setPreviewObjects:[NSSet setWithObject:obj]];
    }
}

-(void)setPreviewObjects:(NSSet *)objects {
    NSMutableSet *newPreviewObjects = [NSMutableSet setWithSet:objects];
    [newPreviewObjects minusSet:_previewObjects];
    for(BounceObject *obj in newPreviewObjects) {
        NSValue *val = [NSValue valueWithNonretainedObject:obj];
        [_originals setObject:[self originalValueForObject:obj] forKey:val];
        
        [self setConfigurationValueForObject:obj];
    }

    [_previewObjects minusSet:objects];
    
    for(BounceObject *obj in _previewObjects) {
        NSValue *val = [NSValue valueWithNonretainedObject:obj];
        if(0) { // if(!paint_mode) TODO
            [self setValue:[_originals objectForKey:val] forObject:obj];
        }
        [_originals removeObjectForKey:val];
    }
    
    [_previewObjects setSet:objects];
}

-(NSSet*)previewObjects {
    return _previewObjects;
}

-(void)singleTapAt:(const vec2 &)loc {
    _intensity = 2.2;
    [_renderable burst:5];
}

-(void)draw {
    for(BounceObject *obj in _previewObjects) {
        [obj drawSelected];
    }
    [super draw];
}

-(void)dealloc {
    [_originals release]; _originals = nil;
    [_previewObjects release]; _previewObjects = nil;
    [super dealloc];
}

@end


@implementation BounceShapeConfigurationObject

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    obj.bounceShape = _bounceShape;
}

-(id)originalValueForObject:(BounceObject *)obj {
    NSValue *val = [NSNumber numberWithUnsignedInt:obj.bounceShape];
    return val;
}

-(void)setValue: (id)val forObject:(BounceObject *)obj {
    obj.bounceShape = BounceShape([val unsignedIntValue]);
}

@end

@implementation BouncePatternConfigurationObject

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    obj.patternTexture = _patternTexture;
}

-(id)originalValueForObject:(BounceObject *)obj {
    return obj.patternTexture;
}

-(void)setValue:(id)val forObject:(BounceObject *)obj {
    obj.patternTexture = val;
}

@end

@implementation BounceSizeOriginal

@synthesize size = _size;
@synthesize secondarySize = _size2;

+(BounceSizeOriginal*)sizeWithSize:(float)size secondarySize:(float)size2 {
    BounceSizeOriginal *s = [[[BounceSizeOriginal alloc] init] autorelease];
    s.size = size;
    s.secondarySize = size2;
    
    return s;
}

@end

@implementation BounceSizeConfigurationObject

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    [obj setSize:_size secondarySize:_size*GOLDEN_RATIO];
}

-(id)originalValueForObject:(BounceObject *)obj {
    return [BounceSizeOriginal sizeWithSize: obj.size secondarySize: obj.secondarySize];
}

-(void)setValue:(id)val forObject:(BounceObject *)obj {
    BounceSizeOriginal *s = (BounceSizeOriginal*)val;
    [obj setSize:s.size secondarySize:s.secondarySize];
}

@end

@implementation BounceColorOriginal

@synthesize color = _color;

+(BounceColorOriginal*)colorWithColor:(const vec4 &)col {
    BounceColorOriginal *orig = [[[BounceColorOriginal alloc] init] autorelease];
    
    orig.color = col;
    
    return orig;
}

@end

@implementation BounceColorConfigurationObject


-(void)setColor:(const vec4 &)color {
}

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    vec2 loc = self.position;
    obj.color = [_colorGenerator randomColorFromLocation:loc];
}

-(id)originalValueForObject:(BounceObject *)obj {
    return [BounceColorOriginal colorWithColor:obj.color];
}

-(void)setValue:(id)val forObject:(BounceObject *)obj {
    BounceColorOriginal *orig = (BounceColorOriginal*)val;
    obj.color = orig.color;
}

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
    
    _color = [_colorGenerator perlinColorFromLocation:pos time:time];
}

-(void)dealloc {
    [_colorGenerator release];
    [super dealloc];
}

@end

@implementation BouncePastelColorConfigurationObject
-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    if(self) {
        _colorGenerator = [[BouncePastelColorGenerator alloc] init];
        _color = [_colorGenerator randomColorFromLocation:loc];
    }
    return self;
}

@end

@implementation BounceRedColorConfigurationObject

-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    if(self) {
        _colorGenerator = [[BounceRedColorGenerator alloc] init];
        _color = [_colorGenerator randomColorFromLocation:loc];
    }
    return self;
}

@end

@implementation BounceOrangeColorConfigurationObject

-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    if(self) {
        _colorGenerator = [[BounceOrangeColorGenerator alloc] init];
        _color = [_colorGenerator randomColorFromLocation:loc];
    }
    return self;
}

@end

@implementation BounceYellowColorConfigurationObject


-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    if(self) {
        _colorGenerator = [[BounceYellowColorGenerator alloc] init];
        _color = [_colorGenerator randomColorFromLocation:loc];
    }
    return self;
}

@end

@implementation BounceGreenColorConfigurationObject


-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    if(self) {
        _colorGenerator = [[BounceGreenColorGenerator alloc] init];
        _color = [_colorGenerator randomColorFromLocation:loc];
    }
    return self;
}

@end

@implementation BounceBlueColorConfigurationObject

-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    if(self) {
        _colorGenerator = [[BounceBlueColorGenerator alloc] init];
        _color = [_colorGenerator randomColorFromLocation:loc];
    }
    return self;
}

@end

@implementation BouncePurpleColorConfigurationObject

-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    if(self) {
        _colorGenerator = [[BouncePurpleColorGenerator alloc] init];
        _color = [_colorGenerator randomColorFromLocation:loc];
    }
    return self;
}

@end

@implementation BounceGrayColorConfigurationObject

-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    if(self) {
        _colorGenerator = [[BounceGrayColorGenerator alloc] init];
        _color = [_colorGenerator randomColorFromLocation:loc];
    }
    return self;
}

@end

@implementation BounceNoteConfigurationObject


-(void)playSound:(float)volume {

}

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    obj.sound = _sound;
    [_sound play:.2];
}

-(id)originalValueForObject:(BounceObject *)obj {
    return obj.sound;
}

-(void)setValue:(id)val forObject:(BounceObject *)obj {
    obj.sound = val;
}

@end


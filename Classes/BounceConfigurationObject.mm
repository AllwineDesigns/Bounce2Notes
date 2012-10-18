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
#import "BounceConfigurationSimulation.h"
#import "BounceMusicConfigurationSimulation.h"

@implementation BounceConfigurationObject

@synthesize createOnTap = _createOnTap;
@synthesize painting = _painting;
@synthesize timeSinceLastCreate = _timeSinceLastCreate;

-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle  {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    
    if(self) {
        [(NSObject*)_sound release];
        _sound = [[[BounceNoteManager instance] getRest] retain];
        _createOnTap = YES;
        
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
    [self updateSetting];
}
-(id)originalValueForObject:(BounceObject *)objj {
    NSAssert(NO, @"originalValueForObject: must be implemented by subclass\n");
    return nil;
}
-(void)setValue:(id)val forObject:(BounceObject *)obj {
}

-(void)updateSetting {
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
        if(![BounceSettings instance].paintMode) {
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
    
    if([BounceSettings instance].paintMode || [_previewObjects count] == 0) {
        [super draw];
    }
}

-(void)dealloc {
    [_originals release]; _originals = nil;
    [_previewObjects release]; _previewObjects = nil;
    [super dealloc];
}

@end


@implementation BounceShapeConfigurationObject

-(void)updateSetting {
    BounceShapeGenerator *gen = [[[BounceShapeGenerator alloc] initWithBounceShape:_bounceShape] autorelease];
    
    if(![gen isEqual:[BounceSettings instance].bounceShapeGenerator]) {
        [BounceSettings instance].bounceShapeGenerator =   gen;  
        [[(BounceConfigurationSimulation*)_simulation pane] randomizeShape];
    }
}

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    [super setConfigurationValueForObject:obj];
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

-(void)updateSetting {
    BouncePatternGenerator *gen = [[BouncePatternGenerator alloc] initWithPatternTexture:_patternTexture];
    [BounceSettings instance].patternTextureGenerator = gen;
    [gen release];
}

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    [super setConfigurationValueForObject:obj];
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

-(void)updateSetting {
    [BounceSettings instance].sizeGenerator = [[[BounceSizeGenerator alloc] initWithSize:_size] autorelease];    
}

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    [super setConfigurationValueForObject:obj];
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

-(void)updateSetting {
    [BounceSettings instance].colorGenerator = _colorGenerator;
    [[(BounceConfigurationSimulation*)_simulation pane] randomizeColor];
}

-(void)setColor:(const vec4 &)color {
}

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    [super setConfigurationValueForObject:obj];
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

-(void)updateSetting {
    [BounceSettings instance].sound = self.sound;
    if([BounceSettings instance].affectAllObjects) {
        [[[(BounceConfigurationSimulation*)_simulation pane] simulation] setSound:self.sound];
    }
}

-(void)setConfigurationValueForObject:(BounceObject *)obj {
    [super setConfigurationValueForObject:obj];
    obj.sound = _sound;
    [_sound play:.2];
}

-(id)originalValueForObject:(BounceObject *)obj {
    return obj.sound;
}

-(void)setValue:(id)val forObject:(BounceObject *)obj {
    obj.sound = val;
    [val play:.2];

}

@end

@implementation BounceChordConfigurationObject

@synthesize active = _active;

-(id)initWithChord:(unsigned int)chord {
    self = [super initObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2() withColor:vec4() withSize:.1 withAngle:0];
    
    if(self) {
        _chord = chord;
        _createOnTap = NO;
        [self changeInversion];
    }
    
    return self;
}

-(void)step:(float)dt {
    [super step:dt];
    if(_active && _intensity < 1) {
        _intensity = 1;
    }
}


-(void)changeInversion {
    BounceNoteManager *noteManager = [BounceNoteManager instance];
    NSString *key = noteManager.key;
    
    int inv = RANDFLOAT*3;
    
    int rootOffset = (inv == 1 || inv == 2) ? 7 : 0;
    int thirdOffset = (inv == 2) ? 7 : 0;
    int fifthOffset =  0;

    NSArray *sounds = [[NSArray alloc] initWithObjects:
                       [noteManager getSound:_chord forKey:key forOctave:3],
                       [noteManager getSound:_chord+rootOffset],
                       [noteManager getSound:_chord+2+thirdOffset],
                       [noteManager getSound:_chord+4+fifthOffset],
                       nil];
    BounceRandomSounds *s = [[BounceRandomSounds alloc] initWithSounds:sounds label:@""];
    self.sound = s;
    [s release];
    [sounds release];
}

-(void)singleTapAt:(const vec2 &)loc {
    [self changeInversion];
    BounceNoteManager *noteManager = [BounceNoteManager instance];
    
    NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
    if(now-_lastPlayed > .02) {
        [[noteManager getSound:_chord] play:.2];
        _lastPlayed = now;
    }
    [self updateSetting];
    [(BounceMusicConfigurationSimulation*)_simulation setActiveChord:self];
    [super singleTapAt:loc];
}

-(void)endGrabCallback {
    [self changeInversion];
    [super endGrabCallback];
}


@end

@implementation BouncePasteOriginal

@synthesize bounceShape = _bounceShape;
@synthesize color = _color;
@synthesize patternTexture = _patternTexture;
@synthesize size = _size;
@synthesize secondarySize = _size2;
@synthesize sound = _sound;

@end

@implementation BouncePasteConfigurationObject
@synthesize hasCopied = _hasCopied;
-(void)playSound:(float)volume {
    
}
-(void)randomizeColor {
    
}

-(void)updateSetting {
    
}

-(void)setConfigurationValueForObject:(BounceObject*)obj {
    if(_hasCopied) {
        obj.bounceShape = _bounceShape;
        obj.color = _color;
        obj.patternTexture = _patternTexture;
        [obj setSize:_size secondarySize:_size2];
        obj.sound = _sound;
    }
}

-(id)originalValueForObject:(BounceObject *)obj {
    BouncePasteOriginal *orig = [[BouncePasteOriginal alloc] init];
    orig.bounceShape = obj.bounceShape;
    orig.color = obj.color;
    orig.patternTexture = obj.patternTexture;
    orig.size = obj.size;
    orig.secondarySize = obj.secondarySize;
    orig.sound = obj.sound;
    
    return [orig autorelease];
}

-(void)setValue:(id)value forObject:(BounceObject *)obj {
    BouncePasteOriginal *orig = (BouncePasteOriginal*)value;
    obj.color = orig.color;
    obj.bounceShape = orig.bounceShape;
    obj.patternTexture = orig.patternTexture;
    [obj setSize:orig.size secondarySize:orig.secondarySize];
    obj.sound = orig.sound;
}

@end

@implementation BounceCopyConfigurationObject

-(void)updateSetting {
    
}

-(id)initWithPasteObject:(BouncePasteConfigurationObject*)pasteObj {
    self = [super initObjectWithShape:BOUNCE_BALL at:vec2(0,-2) withVelocity:vec2() withColor:vec4(1,1,1,1) withSize:.15 withAngle:0];
    if(self) {
        _pasteObj = [pasteObj retain];
        _createOnTap = NO;
    }
    return self;

}

-(void)setConfigurationValueForObject:(BounceObject*)obj {
    _pasteObj.hasCopied = YES;
    _pasteObj.color = obj.color;
    _pasteObj.bounceShape = obj.bounceShape;
    _pasteObj.patternTexture = obj.patternTexture;
    [_pasteObj setSize:obj.size secondarySize:obj.secondarySize];
    _pasteObj.sound = obj.sound;
}

-(id)originalValueForObject:(BounceObject *)obj {
    return [NSNull null];
}

-(void)setValue:(id)val forObject:(BounceObject *)obj {
    
}

-(void)dealloc {
    [_pasteObj release];
    [super dealloc];
}

@end



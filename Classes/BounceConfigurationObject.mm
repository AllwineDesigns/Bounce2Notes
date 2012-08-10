//
//  BounceConfigurationObject.m
//  ParticleSystem
//
//  Created by John Allwine on 6/30/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationObject.h"
#import "FSASoundManager.h"
#import "fsa/Noise.hpp"
#import "FSAUtil.h"

@implementation BounceConfigurationObject

@synthesize painting = _painting;
@synthesize timeSinceLastCreate = _timeSinceLastCreate;

-(id)initObjectWithShape:(BounceShape)bounceShape at:(const vec2 &)loc withVelocity:(const vec2 &)vel withColor:(const vec4 &)color withSize:(float)size withAngle:(float)angle  {
    self = [super initObjectWithShape:bounceShape at:loc withVelocity:vel withColor:color withSize:size withAngle:angle];
    
    if(self) {
        [_sound release];
        _sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
    }
    
    return self;
}

-(BounceObject*)previewObject {
    return _previewObject;
}

-(void)step:(float)dt {
    [super step:dt];
    
    _timeSinceLastCreate += dt;
}

-(void)setPreviewObject:(BounceObject*)obj {
    if(obj != _previewObject) {
        if(_previewObject) {
           // if(!_painting) {
             //   [self cancelChange];
            //}
            _previewing = NO;
        }
        
        [obj retain];
        [_previewObject release];
        _previewObject = obj;
        
        if(obj) {
            [self previewChange];
            _previewing = YES;
        }
    }
}

-(void)singleTapAt:(const vec2 &)loc {
    _intensity = 2.2;
    [_renderable burst:5];
}

-(void)previewChange {
    NSAssert(NO, @"preview change must be implemented by a subclass\n");    
}

-(void)cancelChange {
    NSAssert(NO, @"cancel change must be implemented by a subclass\n");    
}

-(void)finalizeChange {
    _previewing = NO;
    [_previewObject release];
    _previewObject = nil;
}

-(void)draw {
    if(_previewing) {
        [_previewObject drawSelected];
    } else {
        [super draw];
    }
}

-(void)dealloc {
    [_previewObject release]; _previewObject = nil;
    [super dealloc];
}

@end


@implementation BounceShapeConfigurationObject

-(void)previewChange {
    _originalShape = _previewObject.bounceShape;
    
    _previewObject.bounceShape = _bounceShape;
}

-(void)cancelChange {
    _previewObject.bounceShape = _originalShape;
}

@end

@implementation BouncePatternConfigurationObject
@synthesize originalPattern = _originalPattern;
-(void)previewChange {
    self.originalPattern = _previewObject.patternTexture;
    
    _previewObject.patternTexture  = _patternTexture;
}

-(void)cancelChange {
    _previewObject.patternTexture = _originalPattern;
    self.originalPattern = nil;
}

@end

@implementation BounceSizeConfigurationObject

-(void)previewChange {
    _originalSize = _previewObject.size;
    _originalSecondarySize = _previewObject.secondarySize;
    
    [_previewObject setSize:_size secondarySize:_size*GOLDEN_RATIO];
}

-(void)cancelChange {
    [_previewObject setSize:_originalSize secondarySize:_originalSecondarySize];
}

@end

@implementation BounceColorConfigurationObject

-(void)setColor:(const vec4 &)color {
}

-(void)previewChange {
    _originalColor = _previewObject.color;
    
    [_previewObject setColor:_color];
}

-(void)cancelChange {
    [_previewObject setColor:_originalColor];
}

@end

@implementation BouncePastelColorConfigurationObject

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    
    vec2 loc = 6*pos+vec2(123,923);
    vec2 loc2 = 6*pos+vec2(456,-120);
    float time = [[NSProcessInfo processInfo] systemUptime];
    float time2 = time+1000;
    
    float k = .5*pnoise(loc.x, loc.y, time)+.5;
    float k2 = .5*pnoise(loc2.x, loc2.y, time2)+.5;

    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             360.*k, .4, .05*k2+.75   );
    color.w = 1;
    _color = color;
}

@end

@implementation BounceRedColorConfigurationObject

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    
    vec2 loc = 6*pos+vec2(123,923);
    vec2 loc2 = 6*pos+vec2(456,-120);
    vec2 loc3 = 6*pos+vec2(8721,-1220);

    float time = [[NSProcessInfo processInfo] systemUptime];
    float time2 = time+1000;
    float time3 = time+2000;

    float k = .5*pnoise(loc.x, loc.y, time)+.5;
    float k2 = .5*pnoise(loc2.x, loc2.y, time2)+.5;
    float k3 = .5*pnoise(loc3.x, loc3.y, time3)+.5;

    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             10.*k, .2*k3+.8, .8*k2+.2   );
    color.w = 1;
    _color = color;
}

@end

@implementation BounceOrangeColorConfigurationObject

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    
    vec2 loc = 6*pos+vec2(123,923);
    vec2 loc2 = 6*pos+vec2(456,-120);
    vec2 loc3 = 6*pos+vec2(8721,-1220);
    
    float time = [[NSProcessInfo processInfo] systemUptime];
    float time2 = time+1000;
    float time3 = time+2000;
    
    float k = .5*pnoise(loc.x, loc.y, time)+.5;
    float k2 = .5*pnoise(loc2.x, loc2.y, time2)+.5;
    float k3 = .5*pnoise(loc3.x, loc3.y, time3)+.5;
    
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             15.*k+15, .2*k3+.8, .8*k2+.2   );
    color.w = 1;
    _color = color;
}

@end

@implementation BounceYellowColorConfigurationObject

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    
    vec2 loc = 6*pos+vec2(123,923);
    vec2 loc2 = 6*pos+vec2(456,-120);
    vec2 loc3 = 6*pos+vec2(8721,-1220);
    
    float time = [[NSProcessInfo processInfo] systemUptime];
    float time2 = time+1000;
    float time3 = time+2000;
    
    float k = .5*pnoise(loc.x, loc.y, time)+.5;
    float k2 = .5*pnoise(loc2.x, loc2.y, time2)+.5;
    float k3 = .5*pnoise(loc3.x, loc3.y, time3)+.5;
    
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             15.*k+45, .2*k3+.8, .8*k2+.2   );
    color.w = 1;
    _color = color;
}

@end

@implementation BounceGreenColorConfigurationObject

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    
    vec2 loc = 6*pos+vec2(123,923);
    vec2 loc2 = 6*pos+vec2(456,-120);
    vec2 loc3 = 6*pos+vec2(8721,-1220);
    
    float time = [[NSProcessInfo processInfo] systemUptime];
    float time2 = time+1000;
    float time3 = time+2000;
    
    float k = .5*pnoise(loc.x, loc.y, time)+.5;
    float k2 = .5*pnoise(loc2.x, loc2.y, time2)+.5;
    float k3 = .5*pnoise(loc3.x, loc3.y, time3)+.5;
    
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             30.*k+100, .2*k3+.8, .8*k2+.2   );
    color.w = 1;
    _color = color;
}

@end

@implementation BounceBlueColorConfigurationObject

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    
    vec2 loc = 6*pos+vec2(123,923);
    vec2 loc2 = 6*pos+vec2(456,-120);
    vec2 loc3 = 6*pos+vec2(8721,-1220);
    
    float time = [[NSProcessInfo processInfo] systemUptime];
    float time2 = time+1000;
    float time3 = time+2000;
    
    float k = .5*pnoise(loc.x, loc.y, time)+.5;
    float k2 = .5*pnoise(loc2.x, loc2.y, time2)+.5;
    float k3 = .5*pnoise(loc3.x, loc3.y, time3)+.5;
    
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             45.*k+215, .2*k3+.8, .8*k2+.2   );
    color.w = 1;
    _color = color;
}

@end

@implementation BouncePurpleColorConfigurationObject

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    
    vec2 loc = 6*pos+vec2(123,923);
    vec2 loc2 = 6*pos+vec2(456,-120);
    vec2 loc3 = 6*pos+vec2(872,-62);
    
    float time = [[NSProcessInfo processInfo] systemUptime];
    float time2 = time+1000;
    float time3 = time+2000;
    
    float k = .5*pnoise(loc.x, loc.y, time)+.5;
    float k2 = .5*pnoise(loc2.x, loc2.y, time2)+.5;
    float k3 = .5*pnoise(loc3.x, loc3.y, time3)+.5;
    
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             10.*k+270, .2*k3+.8, .5*k2+.5   );
    color.w = 1;
    _color = color;
}

@end

@implementation BounceGrayColorConfigurationObject

-(void)step:(float)dt {
    [super step:dt];
    
    vec2 pos = self.position;
    
    vec2 loc = 6*pos+vec2(123,923);
    
    float time = [[NSProcessInfo processInfo] systemUptime];
    
    float k = .5*pnoise(loc.x, loc.y, time)+.5;
    
    vec4 color;
    HSVtoRGB(&(color.x), &(color.y), &(color.z), 
             0, 0, .7*k+.3   );
    color.w = 1;
    _color = color;
}

@end

@implementation BounceNoteConfigurationObject
@synthesize originalNote = _originalNote;
-(void)playSound:(float)volume {
}

-(void)previewChange {
    self.originalNote = _previewObject.sound;
    
    _previewObject.sound = _sound;
    [_sound play:.2];
}

-(void)cancelChange {
    _previewObject.sound = _originalNote;
    [_originalNote play:.2];
    self.originalNote = nil;
}

@end


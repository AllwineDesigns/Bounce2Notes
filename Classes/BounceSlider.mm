//
//  BounceSlider.m
//  ParticleSystem
//
//  Created by John Allwine on 7/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSlider.h"
#import "FSATextureManager.h"

@implementation NSNumber (Lerp)

-(float)interp:(id)b x:(id)x { // returns t such that [a lerp:b param:t] returns x
    float v = [self floatValue];
    float v2 = [b floatValue];
    
    float xv = [x floatValue];
    
    return (xv-v)/(v2-v);
}

-(id)lerp:(id)n param:(float)t {
    float v = [self floatValue];
    float v2 = [n floatValue];
    
    return [NSNumber numberWithFloat:v*(1-t)+v2*t];
}

@end

@implementation BounceSlider

@synthesize track = _track;
@synthesize handle = _handle;

@synthesize value = _value;
@synthesize label = _label;
@synthesize index = _index;

@synthesize lastValue = _lastValue;
@synthesize lastLabel = _lastLabel;
@synthesize lastIndex = _lastIndex;

@synthesize padding = _padding;

@synthesize delegate = _delegate;
@synthesize selector = _selector;

-(void)setupBounceObjects {
    _track = [[BounceSliderTrack alloc] initWithSlider:self];
    _handle = [[BounceSliderHandle alloc] initWithSlider:self];
    
   // [_track setGroup:(cpGroup)self];
   // [_handle setGroup:(cpGroup)self];
    
}

-(id)initWithLabels:(NSArray *)labels index:(unsigned int)index {
    self = [super init]; 
    if(self) {
        _continuous = NO;
        _index = index;
        _value = [labels objectAtIndex:index];
        _label = [labels objectAtIndex:index];
        _curT = (float)index/([labels count]-1);
        _actualT = _curT;
        
        _values = [labels copy];
        _labels = [labels copy];
        _selector = @selector(changed:);

        [self setupBounceObjects];
    }
    return self;
}

-(id)initWithLabels:(NSArray*)labels values:(NSArray*)values index:(unsigned int)index {
    self = [super init];
    NSAssert([labels count] == [values count], @"must have the same number of labels as values\n");
    if(self) {
        _continuous = NO;
        _labels = [labels copy];
        _values = [values copy];
        _value = [_values objectAtIndex:index];
        [_value retain];
        _label = [_labels objectAtIndex:index];
        [_label retain];
        _index = _index;
        _curT = (float)index/([labels count]-1);
        _actualT = _curT;
        _selector = @selector(changed:);

        
        [self setupBounceObjects];

    }
    return self;
}

-(id)initContinuousWithLabels:(NSArray*)labels values:(NSArray*)values index:(unsigned int)index {
    self = [super init];
    NSAssert([labels count] == [values count], @"must have the same number of labels as values\n");

    if(self) {
        _continuous = YES;
        _labels = [labels copy];
        _values = [values copy];
        
        _value = [values objectAtIndex:index];
        [_value retain];
        
        _label = [labels objectAtIndex:index];
        [_label retain];
        
        _index = index;
        _curT = (float)index/([labels count]-1);
        _actualT = _curT;
        
        _selector = @selector(changed:);
        
        [self setupBounceObjects];
    }
    return self;
}

-(void)setValue:(id)value {
    if(_continuous) {
        unsigned int numValues = [_values count];
        for(unsigned int i = 0; i < numValues-1; i++) {
            id a = [_values objectAtIndex:i];
            id b = [_values objectAtIndex:i+1];
            float t = [a interp:b x:value];
            if(t >= 0 && t <= 1) {
                self.param = (float)(i+t)/(numValues-1);
                return;
            }
        }
    } else {
        unsigned int numValues = [_values count];
        for(unsigned int i = 0; i < numValues; i++) {
            if([value isEqual:[_values objectAtIndex:i]]) {
                self.index = i;
                return;
            }
        }
    }
    
    NSLog(@"invalid value for slider: %@", self);
    NSAssert(NO, @"invalid value for slider");
}

-(void)setLabels:(NSArray *)labels {
    [_labels release];
    _labels = [labels copy];

    [_label release];
    _label = [[_labels objectAtIndex:_index] retain];
    //[_delegate changed:self];
    [_delegate performSelector:_selector withObject:self];
}

-(void)addToSimulation:(BounceSimulation *)simulation {
    [_track addToSimulation:simulation];
    [_handle addToSimulation:simulation];
}

-(float)paramFromLocation:(const vec2&)loc {
    vec2 trackPos = _track.position;
    float trackSize = _track.size;
    float trackAngle = _track.angle;
    
    float cosa = cos(-trackAngle);
    float sina = sin(-trackAngle);
    
    vec2 minLoc(-trackSize+_padding, 0);
    minLoc.rotate(cosa,sina);
    minLoc += trackPos;
    
    vec2 maxLoc(trackSize-_padding, 0);
    maxLoc.rotate(cosa,sina);
    maxLoc += trackPos;
    
    vec2 trackVec = maxLoc-minLoc;
    float trackLength = 2*(trackSize-_padding);
    vec2 trackDir = trackVec.unit();
    
    vec2 vec = loc-minLoc;
    float vecLength = vec.length();
    if(vecLength > 0) {
        vec.normalize();
    }
    
    float t = vec.dot(trackDir)*vecLength/trackLength;
    if(t < 0) {
        t = 0;
    } else if(t > 1) {
        t = 1;
    }    
    if(!_continuous) {
        int maxNum = [_values count]-1;
        
        t = roundf(t*maxNum)/maxNum;
    }
    
    return t;
}

-(void)setLayers:(cpLayers)l {
    [self.handle setLayers:l];
    [self.track setLayers:l];
}

-(void)update {
    float t = _actualT;

    BOOL changed = NO;

    float index = t*([_values count]-1);
    if(_continuous) {
        float tt = index-(int)index;
        id newValue;
        id value1 = [_values objectAtIndex:(int)index];

        if(t < 1) {
            id value2 = [_values objectAtIndex:(int)(index+1)];
            newValue = [value1 lerp:value2 param:tt];
        } else {
            newValue = value1;
        }

        if(![newValue isEqual:_value]) {
            changed = YES;
        }
        index = roundf(index);
        [_lastValue release];
        _lastValue = _value;
        
        [newValue retain];
        _value = newValue;
    } else {
        index = roundf(index);
        if(index != _index) {
            changed = YES;
        }
        
        [_lastValue release];
        _lastValue = _value;
        
        _value = [_values objectAtIndex:(int)index];
        [_value retain];
    }
    
    if(changed) {
        _lastIndex = _index;
        
        [_label retain];
        [_lastLabel release];
        _lastLabel = _label;
        
        _index = (float)index;
        [_label release];
        _label = [_labels objectAtIndex:_index];
        [_label retain];
        
        [_delegate performSelector:_selector withObject:self];
    }
}

-(float)tFromLength: (float)length {
    float maxLength = 2*_track.size;
    return length/maxLength;
}

-(float)lengthFromT: (float)t {
    float maxLength = 2*_track.size;
    return t*maxLength;
}

-(const vec2)posFromT:(float)t {
    vec2 trackPos = _track.position;
    float trackSize = _track.size;
    float trackAngle = _track.angle;
    
    float cosa = cos(-trackAngle);
    float sina = sin(-trackAngle);
    
    vec2 minLoc(-trackSize+_padding,0);
    minLoc.rotate(cosa,sina);
    minLoc += trackPos;
    
    vec2 maxLoc(trackSize-_padding,0);
    maxLoc.rotate(cosa,sina);
    maxLoc += trackPos;
    
    vec2 trackVec = maxLoc-minLoc;
    
    return minLoc+t*trackVec;
}

-(const vec2)trackDir {
    float trackAngle = _track.angle;
    
    vec2 dir(1,0);
    dir.rotate(-trackAngle);
    return dir;
}

-(void)setIndex:(unsigned int)index {
    _actualT = (float)index/([_values count]-1);
    [self update];
}

-(void)setParam:(float)t {
    NSAssert(t >= 0 && t <= 1, @"param must be between 0 and 1 inclusive\n");
    _actualT = t;
    [self update];
}

-(float)param {
    return _actualT;
}

-(void)slideTo:(const vec2 &)loc {
    _actualT = [self paramFromLocation:loc];
    [self update];
}

-(void)step:(float)dt {
    float spring_k = 400;
    float drag = .3;
    
    float curLength = [self lengthFromT:_curT];
    float actualLength = [self lengthFromT:_actualT];

    curLength += _vel*dt;

    float a = -spring_k*(curLength-actualLength);
    
    _vel +=  a*dt-drag*_vel;
    
    _curT = [self tFromLength:curLength];
    if(_curT > 1 && _vel > 0) {
        _curT = 1;
        _vel *= -.9025;
    } else if(_curT < 0 && _vel < 0) {
        _curT = 0;
        _vel *= -.9025;
    }
    
    vec2 pos = [self posFromT:_curT];
    vec2 vel = [self trackDir]*_vel+_track.velocity;
    
    [_handle setPosition:pos];
    [_handle setVelocity:vel];
}
-(void)setPosition:(const vec2 &)loc {
    [self.track setPosition:loc];
    [self.handle setPosition:[self posFromT:_curT]];
}

-(void)setVelocity:(const vec2 &)vel {
    [self.track setVelocity:vel];
    //[self.handle setVelocity:vel];
}

-(void)setAngle:(float)angle {
    [self.track setAngle:angle];
    [self.handle setAngle:angle];
}
-(void)setAngVel:(float)angVel {
    [self.track setAngVel:angVel];
    [self.handle setAngVel:angVel];
}

-(void)draw {
    [_track draw];
    [_handle draw];
}

-(void)dealloc {
    [_track release];
    [_handle release];
    [_values release];
    [_labels release];
    [_value release];
    [_label release];
    [_lastLabel release];
    [_lastValue release];
    [super dealloc];
}

@end


@implementation BounceSliderTrack

-(id)initWithSlider:(BounceSlider *)slider {
    self = [super initObjectWithShape:BOUNCE_CAPSULE at:vec2() withVelocity:vec2() withColor:vec4(.5,.75,1,1) withSize:.3 withAngle:0];
    
    if(self) {
        _slider = slider;
        self.secondarySize = .015;
        self.isStationary = NO;
        self.isPreviewable = NO;
        self.isRemovable = NO;
        self.simulationWillArchive = NO;
        self.simulationWillDraw = YES;
        self.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
        [self makeStatic];
    }
    
    return self;
}

-(void)singleTapAt:(const vec2 &)loc {
    [_slider slideTo:loc];
}

-(void)flickAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {
}

-(void)createCallbackWithSize:(float)size secondarySize:(float)size2 {
}

-(void)beginGrabCallback:(const vec2&)loc {
    [_slider slideTo:loc];
}

-(void)grabCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel stationary:(BOOL)stationary {
    
}

-(void)grabCallback:(const vec2 &)loc {
    [_slider slideTo:loc];
}

-(void)endGrabCallback {
    
}

-(void)beginTransformCallback {
    
}

-(void)transformCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel size:(float)size secondarySize:(float)size2 doSecondarySize:(BOOL)_doSecondarySize {
    
}

-(void)endTransformCallback {
    
}


-(void)makeSimulated {
    [self makeStatic];
}

@end

@implementation BounceSliderHandle

-(id)initWithSlider:(BounceSlider *)slider {
    self = [super initObjectWithShape:BOUNCE_BALL at:vec2() withVelocity:vec2() withColor:vec4(.5,.75,1,1) withSize:.05 withAngle:0];
    
    if(self) {
        _slider = slider;
        self.isStationary = NO;
        self.isPreviewable = NO;
        self.isRemovable = NO;
        self.simulationWillArchive = NO;
        self.simulationWillDraw = YES;
        [self makeStatic];
    }
    
    return self;
}

-(void)makeSimulated {
    [self makeStatic];
}

//-(void)makeStatic {
//    [self makeHeavyRogue];
//}

-(void)singleTapAt:(const vec2 &)loc {
    [_slider slideTo:loc];
}

-(void)flickAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    
}

-(void)createCallbackWithSize:(float)size secondarySize:(float)size2 {
}

-(void)beginGrabCallback:(const vec2&)loc {
    [_slider slideTo:loc];
}

-(void)grabCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel stationary:(BOOL)stationary {
    
}

-(void)endGrabCallback {
    
}

-(void)beginTransformCallback {
    
}

-(void)grabCallback:(const vec2 &)loc {
    [_slider slideTo:loc];
}

-(void)endTransformCallback {
    
}

-(void)transformCallbackWithPosition:(const vec2 &)pos velocity:(const vec2 &)vel angle:(float)angle angVel:(float)angVel size:(float)size secondarySize:(float)size2 doSecondarySize:(BOOL)_doSecondarySize {
    
}


@end

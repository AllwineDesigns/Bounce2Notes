//
//  BounceSlider.h
//  ParticleSystem
//
//  Created by John Allwine on 7/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BounceObject.h"
#import "BouncePages.h"

@interface NSNumber (Lerp)

-(id)lerp:(id)n param:(float)t;

@end

@class BounceSlider;

@protocol BounceSliderDelegate <NSObject>

-(void)changed: (BounceSlider*)slider;

@end

@interface BounceSlider : NSObject <BounceWidget> {
    BounceObject *_track;
    BounceObject *_handle;
        
    BOOL _continuous;
    
    float _curT;
    float _actualT;
    
    unsigned int _index;
    id _value;
    NSString *_label;
    
    unsigned int _lastIndex;
    id _lastValue;
    NSString *_lastLabel;
    
    NSArray *_labels;
    NSArray *_values;
    
    float _padding;
    
    id<BounceSliderDelegate> _delegate;
    SEL _selector;
    
    float _vel;
}

@property (nonatomic, retain) id value;
@property (nonatomic, readonly) NSString* label;
@property (nonatomic) unsigned int index;

@property (nonatomic, readonly) id lastValue;
@property (nonatomic, readonly) NSString* lastLabel;
@property (nonatomic, readonly) unsigned int lastIndex;

@property (nonatomic, readonly) BounceObject* track;
@property (nonatomic, readonly) BounceObject* handle;
@property (nonatomic, retain) id<BounceSliderDelegate> delegate;
@property (nonatomic) SEL selector;

@property (nonatomic) float padding;

-(id)initWithLabels:(NSArray*)labels index:(unsigned int)index;
-(id)initWithLabels:(NSArray*)labels values:(NSArray*)values index:(unsigned int)index;
-(id)initContinuousWithLabels:(NSArray*)labels values:(NSArray*)values index:(unsigned int)index;
-(void)addToSimulation:(BounceSimulation*)simulation;
-(void)removeFromSimulation;
-(void)draw;
-(void)slideTo:(const vec2&)loc;
-(void)step: (float)dt;
-(void)setPosition:(const vec2&)loc;
-(void)setVelocity:(const vec2&)vel;
-(void)setAngle:(float)angle;
-(void)setAngVel:(float)angVel;
-(void)setLabels:(NSArray*)labels;
-(void)setLayers:(cpLayers)l;

-(void)setParam:(float)t;
-(float)param;

@end

@interface BounceSliderTrack : BounceObject {
    BounceSlider *_slider;
}
-(id)initWithSlider: (BounceSlider*)slider;
@end

@interface BounceSliderHandle : BounceObject {
    BounceSlider *_slider;
}
-(id)initWithSlider: (BounceSlider*)slider;

@end

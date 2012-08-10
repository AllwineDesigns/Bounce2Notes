//
//  BounceSlider.h
//  ParticleSystem
//
//  Created by John Allwine on 7/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BounceObject.h"

@interface NSNumber (Lerp)

-(id)lerp:(id)n param:(float)t;

@end

@class BounceSlider;

@protocol BounceSliderDelegate <NSObject>

-(void)changed: (BounceSlider*)slider;

@end

@interface BounceSlider : NSObject {
    BounceObject *_track;
    BounceObject *_handle;
        
    BOOL _continuous;
    
    float _curT;
    float _actualT;
    
    unsigned int _index;
    id _value;
    NSString *_label;
    
    NSArray *_labels;
    NSArray *_values;
    
    float _padding;
    
    id<BounceSliderDelegate> _delegate;
    
    float _vel;
}

@property (nonatomic, readonly) id value;
@property (nonatomic, readonly) NSString* label;
@property (nonatomic, readonly) unsigned int index;

@property (nonatomic, readonly) BounceObject* track;
@property (nonatomic, readonly) BounceObject* handle;
@property (nonatomic, retain) id<BounceSliderDelegate> delegate;

@property (nonatomic) float padding;

-(id)initWithLabels:(NSArray*)labels index:(unsigned int)index;
-(id)initWithLabels:(NSArray*)labels values:(NSArray*)values index:(unsigned int)index;
-(id)initContinuousWithLabels:(NSArray*)labels values:(NSArray*)values index:(unsigned int)index;
-(void)addToSimulation:(BounceSimulation*)simulation;
-(void)draw;
-(void)slideTo:(const vec2&)loc;
-(void)step: (float)dt;
-(void)setPosition:(const vec2&)loc;
-(void)setVelocity:(const vec2&)vel;
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

//
//  BounceSettingsSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 7/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSimulation.h"
#import "BounceConfigurationSimulation.h"
#import "BounceSlider.h"
#import <vector>

@class BounceSettingsPages;

@protocol BounceSettingsWidget <NSObject>

-(void)setPosition:(const vec2&)pos;

@end

@interface BounceSettingsPage : NSObject {
    BounceSettingsPages *_parent;
    
    float _pageOffset;
    NSMutableArray *_objects;
    std::vector<vec2> _offsets;
}

@property (nonatomic, assign) BounceSettingsPages *parent;
@property (nonatomic) float pageOffset;

-(void)addWidget:(id)widget offset:(const vec2&)offset; 
-(void)updatePositions:(const vec2&)panePosition;

@end

@interface BounceSettingsPages : NSObject {
    float _pos;
    float _vel;
    float _touchOffset;
    float _pageWidth;
    unsigned int _curPage;
    
    float _springLoc;
    
    NSMutableArray *_pages;
}

@property (nonatomic, readonly) float position;
@property (nonatomic, readonly) float velocity;
@property (nonatomic) unsigned int currentPage;
@property (nonatomic) float touchOffset;

-(unsigned int)count;

-(void)nextPage;
-(void)previousPage;

-(id)initWithPageWidth: (float)width;

-(void)addPage:(BounceSettingsPage*)page;
-(void)step:(float)dt;
-(void)updatePositions:(const vec2&)panePosition;
@end


@interface BounceSettingsSimulation : BounceConfigurationSimulation <BounceSliderDelegate> {
    BounceSlider *_bouncinessSlider;
    BounceSlider *_gravitySlider;
    BounceSlider *_shapesSlider;
    BounceSlider *_patternsSlider;
    BounceSlider *_dampingSlider;
    BounceSlider *_velLimitSlider;
    BounceSlider *_frictionSlider;
    BounceSlider *_colorSlider;
    
    float _timeSinceRandomsRefresh;
    
    BounceSlider *_pageSlider;
    
    BounceSettingsPages *_pages;
    void* _sliding;
    vec2 _beginSlidingPos;
    
    BounceConfigurationPane *_pane;
    
}
@property (nonatomic, retain) BounceConfigurationPane *pane;
-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation*)sim;
@end

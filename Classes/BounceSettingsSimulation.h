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
    float _top;
    float _bottom;
    
    float _verticalScroll;
    float _verticalSpringLoc;
    
    float _verticalPos;
    float _verticalVel;
    
    float _pageOffset;
    NSMutableArray *_objects;
    std::vector<vec2> _offsets;
}

@property (nonatomic, assign) BounceSettingsPages *parent;
@property (nonatomic) float pageOffset;

-(void)step:(float)dt;
-(void)setScroll:(float)scroll;
-(void)finalizeScroll;
-(void)addWidget:(id)widget offset:(const vec2&)offset; 
-(void)updatePositions:(const vec2&)panePosition;

@end

@interface BounceSettingsPages : NSObject {
    float _pos;
    float _vel;
    float _touchOffset;
    float _pageWidth;
    float _pageHeight;
    unsigned int _curPage;
    
    float _springLoc;
    
    NSMutableArray *_pages;
}
@property (nonatomic, readonly) float pageWidth;
@property (nonatomic, readonly) float pageHeight;
@property (nonatomic, readonly) float position;
@property (nonatomic, readonly) float velocity;
@property (nonatomic) unsigned int currentPage;
@property (nonatomic) float touchOffset;

-(unsigned int)count;

-(void)nextPage;
-(void)previousPage;

-(id)initWithPageWidth: (float)width pageHeight:(float)height;

-(void)addPage:(BounceSettingsPage*)page;
-(void)step:(float)dt;
-(void)updatePositions:(const vec2&)panePosition;

-(void)setScroll:(float)scroll;
-(void)finalizeScroll;
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
    BounceSlider *_minSizeSlider;
    BounceSlider *_maxSizeSlider;
    
    BounceSlider *_allNewBouncinessSlider;
    BounceSlider *_allNewGravitySlider;
    BounceSlider *_allNewShapesSlider;
    BounceSlider *_allNewPatternsSlider;
    BounceSlider *_allNewDampingSlider;
    BounceSlider *_allNewVelLimitSlider;
    BounceSlider *_allNewFrictionSlider;
    BounceSlider *_allNewColorSlider;
    BounceSlider *_allNewSizeSlider;
    
    BounceSlider *_paintModeSlider;
    BounceSlider *_grabRotatesSlider;
    BounceSlider *_paneUnlockedSlider;
    
    float _timeSinceRandomsRefresh;
    
    BounceSlider *_pageSlider;
    
    BounceSettingsPages *_pages;
    void* _sliding;
    vec2 _beginSlidingPos;
    
    BounceConfigurationPane *_pane;
    
}
@property (nonatomic, retain) BounceConfigurationPane *pane;
-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation*)sim;
-(void)changedBouncinessSlider:(BounceSlider*)slider;
-(void)changedGravitySlider:(BounceSlider*)slider;
-(void)changedShapesSlider:(BounceSlider*)slider;
-(void)changedPatternsSlider:(BounceSlider*)slider;
-(void)changedDampingSlider:(BounceSlider*)slider;
-(void)changedVelLimitSlider:(BounceSlider*)slider;
-(void)changedFrictionSlider:(BounceSlider*)slider;
-(void)changedColorSlider:(BounceSlider*)slider;
-(void)changedMinSizeSlider:(BounceSlider*)slider;
-(void)changedMaxSizeSlider:(BounceSlider*)slider;
-(void)changedPageSlider:(BounceSlider*)slider;

-(void)changedAllNewBouncinessSlider:(BounceSlider*)slider;
-(void)changedAllNewGravitySlider:(BounceSlider*)slider;
-(void)changedAllNewShapesSlider:(BounceSlider*)slider;
-(void)changedAllNewPatternsSlider:(BounceSlider*)slider;
-(void)changedAllNewDampingSlider:(BounceSlider*)slider;
-(void)changedAllNewVelLimitSlider:(BounceSlider*)slider;
-(void)changedAllNewFrictionSlider:(BounceSlider*)slider;
-(void)changedAllNewColorSlider:(BounceSlider*)slider;
-(void)changedAllNewSizeSlider:(BounceSlider*)slider;

-(void)changedPaintModeSlider:(BounceSlider*)slider;
-(void)changedGrabRotatesSlider:(BounceSlider*)slider;
-(void)changedPaneUnlockedSlider:(BounceSlider*)slider;


@end

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
#import "BouncePages.h"

@interface BounceSettingsSimulation : BounceConfigurationSimulation <BounceSliderDelegate> {
    BounceSlider *_bouncinessSlider;
    BounceSlider *_gravitySlider;
    BounceSlider *_shapesSlider;
    BounceSlider *_patternsSlider;
    BounceSlider *_dampingSlider;
    BounceSlider *_velLimitSlider;
    BounceSlider *_frictionSlider;
    BounceSlider *_colorSlider;
    BounceSlider *_sizeSlider;
    
    BounceSlider *_affectsAllObjectsSlider;
    
    BounceSlider *_paintModeSlider;
    BounceSlider *_grabRotatesSlider;
    BounceSlider *_paneUnlockedSlider;
    
    BounceArena *_copyPasteArena;
    BounceObject *_copyObject;
    BounceObject *_pasteObject;
    
    float _timeSinceRandomsRefresh;
    
    BounceSlider *_pageSlider;
    
    BouncePages *_pages;
    void* _sliding;
    vec2 _beginSlidingPos;
    
    BOOL _updatingSettings;
    
    
    //Music page
    BounceSlider *_keySlider;
    BounceSlider *_octaveSlider;
    BounceSlider *_tonalitySlider;
    BounceSlider *_modeSlider;
    ChipmunkObject *_buffer;
    BounceArena *_musicArena;
    
    NSArray *_noteConfigObjects;
}
-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation*)sim;
-(void)changedBouncinessSlider:(BounceSlider*)slider;
-(void)changedGravitySlider:(BounceSlider*)slider;
-(void)changedShapesSlider:(BounceSlider*)slider;
-(void)changedPatternsSlider:(BounceSlider*)slider;
-(void)changedDampingSlider:(BounceSlider*)slider;
-(void)changedVelLimitSlider:(BounceSlider*)slider;
-(void)changedFrictionSlider:(BounceSlider*)slider;
-(void)changedColorSlider:(BounceSlider*)slider;
-(void)changedSizeSlider:(BounceSlider*)slider;
-(void)changedPageSlider:(BounceSlider*)slider;

-(void)changedMusicSlider:(BounceSlider*)slider;

-(void)changedAffectsAllObjectsSlider:(BounceSlider*)slider;

-(void)changedPaintModeSlider:(BounceSlider*)slider;
-(void)changedGrabRotatesSlider:(BounceSlider*)slider;
-(void)changedPaneUnlockedSlider:(BounceSlider*)slider;


@end

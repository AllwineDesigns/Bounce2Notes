//
//  BounceSettingsSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 7/23/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSettingsSimulation.h"
#import "BounceConstants.h"
#import "FSAShaderManager.h"
#import "BounceNoteManager.h"
#import "FSATextureManager.h"
#import "BounceSettings.h"
#import "BounceShapeGenerator.h"

@implementation BounceSettingsPages

@synthesize pageWidth = _pageWidth;
@synthesize pageHeight = _pageHeight;
@synthesize position = _pos;
@synthesize velocity = _vel;
@synthesize currentPage = _curPage;
@synthesize touchOffset = _touchOffset;

-(id)initWithPageWidth:(float)width pageHeight:(float)height {
    self = [super init];
    if(self) {
        _pageWidth = width;
        _pageHeight = height;
        _pages = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    return self;
}

-(void)setTouchOffset:(float)touchOffset {
    _touchOffset = touchOffset;
    
    _springLoc = -_pageWidth*_curPage+_touchOffset;
}

-(void)setCurrentPage:(unsigned int)currentPage {
    _curPage = currentPage;
    
    _springLoc = -_pageWidth*_curPage+_touchOffset;
}

-(void)addPage:(BounceSettingsPage*)page {
    page.parent = self;
    page.pageOffset = [_pages count]*_pageWidth;
    [_pages addObject:page];
}
-(void)step:(float)dt {
    float spring_k = 130;
    float drag = .2;
    
    _pos += _vel*dt;
    
    float a = spring_k*(_springLoc-_pos);
    
    _vel +=  a*dt-drag*_vel;
    
    for(BounceSettingsPage* page in _pages) {
        [page step:dt];
    }
}
-(void)updatePositions:(const vec2&)panePosition {
    for(BounceSettingsPage *page in _pages) {
        [page updatePositions:panePosition];
    }
}

-(unsigned int)count {
    return [_pages count];
}

-(void)nextPage {
    if(_curPage < [_pages count]-1) {
        //[self finalizeScroll];
        [self setCurrentPage:_curPage+1];
    }
}
-(void)previousPage {
    if(_curPage > 0) {
        //[self finalizeScroll];
        [self setCurrentPage:_curPage-1];
    }
}

-(void)setScroll:(float)scroll {
    [[_pages objectAtIndex:_curPage] setScroll:scroll];
}

-(void)finalizeScroll {
    [[_pages objectAtIndex:_curPage] finalizeScroll];
}

-(void)dealloc {
    [_pages dealloc];
    [super dealloc];
}

@end

@implementation BounceSettingsPage
@synthesize parent = _parent;
@synthesize pageOffset = _pageOffset;

-(id)init {
    self = [super init];
    if(self) {
        _objects = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

-(void)step:(float)dt {
    float spring_k = 130;
    float drag = .2;
    
    _verticalPos += _verticalVel*dt;
    
    float a = spring_k*(_verticalSpringLoc+_verticalScroll-_verticalPos);
    
    _verticalVel +=  a*dt-drag*_verticalVel;
}

-(void)setScroll:(float)scroll {
    _verticalScroll = scroll;
}

-(void)finalizeScroll {
    _verticalSpringLoc += _verticalScroll;
    if(_verticalSpringLoc < _top) {
        _verticalSpringLoc = _top;
    } else if(_verticalSpringLoc > _bottom) {
        _verticalSpringLoc = _bottom;
    }
    _verticalScroll = 0;
}

-(void)addWidget:(id)widget offset:(const vec2&)offset {
    if(-offset.y-_parent.pageHeight*.5 < _top) {
        _top = offset.y-_parent.pageHeight*.5;
    } else if(-offset.y+_parent.pageHeight*.5 > _bottom) {
        _bottom = -offset.y+_parent.pageHeight*.5;
    }
    [_objects addObject:widget];
    _offsets.push_back(offset);
}
-(void)updatePositions:(const vec2&)panePosition {
    unsigned int numObjects = [_objects count];
    float pagesPos = _parent.position;
    for(unsigned int i = 0; i < numObjects; i++) {
        id<BounceSettingsWidget> widget = [_objects objectAtIndex:i];
        vec2 offset = _offsets[i];
        vec2 pos = panePosition+offset+vec2(_pageOffset+pagesPos, _verticalPos);

        [widget setPosition:pos];
    }
}

-(void)dealloc {
    [_objects release];
    [super dealloc];
}
@end

@implementation BounceSettingsSimulation

@synthesize pane = _pane;

-(void)setupFrictionSlider {
    CGSize dimensions = self.arena.dimensions;

    float upi = [[BounceConstants instance] unitsPerInch];
    
    NSArray *labels = [NSArray arrayWithObjects:@"Frictionless", @"Smooth", @"Coarse", @"Rough", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],
                       [NSNumber numberWithFloat:.1],
                       [NSNumber numberWithFloat:.5],
                       [NSNumber numberWithFloat:.9], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:2];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .3*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedFrictionSlider:);
    slider.padding = .07*dimensions.width;

    [slider addToSimulation:self];
    
    _frictionSlider = slider;
}

-(void)setupVelLimitSlider {
    CGSize dimensions = self.arena.dimensions;

    float upi = [[BounceConstants instance] unitsPerInch];
    
    NSArray *labels = [NSArray arrayWithObjects:@"Stopped", @"Slow", @"Fast", @"Very Fast", @"No Limit", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],
                       [NSNumber numberWithFloat:1],
                       [NSNumber numberWithFloat:10],
                       [NSNumber numberWithFloat:40],
                       [NSNumber numberWithFloat:999999], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:2];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .3*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedVelLimitSlider:);
    slider.padding = .07*dimensions.width;

    [slider addToSimulation:self];
    
    _velLimitSlider = slider;
}


-(void)setupDampingSlider {
    CGSize dimensions = self.arena.dimensions;

    float upi = [[BounceConstants instance] unitsPerInch];
    
    NSArray *labels = [NSArray arrayWithObjects:@"Vacuum", @"Air", @"Water", @"Syrup", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1],
                       [NSNumber numberWithFloat:.9],
                       [NSNumber numberWithFloat:.01],
                       [NSNumber numberWithFloat:.001], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:0];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .3*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedDampingSlider:);
    slider.padding = .07*dimensions.width;

    [slider addToSimulation:self];
    
    _dampingSlider = slider;
}

-(void)setupShapesSlider {
    CGSize dimensions = self.arena.dimensions;

    float upi = [[BounceConstants instance] unitsPerInch];

    NSArray *labels = [NSArray arrayWithObjects:@"Circle", @"Square", @"Triangle", @"Pentagon", @"Star", @"Rectangle", @"Capsule", @"Note", @"Random", nil];
    NSArray *values = [NSArray arrayWithObjects:[[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_BALL],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_SQUARE],                     
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_TRIANGLE],                       
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_PENTAGON],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_STAR],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_RECTANGLE],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_CAPSULE],
                       [[BounceShapeGenerator alloc] initWithBounceShape:BOUNCE_NOTE],
                       [[BounceRandomShapeGenerator alloc] init], nil];
    
    for(BounceShapeGenerator *v in values) {
        [v release];
    }
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    slider.handle.bounceShape = [slider.value bounceShape];
    slider.handle.size = .145*dimensions.height;
    slider.handle.secondarySize = .145*dimensions.height*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .3*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedShapesSlider:);
    slider.padding = .05*dimensions.width;

    [slider addToSimulation:self];
    
    _shapesSlider = slider;
}

-(void)setupColorSlider {
    CGSize dimensions = self.arena.dimensions;

    float upi = [[BounceConstants instance] unitsPerInch];
    FSATextureManager *texManager = [FSATextureManager instance];
    
    NSArray *labels = [NSArray arrayWithObjects:@"Pastel", @"Red", @"Orange", @"Yellow", @"Green", @"Blue", @"Purple", @"Gray", @"Random", nil];
    NSArray *values = [NSArray arrayWithObjects:[[BouncePastelColorGenerator alloc] init],
                       [[BounceRedColorGenerator alloc] init],
                       [[BounceOrangeColorGenerator alloc] init],
                       [[BounceYellowColorGenerator alloc] init],
                       [[BounceGreenColorGenerator alloc] init],
                       [[BounceBlueColorGenerator alloc] init],
                       [[BouncePurpleColorGenerator alloc] init],
                       [[BounceGrayColorGenerator alloc] init], 
                       [[BounceRandomColorGenerator alloc] init], nil];
    
    for(BounceColorGenerator *c in values) {
        [c release];
    }
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    slider.handle.bounceShape = BOUNCE_BALL;
    slider.handle.size = .145*dimensions.height;
    slider.handle.secondarySize = .145*dimensions.height*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .3*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedColorSlider:);
    slider.padding = .05*dimensions.width;

    [slider addToSimulation:self];
    
    _colorSlider = slider;
}

-(void)setupPatternsSlider {
    CGSize dimensions = self.arena.dimensions;
    float upi = [[BounceConstants instance] unitsPerInch];
    FSATextureManager *texManager = [FSATextureManager instance];
    
    NSArray *labels = [NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", nil];
    NSArray *values = [NSArray arrayWithObjects:
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"spiral.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"checkered.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"plasma.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"sections.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"weave.jpg"]], 
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"stripes.jpg"]], 
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"squares.jpg"]],    
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"black.jpg"]],
                       [[BouncePatternGenerator alloc] initWithPatternTexture:[texManager getTexture:@"white.jpg"]], 
                       [[BounceRandomPatternGenerator alloc] init], nil];
    
    for(id v in values) {
        [v release];
    }
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    slider.handle.bounceShape = BOUNCE_BALL;
    slider.handle.size = .145*dimensions.height;
    slider.handle.secondarySize = .145*dimensions.height*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .3*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [slider.value patternTexture];
    slider.delegate = self;
    slider.selector = @selector(changedPatternsSlider:);
    slider.padding = .05*dimensions.width;

    
    [slider addToSimulation:self];
    
    _patternsSlider = slider;
}

-(void)setupMinSizeSlider {
    CGSize dimensions = self.arena.dimensions;
        
    NSArray *labels = [NSArray arrayWithObjects:@"", @"", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.03],
                       [NSNumber numberWithFloat:.5], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:0];
    slider.handle.bounceShape = BOUNCE_BALL;
    slider.param = .04255;

    slider.handle.size = [slider.value floatValue];
    slider.handle.secondarySize = [slider.value floatValue]*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .15*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
  //  slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedMinSizeSlider:);
    slider.padding = .05*dimensions.width;

    [slider addToSimulation:self];
    
    _minSizeSlider = slider;
}

-(void)setupMaxSizeSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"", @"", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.03],
                       [NSNumber numberWithFloat:.5], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:1];

    slider.handle.bounceShape = BOUNCE_BALL;
    slider.param = .468085;

    slider.handle.size = [slider.value floatValue];
    slider.handle.secondarySize = [slider.value floatValue]*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;

    
    slider.track.position = vec2(-2,0);
    slider.track.size = .15*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
   // slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedMaxSizeSlider:);
    slider.padding = .05*dimensions.width;

    [slider addToSimulation:self];
    
    _maxSizeSlider = slider;
}

-(BounceSlider*)allNewSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"All", @"New", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                       [NSNumber numberWithBool:NO], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    
    slider.handle.position = vec2(-2,0);
    slider.handle.bounceShape = BOUNCE_BALL;    
    slider.handle.size = .1*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .05*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.padding = .015*dimensions.width;
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    
    [slider addToSimulation:self];
    
    return slider;
}

-(void)changedAllNewBouncinessSlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [self changedBouncinessSlider:_bouncinessSlider];
    }
}

-(void)changedAllNewColorSlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [self changedColorSlider:_colorSlider];
    }
}

-(void)changedAllNewDampingSlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [self changedDampingSlider:_dampingSlider];
    }
}

-(void)changedAllNewFrictionSlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [self changedFrictionSlider:_frictionSlider];
    }
}

-(void)changedAllNewGravitySlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [self changedGravitySlider:_gravitySlider];
    }
}

-(void)changedAllNewPatternsSlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [self changedPatternsSlider:_patternsSlider];
    }
}

-(void)changedAllNewShapesSlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [self changedShapesSlider:_shapesSlider];
    }
}

-(void)changedAllNewSizeSlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [_simulation clampSize]; 
    }
}

-(void)changedAllNewVelLimitSlider:(BounceSlider *)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if([slider.value boolValue]) {
        [self changedVelLimitSlider:_velLimitSlider];
    }
}

-(void)setupAllNewSliders {
    _allNewColorSlider = [self allNewSlider];
    _allNewColorSlider.selector = @selector(changedAllNewColorSlider:);
    
    _allNewBouncinessSlider = [self allNewSlider];
    _allNewBouncinessSlider.selector = @selector(changedAllNewBouncinessSlider:);
    
    _allNewDampingSlider = [self allNewSlider];
    _allNewDampingSlider.selector = @selector(changedAllNewDampingSlider:);
    
    _allNewFrictionSlider = [self allNewSlider];
    _allNewFrictionSlider.selector = @selector(changedAllNewFrictionSlider:);
    
    _allNewGravitySlider = [self allNewSlider];
    _allNewGravitySlider.selector = @selector(changedAllNewGravitySlider:);
    
    _allNewPatternsSlider = [self allNewSlider];
    _allNewPatternsSlider.selector = @selector(changedAllNewPatternsSlider:);
    
    _allNewShapesSlider = [self allNewSlider];
    _allNewShapesSlider.selector = @selector(changedAllNewShapesSlider:);
    
    _allNewSizeSlider = [self allNewSlider];
    _allNewSizeSlider.selector = @selector(changedAllNewSizeSlider:);
    
    _allNewVelLimitSlider = [self allNewSlider];
    _allNewVelLimitSlider.selector = @selector(changedAllNewVelLimitSlider:);
}

-(void)setupPaintModeSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Paint Mode", @"Assign Mode", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                       [NSNumber numberWithBool:NO], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    
    slider.handle.position = vec2(-2,0);
    slider.handle.bounceShape = BOUNCE_CAPSULE;    
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .1*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.padding = .015*dimensions.width;
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedPaintModeSlider:);
    
    [slider addToSimulation:self];
    
    _paintModeSlider = slider;
}

-(void)setupGrabRotatesSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Spin Mode", @"Move Mode", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:YES],
                       [NSNumber numberWithBool:NO], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    
    slider.handle.position = vec2(-2,0);
    slider.handle.bounceShape = BOUNCE_CAPSULE;    
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .1*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.padding = .015*dimensions.width;
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedGrabRotatesSlider:);
    
    [slider addToSimulation:self];
    
    _grabRotatesSlider = slider;
}

-(void)setupPaneUnlockedSlider {
    CGSize dimensions = self.arena.dimensions;
    
    NSArray *labels = [NSArray arrayWithObjects:@"Pane Locked", @"Pane Unlocked", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithBool:NO],
                       [NSNumber numberWithBool:YES], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initWithLabels:labels values:values index:0];
    
    slider.handle.position = vec2(-2,0);
    slider.handle.bounceShape = BOUNCE_CAPSULE;    
    slider.handle.size = .2*dimensions.height;
    slider.handle.secondarySize = .1*dimensions.height;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .1*dimensions.width;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.padding = .015*dimensions.width;
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    slider.selector = @selector(changedPaneUnlockedSlider:);
    
    [slider addToSimulation:self];
    
    _paneUnlockedSlider = slider;
}

-(void)setupPages {
    CGSize dimensions = self.arena.dimensions;
    _pages = [[BounceSettingsPages alloc] initWithPageWidth:dimensions.width pageHeight:dimensions.height];
    float spacing = .15 *dimensions.height;
    float tspacing = .25 *dimensions.height;
    
    BounceSettingsPage *page = [[BounceSettingsPage alloc] init];
    [page addWidget:_allNewShapesSlider offset:vec2(-.35*dimensions.width, tspacing)];
    [page addWidget:_shapesSlider offset:vec2(.1*dimensions.width,tspacing)];
    [page addWidget:_allNewPatternsSlider offset:vec2(-.35*dimensions.width, -spacing)];
    [page addWidget:_patternsSlider offset:vec2(.1*dimensions.width,-spacing)];

    [_pages addPage:page];
    [page release];

    
    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_allNewColorSlider offset:vec2(-.35*dimensions.width, tspacing)];
    [page addWidget:_colorSlider offset:vec2(.1*dimensions.width,tspacing)];
    [page addWidget:_allNewSizeSlider offset:vec2(-.35*dimensions.width, -spacing)];
    [page addWidget:_minSizeSlider offset:vec2(-.05*dimensions.width, -spacing)];
    [page addWidget:_maxSizeSlider offset:vec2(.25*dimensions.width, -spacing)];
    [_pages addPage:page];
    [page release];
     

    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_allNewBouncinessSlider offset:vec2(-.35*dimensions.width, tspacing)];
    [page addWidget:_bouncinessSlider offset:vec2(.1*dimensions.width,tspacing)];
    [page addWidget:_allNewGravitySlider offset:vec2(-.35*dimensions.width, -spacing)];
    [page addWidget:_gravitySlider offset:vec2(.1*dimensions.width,-spacing)];
    [_pages addPage:page];
    [page release];
  
    
    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_allNewDampingSlider offset:vec2(-.35*dimensions.width, tspacing)];
    [page addWidget:_dampingSlider offset:vec2(.1*dimensions.width,tspacing)];
    [page addWidget:_allNewVelLimitSlider offset:vec2(-.35*dimensions.width, -spacing)];
    [page addWidget:_velLimitSlider offset:vec2(.1*dimensions.width,-spacing)];
    [_pages addPage:page];
    [page release];

    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_allNewFrictionSlider offset:vec2(-.35*dimensions.width, (tspacing-spacing)*.5)];
    [page addWidget:_frictionSlider offset:vec2(.1*dimensions.width,(tspacing-spacing)*.5)];
    [_pages addPage:page];
    [page release];
    
    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_paintModeSlider offset:vec2(-.2*dimensions.width,tspacing)];
    [page addWidget:_grabRotatesSlider offset:vec2(.2*dimensions.width,tspacing)];
    [page addWidget:_paneUnlockedSlider offset:vec2(-.2*dimensions.width,-spacing)];

    [_pages addPage:page];
    [page release];
     
}

-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    
    if(self) {
        CGSize dimensions = self.arena.dimensions;
        float upi = [[BounceConstants instance] unitsPerInch];
        NSArray *bouncinessLabels = [NSArray arrayWithObjects:@"Bouncy", @"Springy", @"Squishy", @"Rigid", nil];
        NSArray *bouncinessValues = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithFloat:.9], [NSNumber numberWithFloat:.5], [NSNumber numberWithFloat:0], nil];
        _bouncinessSlider = [[BounceSlider alloc] initContinuousWithLabels:bouncinessLabels values:bouncinessValues index:1];
        _bouncinessSlider.handle.bounceShape = BOUNCE_CAPSULE;
        _bouncinessSlider.handle.size = .2*dimensions.height;
        _bouncinessSlider.handle.secondarySize = .1*dimensions.height;
        _bouncinessSlider.handle.isStationary = NO;

        _bouncinessSlider.handle.sound = [[BounceNoteManager instance] getRest];

        _bouncinessSlider.track.position = vec2(-2,0);
        _bouncinessSlider.track.angle = PI;
        _bouncinessSlider.track.size = .3*dimensions.width;
        _bouncinessSlider.track.isStationary = NO;

        _bouncinessSlider.track.sound = [[BounceNoteManager instance] getRest];
        
        _bouncinessSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:_bouncinessSlider.label];

        _bouncinessSlider.delegate = self;
        _bouncinessSlider.selector = @selector(changedBouncinessSlider:);
        _bouncinessSlider.padding = .07*dimensions.width;

        [_bouncinessSlider addToSimulation:self];
        
        NSArray *gravityLabels = [NSArray arrayWithObjects:@"Weightless", @"Airy", @"Floaty", @"Light", @"Normal", @"Heavy", nil];
        NSArray *gravityValues = [NSArray arrayWithObjects:
                                  [NSNumber numberWithFloat:0], 
                                  [NSNumber numberWithFloat:.05], 
                                  [NSNumber numberWithFloat:1], 
                                  [NSNumber numberWithFloat:4], 


                                  [NSNumber numberWithFloat:10], 
                                  [NSNumber numberWithFloat:40],
                                  nil];
        _gravitySlider = [[BounceSlider alloc] initContinuousWithLabels:gravityLabels values:gravityValues index:4];
        _gravitySlider.handle.bounceShape = BOUNCE_CAPSULE;
        _gravitySlider.handle.size = .2*dimensions.height;
        _gravitySlider.handle.secondarySize = .1*dimensions.height;
        _gravitySlider.handle.sound = [[BounceNoteManager instance] getRest];
        _gravitySlider.handle.isStationary = NO;


        _gravitySlider.track.position = vec2(-2,0);
        _gravitySlider.track.size = .3*dimensions.width;
        _gravitySlider.track.sound = [[BounceNoteManager instance] getRest];
        _gravitySlider.track.isStationary = NO;

        
        _gravitySlider.handle.patternTexture = [[FSATextureManager instance] getTexture:_gravitySlider.label];

        
        _gravitySlider.delegate = self;
        _gravitySlider.selector = @selector(changedGravitySlider:);
        _gravitySlider.padding = .07*dimensions.width;

        [_gravitySlider addToSimulation:self];
        
        [self setupShapesSlider];
        [self setupPatternsSlider];
        [self setupDampingSlider];
        [self setupVelLimitSlider];
        [self setupFrictionSlider];
        [self setupColorSlider];
        [self setupMinSizeSlider];
        [self setupMaxSizeSlider];
        [self setupAllNewSliders];
        [self setupPaintModeSlider];
        [self setupGrabRotatesSlider];
        [self setupPaneUnlockedSlider];
        [self setupPages];
        
        unsigned int numPages = [_pages count];
        NSMutableArray *pageLabels = [NSMutableArray arrayWithCapacity:[_pages count]]; 
        for(int i = 0; i < numPages; i++) {
            [pageLabels addObject:@""];
        }
        _pageSlider = [[BounceSlider alloc] initWithLabels:pageLabels index:0];
        _pageSlider.padding = .08*dimensions.width+.005;
        _pageSlider.handle.bounceShape = BOUNCE_CAPSULE;
        _pageSlider.handle.size = .08*dimensions.width;
        _pageSlider.handle.secondarySize = .01;
        _pageSlider.handle.sound = [[BounceNoteManager instance] getRest];
        _pageSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
        _pageSlider.handle.isStationary = NO;
        
        
        _pageSlider.track.position = vec2(-2,0);
        _pageSlider.track.size = .35*dimensions.width;
        _pageSlider.track.secondarySize = .015;
        
        _pageSlider.track.sound = [[BounceNoteManager instance] getRest];
        _pageSlider.track.patternTexture = [[FSATextureManager instance] getTexture:@"black.jpg"];
        _pageSlider.track.isStationary = NO;
        _pageSlider.handle.renderable.blendMode = GL_ONE;
        _pageSlider.track.renderable.blendMode = GL_ONE;
        
        _pageSlider.delegate = self;
        _pageSlider.selector = @selector(changedPageSlider:);
        [_pageSlider addToSimulation:self];
    }
    
    return self;
}

-(BOOL)respondsToGesture:(void *)uniqueId {
    if(_sliding == uniqueId) {
        return YES;
    }
    return [super respondsToGesture:uniqueId];
}

-(void)flick:(void *)uniqueId at:(const vec2 &)loc inDirection:(const vec2 &)dir time:(NSTimeInterval)time {
    
    if(_sliding == uniqueId) {
        BOOL horizontalFlick = (fabsf(dir.x) > fabsf(dir.y));
        if(horizontalFlick) {
            if(dir.x > 0) {
                [_pages previousPage];
            } else if(dir.x < 0) {
                [_pages nextPage];
            }
        }
        _pageSlider.index = _pages.currentPage;
    }
    [super flick:uniqueId at:loc inDirection:dir time:time];
}

-(void)beginDrag:(void *)uniqueId at:(const vec2 &)loc {
    if(!_sliding && ![self objectAt:loc]) {
        _sliding = uniqueId;
        _beginSlidingPos = loc;
    }
    [super beginDrag:uniqueId at:loc];
}

-(void)drag:(void *)uniqueId at:(const vec2 &)loc {
    if(_sliding == uniqueId) {
        float horizontal = loc.x-_beginSlidingPos.x;
        float vertical = loc.y-_beginSlidingPos.y;
        _pages.touchOffset = horizontal;
       // _pages.scroll = vertical;
    }

    [super drag:uniqueId at:loc];
}

-(void)endDrag:(void *)uniqueId at:(const vec2 &)loc {
    if(_sliding == uniqueId) {
        CGSize dimensions = self.arena.dimensions;
        float horizontal = loc.x-_beginSlidingPos.x;
        float vertical = loc.y-_beginSlidingPos.y;
       // _pages.scroll = vertical;
       // [_pages finalizeScroll];
        
        if(horizontal > dimensions.width*.5) {
            [_pages previousPage];
        } else if(horizontal < -dimensions.width*.5) {
            [_pages nextPage];
        }
        _pageSlider.index = _pages.currentPage;

        _pages.touchOffset = 0;
        _sliding = 0;
    }
    [super endDrag:uniqueId at:loc];
}

-(void)cancelDrag:(void *)uniqueId at:(const vec2 &)loc {
    if(_sliding == uniqueId) {
        _sliding = 0;
        _pages.touchOffset = 0;
      //  [_pages finalizeScroll];
    }
    [super cancelDrag:uniqueId at:loc];
}

-(void)changedBouncinessSlider:(BounceSlider *)slider {
    [BounceSettings instance].bounciness = [slider.value floatValue];
    if([_allNewBouncinessSlider.value boolValue]) {
        [_simulation setBounciness:[slider.value floatValue]];
    }
    [_simulation.arena setBounciness:[slider.value floatValue]];
    [_pane setBounciness:[slider.value floatValue]];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    }
}

-(void)changedGravitySlider:(BounceSlider *)slider {
    [BounceSettings instance].gravityScale = [slider.value floatValue];
    if([_allNewGravitySlider.value boolValue]) {
        [_simulation setGravityScale:[slider.value floatValue]];
    }
    [_pane setGravityScale:[slider.value floatValue]];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    }
}

-(void)changedPatternsSlider:(BounceSlider *)slider {
    BouncePatternGenerator *patternGen = slider.value;
    [BounceSettings instance].patternTextureGenerator = patternGen;
    [slider.handle.renderable burst:5];
    _minSizeSlider.handle.patternTexture = [patternGen patternTexture];
    _maxSizeSlider.handle.patternTexture = [patternGen patternTexture];
    if([patternGen isKindOfClass:[BounceRandomPatternGenerator class]]) {
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"Random"];
    } else {
        slider.handle.patternTexture = [patternGen patternTexture];
    }
    
    if([_allNewPatternsSlider.value boolValue]) {
        [_simulation randomizePattern];
    }
}

-(void)changedShapesSlider:(BounceSlider *)slider {
    BounceShapeGenerator* shapeGen = slider.value;
    [BounceSettings instance].bounceShapeGenerator = shapeGen;
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.handle.bounceShape = [shapeGen bounceShape];
    _patternsSlider.handle.bounceShape = [shapeGen bounceShape];
    _colorSlider.handle.bounceShape = [shapeGen bounceShape];
    _maxSizeSlider.handle.bounceShape = [shapeGen bounceShape];
    _minSizeSlider.handle.bounceShape = [shapeGen bounceShape];
    if([_allNewShapesSlider.value boolValue]) {
        [_simulation randomizeShape];
    }
    [_pane randomizeShape];
}

-(void)changedDampingSlider:(BounceSlider *)slider {
    [BounceSettings instance].damping = [slider.value floatValue];
    if([_allNewDampingSlider.value boolValue]) {
        [_simulation setDamping:[slider.value floatValue]];
    }
    [_pane setDamping:[slider.value floatValue]];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    }
}

-(void)changedVelLimitSlider:(BounceSlider *)slider {
    [BounceSettings instance].velocityLimit = [slider.value floatValue];
    if([_allNewVelLimitSlider.value boolValue]) {
        [_simulation setVelocityLimit:[slider.value floatValue]];
    }
    [_pane setVelocityLimit:[slider.value floatValue]];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    } 
}

-(void)changedFrictionSlider:(BounceSlider *)slider {
    [BounceSettings instance].friction = [slider.value floatValue];
    if([_allNewFrictionSlider.value boolValue]) {
        [_simulation setFriction:[slider.value floatValue]];
    }
    [_simulation.arena setFriction:[slider.value floatValue]];
    [_pane setFriction:[slider.value floatValue]];
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    if(slider.lastLabel != slider.label) {
        [slider.handle.renderable burst:5];
    } 
}

-(void)changedColorSlider:(BounceSlider *)slider {
    [BounceSettings instance].colorGenerator = slider.value;
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    [slider.handle.renderable burst:5]; 
    [_pane randomizeColor];
    if([_allNewColorSlider.value boolValue]) {
        [_simulation randomizeColor];
    }
}

-(void)changedMinSizeSlider:(BounceSlider *)slider {
    float size = [slider.value floatValue];
    float maxSize = [_maxSizeSlider.value floatValue];
    
    slider.handle.size = size;
    slider.handle.secondarySize = size*GOLDEN_RATIO;
    
    if(size > maxSize) {
        _maxSizeSlider.param = _minSizeSlider.param;
    }
    [BounceSettings instance].minSize = size;
    
    if([_allNewSizeSlider.value boolValue]) {
        [_simulation clampSize];
    }
}

-(void)changedMaxSizeSlider:(BounceSlider *)slider {
    float size = [slider.value floatValue];
    float minSize = [_minSizeSlider.value floatValue];
    
    slider.handle.size = size;
    slider.handle.secondarySize = size*GOLDEN_RATIO;
    
    if(size < minSize) {
        _minSizeSlider.param = _maxSizeSlider.param;
    }
    [BounceSettings instance].maxSize = size;
    
    if([_allNewSizeSlider.value boolValue]) {
        [_simulation clampSize];
    }
}

-(void)changedPageSlider:(BounceSlider *)slider {
    _pages.currentPage = slider.index;

}

-(void)changedPaintModeSlider:(BounceSlider*)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    [BounceSettings instance].paintMode = [slider.value boolValue];
}

-(void)changedGrabRotatesSlider:(BounceSlider*)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    [BounceSettings instance].grabRotates = [slider.value boolValue];
}

-(void)changedPaneUnlockedSlider:(BounceSlider*)slider {
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    [BounceSettings instance].paneUnlocked = [slider.value boolValue];
    
    if([slider.value boolValue]) {
        _pane.object.springLoc = _pane.object.customSpringLoc;
    } else {
        _pane.object.springLoc = _pane.object.activeSpringLoc;
    }
}

-(void)changed: (BounceSlider*)slider {
    NSAssert(NO, @"all sliders in the settings simulation should have custom selectors\n");
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    
    CGSize dimensions = self.arena.dimensions;
    float spacing = .45 *dimensions.height;

    [_pageSlider setPosition:pos-vec2(0,spacing)];
     
    [_pages updatePositions:pos];

}

-(void)next {
    [super next];
    [_bouncinessSlider step:_dt];
    [_gravitySlider step:_dt];
    [_pageSlider step:_dt];
    [_shapesSlider step:_dt];
    [_patternsSlider step:_dt];
    [_dampingSlider step:_dt];
    [_velLimitSlider step:_dt];
    [_frictionSlider step:_dt];
    [_colorSlider step:_dt];
    [_minSizeSlider step:_dt];
    [_maxSizeSlider step:_dt];
    [_allNewBouncinessSlider step:_dt];
    [_allNewGravitySlider step:_dt];
    [_allNewShapesSlider step:_dt];
    [_allNewPatternsSlider step:_dt];
    [_allNewDampingSlider step:_dt];
    [_allNewVelLimitSlider step:_dt];
    [_allNewFrictionSlider step:_dt];
    [_allNewColorSlider step:_dt];
    [_allNewSizeSlider step:_dt];
    
    [_paintModeSlider step:_dt];
    [_grabRotatesSlider step:_dt];
    [_paneUnlockedSlider step:_dt];

    BounceSettings *settings = [BounceSettings instance];

    vec2 l = _colorSlider.handle.position;
    float t = [[NSProcessInfo processInfo] systemUptime];
    _colorSlider.handle.color = [settings.colorGenerator perlinColorFromLocation:l time:t];
/*
    _timeSinceRandomsRefresh += _dt;
    
    if(_timeSinceRandomsRefresh > .5) {
        if([settings.bounceShapeGenerator isKindOfClass:[BounceRandomShapeGenerator class]]) {
            _shapesSlider.handle.bounceShape = [settings.bounceShapeGenerator bounceShape];
            _patternsSlider.handle.bounceShape = [settings.bounceShapeGenerator bounceShape];
            _colorSlider.handle.bounceShape = [settings.bounceShapeGenerator bounceShape];
        }
        _timeSinceRandomsRefresh = 0;
    } */
    [_pages step:_dt];
}

-(void)drawRectangle {
    vec2 pos = self.arena.position;
    
    CGSize dimensions = self.arena.dimensions;
    
    float top = pos.y+dimensions.height*.5;
    float bottom = pos.y-dimensions.height*.5;
    float left = pos.x-dimensions.width*.5;
    float right = pos.x+dimensions.width*.5;
    
    vec2 verts[4];
    verts[0] = vec2(right, top);
    verts[1] = vec2(left, top);
    verts[2] = vec2(left, bottom);
    verts[3] = vec2(right, bottom);
    
    unsigned int indices[6];
    
    FSAShader *shader = [[FSAShaderManager instance] getShader:@"ColorShader"];
    [shader setPtr:verts forAttribute:@"position"];
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 0;
    indices[4] = 2;
    indices[5] = 3;
    
    vec4 color(0,0,0,1);
    [shader setPtr:&color forUniform:@"color"];
    
    [shader enable];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, indices);
    [shader disable];
}

-(void)draw {
    glEnable(GL_STENCIL_TEST);
    
    glStencilFunc(GL_ALWAYS, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ZERO, GL_ONE);
    [self drawRectangle];
    glDisable(GL_BLEND);
    
    glStencilFunc(GL_EQUAL, 1, 1);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
    
    [super draw];
    
    [_allNewColorSlider draw];
    [_allNewBouncinessSlider.track draw];
    [_allNewDampingSlider draw];
    [_allNewFrictionSlider draw];
    [_allNewGravitySlider.track draw];
    [_allNewPatternsSlider draw];
    [_allNewShapesSlider draw];
    [_allNewSizeSlider draw];
    [_allNewVelLimitSlider draw];

    [_shapesSlider draw];
    [_patternsSlider draw];
    [_dampingSlider draw];
    [_velLimitSlider draw];
    [_frictionSlider draw];
    [_minSizeSlider.track draw];
    [_maxSizeSlider.track draw];
    [_colorSlider.track draw];
    [_gravitySlider.track draw];
    [_bouncinessSlider.track draw];

    [_minSizeSlider.handle draw];
    [_maxSizeSlider.handle draw];
    [_colorSlider.handle draw];
    [_bouncinessSlider.handle draw];
    [_gravitySlider.handle draw];
    [_allNewGravitySlider.handle draw];
    [_allNewBouncinessSlider.handle draw];
    
    [_paintModeSlider draw];
    [_grabRotatesSlider draw];
    [_paneUnlockedSlider draw];
    
    [_pageSlider draw];

    
    glDisable(GL_STENCIL_TEST);

}

-(void)dealloc {
    [_bouncinessSlider release];
    [_gravitySlider release];
    [_pageSlider release];
    [_shapesSlider release];
    [_patternsSlider release];
    [_dampingSlider release];
    [_frictionSlider release];
    [_velLimitSlider release];
    [_colorSlider release];
    [_allNewBouncinessSlider release];
    [_allNewColorSlider release];
    [_allNewDampingSlider release];
    [_allNewFrictionSlider release];
    [_allNewGravitySlider release];
    [_allNewPatternsSlider release];
    [_allNewShapesSlider release];
    [_allNewSizeSlider release];
    [_allNewVelLimitSlider release];
    
    [_pages release];

    [super dealloc];
}
@end

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

@synthesize position = _pos;
@synthesize velocity = _vel;
@synthesize currentPage = _curPage;
@synthesize touchOffset = _touchOffset;

-(id)initWithPageWidth:(float)width {
    self = [super init];
    if(self) {
        _pageWidth = width;
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
        [self setCurrentPage:_curPage+1];
    }
}
-(void)previousPage {
    if(_curPage > 0) {
        [self setCurrentPage:_curPage-1];
    }
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

-(void)addWidget:(id)widget offset:(const vec2&)offset {
    [_objects addObject:widget];
    _offsets.push_back(offset);
}
-(void)updatePositions:(const vec2&)panePosition {
    unsigned int numObjects = [_objects count];
    float pagesPos = _parent.position;
    for(unsigned int i = 0; i < numObjects; i++) {
        id<BounceSettingsWidget> widget = [_objects objectAtIndex:i];
        vec2 offset = _offsets[i];
        vec2 pos = panePosition+offset+vec2(_pageOffset+pagesPos, 0);

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
    float upi = [[BounceConstants instance] unitsPerInch];
    
    NSArray *labels = [NSArray arrayWithObjects:@"Frictionless", @"Smooth", @"Coarse", @"Rough", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],
                       [NSNumber numberWithFloat:.1],
                       [NSNumber numberWithFloat:.5],
                       [NSNumber numberWithFloat:.9], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:2];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*upi;
    slider.handle.secondarySize = .1*upi;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .5*upi;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    
    [slider addToSimulation:self];
    
    _frictionSlider = slider;
}

-(void)setupVelLimitSlider {
    float upi = [[BounceConstants instance] unitsPerInch];
    
    NSArray *labels = [NSArray arrayWithObjects:@"Stopped", @"Slow", @"Fast", @"Very Fast", @"No Limit", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0],
                       [NSNumber numberWithFloat:1],
                       [NSNumber numberWithFloat:10],
                       [NSNumber numberWithFloat:40],
                       [NSNumber numberWithFloat:999999], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:2];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*upi;
    slider.handle.secondarySize = .1*upi;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .5*upi;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    
    [slider addToSimulation:self];
    
    _velLimitSlider = slider;
}


-(void)setupDampingSlider {
    float upi = [[BounceConstants instance] unitsPerInch];
    
    NSArray *labels = [NSArray arrayWithObjects:@"Vacuum", @"Air", @"Water", @"Syrup", nil];
    NSArray *values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1],
                       [NSNumber numberWithFloat:.9],
                       [NSNumber numberWithFloat:.01],
                       [NSNumber numberWithFloat:.001], nil];
    
    BounceSlider *slider = [[BounceSlider alloc] initContinuousWithLabels:labels values:values index:0];
    slider.handle.bounceShape = BOUNCE_CAPSULE;
    slider.handle.size = .2*upi;
    slider.handle.secondarySize = .1*upi;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .5*upi;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    
    [slider addToSimulation:self];
    
    _dampingSlider = slider;
}

-(void)setupShapesSlider {
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
    slider.handle.size = .145*upi;
    slider.handle.secondarySize = .145*upi*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .5*upi;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    
    [slider addToSimulation:self];
    
    _shapesSlider = slider;
}

-(void)setupColorSlider {
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
    slider.handle.size = .145*upi;
    slider.handle.secondarySize = .145*upi*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .5*upi;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
    slider.delegate = self;
    
    [slider addToSimulation:self];
    
    _colorSlider = slider;
}

-(void)setupPatternsSlider {
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
    slider.handle.size = .145*upi;
    slider.handle.secondarySize = .145*upi*GOLDEN_RATIO;
    slider.handle.sound = [[BounceNoteManager instance] getRest];
    slider.handle.isStationary = NO;
    
    slider.track.position = vec2(-2,0);
    slider.track.size = .5*upi;
    slider.track.sound = [[BounceNoteManager instance] getRest];
    
    slider.handle.patternTexture = [slider.value patternTexture];
    slider.delegate = self;
    
    [slider addToSimulation:self];
    
    _patternsSlider = slider;
}

-(void)setupPages {
    CGSize dimensions = self.arena.dimensions;
    _pages = [[BounceSettingsPages alloc] initWithPageWidth:dimensions.width];
    float upi = [[BounceConstants instance] unitsPerInch];
    float spacing = .3 *upi;
    
    BounceSettingsPage *page = [[BounceSettingsPage alloc] init];
    [page addWidget:_shapesSlider offset:vec2(0,spacing)];
    [page addWidget:_patternsSlider offset:vec2(0,0)];
    [_pages addPage:page];
    [page release];
    
    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_colorSlider offset:vec2(0,spacing)];
    [_pages addPage:page];
    [page release];

    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_bouncinessSlider offset:vec2(0,spacing)];
    [page addWidget:_gravitySlider offset:vec2(0,0)];
    [_pages addPage:page];
    [page release];
    
    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_dampingSlider offset:vec2(0,spacing)];
    [page addWidget:_velLimitSlider offset:vec2(0,0)];
    [_pages addPage:page];
    [page release];

    page = [[BounceSettingsPage alloc] init];
    [page addWidget:_frictionSlider offset:vec2(0,spacing)];
    [_pages addPage:page];
    [page release];
}

-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    
    if(self) {
        float upi = [[BounceConstants instance] unitsPerInch];
        NSArray *bouncinessLabels = [NSArray arrayWithObjects:@"Bouncy", @"Springy", @"Squishy", @"Rigid", nil];
        NSArray *bouncinessValues = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1],[NSNumber numberWithFloat:.9], [NSNumber numberWithFloat:.5], [NSNumber numberWithFloat:0], nil];
        _bouncinessSlider = [[BounceSlider alloc] initContinuousWithLabels:bouncinessLabels values:bouncinessValues index:1];
        _bouncinessSlider.handle.bounceShape = BOUNCE_CAPSULE;
        _bouncinessSlider.handle.size = .2*upi;
        _bouncinessSlider.handle.secondarySize = .1*upi;
        _bouncinessSlider.handle.sound = [[BounceNoteManager instance] getRest];

        _bouncinessSlider.track.position = vec2(-2,0);
        _bouncinessSlider.track.angle = PI;
        _bouncinessSlider.track.size = .5*upi;
        _bouncinessSlider.track.sound = [[BounceNoteManager instance] getRest];
        
        _bouncinessSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:_bouncinessSlider.label];

        _bouncinessSlider.delegate = self;
        
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
        _gravitySlider.handle.size = .2*upi;
        _gravitySlider.handle.secondarySize = .1*upi;
        _gravitySlider.handle.sound = [[BounceNoteManager instance] getRest];

        _gravitySlider.track.position = vec2(-2,0);
        _gravitySlider.track.size = .5*upi;
        _gravitySlider.track.sound = [[BounceNoteManager instance] getRest];
        
        _gravitySlider.handle.patternTexture = [[FSATextureManager instance] getTexture:_gravitySlider.label];

        
        _gravitySlider.delegate = self;
        [_gravitySlider addToSimulation:self];
        
        [self setupShapesSlider];
        [self setupPatternsSlider];
        [self setupDampingSlider];
        [self setupVelLimitSlider];
        [self setupFrictionSlider];
        [self setupColorSlider];
        [self setupPages];
        
        unsigned int numPages = [_pages count];
        NSMutableArray *pageLabels = [NSMutableArray arrayWithCapacity:[_pages count]]; 
        for(int i = 0; i < numPages; i++) {
            [pageLabels addObject:@""];
        }
        _pageSlider = [[BounceSlider alloc] initWithLabels:pageLabels index:0];
        _pageSlider.padding = .125*upi+.005;
        _pageSlider.handle.bounceShape = BOUNCE_CAPSULE;
        _pageSlider.handle.size = .125*upi;
        _pageSlider.handle.secondarySize = .01;
        _pageSlider.handle.sound = [[BounceNoteManager instance] getRest];
        _pageSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
        
        
        _pageSlider.track.position = vec2(-2,0);
        _pageSlider.track.size = .5*upi;
        _pageSlider.track.secondarySize = .015;
        
        _pageSlider.track.sound = [[BounceNoteManager instance] getRest];
        _pageSlider.track.patternTexture = [[FSATextureManager instance] getTexture:@"black.jpg"];
        
        _pageSlider.delegate = self;
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
        if(dir.x > 0) {
            [_pages previousPage];
        } else if(dir.x < 0) {
            [_pages nextPage];
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
        float length = loc.x-_beginSlidingPos.x;
        _pages.touchOffset = length;
    }

    [super drag:uniqueId at:loc];
}

-(void)endDrag:(void *)uniqueId at:(const vec2 &)loc {
    if(_sliding == uniqueId) {
        CGSize dimensions = self.arena.dimensions;
        float length = loc.x-_beginSlidingPos.x;
        if(length > dimensions.width*.5) {
            [_pages previousPage];
        } else if(length < -dimensions.width*.5) {
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
    }
    [super cancelDrag:uniqueId at:loc];
}

-(void)changed: (BounceSlider*)slider {
    if(slider == _bouncinessSlider) {
        [_simulation setBounciness:[slider.value floatValue]];
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
        if(slider.lastLabel != slider.label) {
            [slider.handle.renderable burst:5];
        }
    } else if(slider == _gravitySlider) {
        [_simulation setGravityScale:[slider.value floatValue]];
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
        if(slider.lastLabel != slider.label) {
            [slider.handle.renderable burst:5];
        }
    } else if(slider == _patternsSlider) {
        BouncePatternGenerator *patternGen = slider.value;
        [BounceSettings instance].patternTextureGenerator = patternGen;
        [slider.handle.renderable burst:5];
        if([patternGen isKindOfClass:[BounceRandomPatternGenerator class]]) {
            slider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"Random"];
        } else {
            slider.handle.patternTexture = [patternGen patternTexture];
        }
    } else if(slider == _shapesSlider) {
        BounceShapeGenerator* shapeGen = slider.value;
        [BounceSettings instance].bounceShapeGenerator = shapeGen;
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
        slider.handle.bounceShape = [shapeGen bounceShape];
        _patternsSlider.handle.bounceShape = [shapeGen bounceShape];
        _colorSlider.handle.bounceShape = [shapeGen bounceShape];
    } else if(slider == _dampingSlider) {
        [_simulation setDamping:[slider.value floatValue]];
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
        if(slider.lastLabel != slider.label) {
            [slider.handle.renderable burst:5];
        }
    } else if(slider == _velLimitSlider) {
        [_simulation setVelocityLimit:[slider.value floatValue]];
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
        if(slider.lastLabel != slider.label) {
            [slider.handle.renderable burst:5];
        }    
    } else if(slider == _frictionSlider) {
        [_simulation setFriction:[slider.value floatValue]];
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
        if(slider.lastLabel != slider.label) {
            [slider.handle.renderable burst:5];
        }    
    } else if(slider == _colorSlider) {
        [BounceSettings instance].colorGenerator = slider.value;
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];
        [slider.handle.renderable burst:5]; 
        [_pane randomizeColor];
        [_simulation randomizeColor];
    } else if(slider == _pageSlider) {
        _pages.currentPage = slider.index;
    }
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    
    float upi = [[BounceConstants instance] unitsPerInch];
    float spacing = .3 *upi;

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
    [_bouncinessSlider draw];
    [_gravitySlider draw];
    [_pageSlider draw];
    [_shapesSlider draw];
    [_patternsSlider draw];
    [_dampingSlider draw];
    [_velLimitSlider draw];
    [_frictionSlider draw];
    [_colorSlider draw];
    
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
    
    [_pages release];

    [super dealloc];
}
@end

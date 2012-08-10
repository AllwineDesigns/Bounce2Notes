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
#import "FSASoundManager.h"
#import "FSATextureManager.h"

@implementation BounceSettingsSimulation

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
        _bouncinessSlider.handle.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];

        _bouncinessSlider.track.position = vec2(-2,0);
        _bouncinessSlider.track.angle = PI;
        _bouncinessSlider.track.size = .5*upi;
        _bouncinessSlider.track.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
        
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
        _gravitySlider.handle.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];

        _gravitySlider.track.position = vec2(-2,0);
        _gravitySlider.track.size = .5*upi;
        _gravitySlider.track.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
        
        _gravitySlider.handle.patternTexture = [[FSATextureManager instance] getTexture:_gravitySlider.label];

        
        _gravitySlider.delegate = self;
        [_gravitySlider addToSimulation:self];
        
        NSArray *pageLabels = [NSArray arrayWithObjects:@"Page 1", @"Page 2", @"Page 3", @"Page 4", nil];

        _pageSlider = [[BounceSlider alloc] initWithLabels:pageLabels index:0];
        _pageSlider.padding = .125*upi+.005;
        _pageSlider.handle.bounceShape = BOUNCE_CAPSULE;
        _pageSlider.handle.size = .125*upi;
        _pageSlider.handle.secondarySize = .01;
        _pageSlider.handle.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
        _pageSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];

        
        _pageSlider.track.position = vec2(-2,0);
        _pageSlider.track.size = .5*upi;
        _pageSlider.track.secondarySize = .015;

        _pageSlider.track.sound = [[BounceNote alloc] initWithSound:[[FSASoundManager instance] getSound:@"rest"]];
        _pageSlider.track.patternTexture = [[FSATextureManager instance] getTexture:@"black.jpg"];
        
        _pageSlider.delegate = self;
        [_pageSlider addToSimulation:self];
    }
    
    return self;
}

-(void)changed: (BounceSlider*)slider {
    if(slider == _bouncinessSlider) {
        [_simulation setBounciness:[slider.value floatValue]];
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];

    } else if(slider == _gravitySlider) {
        [_simulation setGravityScale:[slider.value floatValue]];
        slider.handle.patternTexture = [[FSATextureManager instance] getTexture:slider.label];

    }
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    float upi = [[BounceConstants instance] unitsPerInch];
    float spacing = .3 *upi;
    [_bouncinessSlider setPosition:pos+vec2(0,spacing)];
    [_gravitySlider setPosition:pos];
    [_pageSlider setPosition:pos-vec2(0,spacing)];

}

-(void)next {
    [super next];
    [_bouncinessSlider step:_dt];
    [_gravitySlider step:_dt];
    [_pageSlider step:_dt];
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
    
    glDisable(GL_STENCIL_TEST);

}

-(void)dealloc {
    [_bouncinessSlider release];
    [_gravitySlider release];
    [_pageSlider release];

    [super dealloc];
}
@end

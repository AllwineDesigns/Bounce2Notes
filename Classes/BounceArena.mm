//
//  BounceArena.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceArena.h"
#import "BounceSimulation.h"

@implementation BounceArena

@synthesize dimensions = _dimensions;

-(id)initWithRect:(CGRect)rect {
    self = [super initStatic];
    
    if(self) {
        _dimensions = rect.size;
        
        vec2 tr(rect.size.width*.5, rect.size.height*.5);
        vec2 tl(-rect.size.width*.5, tr.y);
        vec2 bl(tl.x,-rect.size.height*.5);
        vec2 br(tr.x,bl.y);
        
        const float pad = 50;
        
        vec2 pad_tr(tr.x+pad, tr.y+pad);
        vec2 pad_tl(tl.x-pad, tl.y+pad);
        vec2 pad_bl(bl.x-pad, bl.y-pad);
        vec2 pad_br(br.x+pad, br.y-pad);
        
        [self addSegmentShapeWithRadius:pad fromA:pad_tr toB:pad_tl];
        [self addSegmentShapeWithRadius:pad fromA:pad_tl toB:pad_bl];
        [self addSegmentShapeWithRadius:pad fromA:pad_bl toB:pad_br];
        [self addSegmentShapeWithRadius:pad fromA:pad_br toB:pad_tr];
        
        [self setPosition:vec2(rect.origin.x+rect.size.width*.5, rect.origin.y+rect.size.height*.5)];
        
        for(int i = 0; i < _numShapes; i++) {
            cpShapeSetCollisionType(_shapes[i], WALL_TYPE);
            cpShapeSetFriction(_shapes[i],.5);
            cpShapeSetElasticity(_shapes[i],.95);
        }
    }
    return self;
}

-(BOOL)isInBounds:(BounceObject*)obj  {
    vec2 pos = self.position;
    
    float left = pos.x-_dimensions.width*.5;
    float right = pos.x+_dimensions.width*.5;
    
    float top = pos.y+_dimensions.height*.5;
    float bottom = pos.y-_dimensions.height*.5;
    
    cpBB bb = cpBBNew(left, bottom, right, top);
    
    cpShape **shapes = obj.shapes;
    int numShapes = obj.numShapes;
    for(int i = 0; i < numShapes; i++) {
        if(cpBBIntersects(bb, shapes[i]->bb)) {
            return YES;
        }
    }
    return NO;
}


-(BOOL)isInBoundsAt:(const vec2 &)loc withPadding:(float)pad {
    vec2 pos = self.position;
    
    float left = pos.x-_dimensions.width*.5-pad;
    float right = pos.x+_dimensions.width*.5+pad;
    
    float top = pos.y+_dimensions.height*.5+pad;
    float bottom = pos.y-_dimensions.height*.5-pad;
    
    return loc.x >= left && loc.x <= right && loc.y >= bottom && loc.y <= top;
}

-(BOOL)isInBoundsAt:(const vec2 &)loc {
    vec2 pos = self.position;
    
    float left = pos.x-_dimensions.width*.5;
    float right = pos.x+_dimensions.width*.5;

    float top = pos.y+_dimensions.height*.5;
    float bottom = pos.y-_dimensions.height*.5;

    return loc.x >= left && loc.x <= right && loc.y >= bottom && loc.y <= top;
}

-(void)setBounciness:(float)b {
    for(int i = 0; i < _numShapes; i++) {
        cpShapeSetElasticity(_shapes[i], .5*(1-b)+1*b);
    }
}

-(void)setFriction:(float)f {
    for(int i = 0; i < _numShapes; i++) {
        cpShapeSetFriction(_shapes[i], f);
    }
}

@end

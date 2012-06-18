//
//  BounceArena.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceArena.h"

@implementation BounceArena

-(id)initWithRect:(CGRect)rect {
    self = [super initStatic];
    
    if(self) {
        _rect = rect;
        
        vec2 tr(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
        vec2 tl(rect.origin.x, tr.y);
        vec2 bl(tl.x,rect.origin.y);
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
        
        for(int i = 0; i < _numShapes; i++) {
            cpShapeSetCollisionType(_shapes[i], WALL_TYPE);
            cpShapeSetFriction(_shapes[i],.1);
            cpShapeSetElasticity(_shapes[i],1.);
        }
    }
    return self;
}
@end

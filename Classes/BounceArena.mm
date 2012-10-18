//
//  BounceArena.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceArena.h"
#import "BounceSimulation.h"
#import <algorithm>

@implementation BounceArena

@synthesize dimensions = _dimensions;

-(id)initWithCoder:(NSCoder *)aDecoder {
    float x = [aDecoder decodeFloatForKey:@"BounceArenaPositionX"];
    float y = [aDecoder decodeFloatForKey:@"BounceArenaPositionY"];
    float width = [aDecoder decodeFloatForKey:@"BounceArenaWidth"];
    float height = [aDecoder decodeFloatForKey:@"BounceArenaHeight"];
    CGRect rect = CGRectMake(x-width*.5, 
                             y-height*.5,
                             width, 
                             height);
    
    return [self initWithRect:rect];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    vec2 pos = self.position;
    [aCoder encodeFloat:pos.x forKey:@"BounceArenaPositionX"];
    [aCoder encodeFloat:pos.y forKey:@"BounceArenaPositionY"];
    [aCoder encodeFloat:_dimensions.width forKey:@"BounceArenaWidth"];
    [aCoder encodeFloat:_dimensions.height forKey:@"BounceArenaHeight"];
}

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

-(CGRect)rect {
    vec2 loc = self.position;
    return CGRectMake(loc.x-.5*_dimensions.width, loc.y-.5*_dimensions.height, _dimensions.width, _dimensions.height);
}

-(BOOL)isInBounds:(BounceObject*)obj  {
    vec2 pos = self.position;
    
    float left = -_dimensions.width*.5;
    float right = _dimensions.width*.5;
    
    float top = _dimensions.height*.5;
    float bottom = -_dimensions.height*.5;
    
    vec2 tl = vec2(left,top);
    vec2 tr = vec2(right,top);
    vec2 bl = vec2(left,bottom);
    vec2 br = vec2(right, bottom);
    
    float angle = self.angle;
    float cosa = cos(angle);
    float sina = sin(angle);
    
    tl.rotate(cosa,sina);
    tr.rotate(cosa,sina);
    bl.rotate(cosa,sina);
    br.rotate(cosa,sina);
    
    float xs[4];
    xs[0] = tl.x;
    xs[1] = tr.x;
    xs[2] = bl.x;
    xs[3] = br.x;
    
    float ys[4];
    ys[0] = tl.y;
    ys[1] = tr.y;
    ys[2] = bl.y;
    ys[3] = br.y;
    
    left = *std::min_element(xs, xs+4);
    right = *std::max_element(xs, xs+4);
    top = *std::max_element(ys, ys+4);
    bottom = *std::min_element(ys, ys+4);
    
    cpBB bb = cpBBNew(left+pos.x, bottom+pos.y, right+pos.x, top+pos.y);
    
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
    
    float left = -_dimensions.width*.5-pad;
    float right = _dimensions.width*.5+pad;
    
    float top = _dimensions.height*.5+pad;
    float bottom = -_dimensions.height*.5-pad;
    
    vec2 l = loc;
    l -= pos;
    l.rotate(self.angle);
    
    return l.x >= left && l.x <= right && l.y >= bottom && l.y <= top;
}

-(BOOL)isInBoundsAt:(const vec2 &)loc {
    return [self isInBoundsAt:loc withPadding:0];
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

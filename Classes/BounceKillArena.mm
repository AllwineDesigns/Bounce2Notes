//
//  BounceKillArena.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceKillArena.h"
#import "BounceSimulation.h"
#import "FSAShaderManager.h"
#import "fsa/Noise.hpp"
#import "FSAUtil.h"
#import <chipmunk/chipmunk_unsafe.h>

int presolve_kill(cpArbiter *arb, cpSpace *space, void *data) {
    BounceKillArena *killArena = (BounceKillArena*)data;
    
    cpBody *body1;
    cpShape *shape1;
    
    cpBody *body2;
    cpShape *shape2;
    cpArbiterGetBodies(arb, &body1, &body2);
    cpArbiterGetShapes(arb, &shape1, &shape2);
    
    BounceObject *obj = (BounceObject*)cpBodyGetUserData(body1);
    
    [killArena kill: obj];
    return 1;
}


@implementation BounceKillArena

-(id)initWithRect:(CGRect)rect simulation:(BounceSimulation *)simulation {
    self = [super initRogue];
    
    if(self) {
        _simulation = simulation;
        [simulation retain];
        
        _rect = rect;
        
        _top = rect.origin.y+rect.size.height+1;
        _left = rect.origin.x-1;
        _right = rect.origin.x+rect.size.width+1;
        _bottom = rect.origin.y-1;
        
        vec2 tr(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
        vec2 tl(rect.origin.x, tr.y);
        vec2 bl(tl.x,rect.origin.y);
        vec2 br(tr.x,bl.y);
        
        _pad = 50;
        
        float pad = _pad;
        
        vec2 pad_tr(tr.x+pad, tr.y+pad);
        vec2 pad_tl(tl.x-pad, tl.y+pad);
        vec2 pad_bl(bl.x-pad, bl.y-pad);
        vec2 pad_br(br.x+pad, br.y-pad);
        
        _color = vec4(1,1,1,1);
        
        [self addSegmentShapeWithRadius:pad fromA:pad_tr toB:pad_tl];
        [self addSegmentShapeWithRadius:pad fromA:pad_tl toB:pad_bl];
        [self addSegmentShapeWithRadius:pad fromA:pad_bl toB:pad_br];
        [self addSegmentShapeWithRadius:pad fromA:pad_br toB:pad_tr];
        
        for(int i = 0; i < _numShapes; i++) {
            cpShapeSetSensor(_shapes[i], true);
        }
        
        cpShapeSetCollisionType(_shapes[0],KILL_TOP_TYPE);
        cpShapeSetCollisionType(_shapes[1], KILL_LEFT_TYPE);
        cpShapeSetCollisionType(_shapes[2], KILL_BOTTOM_TYPE);
        cpShapeSetCollisionType(_shapes[3], KILL_RIGHT_TYPE);
        
        _killTop = NO;
        _killBottom = NO;
        _killLeft = NO;
        _killRight = NO;
    }
    return self;
}

-(void)kill: (BounceObject*)obj {
    if(obj.isManipulatable) {
        [_simulation postSolveRemoveObject:obj];
    }
}

-(BOOL)isEnabled {
    return _killTop || _killBottom || _killLeft || _killRight;
}
-(BOOL)isTopEnabled {
    return _killTop;
}
-(BOOL)isBottomEnabled {
    return _killBottom;
}
-(BOOL)isLeftEnabled {
    return _killLeft;
}
-(BOOL)isRightEnabled {
    return _killRight;
}

-(void)randomizeColor {
    NSTimeInterval time = [[NSProcessInfo processInfo] systemUptime];
    HSVtoRGB(&(_color.x), &(_color.y), &(_color.z), 
             360.*random(64.28327*time), .4, .05*random(736.2827*time)+.75   );
}

-(void)enableTop {
    _killTop = YES;
    
    [self randomizeColor];
    
    if(_space != NULL) {
        cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, KILL_TOP_TYPE, NULL, presolve_kill, NULL, NULL, self);
    }
}
-(void)disableTop {
    _killTop = NO;
    [self setTop:_rect.origin.y+_rect.size.height+1];
    
    if(_space != NULL) {
        cpSpaceRemoveCollisionHandler(_space, OBJECT_TYPE, KILL_TOP_TYPE);
    }
}

-(void)enableBottom {
    _killBottom = YES;
    [self randomizeColor];

    if(_space != NULL) {
        cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, KILL_BOTTOM_TYPE, NULL, presolve_kill, NULL, NULL, self);
    }
}
-(void)disableBottom {
    _killBottom = NO;
    [self setBottom:_rect.origin.y-1];
    
    if(_space != NULL) {
        cpSpaceRemoveCollisionHandler(_space, OBJECT_TYPE, KILL_BOTTOM_TYPE);
    }
}

-(void)enableLeft {
    _killLeft = YES;
    
    [self randomizeColor];

    if(_space != NULL) {
        cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, KILL_LEFT_TYPE, NULL, presolve_kill, NULL, NULL, self);
    }
}
-(void)disableLeft {
    _killLeft = NO;
    [self setLeft:_rect.origin.x-1];
    if(_space != NULL) {
        cpSpaceRemoveCollisionHandler(_space, OBJECT_TYPE, KILL_LEFT_TYPE);
    }
}

-(void)enableRight {
    _killRight = YES;
    
    [self randomizeColor];

    if(_space != NULL) {
        cpSpaceAddCollisionHandler(_space, OBJECT_TYPE, KILL_RIGHT_TYPE, NULL, presolve_kill, NULL, NULL, self);
    }
}
-(void)disableRight {
    _killRight = NO;
    [self setRight: _rect.origin.x+_rect.size.width+1];
    if(_space != NULL) {
        cpSpaceRemoveCollisionHandler(_space, OBJECT_TYPE, KILL_RIGHT_TYPE);
    }
}

-(void)setTop:(float)y {
    vec2 tr(_rect.origin.x+_rect.size.width, y);
    vec2 tl(_rect.origin.x, y);
    _top = y;
    
    vec2 pad_tr(tr.x+_pad, tr.y+_pad);
    vec2 pad_tl(tl.x-_pad, tl.y+_pad);

    cpSegmentShapeSetEndpoints(_shapes[0], (cpVect&)pad_tr, (cpVect&)pad_tl);
    if(_space != NULL) {
        cpSpaceReindexShape(_space, _shapes[0]);
    }

}
-(void)setBottom:(float)y {
    vec2 bl(_rect.origin.x,y);
    vec2 br(_rect.origin.x+_rect.size.width,y);
    _bottom = y;
    
    vec2 pad_bl(bl.x-_pad, bl.y-_pad);
    vec2 pad_br(br.x+_pad, br.y-_pad);

    cpSegmentShapeSetEndpoints(_shapes[2], (cpVect&)pad_bl, (cpVect&)pad_br);
    if(_space != NULL) {
        cpSpaceReindexShape(_space, _shapes[2]);
    }
    
}
-(void)setLeft:(float)x {
    vec2 tl(x, _rect.origin.y+_rect.size.height);
    vec2 bl(x,_rect.origin.y);
    _left = x;
    
    vec2 pad_tl(tl.x-_pad, tl.y+_pad);
    vec2 pad_bl(bl.x-_pad, bl.y-_pad);
    
    cpSegmentShapeSetEndpoints(_shapes[1], (cpVect&)pad_tl, (cpVect&)pad_bl);
    if(_space != NULL) {
        cpSpaceReindexShape(_space, _shapes[1]);
    }
    
}
-(void)setRight:(float)x {
    vec2 tr(x, _rect.origin.y+_rect.size.height);
    vec2 br(x,_rect.origin.y);
    _right = x;
    
    vec2 pad_tr(tr.x+_pad, tr.y+_pad);
    vec2 pad_br(br.x+_pad, br.y-_pad);
    
    cpSegmentShapeSetEndpoints(_shapes[3], (cpVect&)pad_br, (cpVect&)pad_tr);
    if(_space != NULL) {
        cpSpaceReindexShape(_space, _shapes[3]);
    }
}

-(void)draw {
    vec2 verts[4];
    unsigned int indices[5];
    
    verts[0] = vec2(_right, _top);
    verts[1] = vec2(_left, _top);
    verts[2] = vec2(_left, _bottom);
    verts[3] = vec2(_right, _bottom);
    
    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 3;
    indices[4] = 0;
    
    FSAShader *shader = [[FSAShaderManager instance] getShader:@"ColorShader"];
    [shader setPtr:verts forAttribute:@"position"];
    [shader setPtr:&_color forUniform:@"color"];
    
    [shader enable];
    glDrawElements(GL_LINE_STRIP, 5, GL_UNSIGNED_INT, indices);
    [shader disable];
}
       
-(void)dealloc {
    [_simulation release]; _simulation = nil;
    [super dealloc];                
}

@end


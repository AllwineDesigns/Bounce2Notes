//
//  BounceKillArena.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "ChipmunkObject.h"
#import "BounceSimulation.h"

#define KILL_TOP_TYPE 3333
#define KILL_BOTTOM_TYPE 4444
#define KILL_LEFT_TYPE 5555
#define KILL_RIGHT_TYPE 6666

@interface BounceKillArena : ChipmunkObject {
    BounceSimulation *_simulation;
    
    vec4 _color;
    
    CGRect _rect;
    float _pad;
    BOOL _killTop;
    BOOL _killLeft;
    BOOL _killBottom;
    BOOL _killRight;
    
    float _top;
    float _bottom;
    float _left;
    float _right;
}

-(id)initWithRect: (CGRect)rect simulation:(BounceSimulation*)simulation;

-(void)kill: (BounceObject*)obj;

-(BOOL)isEnabled;
-(BOOL)isTopEnabled;
-(BOOL)isBottomEnabled;
-(BOOL)isLeftEnabled;
-(BOOL)isRightEnabled;

-(void)enableTop;
-(void)disableTop;

-(void)enableBottom;
-(void)disableBottom;

-(void)enableLeft;
-(void)disableLeft;

-(void)enableRight;
-(void)disableRight;

-(void)setTop:(float)y;
-(void)setBottom:(float)y;
-(void)setLeft:(float)x;
-(void)setRight:(float)x;

-(void)draw;

@end

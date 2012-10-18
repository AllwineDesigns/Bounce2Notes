//
//  BouncePages.h
//  ParticleSystem
//
//  Created by John Allwine on 9/6/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "fsa/Vector.hpp"
#import <vector>

using namespace fsa;

@class BouncePages;

@protocol BounceWidget <NSObject>

-(void)setPosition:(const vec2&)pos;
-(void)setVelocity:(const vec2&)vel;
-(void)setAngle:(float)angle;
-(void)setAngVel:(float)angVel;

@end

@interface BouncePage : NSObject {
    BouncePages *_parent;
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

@property (nonatomic, assign) BouncePages *parent;
@property (nonatomic) float pageOffset;

-(void)step:(float)dt;
-(void)setScroll:(float)scroll;
-(void)finalizeScroll;
-(void)addWidget:(id<BounceWidget>)widget offset:(const vec2&)offset; 
-(void)updatePositions:(const vec2&)panePosition;

@end

@interface BouncePages : NSObject {
    float _pos;
    float _vel;
    float _touchOffset;
    float _pageWidth;
    float _pageHeight;
    unsigned int _curPage;
    
    float _angle;
    float _angVel;
    
    float _springLoc;
    
    NSMutableArray *_pages;
}

@property (nonatomic, readonly) float pageWidth;
@property (nonatomic, readonly) float pageHeight;
@property (nonatomic, readonly) float position;
@property (nonatomic, readonly) float velocity;
@property (nonatomic) unsigned int currentPage;
@property (nonatomic) float angle;
@property (nonatomic) float angVel;
@property (nonatomic) float touchOffset;

-(unsigned int)count;

-(void)nextPage;
-(void)previousPage;

-(id)initWithPageWidth: (float)width pageHeight:(float)height;

-(void)addPage:(BouncePage*)page;
-(void)step:(float)dt;
-(void)updatePositions:(const vec2&)panePosition;

-(void)setScroll:(float)scroll;
-(void)finalizeScroll;
@end



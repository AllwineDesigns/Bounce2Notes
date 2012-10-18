//
//  BouncePages.m
//  ParticleSystem
//
//  Created by John Allwine on 9/6/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BouncePages.h"

@implementation BouncePages

@synthesize angVel = _angVel;
@synthesize angle = _angle;
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

-(void)addPage:(BouncePage*)page {
    page.parent = self;
    page.pageOffset = [_pages count]*_pageWidth;
    [_pages addObject:page];
}
-(void)step:(float)dt {
    /*
    float spring_k = 130;
    float drag = .2;
    
    _pos += _vel*dt;
    
    float a = spring_k*(_springLoc-_pos);
    
    _vel +=  a*dt-drag*_vel;
     */
    
    float lastPos = _pos;
    float t = .2;
    _pos = t*_springLoc+(1-t)*_pos;
    
    _vel = (_pos-lastPos)/dt;
    
    for(BouncePage* page in _pages) {
        [page step:dt];
    }
}
-(void)updatePositions:(const vec2&)panePosition {
    for(BouncePage *page in _pages) {
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

@implementation BouncePage
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

-(void)addWidget:(id<BounceWidget>)widget offset:(const vec2&)offset {
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
    float cosangle = cos(-_parent.angle);
    float sinangle = sin(-_parent.angle);
    for(unsigned int i = 0; i < numObjects; i++) {
        id<BounceWidget> widget = [_objects objectAtIndex:i];
        vec2 offset = _offsets[i];
        vec2 pos = offset+vec2(_pageOffset+pagesPos, _verticalPos);
        pos.rotate(cosangle, sinangle);
        pos += panePosition;
        [widget setPosition:pos];
        [widget setVelocity:vec2(_parent.velocity, 0)];
        [widget setAngle:_parent.angle];
        [widget setAngVel:_parent.angVel];
    }
}

-(void)dealloc {
    [_objects release];
    [super dealloc];
}
@end


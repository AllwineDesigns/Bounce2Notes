//
//  FSATexture.m
//  ParticleSystem
//
//  Created by John Allwine on 7/3/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSATexture.h"

@implementation FSATexture

@synthesize name = _name;
@synthesize width = _width;
@synthesize height = _height;
@synthesize textWidth = _textWidth;
@synthesize textHeight = _textHeight;
@synthesize aspect = _aspect;
@synthesize inverseAspect = _invaspect;

-(id)initWithName:(GLuint)name width:(unsigned int)width height:(unsigned int)height {
    self = [super init];
    
    if(self) {
        _name = name;
        _width = width;
        _height = height;
        
        _aspect = (float)width/height;
        _invaspect = 1./_aspect;
    }
    
    return self;
}

-(id)initWithName:(GLuint)name width:(unsigned int)width height:(unsigned int)height textWidth:(unsigned int)textWidth textHeight:(unsigned int)textHeight {
    self = [super init];
    
    if(self) {
        _name = name;
        _width = width;
        _height = height;
        
        _textWidth = textWidth;
        _textHeight = textHeight;
        
        _aspect = (float)width/height;
        _invaspect = 1./_aspect;
    }
    
    return self;
}
@end

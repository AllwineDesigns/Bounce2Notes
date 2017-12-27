//
//  FSABuffer.m
//  ParticleSystem
//
//  Created by John Allwine on 8/12/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSABuffer.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@implementation FSABuffer 

@synthesize name = _name;
@synthesize count = _count;
@synthesize target = _target;

-(FSABuffer*)initElementArrayWithData:(const unsigned int*)data count:(GLsizei)count {
    self = [super init];
    
    if(self) {
        _target = GL_ELEMENT_ARRAY_BUFFER;
        glGenBuffers(1, &_name);
        glBindBuffer(_target, _name);
        glBufferData(_target, count*sizeof(unsigned int), data, GL_STATIC_DRAW);
        _count = count;
        glBindBuffer(_target, 0);
    }
    
    return self;
}

-(void)bind {
    glBindBuffer(_target, _name);
}

-(void)unbind {
    glBindBuffer(_target, 0);
}

-(void)dealloc {
    glDeleteBuffers(1, &_name);
    [super dealloc];
}

@end

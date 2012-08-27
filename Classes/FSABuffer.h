//
//  FSABuffer.h
//  ParticleSystem
//
//  Created by John Allwine on 8/12/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSABuffer : NSObject {
    GLuint _name;
    GLsizei _count;
    GLenum _target;
}

@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) GLsizei count;
@property (nonatomic, readonly) GLenum target;

-(FSABuffer*)initElementArrayWithData: (const unsigned int*)data count:(GLsizei)count;
-(void)bind;
-(void)unbind;

@end

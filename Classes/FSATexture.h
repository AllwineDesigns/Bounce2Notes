//
//  FSATexture.h
//  ParticleSystem
//
//  Created by John Allwine on 7/3/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSATexture : NSObject {
    GLuint _name;
    unsigned int _width;
    unsigned int _height;
    
    unsigned int _textWidth;
    unsigned int _textHeight;
    
    float _aspect;
    float _invaspect;
}

@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) unsigned int width;
@property (nonatomic, readonly) unsigned int height;
@property (nonatomic, readonly) unsigned int textWidth;
@property (nonatomic, readonly) unsigned int textHeight;
@property (nonatomic, readonly) float aspect;
@property (nonatomic, readonly) float inverseAspect;

-(id)initWithName: (GLuint)name width:(unsigned int)width height:(unsigned int)height;
-(id)initWithName: (GLuint)name width:(unsigned int)width height:(unsigned int)height textWidth:(unsigned int)textWidth textHeight:(unsigned int)textHeight;


@end

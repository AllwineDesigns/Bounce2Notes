//
//  FSAShaderManager.h
//  ParticleSystem
//
//  Created by John Allwine on 6/16/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "FSAShader.h"

@interface FSAShaderManager : NSObject {
    NSMutableDictionary *shaders;
}

-(id)init;
-(FSAShader*)getShader: (NSString*)name;
+(FSAShaderManager*)instance;

@end

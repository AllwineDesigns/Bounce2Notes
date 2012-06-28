//
//  FSATextureManager.h
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

@interface FSATextureManager : NSObject {
    NSMutableDictionary *textures;
    NSMutableDictionary *largeTextures;
    NSString* largeTexturePrefix;
}

-(id)init;
-(GLuint)getTexture: (NSString*)name;
-(void)addLargeTexture: (NSString*)name;
+(FSATextureManager*)instance;

@end

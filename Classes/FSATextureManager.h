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

#import "FSATexture.h"
#import <fsa/Vector.hpp>

using namespace fsa;

@interface FSATextureManager : NSObject {
    NSMutableDictionary *textures;
    NSMutableDictionary *largeTextures;
    int largeTexturePrefix;
    
    int startTextTextureSize;
}

-(id)init;
-(void)generateTextureForText: (NSString*)txt forKey:(NSString*)key withFontSize: (float)size withOffset: (const vec2&)offset;
-(void)generateTextureForText: (NSString*)txt;

-(FSATexture*)getTexture: (NSString*)name;
-(void)addLargeTexture: (NSString*)name;
+(FSATextureManager*)instance;

@end

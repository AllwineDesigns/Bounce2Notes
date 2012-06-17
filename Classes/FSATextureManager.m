//
//  FSATextureManager.m
//  ParticleSystem
//
//  Created by John Allwine on 6/16/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSATextureManager.h"

static FSATextureManager* fsaTextureManager;

@implementation FSATextureManager

-(id)init {
    textures = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    return self;
}

-(GLuint)getTexture:(NSString *)name {
    NSNumber *num = [textures objectForKey:name];
    if(num == nil) {
        GLuint texId;
        glGenTextures(1, &texId);
        glBindTexture(GL_TEXTURE_2D, texId);
        UIImage* image = [UIImage imageNamed:name];
        
        GLubyte* imageData = (GLubyte*)malloc(image.size.width * image.size.height * 4);
        
        CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
        CGContextRelease(imageContext); 
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        free(imageData);
        glGenerateMipmap(GL_TEXTURE_2D);
        
        [textures setObject:[NSNumber numberWithUnsignedInt:texId] forKey:name];
        
        return texId;
    }
    
    return [num unsignedIntValue];
}

-(void)dealloc {
    for(NSNumber *num in [textures objectEnumerator]) {
        GLuint tex = [num unsignedIntValue];
        glDeleteTextures(1, &tex);
    }
    [textures release]; textures = nil;
    [super dealloc];
}

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        fsaTextureManager = [[FSATextureManager alloc] init];
    }
}

+(FSATextureManager*)instance {
    return fsaTextureManager;
}



@end

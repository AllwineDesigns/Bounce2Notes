//
//  FSATextureManager.m
//  ParticleSystem
//
//  Created by John Allwine on 6/16/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSATextureManager.h"
#import "PVRTexture.h"
#import "FSAUtil.h"

static FSATextureManager* fsaTextureManager;

@implementation FSATextureManager

-(id)init {
    self = [super init];
    
    if(self) {
        textures = [[NSMutableDictionary alloc] initWithCapacity:5];
        largeTextures = [[NSMutableDictionary alloc] initWithCapacity:5];

    //    NSString *device = machineName();
        CGSize size = screenSize();
        int prefix = 1 << (int)ceilf(logf(size.width)/logf(2));
        largeTexturePrefix = [NSString stringWithFormat:@"%d", prefix];
        [largeTexturePrefix retain];
      //  NSLog(@"prefix: %@\n", largeTexturePrefix);
     //   NSLog(@"device: %@\n", device);
     //   NSLog(@"screen size: %f, %f\n", size.width, size.height);
    }
    
    return self;
}
-(void)addLargeTexture:(NSString *)name {
    NSString *largeName = [NSString stringWithFormat:@"%@%@", largeTexturePrefix, name];
    [largeTextures setObject:largeName forKey:name];
    [self getTexture:largeName];
}

-(GLuint)getTexture:(NSString *)name {
    NSString* largeName = [largeTextures objectForKey:name];
    if(largeName != nil) {
        name = largeName;
    }
    NSNumber *num = [textures objectForKey:name];
    if(num == nil) {
        if([name hasSuffix:@".pvrtc"]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
            NSLog(@"%@", path);
            
            PVRTexture *tex = [[PVRTexture alloc] initWithContentsOfFile:path];
            [textures setObject:[NSNumber numberWithUnsignedInt:tex.name] forKey:name];
            NSLog(@"loaded pvr texture %@ into textureId %d (%@)\n", name, tex.name, tex);
            return tex.name;
        } else {
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
            
            NSLog(@"loaded %@ into textureId %u", name, texId);

            
            return texId;

        }
    }
    
    return [num unsignedIntValue];
}

-(void)dealloc {
    for(NSNumber *num in [textures objectEnumerator]) {
        GLuint tex = [num unsignedIntValue];
        glDeleteTextures(1, &tex);
    }
    [largeTexturePrefix release]; largeTexturePrefix = nil;
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

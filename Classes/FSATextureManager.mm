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

        CGSize size = screenSize();
        largeTexturePrefix = nextPowerOfTwo(size.width);
        startTextTextureSize = nextPowerOfTwo(size.width*.25);
    }
    
    return self;
}
-(void)addLargeTexture:(NSString *)name {
    NSString *largeName = [NSString stringWithFormat:@"%d%@", largeTexturePrefix, name];
    [largeTextures setObject:largeName forKey:name];
    [self getTexture:largeName];
}

-(FSATexture*)getTexture:(NSString *)name {
    NSString* largeName = [largeTextures objectForKey:name];
    if(largeName != nil) {
        name = largeName;
    }
    FSATexture *tex = [textures objectForKey:name];
    if(tex == nil) {
        if([name hasSuffix:@".pvrtc"]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];            
            PVRTexture *pvrtex = [[PVRTexture alloc] initWithContentsOfFile:path];
            
            tex = [[FSATexture alloc] initWithName:pvrtex.name width:pvrtex.width height:pvrtex.height];
            
            [textures setObject:tex forKey:name];
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
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

            
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
            free(imageData);
            glGenerateMipmap(GL_TEXTURE_2D);
            
            tex = [[FSATexture alloc] initWithName:texId width:image.size.width height:image.size.height];
            
            [textures setObject:tex forKey:name];
            
            NSLog(@"loaded %@ into textureId %u", name, texId);
        }
    }
    
    return tex;
}

-(void)generateTextureForText:(NSString *)txt {
    [self generateTextureForText:txt forKey:txt withFontSize:50 withOffset:vec2()];
}

-(void)generateTextureForText: (NSString*)txt forKey:(NSString*)key withFontSize: (float)size withOffset: (const vec2&)offset {
    NSAssert(([textures objectForKey:key] == nil), ([NSString stringWithFormat:@"texture exists for key: %@\n", key]));
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:startTextTextureSize/512.*size];
    
    CGSize renderedSize = [txt sizeWithFont:font];

    uint32_t height = startTextTextureSize;
    uint32_t width = nextPowerOfTwo(renderedSize.width);
    
    if(width > height) {
        height = width;
    } else {
        width = height;
    }
    
    const int bitsPerElement = 8;
    int sizeInBytes = height*width*4;
    int texturePitch = width*4;
    uint8_t *data = new uint8_t[sizeInBytes];
    memset(data, 0x00, sizeInBytes);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerElement, texturePitch, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    
    float components[4] = { 1, 1, 1, 1 };
    float components2[4] = { .26666667, .26666667, .26666667, 1 };
    CGColorRef color = CGColorCreate(colorSpace, components);
    CGColorRef color2 = CGColorCreate(colorSpace, components2);
    
    CGContextSetStrokeColorWithColor(context, color);    
    CGContextSetFillColorWithColor(context, color2);
    
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    CGContextSetFillColorWithColor(context, color);

    CGContextTranslateCTM(context, 0.0f, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextTranslateCTM(context, offset.x, offset.y);

    
    UIGraphicsPushContext(context);
    
    [txt drawInRect:CGRectMake(.5*width-.5*renderedSize.width, .5*height-.5*renderedSize.height, width, height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    UIGraphicsPopContext();
    
    CGContextRelease(context);
    CGColorRelease(color);
    CGColorRelease(color2);
    CGColorSpaceRelease(colorSpace);    
    
    GLuint textureID;
    glGenTextures(1, &textureID);    
    
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);     
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    glGenerateMipmap(GL_TEXTURE_2D);
    
    delete [] data;

    FSATexture *tex = [[FSATexture alloc] initWithName:textureID width:width height:height textWidth:renderedSize.width textHeight:renderedSize.height];
    [textures setObject:tex forKey:key];
    
    NSLog(@"loaded text \"%@\" into textureId %d as %@\n", txt, tex.name, key);
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

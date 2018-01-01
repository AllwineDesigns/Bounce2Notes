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
#import "FSABackgroundQueue.h"

static FSATextureManager* fsaTextureManager;

@implementation FSATextureManager

@synthesize lastMemoryWarning;

-(id)init {
    self = [super init];
    
    if(self) {
        _lastTextTextureId = 0;
        textures = [[NSMutableDictionary alloc] initWithCapacity:5];

        largeTextures = [[NSMutableDictionary alloc] initWithCapacity:5];

        CGSize size = screenSize();
        largeTexturePrefix = nextPowerOfTwo(size.width);
        
        NSString *device = machineName();
        

        if([device hasPrefix:@"iPhone"] || [device hasPrefix:@"iPad3"] || [device hasPrefix:@"iPad2,5"]) {
            startTextTextureSize = nextPowerOfTwo(size.width*.25);
        } else {
            startTextTextureSize = nextPowerOfTwo(size.width*.1);
        }
    }
    
    return self;
}

-(FSATexture*)getNewTextTexture {
    FSATextTexture *tex = [[FSATextTexture alloc] init];
    
    NSString *key = [NSString stringWithFormat:@"texttexture%d", _lastTextTextureId];
    _lastTextTextureId++;
    [textures setObject:tex forKey:key];
    
    return [tex autorelease];
}

-(void)memoryWarning {
    [[FSABackgroundQueue instance] suspendFor:5];
    lastMemoryWarning = [[NSProcessInfo processInfo] systemUptime];
    for(FSATexture* tex in [textures objectEnumerator]) {
        [tex memoryWarning];
    }
}
-(void)addTextTexture:(NSString *)name {
    FSATextTexture *tex = [[FSATextTexture alloc] init];
    [textures setObject:tex forKey:name];
    [tex release];
}

-(void)addSmartTexture:(NSString *)name {
    CGSize size = screenSize();
    
    unsigned int min = nextPowerOfTwo(size.width*.25);
    unsigned int max = nextPowerOfTwo(size.width);

    FSASmartTexture *tex = [[FSASmartTexture alloc] initWithFile:name minPrefix:min maxPrefix:max];
    
    [textures setObject:tex forKey:name];
    [tex release];
}
-(void)addLargeTexture:(NSString *)name {
    NSString *largeName = [NSString stringWithFormat:@"%d%@", largeTexturePrefix, name];
    [largeTextures setObject:largeName forKey:name];
    [self getTexture:largeName];
}

-(FSATexture*)temporaryTexture:(NSString *)name {
    FSATexture* tex;
    
    if([name hasSuffix:@".pvrtc"]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        PVRTexture *pvrtex = [[PVRTexture alloc] initWithContentsOfFile:path];
        
        tex = [[FSATexture alloc] initWithKey:name glName:pvrtex.name width:pvrtex.width height:pvrtex.height];
    } else {
        if(!name || ![[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:name ofType:@""]]) {
            NSLog(@"file doesn't exist: %@", name);
            return nil;
        } else {
            GLuint texId;
            glGenTextures(1, &texId);
            glBindTexture(GL_TEXTURE_2D, texId);
            UIImage* image = [UIImage imageNamed:name];
            
            GLubyte* imageData = (GLubyte*)malloc(image.size.width * image.size.height * 4);
            
            
            CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
            
            if(!imageContext) {
                NSLog(@"attempting to load %@", name);
                NSAssert(imageContext, @"must have imageContext to continue");
            }
            
            CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
            CGContextRelease(imageContext);
            
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
            free(imageData);
            glGenerateMipmap(GL_TEXTURE_2D);
            
            tex = [[FSATexture alloc] initWithKey:name glName:texId width:image.size.width height:image.size.height];
            
            
        }
    }
    return [tex autorelease];
}

-(void)addTexture:(NSString *)name forKey:(NSString *)key {
    FSATexture* tex = [self temporaryTexture:name];
    [textures setObject:tex forKey:key];
  //  NSLog(@"loaded %@ into textureId %u", name, tex.name);
}

-(FSATexture*)getTexture:(NSString *)name {
    NSString* largeName = [largeTextures objectForKey:name];
    if(largeName != nil) {
        name = largeName;
    }

    FSATexture *tex = [textures objectForKey:name];
    if(tex == nil) {
        [self addTexture:name forKey:name];
        
        tex = [textures objectForKey:name];
    }
    
    return tex;
}

-(FSATexture*)generateTemporaryTextureForText:(NSString *)txt {
    return [self generateTemporaryTextureForText:txt withFontSize:50 withOffset:vec2()];
}

-(FSATexture*)generateTemporaryTextureForText:(NSString *)txt withFontSize:(float)size withOffset:(const vec2 &)offset {
    return [self generateTemporaryTextureForText:txt withFontName:@"Arial" withFontSize:size withOffset:offset];
}

-(FSATexture*)generateTemporaryTextureForText:(NSString *)txt withFontName:(NSString *)fontName withFontSize:(float)size withOffset:(const vec2 &)offset {
    
    UIFont *font = [UIFont fontWithName:fontName size:startTextTextureSize/512.*size];
    
    // https://stackoverflow.com/questions/19145078/ios-7-sizewithattributes-replacement-for-sizewithfontconstrainedtosize
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]
                                 };
    CGSize renderedSize = [txt sizeWithAttributes:attributes];
    
    uint32_t height = startTextTextureSize;
    uint32_t width = nextPowerOfTwo(renderedSize.width);
    
    if(width > height) {
        height = width;
    } else {
        width = height;
    }
        
    const int bitsPerElement = 8;
    int sizeInBytes = height*width;
    int texturePitch = width;
    uint8_t *data = new uint8_t[sizeInBytes];
    memset(data, 0x00, sizeInBytes);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerElement, texturePitch, colorSpace, kCGImageAlphaNone);
    
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    
    CGFloat components[2] = { 1, 1 };
    CGFloat components2[2] = { .26666667, 1 };
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
    
    [txt drawInRect:CGRectMake(.5*width-.5*renderedSize.width, .5*height-.5*renderedSize.height, width, height) withAttributes:attributes];
    
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
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
    
    glGenerateMipmap(GL_TEXTURE_2D);
    
    delete [] data;
    
    FSATexture *tex = [[FSATexture alloc] initWithKey:@"" glName:textureID width:width height:height];
    return [tex autorelease];
}

-(void)generateTextureForText:(NSString *)txt {
    [self generateTextureForText:txt forKey:txt withFontSize:50 withOffset:vec2()];
}
-(void)generateTextureForText: (NSString*)txt forKey:(NSString*)key withFontSize: (float)size withOffset: (const vec2&)offset {
    [self generateTextureForText:txt forKey:key withFontName:@"Arial" withFontSize:size withOffset:offset];
}

-(void)generateTextureForText: (NSString*)txt forKey:(NSString*)key withFontName: (NSString*)fontName withFontSize: (float)size withOffset: (const vec2&)offset {
    NSAssert(([textures objectForKey:key] == nil), ([NSString stringWithFormat:@"texture exists for key: %@\n", key]));
    FSATexture *tex = [self generateTemporaryTextureForText:txt withFontName:fontName withFontSize:size withOffset:offset];
    tex.key = key;
    
    [textures setObject:tex forKey:key];
        
  //  NSLog(@"loaded text \"%@\" into textureId %d as %@\n", txt, tex.name, key);
    

}

-(FSATexture*)getTextTexture:(NSString *)name {
    NSString* largeName = [largeTextures objectForKey:name];
    if(largeName != nil) {
        name = largeName;
    }
    FSATexture *tex = [textures objectForKey:name];
    if(tex == nil) {
        tex = [self generateTemporaryTextureForText:name withFontSize:50 withOffset:vec2()];
        tex.key = name;
        [textures setObject:tex forKey:name];
    }
    
    return tex;
}

-(void)dealloc {
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

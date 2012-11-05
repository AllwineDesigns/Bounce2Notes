//
//  FSATexture.m
//  ParticleSystem
//
//  Created by John Allwine on 7/3/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSATexture.h"
#import "FSABackgroundQueue.h"
#import "FSAUtil.h"
#import "FSATextureManager.h"

@implementation FSATexture {
    GLuint _name;
    unsigned int _width;
    unsigned int _height;
    
    float _aspect;
    float _invaspect;
}

@synthesize key = _key;
@synthesize name = _name;
@synthesize width = _width;
@synthesize height = _height;
@synthesize aspect = _aspect;
@synthesize inverseAspect = _invaspect;

-(id)initWithKey:(NSString*)key name:(GLuint)name width:(unsigned int)width height:(unsigned int)height {
    self = [super init];
    
    if(self) {
        _name = name;
        _width = width;
        _height = height;
        _key = key;
        
        _aspect = (float)width/height;
        _invaspect = 1./_aspect;
    }
    
    return self;
}

-(void)needsSize:(float)size {
    
}

-(void)memoryWarning {
    
}

-(void)deleteTexture {
    glDeleteTextures(1, &_name);
}

-(void)dealloc {
    [self deleteTexture];
    [super dealloc];
}

@end

typedef struct {
    GLuint name;
    GLuint width;
    GLuint height;
    unsigned int prefix;
} FSASmartTextureLoadedStruct;

@implementation FSASmartTexture {
    NSString *_filename;
    unsigned int _minPrefix;
    unsigned int _maxPrefix;
    
    unsigned int _curPrefix;
    
    GLuint _minName;
    GLuint _curName;
    
    GLuint _minWidth;
    GLuint _minHeight;
    
    GLuint _curWidth;
    GLuint _curHeight;
    
    float _aspect;
    float _invaspect;
    
    NSMutableSet *_loadOperations;
}

@synthesize name = _curName;
@synthesize width = _curWidth;
@synthesize height = _curHeight;
@synthesize aspect = _aspect;
@synthesize inverseAspect = _invaspect;

-(id)initWithFile:(NSString*)file minPrefix:(unsigned int)minPrefix maxPrefix:(unsigned int)maxPrefix {
    self = [super init];
    if(self) {
        _minPrefix = minPrefix;
        _maxPrefix = maxPrefix;
        _curPrefix = minPrefix;
        _filename = file;
        _key = file;
        
        GLuint texId;
        glGenTextures(1, &texId);
        glBindTexture(GL_TEXTURE_2D, texId);
        NSString *filename = [NSString stringWithFormat:@"%u%@", minPrefix, file];
        UIImage* image = [UIImage imageNamed:filename];
        
        GLubyte* imageData = (GLubyte*)malloc(image.size.width * image.size.height * 4);
            
        CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
        CGContextRelease(imageContext); 
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        free(imageData);
        glGenerateMipmap(GL_TEXTURE_2D);
        
        _loadOperations = [[NSMutableSet alloc] initWithCapacity:3];
        
        _minName = texId;
        _curName = texId;
        
        _minWidth = image.size.width;
        _minHeight = image.size.height;
        
        _curWidth = _minWidth;
        _curHeight = _minHeight;
        
        _aspect = (float)_minWidth/_minHeight;
        _invaspect = 1./_aspect;
    }
    return self;
}

-(void)memoryWarning {
    if(_curName != _minName) {
       // NSLog(@"memory warning, deleting %u%@", _curPrefix, _filename);

        glDeleteTextures(1, &_curName);
        _curPrefix = _minPrefix;
        _curName = _minName;
        _curWidth = _minWidth;
        _curHeight = _curHeight;
        _aspect = (float)_curWidth/_curHeight;
        _invaspect = 1./_aspect;
    }
}
         
-(void)finishedLoadingTexture:(BackgroundTextureLoaderOperation*)loader {
    [_loadOperations removeObject:loader];

    if(_curName != _minName) {
        glDeleteTextures(1, &_curName);
    }

   // NSLog(@"finished loading texture %u%@\n", loader.prefix, _filename);
    //glFlush();
        
    _curPrefix = loader.prefix;
    _curName = loader.name;
    _curWidth = loader.width;
    _curHeight = loader.height;
    _aspect = (float)_curWidth/_curHeight;
    _invaspect = 1./_aspect;
    [self release];
}

-(void)needsSize:(float)size {
    unsigned int prefix = nextPowerOfTwo((unsigned int)size);

    if(prefix < _minPrefix) {
        prefix = _minPrefix;
    } else if(prefix > _maxPrefix) {
        prefix = _maxPrefix;
    }
    
    if(prefix <= _curPrefix) {
        return;
    }
    
    
    for(BackgroundTextureLoaderOperation *loader in _loadOperations) {
        if(prefix <= loader.prefix) {
            return;
        }
    }
    
    NSString *filename = [NSString stringWithFormat:@"%u%@", prefix, _filename];

    BackgroundTextureLoaderOperation *operation = [[BackgroundTextureLoaderOperation alloc] initWithFile:filename prefix:prefix forTexture:self];
    [_loadOperations addObject:operation];
  //  NSLog(@"loading %@, _curPrefix: %u", filename, _curPrefix);

    FSABackgroundQueue* queue = [FSABackgroundQueue instance];
    [queue addOperation:operation];
    [operation release];
}

-(void)deleteTexture {
    if(_minName != _curName) {
        glDeleteTextures(1, &_minName);
    }
    [_loadOperations release];
    glDeleteTextures(1, &_curName);
    
}

@end

@implementation BackgroundTextureLoaderOperation {
    FSASmartTexture* _texture;
    NSString* _file;
    GLuint _name;
    unsigned int _width;
    unsigned int _height;
    unsigned int _prefix;
}

@synthesize texture = _texture;
@synthesize name = _name;
@synthesize width = _width;
@synthesize height = _height;
@synthesize prefix = _prefix;

-(id)initWithFile:(NSString *)file prefix:(unsigned int)prefix forTexture:(FSASmartTexture*)texture {
    self = [super init];
    
    if(self) {
        self.texture = texture;
        _file = [file retain];
        _prefix = prefix;
        
        GLuint texId;
        glGenTextures(1, &texId);
        _name = texId;
        
        [self setThreadPriority:0];
    }
    
    return self;
}

-(void)main {
    @autoreleasepool {
        EAGLSharegroup *sharegroup = [[FSABackgroundQueue instance] sharegroup];
        EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:sharegroup];
        
        if (!aContext)
            NSLog(@"Failed to create ES context");
        else if (![EAGLContext setCurrentContext:aContext])
            NSLog(@"Failed to set ES context current");

        glBindTexture(GL_TEXTURE_2D, _name);
        
        UIImage* image = [UIImage imageNamed:_file];
        [image retain];
        _width = image.size.width;
        _height = image.size.height;
        
        GLubyte* imageData = (GLubyte*)malloc(image.size.width * image.size.height * 4);
        
        CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
        CGContextRelease(imageContext);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        free(imageData);
        glGenerateMipmap(GL_TEXTURE_2D);
        [image release];
        
        glFlush();
        
        [aContext release];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_texture finishedLoadingTexture:self];
        });
    }
}

-(void)dealloc {
    [_file release];
    [super dealloc];
}

@end

@implementation BackgroundTextTextureLoaderOperation {
    FSATextTexture *_texture;
    NSString* _text;
    GLuint _name;
    unsigned int _width;
    unsigned int _height;
    
    float _fontSize;
    NSString *_fontName;
    
    unsigned int _startTextTextureSize;
}

@synthesize texture = _texture;
@synthesize name = _name;
@synthesize width = _width;
@synthesize height = _height;
@synthesize text = _text;

-(id)initWithText:(NSString *)text fontSize:(float)fontSize fontName:(NSString*)fontName forTexture:(FSATextTexture *)texture {
    self = [super init];
    
    if(self) {
        _fontSize = fontSize;
        _fontName = [fontName copy];
        
        self.texture = texture;
        _text = [text retain];
        
        GLuint texId;
        glGenTextures(1, &texId);
        _name = texId;
        
        CGSize size = screenSize();         
        NSString *device = machineName();
        
        if([device hasPrefix:@"iPhone"] || [device hasPrefix:@"iPad3"] || [device hasPrefix:@"iPad2,5"]) {
            _startTextTextureSize = nextPowerOfTwo(size.width*.25);
        } else {
            _startTextTextureSize = nextPowerOfTwo(size.width*.1);
        }
        [self setThreadPriority:0];
    }
    
    return self;
}

-(void)main {
    @autoreleasepool {
        EAGLSharegroup *sharegroup = [[FSABackgroundQueue instance] sharegroup];
        EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:sharegroup];
        
        if (!aContext)
            NSLog(@"Failed to create ES context");
        else if (![EAGLContext setCurrentContext:aContext])
            NSLog(@"Failed to set ES context current");
                
        float size = _fontSize;
        
        UIFont *font = [UIFont fontWithName:_fontName size:_startTextTextureSize/512.*size];
        CGSize renderedSize = [_text sizeWithFont:font];
        
        uint32_t height = _startTextTextureSize;
        uint32_t width = nextPowerOfTwo(renderedSize.width);
        
        if(width > height) {
            height = width;
        } else {
            width = height;
        }
        
        _width = width;
        _height = height;
        
        const int bitsPerElement = 8;
        int sizeInBytes = height*width;
        int texturePitch = width;
        uint8_t *data = new uint8_t[sizeInBytes];
        memset(data, 0x00, sizeInBytes);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerElement, texturePitch, colorSpace, kCGImageAlphaNone);
        
        CGContextSetTextDrawingMode(context, kCGTextFillStroke);
        
        float components[2] = { 1, 1 };
        float components2[2] = { .26666667, 1 };
        CGColorRef color = CGColorCreate(colorSpace, components);
        CGColorRef color2 = CGColorCreate(colorSpace, components2);
        
        CGContextSetStrokeColorWithColor(context, color);
        CGContextSetFillColorWithColor(context, color2);
        
        CGContextFillRect(context, CGRectMake(0, 0, width, height));
        CGContextSetFillColorWithColor(context, color);
        
        CGContextTranslateCTM(context, 0.0f, height);
        CGContextScaleCTM(context, 1.0f, -1.0f);        
        
        UIGraphicsPushContext(context);
        
        [_text drawInRect:CGRectMake(.5*width-.5*renderedSize.width, .5*height-.5*renderedSize.height, width, height) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
        
        UIGraphicsPopContext();
        
        CGContextRelease(context);
        CGColorRelease(color);
        CGColorRelease(color2);
        CGColorSpaceRelease(colorSpace);
        
        glBindTexture(GL_TEXTURE_2D, _name);

        
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
        
        glGenerateMipmap(GL_TEXTURE_2D);
        
        delete [] data;
        
        glFlush();
        
        [aContext release];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_texture finishedLoadingTexture:self];
        });
    }
}

-(void)dealloc {
    [_fontName release];
    [_text release];
    [super dealloc];
}

@end

@implementation FSATextTexture {
    NSString *_text;
    GLuint _name;
    unsigned int _width;
    unsigned int _height;
    float _fontSize;
    NSString* _fontName;
    
    float _aspect;
    float _invaspect;
    NSMutableSet *_loadOperations;
    NSMutableDictionary *_cache;
}

@synthesize fontSize = _fontSize;
@synthesize fontName = _fontName;
@synthesize name = _name;
@synthesize text = _text;
@synthesize width = _width;
@synthesize height = _height;

@synthesize aspect = _aspect;
@synthesize inverseAspect = _invaspect;

-(id)init {
    _name = [[FSATextureManager instance] getTexture:@"gray.jpg"].name;
    _text = nil;
    _width = 0;
    _height = 0;
    _fontSize = 50;
    _fontName = @"Arial";
    
    _cache = [[NSMutableDictionary alloc] initWithCapacity:5];
    [_cache setObject:[NSNumber numberWithUnsignedInt:[[FSATextureManager instance] getTexture:@"gray.jpg"].name ] forKey:@""];
    _loadOperations = [[NSMutableSet alloc] initWithCapacity:5];

    return self;
}

-(id)initWithText:(NSString *)text {
    [self init];
    [self setText:text];
    
    return self;
}

-(void)memoryWarning {
    [_cache removeObjectForKey:@""];
    
    for(NSNumber *num in [_cache objectEnumerator]) {
        GLuint texId = [num unsignedIntValue];
        if(texId != _name) {
            glDeleteTextures(1, &texId);
        }
    }
    [_cache removeAllObjects];
    [_cache setObject:[NSNumber numberWithUnsignedInt:[[FSATextureManager instance] getTexture:@"gray.jpg"].name ] forKey:@""];

    if(_text && _name) {
        [_cache setObject:[NSNumber numberWithUnsignedInt:_name] forKey:_text];
    }
}

-(void)setText:(NSString *)text {
    if(!_text) {
        _text = @"";
    }

    if([text isEqualToString:_text]) {
        return;
    }
    
    NSNumber *num = [_cache objectForKey:text];
    if(num != nil) {
        _name = [num unsignedIntValue];
        [text retain];
        [_text release];
        _text = text;
        // TODO width, height, aspect and invaspect are now out of sync
    } else {
        for(BackgroundTextTextureLoaderOperation *loader in _loadOperations) {
            if([loader.text isEqualToString:text]) {
                return;
            }
        }
        BackgroundTextTextureLoaderOperation *loader = [[BackgroundTextTextureLoaderOperation alloc] initWithText:text fontSize:_fontSize fontName:_fontName forTexture:self];
        
       // NSLog(@"loading text, %@", text);
        
        [_loadOperations addObject:loader];
        FSABackgroundQueue* queue = [FSABackgroundQueue instance];
        [queue addOperation:loader];
        [loader release];
    }
}

-(void)finishedLoadingTexture:(BackgroundTextTextureLoaderOperation *)loader {
    [_loadOperations removeObject:loader];
   // NSLog(@"finished loading text %@ into texture %u\n", loader.text, loader.name);
    // glFlush();
            
    NSString *text = loader.text;
    [text retain];
    [_text release];
    _text = text;
        
    _name = loader.name;
    _width = loader.width;
    _height = loader.height;
    _aspect = (float)_height/_width;
    _invaspect = 1./_aspect;
        
    [_cache setObject:[NSNumber numberWithUnsignedInt:_name] forKey:_text];
    [self release];
}

-(void)deleteTexture {
    [_cache removeObjectForKey:@""];
    for(NSNumber *val in [_cache objectEnumerator]) {
        GLuint texId = [val unsignedIntValue];
        glDeleteTextures(1, &texId);
    }
    [_loadOperations release];
    [_cache release];

    glDeleteTextures(1, &_name);
}
@end

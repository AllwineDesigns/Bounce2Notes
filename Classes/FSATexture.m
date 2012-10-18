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
    
    NSMutableArray *_loadPrefixQueue;
    NSMutableArray *_loadedTextureQueue;
    
    GLuint _minWidth;
    GLuint _minHeight;
    
    GLuint _curWidth;
    GLuint _curHeight;
    
    float _aspect;
    float _invaspect;
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
        _loadPrefixQueue = [[NSMutableArray alloc] initWithCapacity:3];
        _loadedTextureQueue = [[NSMutableArray alloc] initWithCapacity:3];
        
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
        
        _minName = texId;
        _curName = texId;
        
        _minWidth = image.size.width;
        _minHeight = image.size.height;
        
        _curWidth = _minWidth;
        _curHeight = _minHeight;
        
        _aspect = (float)_minWidth/_minHeight;
        _invaspect = 1./_aspect;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLoadingTexture:) name:@"finishedLoadingTexture" object:self];

    }
    return self;
}

-(void)memoryWarning {
    if(_curName != _minName) {
        glDeleteTextures(1, &_curName);
        _curName = _minName;
        _curWidth = _minWidth;
        _curHeight = _curHeight;
        _aspect = (float)_curWidth/_curHeight;
        _invaspect = 1./_aspect;
    }
}

-(void)loadTexture {
    EAGLSharegroup *sharegroup = [[FSABackgroundQueue instance] sharegroup];
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:sharegroup];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
    
    GLuint texId;
    glGenTextures(1, &texId);
    glBindTexture(GL_TEXTURE_2D, texId);
    unsigned int loadPrefix;
    @synchronized(_loadPrefixQueue) {
        loadPrefix = [[_loadPrefixQueue objectAtIndex:0] unsignedIntValue];
    }
    NSString *filename = [NSString stringWithFormat:@"%u%@", loadPrefix, _filename];
    NSLog(@"loading texture %@ into textureId %u\n", filename, texId);

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
    
    FSASmartTextureLoadedStruct *loaded = (FSASmartTextureLoadedStruct*)malloc(sizeof(FSASmartTextureLoadedStruct));
    loaded->name = texId;
    loaded->prefix = loadPrefix;
    loaded->width = image.size.width;
    loaded->height = image.size.height;
    
    @synchronized(_loadedTextureQueue) {
        [_loadedTextureQueue addObject:[NSValue valueWithPointer:loaded]];
    }
    
    @synchronized(_loadPrefixQueue) {
        [_loadPrefixQueue removeObjectAtIndex:0];
    }

    glFlush();
    
    [aContext release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedLoadingTexture" object:self];
}
         
-(void)finishedLoadingTexture:(NSNotification*)notification {
    if(_curName != _minName) {
        glDeleteTextures(1, &_curName);
    }
    
    FSASmartTextureLoadedStruct *loaded;
    @synchronized(_loadedTextureQueue) {
        loaded = [[_loadedTextureQueue objectAtIndex:0] pointerValue];
        [_loadedTextureQueue removeObjectAtIndex:0];
    }
    
    NSLog(@"finished loading texture %u%@\n", loaded->prefix, _filename);
        
    _curPrefix = loaded->prefix;
    _curName = loaded->name;
    _curWidth = loaded->width;
    _curHeight = loaded->height;
    _aspect = (float)_curWidth/_curHeight;
    _invaspect = 1./_aspect;
    
    free(loaded);
}

-(void)needsSize:(float)size {
    if(size <= _curPrefix) {
        return;
    }
    
    unsigned int prefix = nextPowerOfTwo((unsigned int)size);

    if(prefix < _minPrefix) {
        prefix = _minPrefix;
    } else if(prefix > _maxPrefix) {
        prefix = _maxPrefix;
    }
    
    unsigned int lastQueuePrefix = 0;
    @synchronized(_loadPrefixQueue) {
        int count = [_loadPrefixQueue count];
        if(count > 0) {
            lastQueuePrefix = [[_loadPrefixQueue objectAtIndex:count-1] unsignedIntValue];
        }
    }
    
    unsigned int lastLoadedPrefix = 0;
    @synchronized(_loadedTextureQueue) {
        int count = [_loadedTextureQueue count];
        if(count > 0) {
            lastLoadedPrefix = ((FSASmartTextureLoadedStruct*)[[_loadedTextureQueue objectAtIndex:count-1] pointerValue])->prefix;
        }
    }
    
    if(prefix > _curPrefix && prefix > lastQueuePrefix && prefix > lastLoadedPrefix) {
        @synchronized(_loadPrefixQueue) {
            [_loadPrefixQueue addObject:[NSNumber numberWithUnsignedInt:prefix]];
        }
        FSABackgroundQueue* queue = [FSABackgroundQueue instance];

        NSInvocationOperation *invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(loadTexture) object:nil];
        [queue addOperation:invocation];
        [invocation release];
    }
}

-(void)deleteTexture {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    @synchronized(_loadedTextureQueue) {
        for(NSValue *val in _loadedTextureQueue) {
            FSASmartTextureLoadedStruct *loaded = [val pointerValue];
            glDeleteTextures(1, &loaded->name);
            free(loaded);
        }
    }
    [_loadedTextureQueue release];
    [_loadPrefixQueue release];
    if(_minName != _curName) {
        glDeleteTextures(1, &_minName);
    }
    glDeleteTextures(1, &_curName);
    
}

@end

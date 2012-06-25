#import "FSAShader.h"

@interface FSAShader (hidden)
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)link;
- (BOOL)validate;
- (BOOL)loadShaders:(NSString*) vert_shader fragShader: (NSString*) frag_shader;
@end

@implementation FSAShader

-(void)getAttributeAndUniformInfo {
    GLint numUniforms;
    glGetProgramiv(_program, GL_ACTIVE_UNIFORMS, &numUniforms);
    
    if(numUniforms > 0) {
        NSMutableDictionary *uniforms = [[NSMutableDictionary alloc] initWithCapacity:numUniforms];

        for(int i = 0; i < numUniforms; i++) {
            char n[40];
            GLsizei length;
            GLint size;
            GLenum type;
            
            glGetActiveUniform(_program, i, 40, &length, &size, &type, n);
            
            AttributeInfo *info = (AttributeInfo*)malloc(sizeof(AttributeInfo));
            info->ptr = NULL;
            info->stride = 0;
            info->loc = i;
            info->type = type;
            info->size = size;
            
            NSString *name = [NSString stringWithUTF8String:n];
            NSValue *val = [NSValue valueWithPointer:info];
            [uniforms setValue:val forKey:name];
        }
        _uniforms = uniforms;
    }
    
    GLint numAttributes;
    glGetProgramiv(_program, GL_ACTIVE_ATTRIBUTES, &numAttributes);
    
    if(numAttributes > 0) {
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithCapacity:numAttributes];
        
        for(int i = 0; i < numAttributes; i++) {
            char n[40];
            GLsizei length;
            GLint size;
            GLenum type;
            
            glGetActiveAttrib(_program, i, 40, &length, &size, &type, n);
            
            AttributeInfo *info = (AttributeInfo*)malloc(sizeof(AttributeInfo));
            info->ptr = NULL;
            info->stride = 0;
            info->loc = i;
            info->type = type;
            info->size = size;
            
            NSString *name = [NSString stringWithUTF8String:n];
            NSValue *val = [NSValue valueWithPointer:info];
            [attributes setValue:val forKey:name];
        }
        _attributes = attributes;
    }
    
}

-(id)initWithShaderPaths: (NSString*) vert_shader fragShader: (NSString*)frag_shader {
    self = [super init];
    
    if(self) {
        _uniforms = nil;
        _attributes = nil;
        
        [self loadShaders: vert_shader fragShader:frag_shader];
        [self getAttributeAndUniformInfo];
    }
    
    return self;
}

-(void)setPtr:(void *)ptr forUniform: (NSString*)name {
    NSValue *value = [_uniforms objectForKey:name];
    AttributeInfo *info = [value pointerValue];
    info->ptr = ptr;
}

-(void)setPtr:(void *)ptr forAttribute:(NSString*)name {
    NSValue *value = [_attributes objectForKey:name];
    AttributeInfo *info = [value pointerValue];
    info->ptr = ptr;
}

-(void)setStride:(unsigned int)stride forAttribute:(NSString*)name {
    NSValue *value = [_attributes objectForKey:name];
    AttributeInfo *info = [value pointerValue];
    info->stride = stride;
}

-(void)enable {    
    glUseProgram(_program);
    
#if DEBUG
    [self validate];
#endif

    for(NSString *name in _uniforms) {
        NSValue *val = [_uniforms valueForKey:name];
        AttributeInfo *info = (AttributeInfo*)[val pointerValue];
        switch(info->type) {
            case GL_INT:
                glUniform1iv(info->loc, info->size, info->ptr);
                break;
            case GL_INT_VEC2:
                glUniform2iv(info->loc, info->size, info->ptr);
                break;
            case GL_INT_VEC3:
                glUniform3iv(info->loc, info->size, info->ptr);
                break;
            case GL_INT_VEC4:
                glUniform4iv(info->loc, info->size, info->ptr);
                break;
            case GL_FLOAT:
                glUniform1fv(info->loc, info->size, info->ptr);
                break;
            case GL_FLOAT_VEC2:
                glUniform2fv(info->loc, info->size, info->ptr);
                break;
            case GL_FLOAT_VEC3:
                glUniform3fv(info->loc, info->size, info->ptr);
                break;
            case GL_FLOAT_VEC4:
                glUniform4fv(info->loc, info->size, info->ptr);
                break;
            case GL_SAMPLER_2D:
                glUniform1iv(info->loc, info->size, info->ptr);
                break;
            default:
                NSAssert(NO, @"unknown uniform type, %@\n", name);
        }
        
    }
    
    for(NSString *name in _attributes) {
        NSValue *val = [_attributes valueForKey:name];
        AttributeInfo *info = (AttributeInfo*)[val pointerValue];
        switch(info->type) {
            case GL_INT:
                glVertexAttribPointer(info->loc, 1, GL_INT, FALSE, info->stride, info->ptr);
                break;
            case GL_INT_VEC2:
                glVertexAttribPointer(info->loc, 2, GL_INT, FALSE, info->stride, info->ptr);
                break;
            case GL_INT_VEC3:
                glVertexAttribPointer(info->loc, 3, GL_INT, FALSE, info->stride, info->ptr);
                break;
            case GL_INT_VEC4:
                glVertexAttribPointer(info->loc, 4, GL_INT, FALSE, info->stride, info->ptr);
                break;
            case GL_FLOAT:
                glVertexAttribPointer(info->loc, 1, GL_FLOAT, FALSE, info->stride, info->ptr);
                break;
            case GL_FLOAT_VEC2:
                glVertexAttribPointer(info->loc, 2, GL_FLOAT, FALSE, info->stride, info->ptr);
                break;
            case GL_FLOAT_VEC3:
                glVertexAttribPointer(info->loc, 3, GL_FLOAT, FALSE, info->stride, info->ptr);
                break;
            case GL_FLOAT_VEC4:
                glVertexAttribPointer(info->loc, 4, GL_FLOAT, FALSE, info->stride, info->ptr);
                break;
            default:
                NSAssert(NO, @"unknown uniform type\n");
        }
        glEnableVertexAttribArray(info->loc);
    }
}

-(void)disable {
    for(NSString *name in _attributes) {
        NSValue *val = [_attributes objectForKey:name];  
        AttributeInfo *info = (AttributeInfo*)[val pointerValue];
        glDisableVertexAttribArray(info->loc);
    }
}

- (BOOL)loadShaders:(NSString*) vert_shader fragShader: (NSString*)frag_shader
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vert_shader ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:frag_shader ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
            
    // Link program.
    if (![self link])
    {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program)
        {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return FALSE;
    }
        
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}



- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load shader %@", file);
        return FALSE;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)link {
    GLint status;
    
    glLinkProgram(_program);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validate {
    GLint logLength, status;
    
    glValidateProgram(_program);
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(_program, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

-(void)dealloc {
    glDeleteProgram(_program);
    
    for(NSValue* val in [_uniforms objectEnumerator]) {
        AttributeInfo *info = [val pointerValue];
        free(info);
    }
    for(NSValue* val in [_attributes objectEnumerator]) {
        AttributeInfo *info = [val pointerValue];
        free(info);
    }
    [_uniforms release];
    [_attributes release];
    
    [super dealloc];
}

@end
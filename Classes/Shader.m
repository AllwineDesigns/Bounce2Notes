#import "Shader.h"

@interface Shader (hidden)
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)link;
- (BOOL)validate;
- (BOOL)loadShaders:(NSString*) vert_shader fragShader: (NSString*) frag_shader;
@end

@implementation Shader

-(id)initWithShaderPaths: (NSString*) vert_shader fragShader: (NSString*)frag_shader {
    [self loadShaders: vert_shader fragShader:frag_shader];
    
    return self;
}

-(void)bindAttributeLocations {
    // Bind attribute locations.
    // This needs to be done prior to linking.
//    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
//    glBindAttribLocation(program, ATTRIB_COLOR, "color");               
    NSAssert(NO, @"bindAttributeLocations needs to be implemented by a subclass");

}

-(void)updateAttributes {
    // Update attribute values.
//    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
//    glEnableVertexAttribArray(ATTRIB_VERTEX);
//    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_UNSIGNED_BYTE, 1, 0, squareColors);
//    glEnableVertexAttribArray(ATTRIB_COLOR);
    NSAssert(NO, @"updateAttributes needs to be implemented by a subclass");
}

-(void)getUniformLocations {
//    glGetUniformLocation(program, "texture");
}

-(void)draw {
    
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    NSAssert(NO, @"draw needs to be implemented by a subclass");
}

-(void)updateAndDraw {
    glUseProgram(program);
    
    [self updateAttributes];
    // Validate program before drawing. This is a good check, but only really necessary in a debug build.
    // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
    if (![self validate])
    {
        NSLog(@"Failed to validate program: %d", program);
        return;
    }
#endif
    
    [self draw];

}

- (BOOL)loadShaders:(NSString*) vert_shader fragShader: (NSString*)frag_shader
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
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
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
        
    [self bindAttributeLocations];
    
    // Link program.
    if (![self link])
    {
        NSLog(@"Failed to link program: %d", program);
        
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
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }
    
    [self getUniformLocations];
    
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
    
    glLinkProgram(program);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validate {
    GLint logLength, status;
    
    glValidateProgram(program);
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

-(void)dealloc {
    glDeleteProgram(program);
    
    [super dealloc];
}

@end
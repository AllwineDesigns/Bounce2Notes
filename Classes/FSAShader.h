#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct {
    void* ptr;
    unsigned int stride;
    GLenum type;
    GLint size; 
    GLint loc;
} AttributeInfo;

@interface FSAShader : NSObject {
    GLuint _program;
    NSDictionary *_uniforms;
    NSDictionary *_attributes;
}

-(id)initWithShaderPaths: (NSString*) vert_shader fragShader: (NSString*)frag_shader;

-(void)setPtr:(void*)ptr forAttribute: (NSString*)name;
-(void)setStride:(unsigned int)stride forAttribute: (NSString*)name;

-(void)setPtr:(void*)ptr forUniform: (NSString*)name;
-(void)enable;
-(void)disable;

@end

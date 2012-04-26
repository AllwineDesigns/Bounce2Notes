#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface Shader : NSObject {
    GLuint program;
}

- (id)initWithShaderPaths: (NSString*) vert_shader fragShader: (NSString*)frag_shader;
- (void)updateAndDraw;

// implemented by subclasses
- (void)getUniformLocations; // called after linking program
- (void)bindAttributeLocations; // called prior to linking program
- (void)updateAttributes; // called in updateAndDraw
- (void)draw;             // called in updateAndDraw

@end

#import "Shader.h"
#import "BasicParticleSystem.h"

struct BasicVertex {
    vec2 position;
    vec4 color;
    vec2 uv;
    float intensity;
};

@interface BasicParticleShader : Shader {
    BasicParticleSystem *psystem;
    std::vector<BasicVertex> vertices;
    std::vector<unsigned int> indices;
    GLint textureLoc; 
    GLuint texture;
}

-(id)initWithParticleSystem: (BasicParticleSystem*)p;

@end
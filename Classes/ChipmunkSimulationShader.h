#import "Shader.h"
#import "ChipmunkSimulation.h"

struct ChipmunkVertex {
    vec2 position;
    vec4 color;
    vec2 uv;
    float intensity;
};

@interface ChipmunkSimulationShader : Shader {
    ChipmunkSimulation *simulation;
    std::vector<ChipmunkVertex> vertices;
    std::vector<unsigned int> indices;
    GLint textureLoc; 
    GLuint texture;
}

-(id)initWithChipmunkSimulation: (ChipmunkSimulation*)s;

@end
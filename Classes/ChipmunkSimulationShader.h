#import "Shader.h"
#import "ChipmunkSimulation.h"

struct ChipmunkVertex {
    vec2 position;
    vec4 color;
    vec2 uv;
    float intensity;
    float isStatic;
};

@interface ChipmunkSimulationShader : Shader {
    ChipmunkSimulation *simulation;
    std::vector<ChipmunkVertex> vertices;
    std::vector<unsigned int> indices;
    float aspect;
    
    GLint textureLoc; 
    GLint aspectLoc;
    GLuint texture;
}

-(id)initWithChipmunkSimulation: (ChipmunkSimulation*)s aspect:(float)aspect;

@end
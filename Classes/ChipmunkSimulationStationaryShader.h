#import "Shader.h"
#import "ChipmunkSimulation.h"

struct ChipmunkStationaryVertex {
    vec2 position;
    vec4 color;
    vec2 uv;
};

@interface ChipmunkSimulationStationaryShader : Shader {
    ChipmunkSimulation *simulation;
    std::vector<ChipmunkStationaryVertex> vertices;
    std::vector<unsigned int> indices;
    float aspect;
    int numStationary;
    
    GLint textureLoc; 
    GLint aspectLoc;
    
    GLuint texture;
}

-(id)initWithChipmunkSimulation: (ChipmunkSimulation*)s aspect:(float)aspect;

@end
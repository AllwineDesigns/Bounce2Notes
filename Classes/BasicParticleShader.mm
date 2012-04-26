#import "BasicParticleShader.h"
#import <QuartzCore/QuartzCore.h>

enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    ATTRIB_UV,
    ATTRIB_INTENSITY,
    NUM_ATTRIBUTES
};

@implementation BasicParticleShader

-(id)initWithParticleSystem: (BasicParticleSystem*)p {
    psystem = p;
    vertices.resize(psystem->numParticles()*4);
    indices.resize(psystem->numParticles()*6);
      
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
  
    NSArray* images = [NSArray arrayWithObjects:@"ball.jpg", @"ball512.jpg", @"ball256.jpg", @"ball128.jpg", @"ball64.jpg", @"ball32.jpg", @"ball16.jpg", @"ball8.jpg", @"ball4.jpg", @"ball2.jpg", @"ball1.jpg", nil];

//    NSArray* images = [NSArray arrayWithObjects:@"ball.jpg", nil];

    int level = 0;
    
    for(NSString *name in images) {
        UIImage* image = [UIImage imageNamed:name];
        GLubyte* imageData = (GLubyte*)malloc(image.size.width * image.size.height * 4);

        CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
        CGContextRelease(imageContext); 
          
        glTexImage2D(GL_TEXTURE_2D, level, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        free(imageData);
        ++level;
    }
    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);

//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

//    glGenerateMipmap(GL_TEXTURE_2D);
    
    return [self initWithShaderPaths:@"BallShader" fragShader:@"BallShader"];
}

-(void)bindAttributeLocations {
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");   
    glBindAttribLocation(program, ATTRIB_UV, "uv");
    glBindAttribLocation(program, ATTRIB_INTENSITY, "intensity");
}

-(void)getUniformLocations {
    textureLoc = glGetUniformLocation(program, "texture");
}

-(void)updateAttributes {
    unsigned int numParticles = psystem->numParticles();
    if(vertices.size() != 4*numParticles) {
        vertices.resize(4*numParticles);
        indices.resize(6*numParticles);
    }
    
    const BasicParticle* particles = psystem->pointer();
    for(unsigned int i = 0; i < numParticles; i++) {
        unsigned int quad = 4*i;
        unsigned int tris = 6*i;
        
        unsigned int v0 = quad;
        unsigned int v1 = quad+1;
        unsigned int v2 = quad+2;
        unsigned int v3 = quad+3;
        
        const BasicParticle& p = particles[i];
        
        vec2 tr = vec2(p.size, p.size);
        vec2 tl = vec2(-p.size, p.size);
        vec2 bl = vec2(-p.size, -p.size);
        vec2 br = vec2(p.size, -p.size);
        
        tr += p.position;
        tl += p.position;
        bl += p.position;
        br += p.position;
        
        vertices[v0].position   = tr;
        vertices[v1].position = tl;
        vertices[v2].position = bl;
        vertices[v3].position = br;
        
        vertices[v0].color   = p.color;
        vertices[v1].color = p.color;
        vertices[v2].color = p.color;
        vertices[v3].color = p.color;
        
        vertices[v0].intensity   = p.intensity;
        vertices[v1].intensity = p.intensity;
        vertices[v2].intensity = p.intensity;
        vertices[v3].intensity = p.intensity;
        
        vertices[v0].uv   = vec2(1.f,1.f);
        vertices[v1].uv = vec2(0.f,1.f);
        vertices[v2].uv = vec2(0.f,0.f);
        vertices[v3].uv = vec2(1.f,0.f);
        
        indices[tris] = v0;
        indices[tris+1] = v1;
        indices[tris+2] = v3;
        
        indices[tris+3] = v1;
        indices[tris+4] = v2;
        indices[tris+5] = v3;
        
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i(textureLoc, 0);
    
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, sizeof(BasicVertex), &vertices[0]);

    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_FLOAT, 0, sizeof(BasicVertex), (char*)(&vertices[0])+sizeof(vec2));
    glVertexAttribPointer(ATTRIB_UV, 2, GL_FLOAT, 0, sizeof(BasicVertex), (char*)(&vertices[0])+sizeof(vec2)+sizeof(vec4));
    glVertexAttribPointer(ATTRIB_INTENSITY, 1, GL_FLOAT, 0, sizeof(BasicVertex), (char*)(&vertices[0])+sizeof(vec2)+sizeof(vec4)+sizeof(vec2));

    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glEnableVertexAttribArray(ATTRIB_UV);
    glEnableVertexAttribArray(ATTRIB_INTENSITY);
    
}

-(void)draw {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDrawElements(GL_TRIANGLES, 6*psystem->numParticles(), GL_UNSIGNED_INT, &indices[0]);
    glDisableVertexAttribArray(ATTRIB_VERTEX);
    glDisableVertexAttribArray(ATTRIB_COLOR);
    glDisableVertexAttribArray(ATTRIB_UV);
    glDisableVertexAttribArray(ATTRIB_INTENSITY);
}

@end
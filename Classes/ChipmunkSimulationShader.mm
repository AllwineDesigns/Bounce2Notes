//#import "ChipmunkSimulationShader.h"
#import <QuartzCore/QuartzCore.h>

enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    ATTRIB_UV,
    ATTRIB_INTENSITY,
    NUM_ATTRIBUTES
};

@implementation ChipmunkSimulationShader

-(id)initWithChipmunkSimulation: (ChipmunkSimulation*)s aspect:(float)a {
    aspect = a;
    simulation = s;
    vertices.resize(simulation->numBalls()*4);
    indices.resize(simulation->numBalls()*6);
      
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
  
//    NSArray* images = [NSArray arrayWithObjects:@"ball.jpg", @"ball512.jpg", @"ball256.jpg", @"ball128.jpg", @"ball64.jpg", @"ball32.jpg", @"ball16.jpg", @"ball8.jpg", @"ball4.jpg", @"ball2.jpg", @"ball1.jpg", nil];

//    NSArray* images = [NSArray arrayWithObjects:@"ball.jpg", nil];
    NSArray* images = [NSArray arrayWithObjects:@"ball_nocenterglow.jpg", nil];


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
    glGenerateMipmap(GL_TEXTURE_2D);

    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);

//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

//    glGenerateMipmap(GL_TEXTURE_2D);
    {
        glGenTextures(1, &pattern);
        glBindTexture(GL_TEXTURE_2D, pattern);
        UIImage* image = [UIImage imageNamed:@"spiral.jpg"];
  //      UIImage* image = [UIImage imageNamed:@"squares.jpg"];
  //      UIImage* image = [UIImage imageNamed:@"stripes.jpg"];
  //      UIImage* image = [UIImage imageNamed:@"sections.jpg"];
  //      UIImage* image = [UIImage imageNamed:@"black.jpg"];
  //      UIImage* image = [UIImage imageNamed:@"white.jpg"];
  //      UIImage* image = [UIImage imageNamed:@"checkered.jpg"];
  //      UIImage* image = [UIImage imageNamed:@"weave.jpg"];


        
        GLubyte* imageData = (GLubyte*)malloc(image.size.width * image.size.height * 4);
        
        CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
        CGContextRelease(imageContext); 
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.size.width, image.size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        free(imageData);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    
    return [self initWithShaderPaths:@"BallShader" fragShader:@"BallShader"];
}

-(void)bindAttributeLocations { /*
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");   
    glBindAttribLocation(program, ATTRIB_UV, "uv");
    glBindAttribLocation(program, ATTRIB_INTENSITY, "intensity");*/
}

-(void)getUniformLocations {/*
    textureLoc = glGetUniformLocation(program, "texture");
    patternLoc = glGetUniformLocation(program, "pattern");

    aspectLoc = glGetUniformLocation(program, "aspect");*/
}
 
 //do quads
-(void)updateAttributes {
    unsigned int numParticles = simulation->numBalls();
    if(vertices.size() != 4*numParticles) {
        vertices.resize(4*numParticles);
        indices.resize(6*numParticles);
    }
    
    cpBody* const* bodies = simulation->bodiesPointer();
    cpShape* const* shapes = simulation->shapesPointer();
    
    for(unsigned int i = 0; i < numParticles; i++) {
        unsigned int quad = 4*i;
        unsigned int tris = 6*i;
        
        unsigned int v0 = quad;
        unsigned int v1 = quad+1;
        unsigned int v2 = quad+2;
        unsigned int v3 = quad+3;
        
        const cpShape* shape = shapes[i];
        const cpBody* body = bodies[i];
                
        BallData *ballData = (BallData*)cpBodyGetUserData(body);

        float radius = 2*cpCircleShapeGetRadius(shape);
        cpVect pos = cpBodyGetPos(body);
        vec2 position(pos.x, pos.y);
        vec4 color(ballData->color);
        
        float angle = cpBodyGetAngle(body);
        
      //  if(isStatic) {
      //      color = vec4(0., 0.4, 0., 1);
      //  }
        float intensity = ballData->intensity;

        vec2 tr = vec2(radius, radius)+ballData->tr;
        vec2 tl = vec2(-radius, radius)+ballData->tl;
        vec2 bl = vec2(-radius, -radius)+ballData->bl;
        vec2 br = vec2(radius, -radius)+ballData->br;
        
        tr.rotate(-angle);
        tl.rotate(-angle);
        bl.rotate(-angle);
        br.rotate(-angle);
        
        tr += position;
        tl += position;
        bl += position;
        br += position;
        
        vertices[v0].position   = tr;
        vertices[v1].position = tl;
        vertices[v2].position = bl;
        vertices[v3].position = br;
        
        vertices[v0].color   = color;
        vertices[v1].color = color;
        vertices[v2].color = color;
        vertices[v3].color = color;
        
        vertices[v0].intensity   = intensity;
        vertices[v1].intensity = intensity;
        vertices[v2].intensity = intensity;
        vertices[v3].intensity = intensity;
        
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
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, pattern);
    
    glUniform1i(textureLoc, 0);
    glUniform1i(patternLoc, 1);

    glUniform1f(aspectLoc, aspect);
    
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, sizeof(ChipmunkVertex), &vertices[0]);

    glVertexAttribPointer(ATTRIB_COLOR, 4, GL_FLOAT, 0, sizeof(ChipmunkVertex), (char*)(&vertices[0])+sizeof(vec2));
    glVertexAttribPointer(ATTRIB_UV, 2, GL_FLOAT, 0, sizeof(ChipmunkVertex), (char*)(&vertices[0])+sizeof(vec2)+sizeof(vec4));
    glVertexAttribPointer(ATTRIB_INTENSITY, 1, GL_FLOAT, 0, sizeof(ChipmunkVertex), (char*)(&vertices[0])+sizeof(vec2)+sizeof(vec4)+sizeof(vec2));
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_COLOR);
    glEnableVertexAttribArray(ATTRIB_UV);
    glEnableVertexAttribArray(ATTRIB_INTENSITY);    
}

-(void)draw {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDrawElements(GL_TRIANGLES, 6*simulation->numBalls(), GL_UNSIGNED_INT, &indices[0]);
    glDisableVertexAttribArray(ATTRIB_VERTEX);
    glDisableVertexAttribArray(ATTRIB_COLOR);
    glDisableVertexAttribArray(ATTRIB_UV);
    glDisableVertexAttribArray(ATTRIB_INTENSITY);

}

@end
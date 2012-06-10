//
//  BounceKillBoxShader.m
//  ParticleSystem
//
//  Created by John Allwine on 6/9/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceKillBoxShader.h"

enum {
    ATTRIB_VERTEX,
    NUM_ATTRIBUTES
};

@implementation BounceKillBoxShader
-(id)initWithChipmunkSimulation: (ChipmunkSimulation*)s aspect:(float)a {
    aspect = a;
    simulation = s;

    return [self initWithShaderPaths:@"BounceKillBoxShader" fragShader:@"BounceKillBoxShader"];
}

-(void)bindAttributeLocations {
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
}

-(void)getUniformLocations {
    aspectLoc = glGetUniformLocation(program, "aspect");
}

//do quads
-(void)updateAttributes {
    
    float topY = simulation->removingBallsTopY();
    float bottomY = simulation->removingBallsBottomY();
    float leftX = simulation->removingBallsLeftX();
    float rightX = simulation->removingBallsRightX();

    
    vertices[0].x = rightX;
    vertices[3].x = rightX;
    vertices[4].x = rightX;
    
    vertices[1].x = leftX;
    vertices[2].x = leftX;
    
    vertices[0].y = topY;
    vertices[1].y = topY;
    vertices[4].y = topY;
    
    vertices[2].y = bottomY;
    vertices[3].y = bottomY;
   
    glUniform1f(aspectLoc, aspect);
    
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, sizeof(vec2), vertices);
        
    glEnableVertexAttribArray(ATTRIB_VERTEX);
}

-(void)draw {
    glDrawArrays(GL_LINE_STRIP, 0, 5);
    glDisableVertexAttribArray(ATTRIB_VERTEX);
    
}
@end

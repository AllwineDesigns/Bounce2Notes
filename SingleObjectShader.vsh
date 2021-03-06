//
//  SingleBallShader.vsh
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

attribute vec2 position;
attribute vec2 shapeUV;
attribute vec2 patternUV;

varying vec2 shapeUVVarying;
varying vec2 patternUVVarying;

uniform float aspect;

void main()
{
    //gl_Position = vec4(position.x, position.y*0.563380, 0, 1);
    gl_Position = vec4(position.x, position.y*aspect, 0, 1);
    
    shapeUVVarying = shapeUV;
    patternUVVarying = patternUV;
}

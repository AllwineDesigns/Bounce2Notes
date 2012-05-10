//
//  BallShader.vsh
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

attribute vec2 position;
attribute vec4 color;
attribute vec2 uv;
attribute float intensity;

varying vec4 colorVarying;
varying vec2 uvVarying;
varying float intensityVarying;

uniform float aspect;

void main()
{
    gl_Position = vec4(position.x, position.y*aspect, 0, 1);
    colorVarying = color;
    uvVarying = uv;
    intensityVarying = intensity;
}

//
//  BillboardShader.vsh
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

attribute vec2 position;
attribute vec2 uv;
attribute lowp float intensity;

varying vec2 uvVarying;
varying lowp float intensityVarying;

uniform float aspect;

void main()
{
    gl_Position = vec4(position.x, position.y*aspect, 0., 1.);
    uvVarying = uv;
    intensityVarying = intensity;
}

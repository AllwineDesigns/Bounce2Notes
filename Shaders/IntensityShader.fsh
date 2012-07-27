//
//  Shader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//


uniform lowp vec4 color;

varying lowp float intensityVarying;

void main()
{
    gl_FragColor = intensityVarying*color;
}

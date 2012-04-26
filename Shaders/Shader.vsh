//
//  Shader.vsh
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

void main()
{
    gl_Position = position;
    gl_PointSize = 2.0;
    colorVarying = color;
}

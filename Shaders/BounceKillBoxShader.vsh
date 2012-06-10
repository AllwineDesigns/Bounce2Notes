//
//  Shader.vsh
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

attribute vec4 position;

uniform float aspect;

void main()
{
    gl_Position = vec4(position.x, position.y*aspect, 0., 1.);
}

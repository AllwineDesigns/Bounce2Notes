//
//  SingleBallShader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec2 uvVarying;

uniform lowp vec4 color;
uniform lowp float intensity;
uniform lowp sampler2D shapeTexture;

void main()
{    
    lowp vec4 texColor = texture2D(shapeTexture, uvVarying);
    lowp float r = texColor.r;
    lowp float g = texColor.g;
    lowp float b = texColor.b;
     
    lowp float t = intensity*g;
    lowp vec4 col;
    col = t*color;

    col.a = 0.;

    gl_FragColor = col;
}

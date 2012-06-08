//
//  BallShader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 uvVarying;
varying lowp float intensityVarying;

uniform lowp sampler2D texture;
uniform lowp sampler2D pattern;

void main()
{
    lowp vec4 patColor = texture2D(pattern, uvVarying);
    
    lowp vec4 texColor = texture2D(texture, uvVarying);
    lowp float r = texColor.r;
    lowp float g = texColor.g;
    lowp float b = texColor.b;
     
    lowp float t = intensityVarying*g;
    lowp float t2 = b*t;
    lowp vec4 col;
    col = (t+.3*b)*colorVarying+r*colorVarying*patColor;

    col += vec4(t2,t2,t2,0.);
    col.a = r;

    gl_FragColor = col;
}

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

void main()
{
    lowp vec4 texColor = texture2D(texture, uvVarying);
    lowp float r = texColor.r;
    lowp float g = texColor.g;
    lowp float b = texColor.b;
    
//    lowp float t = intensityVarying*texColor.g;
//    lowp float t1 = t < .5 ? 2.*t : 1. ;
//    lowp float t2 = t > .3 ? 1.25*(t-.3) : 0.;
//    lowp vec4 col = (texColor.r+texColor.b)*colorVarying+(.7*t2+texColor.b*intensityVarying)*vec4(1.,1.,1.,0.)+.8*t1*vec4(colorVarying.rgb, 0.);
    
//    lowp vec4 col = vec4(1.,1.,1.,1.);  
    lowp float t = intensityVarying*g;
    lowp float t2 = b*t;
    lowp vec4 col = (r+b+t)*colorVarying;
    col += vec4(t2,t2,t2,0.);
    col.a = r;

    gl_FragColor = col;
}

//
//  BallShader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec2 shapeUVVarying;
varying lowp vec2 patternUVVarying;

uniform lowp sampler2D shapeTexture;
uniform lowp sampler2D patternTexture;
uniform lowp sampler2D stationaryTex;

uniform lowp vec4 color;
uniform lowp float intensity;


void main()
{
    lowp vec4 stationaryColor = texture2D(stationaryTex, shapeUVVarying);
    lowp vec4 patColor = texture2D(patternTexture, patternUVVarying);
    lowp vec4 texColor = texture2D(shapeTexture, shapeUVVarying);
    lowp float r = texColor.r;
    lowp float g = texColor.g;
    lowp float b = texColor.b;
    
    lowp float s = stationaryColor.r;
    lowp float sa = stationaryColor.a;
    
    lowp float t = intensity*g+.3*b*(1.-sa);
    
    lowp vec4 col;
    
    col = t*color+(1.-sa)*r*color*patColor+color*s*(patColor+vec4(.2,.2,.2,0.));
    
    col.a = r*patColor.a*color.a;
    
    gl_FragColor = col;
}

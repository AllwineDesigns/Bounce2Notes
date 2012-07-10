//
//  SingleBallShader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec2 shapeUVVarying;
varying lowp vec2 patternUVVarying;

uniform lowp vec4 color;
uniform lowp float intensity;
uniform lowp sampler2D shapeTexture;
uniform lowp sampler2D patternTexture;

void main()
{
    lowp vec4 patColor = texture2D(patternTexture, patternUVVarying);
    
    lowp vec4 texColor = texture2D(shapeTexture, shapeUVVarying);
    lowp float r = texColor.r;
    lowp float g = texColor.g;
    lowp float b = texColor.b;
    
    lowp float t = intensity*g+.3*b;

    lowp vec4 col;
    col = t*color+r*color*patColor;

    col.a = r*patColor.a;

    gl_FragColor = col;
//    gl_FragColor = patColor;
//    gl_FragColor = texColor;
//    gl_FragColor = vec4(.3,.3,.3, .3);
}

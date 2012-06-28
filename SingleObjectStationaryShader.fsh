//
//  BallShader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec2 uvVarying;
varying lowp vec2 patternUVVarying;

uniform lowp sampler2D texture;
uniform lowp sampler2D pattern;

uniform lowp vec4 color;

void main()
{
    lowp vec4 texColor = texture2D(texture, uvVarying);
    lowp vec4 patternColor = texture2D(pattern, patternUVVarying)+vec4(.2,.2,.2,0.);

    gl_FragColor = color*texColor*patternColor;
}

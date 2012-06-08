//
//  BallShader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec4 colorVarying;
varying lowp vec2 uvVarying;

uniform lowp sampler2D texture;

void main()
{
    lowp vec4 texColor = texture2D(texture, uvVarying);

    gl_FragColor = colorVarying*texColor;
}

//
//  BillboardShader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec2 uvVarying;

uniform lowp sampler2D texture;

void main()
{
    gl_FragColor = texture2D(texture, uvVarying);
}

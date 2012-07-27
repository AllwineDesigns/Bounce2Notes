//
//  BillboardShader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec2 uvVarying;
varying lowp float intensityVarying;

uniform lowp sampler2D texture;
uniform lowp vec4 color;

void main()
{
    gl_FragColor = intensityVarying*color*texture2D(texture, uvVarying);
  //  gl_FragColor = vec4(.5,.5,.5,.5);
}

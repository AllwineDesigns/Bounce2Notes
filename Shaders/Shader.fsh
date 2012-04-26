//
//  Shader.fsh
//  ParticleSystem
//
//  Created by John Allwine on 4/16/12.
//  Copyright 2012 John Allwine. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}

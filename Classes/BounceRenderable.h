//
//  BounceRenderable.h
//  ParticleSystem
//
//  Created by John Allwine on 7/2/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <fsa/Vector.hpp>
#import "FSATexture.h"
#import "FSABuffer.h"

using namespace fsa;

typedef struct {
    float intensity;
    BOOL isStationary;
    vec4 color;
    vec2 position;
    float size;
    float angle;
    FSATexture* patternTexture;
} BounceRenderableData;

typedef struct {
    float *intensity;
    BOOL *isStationary;
    vec4 *color;
    vec2 *position;
    float *size;
    float *angle;
    FSATexture **patternTexture;
} BounceRenderableInputs;

@interface BounceRenderable : NSObject {    
    BounceRenderableInputs _inputs;
    
    GLenum _mode;
    GLenum _blendMode;
    
    FSATexture* _shapeTexture;
    FSATexture* _stationaryTexture;
    
    float _bounciness;

    vec2 *_verts;
    vec2 *_vertsUntransformed;
    vec2 *_vertOffsets;
    vec2 *_vertVels;
    vec2 *_vertShapeUVs;
    vec2 *_vertPatternUVs;
    unsigned int _numVerts;

    FSABuffer *_indexBuffer;
}
@property (nonatomic) GLenum blendMode;
@property (nonatomic) BounceRenderableInputs inputs;
@property (nonatomic) float bounciness;
@property (nonatomic, retain) FSATexture* shapeTexture;
@property (nonatomic, retain) FSATexture* stationaryTexture;

-(id)initWithData:(BounceRenderableData&) data;
-(id)initWithInputs: (BounceRenderableInputs)inputs;
-(void)step: (float)dt;
-(void)draw;
-(void)drawSelected;
-(void)burst:(float)scale;
-(void)collideAt:(const vec2 &)pos withVelocity:(const vec2 &)vel;
-(void)scalePatternUVs:(const vec2&)scale;
-(void)translatePatternUVs:(const vec2&)translate;
-(void)setPatternUVsForTextureSheetAtRow:(unsigned int)row col:(unsigned int)col numRows:(unsigned int)rows numCols:(unsigned int)cols;


@end

@interface BounceBallRenderable : BounceRenderable {
}
@end

@interface BounceGenericRenderable : BounceRenderable {
}
@end

@interface BounceSquareRenderable : BounceRenderable {
}
@end

@interface BounceNoteRenderable : BounceRenderable {
}
@end

@interface BouncePentagonRenderable : BounceRenderable {
}
@end

@interface BounceStarRenderable : BounceRenderable {
}
@end

@interface BounceTriangleRenderable : BounceRenderable {
}
@end

@interface BounceRectangleRenderable : BounceRenderable {
    float _aspect;
    
    vec2 _vertsUntransformedRectangle[4];
    vec2 _vertOffsetsRectangle[4];
}
-(id)initWithInputs:(BounceRenderableInputs)inputs aspect:(float)aspect;
-(void)setAspect:(float)aspect;
-(float)aspect;
@end

@interface BounceCapsuleRenderable : BounceRectangleRenderable {

}
-(id)initWithInputs:(BounceRenderableInputs)inputs aspect:(float)aspect;
@end


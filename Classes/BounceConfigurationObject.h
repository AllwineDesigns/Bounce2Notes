//
//  BounceConfigurationObject.h
//  ParticleSystem
//
//  Created by John Allwine on 6/30/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceObject.h"

@interface BounceConfigurationObject : BounceObject {
    BounceObject *_previewObject;
    BOOL _previewing;
}

-(void)setPreviewObject:(BounceObject*)obj;
-(BounceObject*)previewObject;

-(void)previewChange;
-(void)cancelChange;
-(void)finalizeChange;

@end

@interface BounceShapeConfigurationObject : BounceConfigurationObject {
    BounceShape _originalShape;
}
@end;

@interface BouncePatternConfigurationObject : BounceConfigurationObject {
    GLuint _originalPattern;
}
@end;

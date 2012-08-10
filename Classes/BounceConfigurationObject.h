//
//  BounceConfigurationObject.h
//  ParticleSystem
//
//  Created by John Allwine on 6/30/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceObject.h"
#import "fsa/Noise.hpp"

@interface BounceConfigurationObject : BounceObject {
    BounceObject *_previewObject;
    BOOL _previewing;
    BOOL _painting;
    float _timeSinceLastCreate;
}

@property (nonatomic) BOOL painting;
@property (nonatomic) float timeSinceLastCreate;

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
    FSATexture* _originalPattern;
}
@property (nonatomic, retain) FSATexture* originalPattern;
@end;

@interface BounceSizeConfigurationObject : BounceConfigurationObject {
    float _originalSize;
    float _originalSecondarySize;
}
@end;

@interface BounceColorConfigurationObject : BounceConfigurationObject {
    vec4 _originalColor;
}
@end;

@interface BouncePastelColorConfigurationObject : BounceColorConfigurationObject {
}
@end;

@interface BounceRedColorConfigurationObject : BounceColorConfigurationObject {
}
@end;

@interface BounceOrangeColorConfigurationObject : BounceColorConfigurationObject {
}
@end;

@interface BounceYellowColorConfigurationObject : BounceColorConfigurationObject {
}
@end;

@interface BounceGreenColorConfigurationObject : BounceColorConfigurationObject {
}
@end;

@interface BounceBlueColorConfigurationObject : BounceColorConfigurationObject {
}
@end;

@interface BouncePurpleColorConfigurationObject : BounceColorConfigurationObject {
}
@end;

@interface BounceGrayColorConfigurationObject : BounceColorConfigurationObject {
}
@end;

@interface BounceNoteConfigurationObject : BounceConfigurationObject {
    id<BounceSound> _originalNote;
}
@property (nonatomic,retain) id<BounceSound> originalNote;
@end;

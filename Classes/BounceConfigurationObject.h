//
//  BounceConfigurationObject.h
//  ParticleSystem
//
//  Created by John Allwine on 6/30/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceObject.h"
#import "BounceColorGenerator.h"
#import "fsa/Noise.hpp"

@interface BounceConfigurationObject : BounceObject {
    BOOL _painting;
    float _timeSinceLastCreate;
    
    NSMutableDictionary *_originals;
    NSMutableSet *_previewObjects;
}

@property (nonatomic) BOOL painting;
@property (nonatomic) float timeSinceLastCreate;

-(void)setPreviewObject:(BounceObject*)obj;
-(void)setPreviewObjects:(NSSet*)objects;
-(NSSet*)previewObjects;

-(void)finalizeChanges;
-(void)cancelChanges;

-(id)originalValueForObject:(BounceObject*)obj;
-(void)setConfigurationValueForObject:(BounceObject*)obj;
-(void)setValue: (id)val forObject:(BounceObject*)obj;

@end

@interface BounceShapeConfigurationObject : BounceConfigurationObject {
}
@end;

@interface BouncePatternConfigurationObject : BounceConfigurationObject {
}
@end;

@interface BounceSizeOriginal : NSObject {
    float _size;
    float _size2; 
}

@property (nonatomic) float size;
@property (nonatomic) float secondarySize;

+(BounceSizeOriginal*)sizeWithSize:(float)size secondarySize:(float)size2;

@end

@interface BounceSizeConfigurationObject : BounceConfigurationObject {

}
@end;

@interface BounceColorOriginal : NSObject {
    vec4 _color;
}

@property (nonatomic) vec4 color;

+(BounceColorOriginal*)colorWithColor:(const vec4&)col;

@end

@interface BounceColorConfigurationObject : BounceConfigurationObject {
    BounceColorGenerator *_colorGenerator;
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
}
@end;

@interface BouncePasteOriginal : NSObject {
    BounceShape _bounceShape;
    FSATexture* _patternTexture;
    vec4 _color;
    id<BounceSound> _sound;
    float _size;
    float _size2;
}

@property (nonatomic) BounceShape bounceShape;
@property (nonatomic,retain) FSATexture* patternTexture;
@property (nonatomic) const vec4& color;
@property (nonatomic,retain) id<BounceSound> sound;
@property (nonatomic) float size;
@property (nonatomic) float secondarySize;

@end

@interface BouncePasteConfigurationObject : BounceConfigurationObject {
    BOOL _hasCopied;
}

@property (nonatomic) BOOL hasCopied;

@end
@interface BounceCopyConfigurationObject : BounceConfigurationObject {
    BouncePasteConfigurationObject *_pasteObj;
}
-(id)initWithPasteObject:(BouncePasteConfigurationObject*)pasteObj;
@end

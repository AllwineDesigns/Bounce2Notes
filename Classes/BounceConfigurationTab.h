//
//  BounceConfigurationTab.h
//  ParticleSystem
//
//  Created by John Allwine on 7/11/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceObject.h"

@class BouncePane;

@interface BounceConfigurationTab : BounceObject {
    unsigned int _index;
    BouncePane *_pane;
    vec2 _offset;
}
@property (nonatomic, readonly) const vec2& offset;

-(id)initWithPane:(BouncePane*)pane index:(unsigned int)index offset:(const vec2&)offset;
@end

//
//  BounceConfigurationObject.m
//  ParticleSystem
//
//  Created by John Allwine on 6/30/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationObject.h"

@implementation BounceConfigurationObject

-(BounceObject*)previewObject {
    return _previewObject;
}

-(void)setPreviewObject:(BounceObject*)obj {
    if(obj != _previewObject) {
        if(_previewObject) {
            [self cancelChange];
            _previewing = NO;
        }
        
        [obj retain];
        [_previewObject release];
        _previewObject = obj;
        
        if(obj) {
            [self previewChange];
            _previewing = YES;
        }
    }
}

-(void)previewChange {
    NSAssert(NO, @"preview change must be implemented by a subclass\n");    
}

-(void)cancelChange {
    NSAssert(NO, @"cancel change must be implemented by a subclass\n");    
}

-(void)finalizeChange {
    _previewing = NO;
    [_previewObject release];
    _previewObject = nil;
}

-(void)draw {
    if(_previewing) {
        [_previewObject drawSelected];
    } else {
        [super draw];
    }
}

-(void)dealloc {
    [_previewObject release]; _previewObject = nil;
    [super dealloc];
}

@end


@implementation BounceShapeConfigurationObject

-(void)previewChange {
    _originalShape = _previewObject.bounceShape;
    
    _previewObject.bounceShape = _bounceShape;
}

-(void)cancelChange {
    _previewObject.bounceShape = _originalShape;
}

@end

@implementation BouncePatternConfigurationObject

-(void)previewChange {
    _originalPattern = _previewObject.patternTexture;
    
    _previewObject.patternTexture  = _patternTexture;
}

-(void)cancelChange {
    _previewObject.patternTexture = _originalPattern;
}

@end
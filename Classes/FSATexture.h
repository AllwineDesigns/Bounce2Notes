//
//  FSATexture.h
//  ParticleSystem
//
//  Created by John Allwine on 7/3/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSATexture : NSObject  {
    NSString *_key;
}
@property (nonatomic, retain) NSString *key;
@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) unsigned int width;
@property (nonatomic, readonly) unsigned int height;
@property (nonatomic, readonly) float aspect;
@property (nonatomic, readonly) float inverseAspect;

-(id)initWithKey:(NSString*)key name: (GLuint)name width:(unsigned int)width height:(unsigned int)height;
-(void)memoryWarning;
-(void)needsSize:(float)size;
-(void)deleteTexture;

@end

@class FSASmartTexture;
@interface BackgroundTextureLoaderOperation : NSOperation
@property (nonatomic, retain) FSASmartTexture* texture;
@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) unsigned int width;
@property (nonatomic, readonly) unsigned int height;
@property (nonatomic, readonly) unsigned int prefix;
-(id)initWithFile:(NSString*)file prefix:(unsigned int)prefix forTexture:(FSASmartTexture*)texture;
@end

@interface FSASmartTexture : FSATexture 
-(id)initWithFile:(NSString*)file minPrefix:(unsigned int)minPrefix maxPrefix:(unsigned int)maxPrefix;
-(void)needsSize:(float)size;
-(void)finishedLoadingTexture:(BackgroundTextureLoaderOperation*)loader;
@end

@class FSATextTexture;
@interface BackgroundTextTextureLoaderOperation : NSOperation
@property (nonatomic, retain) FSATextTexture* texture;
@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) NSString* text;
@property (nonatomic, readonly) unsigned int width;
@property (nonatomic, readonly) unsigned int height;
-(id)initWithText:(NSString*)txt forTexture:(FSATextTexture*)texture;
@end

@interface FSATextTexture : FSATexture
@property (nonatomic, retain) NSString* text;

-(id)initWithText:(NSString*)text;
-(void)finishedLoadingTexture:(BackgroundTextTextureLoaderOperation*)loader;

@end



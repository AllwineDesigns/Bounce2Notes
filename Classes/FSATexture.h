//
//  FSATexture.h
//  ParticleSystem
//
//  Created by John Allwine on 7/3/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSATexture : NSObject  
@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) unsigned int width;
@property (nonatomic, readonly) unsigned int height;
@property (nonatomic, readonly) float aspect;
@property (nonatomic, readonly) float inverseAspect;

-(id)initWithName: (GLuint)name width:(unsigned int)width height:(unsigned int)height;
-(void)memoryWarning;
-(void)needsSize:(float)size;
-(void)deleteTexture;

@end

@interface FSASmartTexture : FSATexture 
-(id)initWithFile:(NSString*)file minPrefix:(unsigned int)minPrefix maxPrefix:(unsigned int)maxPrefix;
-(void)needsSize:(float)size;
-(void)finishedLoadingTexture:(NSNotification*)notification;
@end

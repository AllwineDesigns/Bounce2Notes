//
//  MainBounceSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSimulation.h"
#import "BounceKillArena.h"
#import "BounceConfigurationPane.h"

@protocol BounceSaveLoadDelegate <NSObject>

-(void)saveSimulation;
-(void)loadSimulation:(NSString*)file;
-(void)loadBuiltInSimulation:(NSString*)file;
-(void)deleteSimulation:(NSString*)file;

@end

@interface MainBounceSimulation : BounceSimulation <BounceSaveLoadDelegate> {
    float _aspect;
    BounceKillArena *_killArena;
    id<BounceSaveLoadDelegate> _delegate;
}

@property (nonatomic, assign) id<BounceSaveLoadDelegate> delegate;

-(id)initWithAspect:(float)aspect;

-(void)beginTopSwipe:(void*)uniqueId at:(float)y;
-(void)topSwipe:(void*)uniqueId at:(float)y;
-(void)endTopSwipe:(void*)uniqueId;

-(void)beginBottomSwipe:(void*)uniqueId at:(float)y;
-(void)bottomSwipe:(void*)uniqueId at:(float)y;
-(void)endBottomSwipe:(void*)uniqueId;

-(void)beginLeftSwipe:(void*)uniqueId at:(float)x;
-(void)leftSwipe:(void*)uniqueId at:(float)x;
-(void)endLeftSwipe:(void*)uniqueId;

-(void)beginRightSwipe:(void*)uniqueId at:(float)x;
-(void)rightSwipe:(void*)uniqueId at:(float)x;
-(void)endRightSwipe:(void*)uniqueId;

@end

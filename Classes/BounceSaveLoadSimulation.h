//
//  BounceSaveLoadSimulation.h
//  ParticleSystem
//
//  Created by John Allwine on 9/2/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationSimulation.h"
#import "BounceButton.h"
#import "BounceSlider.h"

@interface BounceSaveList : NSObject {
    unsigned int _page;
    unsigned int _pages;
    unsigned int _builtInPages;
    unsigned int _savePages;
    
    unsigned int _filesPerPage;
    
    NSArray *_builtInFiles;
    NSArray *_saveFiles;
}
@property (nonatomic, assign) unsigned int filesPerPage;
-(id)initWithFilesPerPage:(unsigned int)f;

-(void)setPage:(unsigned int)page;
-(unsigned int)numPages;

-(BOOL)isBuiltIn;
-(NSArray*)fileList;

-(void)update;

@end

@interface BounceLoadObject : BounceObject {
    NSString *_file;
    BOOL _longTouched;
    NSTimeInterval _longTouchedTimestamp;
    FSATexture *_backupPattern;
    BOOL _isBuiltIn;
}

@property (nonatomic, retain) FSATexture* backupPattern;

-(id)initWithFile:(NSString*)file;
-(NSString*)file;

-(void)setBuiltIn:(BOOL)b;
-(BOOL)isBuiltIn;

-(void)setLongTouched:(BOOL)l;
-(BOOL)longTouched;
@end

@interface BounceSaveLoadSimulation : BounceConfigurationSimulation <BounceButtonDelegate,BounceSliderDelegate> {
    BounceButton *_save;
    BounceSlider *_pageSlider;
    
    BounceSaveList *_saveList;
    unsigned int _numObjectsPerPage;
    BOOL _isIPad;
}

-(void)updateSavedSimulations;

@end

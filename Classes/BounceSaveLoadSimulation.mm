//
//  BounceSaveLoadSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 9/2/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceSaveLoadSimulation.h"
#import "BounceConfigurationObject.h"
#import "FSATextureManager.h"
#import "BounceNoteManager.h"
#import "BounceFileManager.h"
#import "BounceConstants.h"
#import "FSAUtil.h"

@implementation BounceSaveList

@synthesize filesPerPage = _filesPerPage;

-(id)initWithFilesPerPage:(unsigned int)f {
    _page = 0;
    _filesPerPage = f;
    [self update];
    
    return self;
}

-(void)setFilesPerPage:(unsigned int)filesPerPage {
    _filesPerPage = filesPerPage;
    [self update];
}

-(void)setPage:(unsigned int)page {
    if(page < _pages) {
        _page = page;
    }
}
-(unsigned int)numPages {
    return _pages;
}

-(BOOL)isBuiltIn {
    return _page < _builtInPages;
}
-(NSArray*)fileList {
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:_filesPerPage];

    if(_page < _builtInPages) {
        int numFiles = [_builtInFiles count];
        for(int i = 0; i < _filesPerPage; i++) {
            if(_page*_filesPerPage+i < numFiles) {
                [files addObject:[_builtInFiles objectAtIndex:_page*_filesPerPage+i]];
            }
        }
    } else {
        int numFiles = [_saveFiles count];
        for(int i = 0; i < _filesPerPage; i++) {
            if((_page-_builtInPages)*_filesPerPage+i < numFiles) {
                [files addObject:[_saveFiles objectAtIndex:(_page-_builtInPages)*_filesPerPage+i]];
            }
        }

    }
    
    return files;
}
-(void)update {
    [_builtInFiles release];
    [_saveFiles release];
    
    _builtInFiles = [[[BounceFileManager instance] allBuiltInFiles] retain];
    _saveFiles = [[[BounceFileManager instance] allFiles] retain];
    
    _builtInPages = (([_builtInFiles count]-1)/_filesPerPage)+1;
    if([_saveFiles count] == 0) {
        _savePages = 1;
    } else {
        _savePages = (([_saveFiles count]-1)/_filesPerPage)+1;
    }
    
    _pages = _builtInPages+_savePages;
    
    if(_page >= _pages) {
        _page = _pages-1;
    }
}

@end

@implementation BounceLoadObject

-(id)initWithFile:(NSString *)file {
    self = [super initObjectWithShape:BOUNCE_BALL at:vec2(0,-2) withVelocity:vec2() withColor:[[BounceSettings instance].colorGenerator randomColor] withSize:.25 withAngle:0];
    
    if(self) {
        _file = [file copy];
        _isRemovable = NO;
        _isPreviewable = NO;
        self.bounceShape = BOUNCE_CAPSULE;
        FSATexture *tex = [[FSATextTexture alloc ] initWithText:_file];
        self.patternTexture = tex;
        [tex release];
        self.position = vec2();

        self.sound = [[BounceNoteManager instance] getRest];

    }
    return self;
}

-(NSString*)file {
    return _file;
}

-(void)setBuiltIn:(BOOL)b {
    _isBuiltIn = b;
    if(_isBuiltIn) {
        self.bounceShape = BOUNCE_RECTANGLE;
    } else {
        self.bounceShape = BOUNCE_CAPSULE;
    }
}

-(BOOL)isBuiltIn {
    return _isBuiltIn;
}

-(BOOL)longTouched {
    return _longTouched;
}

-(void)setLongTouched:(BOOL)l {
    if(!_longTouched && l) {
        _longTouchedTimestamp = [[NSProcessInfo processInfo] systemUptime];
        self.backupPattern = self.patternTexture;
        self.patternTexture = [[FSATextureManager instance] getTexture:@"X"];
        [_renderable burst:5];
    } else if(_longTouched && !l) {
        self.patternTexture = self.backupPattern;
        self.backupPattern = nil;
        [_renderable burst:5];
    }
    _longTouched = l;
}

-(void)step:(float)dt {
    [super step:dt];
    
    if(_longTouched) {
        NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
        if(now-_longTouchedTimestamp > 2) {
            [self setLongTouched:NO];
        }
    }
    
}

-(void)dealloc {
    [_file release];
    [_backupPattern release];
    [super dealloc];
}

@end

@implementation BounceSaveLoadSimulation

-(void)setupSaveButton {
    CGSize dimensions = self.arena.dimensions;
    
    BounceButton *button = [[BounceButton alloc] init];
    button.patternTexture = [[FSATextureManager instance] getTexture:@"Save"];
    button.bounceShape = BOUNCE_CAPSULE;
    button.size = dimensions.width*.1;
    button.secondarySize = dimensions.height*.08;
    button.position = vec2(-2,0);
    button.isStationary = NO;
    button.sound = [[BounceNoteManager instance] getRest];
    
    button.delegate = self;
    
  //  [button addToSimulation:self];
    
    _save = button;
}

-(void)setupPageSlider {
    int index = 0;

    if(_pageSlider) {
        index = _pageSlider.index;
        [_pageSlider removeFromSimulation];
        [_pageSlider release];
    }
    
    NSMutableArray *pageLabels = [NSMutableArray arrayWithCapacity:10];
    int numPages = [_saveList numPages];
    for(int i = 0; i < numPages; i++) {
        [pageLabels addObject:@""];
    }
    if(index >= numPages) {
        index = numPages-1;
    }
    
    CGSize dimensions = self.arena.dimensions;
    
    _pageSlider = [[BounceSlider alloc] initWithLabels:pageLabels index:index];
    _pageSlider.handle.bounceShape = BOUNCE_CAPSULE;
    _pageSlider.handle.size = .35*dimensions.width/numPages-.01;
    _pageSlider.handle.secondarySize = .04*[[BounceConstants instance] unitsPerInch];
    _pageSlider.handle.sound = [[BounceNoteManager instance] getRest];
    _pageSlider.handle.patternTexture = [[FSATextureManager instance] getTexture:@"white.jpg"];
    _pageSlider.handle.isStationary = NO;
    
    _pageSlider.padding = _pageSlider.handle.size+.005;
    
    _pageSlider.track.position = vec2(-2,0);
    _pageSlider.track.size = .35*dimensions.width;
    _pageSlider.track.secondarySize = _pageSlider.handle.secondarySize*1.2;
    
    _pageSlider.track.sound = [[BounceNoteManager instance] getRest];
    _pageSlider.track.patternTexture = [[FSATextureManager instance] getTexture:@"black.jpg"];
    _pageSlider.track.isStationary = NO;
    _pageSlider.handle.renderable.blendMode = GL_ONE;
    _pageSlider.track.renderable.blendMode = GL_ONE;
    
    _pageSlider.delegate = self;
    [_pageSlider addToSimulation:self];
    
    [self changed:_pageSlider];
}

-(void)randomizeColor {
    [super randomizeColor];
    [_save randomizeColor];
}

-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {
        
        NSString *device = machineName();
        
        _isIPad = [device hasPrefix:@"iPad"];
        
        if(_isIPad) {
            _numObjectsPerPage = 10;

        } else {
            _numObjectsPerPage = 5;
        }
        _saveList = [[BounceSaveList alloc] initWithFilesPerPage:_numObjectsPerPage];

        [self setupSaveButton];
        [self setupPageSlider];
        [self updateSavedSimulations];


    }
    return self;
}

-(void)prepare {
    [self setupPageSlider];
}

-(void)unload {
    NSMutableArray *remove = [NSMutableArray arrayWithCapacity:5];
    for(BounceObject *obj in _objects) {
        if([obj isKindOfClass:[BounceLoadObject class]]) {
            [remove addObject:obj];
        }
    }
    
    for(BounceObject *obj in remove) {
        [obj removeFromSimulation];
    }
}

-(void)setVelocity:(const vec2 &)vel {
    [super setVelocity:vel];
    
    [_save setVelocity:vel];
    [_pageSlider setVelocity:vel];
}

-(void)setAngle:(float)angle {
    [super setAngle:angle];
    [_save setAngle:angle];
    [_pageSlider setAngle:angle];
}
-(void)setAngVel:(float)angVel {
    [super setAngVel:angVel];
    [_save setAngVel:angVel];
    [_pageSlider setAngVel:angVel];
}
-(void)step:(float)dt {
    [_save step:dt];
    [_pageSlider step:dt];
    if(_save.intensity < .5) {
        _save.intensity = .5;
    }

    [super step:dt];
}

-(void)changed:(BounceSlider *)slider {
    [_saveList setPage:slider.index];
    
    if([_saveList isBuiltIn]) {
        if([_save hasBeenAddedToSimulation]) {
            [_save removeFromSimulation];
        }
    } else {
        if(![_save hasBeenAddedToSimulation]) {
            [_save addToSimulation:self];
        }
    }
    
    NSArray *files = [_saveList fileList];
    BOOL isBuiltIn = [_saveList isBuiltIn];
    
    NSMutableSet *set = [NSMutableSet setWithArray:files];
     
    NSMutableArray *del = [NSMutableArray arrayWithCapacity:5];
    for(BounceObject *obj in _objects) {
        if([obj isKindOfClass:[BounceLoadObject class]]) {
            BounceLoadObject *load = (BounceLoadObject*)obj;
            if(![set containsObject:load.file]) {
                [del addObject:load];
            } else {
                [set removeObject:load.file];
                [load setBuiltIn:isBuiltIn];
            }
        }
    }
    
    for(BounceLoadObject *load in del) {
        [_objects removeObject:load];
    }
    
    for(NSString* file in set) {
        BounceLoadObject *load = [[BounceLoadObject alloc] initWithFile:file];
        if(_isIPad) {
            load.size = self.arena.dimensions.width*.1;
            load.secondarySize = self.arena.dimensions.width*.05;
        } else {
            load.size = self.arena.dimensions.width*.17;
            load.secondarySize = self.arena.dimensions.width*.07;
        }
        [load setBuiltIn:isBuiltIn];
        [load addToSimulation:self];
        [load release];
    }
}

-(void)pressed:(BounceButton *)button {
    [_simulation saveSimulation];
}

-(void)tapObject:(BounceObject *)obj at:(const vec2 &)loc {
    [super tapObject:obj at:loc];
    
    if([obj isKindOfClass:[BounceLoadObject class]]) {
        BounceLoadObject *load = (BounceLoadObject*)obj;

        if(load.longTouched) {
            [_simulation deleteSimulation:load.file];
        } else {
            if(load.isBuiltIn) {
                [_simulation loadBuiltInSimulation:load.file];
            } else {
                [_simulation loadSimulation:load.file];
            }
            [obj.renderable burst:5];
            obj.intensity = 2.2;
        }
    }
}

-(void)longTouchObject:(BounceObject *)obj at:(const vec2 &)loc {
    if([obj isKindOfClass:[BounceLoadObject class]]) {
        BounceLoadObject *load = (BounceLoadObject*)obj;
        if(!load.isBuiltIn) {
            load.longTouched = YES;
        }
    }
}

-(void)flickObject:(BounceObject *)obj at:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    [_save setPosition:pos];
    
    CGSize dimensions = self.arena.dimensions;
    float spacing = .45 *dimensions.height;
    
    vec2 offset(0,-spacing);
    
    offset.rotate(-self.arena.angle);
    
    [_pageSlider setPosition:pos+offset];
}

-(void)updateSavedSimulations {
    [_saveList update];
    [self setupPageSlider];
}
@end

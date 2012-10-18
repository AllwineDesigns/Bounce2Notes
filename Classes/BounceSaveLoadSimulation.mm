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

@implementation BounceLoadObject

@synthesize file = _file;
-(id)initWithFile:(NSString *)file {
    self = [super initObjectWithShape:BOUNCE_BALL at:vec2(0,-2) withVelocity:vec2() withColor:[[BounceSettings instance].colorGenerator randomColor] withSize:.1 withAngle:0];
    
    if(self) {
        _isRemovable = NO;
        _isPreviewable = NO;
        self.bounceShape = BOUNCE_CAPSULE;
        _file = [file retain];
        self.patternTexture = [[FSATextureManager instance] getTextTexture:_file];
        self.sound = [[BounceNoteManager instance] getRest];

    }
    return self;
}

@end

@implementation BounceSaveLoadSimulation

-(void)setupSaveButton {
    CGSize dimensions = self.arena.dimensions;
    
    BounceButton *button = [[BounceButton alloc] init];
    button.patternTexture = [[FSATextureManager instance] getTexture:@"Save"];
    button.bounceShape = BOUNCE_BALL;
    button.size = dimensions.width*.1;
    button.secondarySize = dimensions.height*.08;
    button.position = vec2(-2,0);
    button.isStationary = YES;
    button.sound = [[BounceNoteManager instance] getRest];
    
    button.delegate = self;
    
    [button addToSimulation:self];
    
    _save = button;
}


-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {
        [self setupSaveButton];
        [self updateSavedSimulations];
    }
    return self;
}

-(void)setAngle:(float)angle {
    [super setAngle:angle];
    [_save setAngle:angle];
}
-(void)setAngVel:(float)angVel {
    [super setAngVel:angVel];
    [_save setAngVel:angVel];
}
-(void)step:(float)dt {
    [_save step:dt];

    [super step:dt];
}
                 
-(void)pressed:(BounceButton *)button { 
    [_simulation saveSimulation];
}

-(void)tapObject:(BounceObject *)obj at:(const vec2 &)loc {
    [super tapObject:obj at:loc];
    
    if([obj isKindOfClass:[BounceLoadObject class]]) {
        BounceLoadObject *load = (BounceLoadObject*)obj;
        [_simulation loadSimulation:load.file];
        [obj.renderable burst:5];
        obj.intensity = 2.2;
    }
}

-(void)flickObject:(BounceObject *)obj at:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    [_save setPosition:pos];
}

-(void)updateSavedSimulations {
    NSArray *files = [[BounceFileManager instance] allFiles];
    NSMutableSet *set = [NSMutableSet setWithArray:files];
    
    for(BounceObject *obj in _objects) {
        if([obj isKindOfClass:[BounceLoadObject class]]) {
            BounceLoadObject *load = (BounceLoadObject*)obj;

            [set removeObject:load.file];
        }    
    }
    
    for(NSString* file in set) {
        BounceLoadObject *load = [[BounceLoadObject alloc] initWithFile:file];
        load.size = self.arena.dimensions.width*.1;
        load.secondarySize = self.arena.dimensions.width*.05;
        [load addToSimulation:self];
        [load release];
    }
}
@end

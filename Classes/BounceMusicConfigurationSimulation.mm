//
//  BounceMusicConfigurationSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 7/31/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceMusicConfigurationSimulation.h"
#import "BounceConfigurationObject.h"
#import "BounceConstants.h"
#import "BounceNoteManager.h"
#import "FSATextureManager.h"
#import "BounceSettings.h"
#import "FSASoundManager.h"
#import "AnchoredBounceObject.h"
#import "FSAUtil.h"

@implementation BounceMusicConfigurationSimulation

@synthesize activeChord = _activeChord;

-(void)switchActiveChord {
   // int r = RANDFLOAT*[_chordConfigObjects count];
    
   // BounceChordConfigurationObject* obj = [[_chordConfigObjects objectAtIndex:r] object];
    
  //  [obj updateSetting];
  //  [self setActiveChord:obj];
}

-(void)setActiveChord:(BounceChordConfigurationObject *)activeChord {
    _activeChord.active = NO;
    activeChord.active = YES;
    _activeChord = activeChord;
}

-(void)setupTestBounceObjects {
    float size = .15;
    
    BounceSimulation *sim = self;
    FSATextureManager *texManager = [FSATextureManager instance];
    
    vec4 color;
    
    float aspect = [[BounceConstants instance] aspect];
    float invaspect = 1./aspect;
        
    BounceNoteConfigurationObject * configObject;
    
    FSASoundManager *soundManager = [FSASoundManager instance];
    NSArray *sounds = [NSArray arrayWithObjects:
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"f4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
                       nil];
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceSong alloc] initWithSounds:sounds label:@"Twinkle"] autorelease];
    configObject.size = .08;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:@"Twinkle"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    sounds = [NSArray arrayWithObjects:
              [soundManager getSound:@"c3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"c4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"c5.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"c6.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"d3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"d4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"d5.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"e3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"e4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"e5.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"g3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"g4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"g5.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"a3.caf" volume:BOUNCE_SOUND_VOLUME],
              [soundManager getSound:@"a4.caf" volume:BOUNCE_SOUND_VOLUME], 
              [soundManager getSound:@"a5.caf" volume:BOUNCE_SOUND_VOLUME], 
          
                       nil];
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceRandomSounds alloc] initWithSounds:sounds label:@"Twinkle"] autorelease];
    configObject.size = .05;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:@"C"];
    [configObject addToSimulation:sim];
    [configObject release];
    
    configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, invaspect-1) withVelocity:vec2() withColor:color withSize:size withAngle:0];
    configObject.sound = [[[BounceChordProgression alloc] init] autorelease];
    configObject.size = .15;
    configObject.secondarySize = configObject.size*GOLDEN_RATIO;
    configObject.patternTexture = [texManager getTexture:@"C"];
    [configObject addToSimulation:sim];
    [configObject release];
}

-(void)setupChordObjects {
//    float size = .15;
    
    BounceSimulation *sim = self;
    FSATextureManager *texManager = [FSATextureManager instance];
//    BounceNoteManager *noteManager = [BounceNoteManager instance];
    
    vec4 color;
    int i = 0;
    
    float small = .04;
    float big = .1;
        
    NSArray *keys = [NSArray arrayWithObjects:@"C", @"D", @"E", @"F", @"G", @"A", @"B",@"C", nil];
    int notes = [keys count];
    
    NSMutableArray *anchoredObjects = [[NSMutableArray alloc] initWithCapacity:7];
//    int octaveOffset = 0;
    for(NSString *key in keys) {
        /*
        if(i == 7) {
            octaveOffset = 1;
        }
        
        NSArray *sounds = [[NSArray alloc] initWithObjects:
         [noteManager getSound:0 forKey:key forOctave:3+octaveOffset],
         [noteManager getSound:0 forKey:key forOctave:4+octaveOffset],
         [noteManager getSound:2 forKey:key forOctave:4+octaveOffset],
         [noteManager getSound:4 forKey:key forOctave:4+octaveOffset],
                           nil];
         
        NSArray *sounds = [[NSArray alloc] initWithObjects:
                           [noteManager getSound:i forKey:@"C" forOctave:3+octaveOffset],
                           [noteManager getSound:i forKey:@"C" forOctave:4+octaveOffset],
                           [noteManager getSound:i+2 forKey:@"C" forOctave:4+octaveOffset],
                           [noteManager getSound:i+4 forKey:@"C" forOctave:4+octaveOffset],
                           nil];
        
        BounceRandomSounds *bounceSound = [[BounceRandomSounds alloc] initWithSounds:sounds label:key];
        

        BounceNoteConfigurationObject * configObject = [[BounceNoteConfigurationObject alloc] initObjectWithShape:BOUNCE_BALL at:vec2(-.2, -2) withVelocity:vec2() withColor:color withSize:size withAngle:0];
         */
        
        BounceChordConfigurationObject * configObject = [[BounceChordConfigurationObject alloc] initWithChord:i];
        [configObject addToSimulation:sim];
       // configObject.sound = bounceSound;
        float t = (float)i/(notes-1);
        configObject.size = small*t+(1-t)*big;
        configObject.secondarySize = configObject.size*GOLDEN_RATIO;
        configObject.patternTexture = [texManager getTexture:key];
        
        AnchoredBounceObject *anchoredObject = [[AnchoredBounceObject alloc] initWithBounceObject:configObject];
        
        [anchoredObjects addObject:anchoredObject];
        
        [anchoredObject release];
        [configObject release];
      //  [bounceSound release];
      //  [sounds release];

        ++i;
    }
    
    _chordConfigObjects = anchoredObjects;
}


-(void)setAngle:(float)angle {
    [super setAngle:angle];
    [_pages setAngle:angle];
}

-(void)setupPages {
    CGSize dimensions = self.arena.dimensions;
    _pages = [[BouncePages alloc] initWithPageWidth:dimensions.width pageHeight:dimensions.height];
    
    BouncePage *page = [[BouncePage alloc] init];
 //   cpLayers layers = (1 << [_pages count]);
    
    float pad = .05*dimensions.width;
    float objTotalWidth = 0;
    for(AnchoredBounceObject *aobj in _chordConfigObjects) {
        objTotalWidth += 2*aobj.object.size;
    }
    int numObjects = [_chordConfigObjects count];
    float spacing = (dimensions.width-2*pad-objTotalWidth)/(numObjects-1);


    float x = -.5*dimensions.width+pad;
    for(AnchoredBounceObject *aobj in _chordConfigObjects) {
        x += aobj.object.size;
        [page addWidget:aobj offset:vec2(x, 0)];
        x += aobj.object.size+spacing;
    }
    /*
     float y = .2*dimensions.height;
     
     for(int i = 0; i < 2; i++) {
     float pad = .05*dimensions.width;
     float objTotalWidth = 0;
     for(int j = 0; j < 8-i; j++) {
     AnchoredBounceObject *aobj = [_chordConfigObjects objectAtIndex:i*8+j];
     objTotalWidth += 2*aobj.object.size;
     }
     
     int numObjects = 8; //[_chordConfigObjects count];
     float spacing = (dimensions.width-2*pad-objTotalWidth-i*.12)/(numObjects-1);
     
     float x = -.5*dimensions.width+pad+i*(spacing+.12);
     for(int j = 0; j < 8-i; j++) {
     AnchoredBounceObject *aobj = [_chordConfigObjects objectAtIndex:i*8+j];
     x += aobj.object.size;
     [page addWidget:aobj offset:vec2(x, y)];
     x += aobj.object.size+spacing;
     }
     y -= .4*dimensions.height;
     }
     */
    [_pages addPage:page];
    [page release];
    
    
//    cpLayers mainArenaLayers = CP_ALL_LAYERS ^ copyPasteLayers ^ musicLayers;
    
//    [_arena setLayers:mainArenaLayers];
}

-(void)step:(float)dt {
    for(AnchoredBounceObject *aobj in _chordConfigObjects) {
        [aobj step:dt];
    }
    [_pages step:dt];
    
    [super step:dt];
}

-(void)prepare {
    [super prepare];
    [self updateSettings];
}

-(void)updateSettings {
    int i = 0;
    for(AnchoredBounceObject *aobj in _chordConfigObjects) {
        aobj.object.patternTexture = [[FSATextureManager instance] getTexture:[[BounceNoteManager instance] getLabelForIndex:i]];
        i++;
    }
}

-(void)setPosition:(const vec2 &)pos {
    [super setPosition:pos];
    [_pages updatePositions:pos];
}

-(id)initWithRect:(CGRect)rect bounceSimulation:(MainBounceSimulation *)sim {
    self = [super initWithRect:rect bounceSimulation:sim];
    if(self) {
        [self setupChordObjects];
        [self setupPages];
        _playGestures  = [[NSMutableSet alloc] initWithCapacity:5];
       // [self setupTestBounceObjects];
    }
    return self;
}

-(BOOL)respondsToGesture:(void *)uniqueId {
    NSValue *key = [NSValue valueWithPointer:uniqueId];

    if([_playGestures containsObject:key]) {
        return YES;
    }
    return [super respondsToGesture:uniqueId];
}

-(void)beginDrag:(void*)uniqueId at:(const vec2&)loc {
    BounceObject *obj = [self objectAt:loc];
    if(obj == nil || [obj isKindOfClass:[BounceChordConfigurationObject class]]) {
        [obj singleTapAt:loc];
        NSValue *key = [NSValue valueWithPointer:uniqueId];
        [_playGestures addObject:key];
    } else {
        [super beginDrag:uniqueId at:loc];
    }
}
-(void)drag:(void*)uniqueId at:(const vec2&)loc {
    NSValue *key = [NSValue valueWithPointer:uniqueId];
    if([_playGestures containsObject:key]) {
        BounceObject *obj = [self objectAt:loc];
        if([obj isKindOfClass:[BounceChordConfigurationObject class]]) {
            [obj singleTapAt:loc];
        }
    } else {
        [super drag:uniqueId at:loc];
    }
}
-(void)endDrag:(void*)uniqueId at:(const vec2&)loc {
    NSValue *key = [NSValue valueWithPointer:uniqueId];
    if([_playGestures containsObject:key]) {
        [_playGestures removeObject:key];
    } else {
        [super endDrag:uniqueId at:loc];
    }
}
-(void)cancelDrag:(void*)uniqueId at:(const vec2&)loc {
    NSValue *key = [NSValue valueWithPointer:uniqueId];
    if([_playGestures containsObject:key]) {
        [_playGestures removeObject:key];
    } else {
        [super cancelDrag:uniqueId at:loc];
    }
}
-(void)dealloc {
    [_playGestures release];
    [super dealloc];
}


@end

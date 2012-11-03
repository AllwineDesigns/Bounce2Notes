//
//  BounceNoteManager.m
//  ParticleSystem
//
//  Created by John Allwine on 8/14/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceNoteManager.h"
#import "FSASoundManager.h"

static BounceNoteManager* bounceNoteManager;

@implementation BounceNoteManager

@synthesize key = _key;
@synthesize octave = _octave;

-(void)setupKeyIndices {
    NSMutableDictionary *keyIndices = [[NSMutableDictionary alloc] initWithCapacity:15];
    [keyIndices setObject:[NSNumber numberWithInt:0] forKey:@"C"];
    [keyIndices setObject:[NSNumber numberWithInt:7] forKey:@"G"];
    [keyIndices setObject:[NSNumber numberWithInt:2] forKey:@"D"];
    [keyIndices setObject:[NSNumber numberWithInt:9] forKey:@"A"];
    [keyIndices setObject:[NSNumber numberWithInt:4] forKey:@"E"];
    [keyIndices setObject:[NSNumber numberWithInt:11] forKey:@"B"];
    [keyIndices setObject:[NSNumber numberWithInt:6] forKey:@"Fsharp"];
    [keyIndices setObject:[NSNumber numberWithInt:1] forKey:@"Csharp"];
    [keyIndices setObject:[NSNumber numberWithInt:5] forKey:@"F"];
    [keyIndices setObject:[NSNumber numberWithInt:10] forKey:@"Bflat"];
    [keyIndices setObject:[NSNumber numberWithInt:3] forKey:@"Eflat"];
    [keyIndices setObject:[NSNumber numberWithInt:8] forKey:@"Aflat"];
    [keyIndices setObject:[NSNumber numberWithInt:1] forKey:@"Dflat"];
    [keyIndices setObject:[NSNumber numberWithInt:6] forKey:@"Gflat"];
    [keyIndices setObject:[NSNumber numberWithInt:11] forKey:@"Cflat"];
    
    [keyIndices setObject:[NSNumber numberWithInt:9] forKey:@"Am"];
    [keyIndices setObject:[NSNumber numberWithInt:4] forKey:@"Em"];
    [keyIndices setObject:[NSNumber numberWithInt:11] forKey:@"Bm"];
    [keyIndices setObject:[NSNumber numberWithInt:6] forKey:@"Fsharpm"];
    [keyIndices setObject:[NSNumber numberWithInt:1] forKey:@"Csharpm"];
    [keyIndices setObject:[NSNumber numberWithInt:8] forKey:@"Gsharpm"];
    [keyIndices setObject:[NSNumber numberWithInt:3] forKey:@"Dsharpm"];
    [keyIndices setObject:[NSNumber numberWithInt:10] forKey:@"Asharpm"];
    [keyIndices setObject:[NSNumber numberWithInt:2] forKey:@"Dm"];
    [keyIndices setObject:[NSNumber numberWithInt:7] forKey:@"Gm"];
    [keyIndices setObject:[NSNumber numberWithInt:0] forKey:@"Cm"];
    [keyIndices setObject:[NSNumber numberWithInt:5] forKey:@"Fm"];
    [keyIndices setObject:[NSNumber numberWithInt:10] forKey:@"Bflatm"];
    [keyIndices setObject:[NSNumber numberWithInt:3] forKey:@"Eflatm"];
    [keyIndices setObject:[NSNumber numberWithInt:8] forKey:@"Aflatm"];
    _keyIndices = keyIndices;
}

-(void)setupSharpsAndFlats {
    NSMutableDictionary *sharpsFlats = [[NSMutableDictionary alloc] initWithCapacity:15];
    
    [sharpsFlats setObject:[NSNumber numberWithInt:0] forKey:@"C"];
    [sharpsFlats setObject:[NSNumber numberWithInt:1] forKey:@"G"];
    [sharpsFlats setObject:[NSNumber numberWithInt:2] forKey:@"D"];
    [sharpsFlats setObject:[NSNumber numberWithInt:3] forKey:@"A"];
    [sharpsFlats setObject:[NSNumber numberWithInt:4] forKey:@"E"];
    [sharpsFlats setObject:[NSNumber numberWithInt:5] forKey:@"B"];
    [sharpsFlats setObject:[NSNumber numberWithInt:6] forKey:@"Fsharp"];
    [sharpsFlats setObject:[NSNumber numberWithInt:7] forKey:@"Csharp"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-1] forKey:@"F"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-2] forKey:@"Bflat"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-3] forKey:@"Eflat"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-4] forKey:@"Aflat"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-5] forKey:@"Dflat"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-6] forKey:@"Gflat"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-7] forKey:@"Cflat"];
    
    [sharpsFlats setObject:[NSNumber numberWithInt:0] forKey:@"Am"];
    [sharpsFlats setObject:[NSNumber numberWithInt:1] forKey:@"Em"];
    [sharpsFlats setObject:[NSNumber numberWithInt:2] forKey:@"Bm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:3] forKey:@"Fsharpm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:4] forKey:@"Csharpm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:5] forKey:@"Gsharpm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:6] forKey:@"Dsharpm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:7] forKey:@"Asharpm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-1] forKey:@"Dm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-2] forKey:@"Gm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-3] forKey:@"Cm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-4] forKey:@"Fm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-5] forKey:@"Bflatm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-6] forKey:@"Eflatm"];
    [sharpsFlats setObject:[NSNumber numberWithInt:-7] forKey:@"Aflatm"];
    
    _keySharpsAndFlats = sharpsFlats;
}

-(id)init {
    self = [super init];
    if(self) {
        [self setupKeyIndices];
        [self setupSharpsAndFlats];
        _major_intervals = (int*)malloc(7*sizeof(int));
        _minor_intervals = (int*)malloc(7*sizeof(int));
        
        _major_intervals[0] = 0;
        _major_intervals[1] = 2;
        _major_intervals[2] = 4; 
        _major_intervals[3] = 5;
        _major_intervals[4] = 7;
        _major_intervals[5] = 9;
        _major_intervals[6] = 11;
        
        _minor_intervals[0] = 0;
        _minor_intervals[1] = 2;
        _minor_intervals[2] = 3; 
        _minor_intervals[3] = 5;
        _minor_intervals[4] = 7;
        _minor_intervals[5] = 8;
        _minor_intervals[6] = 10;
        
        _intervals = _major_intervals;
        
        NSMutableArray *sounds = [[NSMutableArray alloc] initWithCapacity:72];
        NSArray *names = [NSArray arrayWithObjects:
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"a2.caf",
                          @"asharp2.caf",
                          @"b2.caf",
                          @"c3.caf",
                          @"csharp3.caf",
                          @"d3.caf",
                          @"dsharp3.caf",
                          @"e3.caf",
                          @"f3.caf",
                          @"fsharp3.caf",
                          @"g3.caf",
                          @"gsharp3.caf",
                          @"a3.caf",
                          @"asharp3.caf",
                          @"b3.caf",
                          @"c4.caf",
                          @"csharp4.caf",
                          @"d4.caf",
                          //@"c_1.caf",

                          @"dsharp4.caf",
                          @"e4.caf",
                          @"f4.caf",
                          //@"e_1.caf",

                          @"fsharp4.caf",
                          @"g4.caf",
                          @"gsharp4.caf",
                          @"a4.caf",
                          //@"g_1.caf",

                          @"asharp4.caf",
                          @"b4.caf",
                         // @"c_2.caf",

                          @"c5.caf",
                          @"csharp5.caf",
                          @"d5.caf",
                          @"dsharp5.caf",
                          @"e5.caf",
                          @"f5.caf",
                          @"fsharp5.caf",
                          @"g5.caf",
                          @"gsharp5.caf",
                          @"a5.caf",
                          @"asharp5.caf",
                          @"b5.caf",
                          @"c6.caf",
                          @"csharp6.caf",
                          @"d6.caf",
                          @"dsharp6.caf",
                          @"e6.caf",
                          @"f6.caf",
                          @"fsharp6.caf",
                          @"g6.caf",
                          @"gsharp6.caf",
                          @"a6.caf",
                          @"rest",
                          @"rest",
                          @"rest", 
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest", 
                          @"rest",
                          @"rest",
                          @"rest",
                          @"rest",
                          nil];
        
        FSASoundManager *soundManager = [FSASoundManager instance];
        _rest = [[BounceNote alloc] initWithSound:[soundManager getSound:@"rest"]];

        for(NSString *file in names) {
            [sounds addObject:[soundManager getSound:file volume:BOUNCE_SOUND_VOLUME]];
        }
        _sounds = sounds;
        
        _octave = 4;
        _key = @"C";
    }
    return self;
}

-(NSString*)getLabelForIndex:(int)index {
    return [self getLabelForIndex:index forKey:_key];
}

-(NSString*)getLabelForIndex:(int)index forKey:(NSString*)key {
    int keyIndex = [[_keyIndices objectForKey:_key] intValue]; 
    int intervalIndex = index;
    while(intervalIndex < 0) {
        intervalIndex += 7;
    }
    intervalIndex = intervalIndex%7;
    index = (_intervals[intervalIndex]+keyIndex)%12;
    
    int sharpsflats = [[_keySharpsAndFlats objectForKey:key] intValue];
    switch(index) {
        case 0:
            if(sharpsflats == 7) {
                return @"Bsharp";
            } else {
                return @"C";
            }
            break;
        case 1:
            if(sharpsflats >= 2) {
                return @"Csharp";
            } else if(sharpsflats <= -4) {
                return @"Dflat";
            }
            break;
        case 2:
            return @"D";
            break;
        case 3:
            if(sharpsflats >= 4) {
                return @"Dsharp";
            } else if(sharpsflats <= -2) {
                return @"Eflat";
            }
            break;
        case 4:
            if(sharpsflats == -7) {
                return @"Fflat";
            } else {
                return @"E";
            }
            break;
        case 5:
            if(sharpsflats >= 6) {
                return @"Esharp";
            } else {
                return @"F";
            }
            break;
        case 6:
            if(sharpsflats >= 1) {
                return @"Fsharp";
            } else if(sharpsflats <= -5) {
                return @"Gflat";
            }
            break;
        case 7:
            return @"G";
            break;
        case 8:
            if(sharpsflats >= 3) {
                return @"Gsharp";
            } else if(sharpsflats <= -3) {
                return @"Aflat";
            }
            break;
        case 9:
            return @"A";
            break;
        case 10:
            if(sharpsflats >= 5) {
                return @"Asharp";
            } else if(sharpsflats <= -1) {
                return @"Bflat";
            }
            break;
        case 11:
            if(sharpsflats <= -6) {
                return @"Cflat";
            } else {
                return @"B";
            }
            break;
    }
    
    NSLog(@"key: %@, index: %u\n", _key, index);
    NSAssert(NO, @"unknown label");
    return @"UNKNOWN";
}

-(void)useMinorIntervals {
    _intervals = _minor_intervals;
}
-(void)useMajorIntervals {
    _intervals = _major_intervals;
}
-(FSASound*)getSound:(int)index {
    return [self getSound:index forKey:_key forOctave:_octave];
}

-(FSASound*)getSound:(int)index forKey:(NSString *)key forOctave:(int)octave {
    int keyIndex = [[_keyIndices objectForKey:key] intValue]; 
    int intervalIndex = index;
    while(intervalIndex < 0) {
        intervalIndex += 7;
        octave--;
    }
    intervalIndex = intervalIndex%7;
    
    int arrayIndex = (_intervals[intervalIndex]+keyIndex+12*(octave-2+index/7));
    if(arrayIndex >= [_sounds count] || arrayIndex < 0) {
        return [[FSASoundManager instance] getSound:@"rest"];
    }
    return [_sounds objectAtIndex:arrayIndex];
}

-(BounceNote*)getNote:(int)index {
   // int keyIndex = [[_keyIndices objectForKey:_key] intValue]; 
    
    FSASound *sound = [self getSound:index];
    
    int intervalIndex = index;
    while(intervalIndex < 0) {
        intervalIndex += 7;
    }
    intervalIndex = intervalIndex%7;
    
    NSString *label = [self getLabelForIndex:index forKey:_key];
    
    if(sound == [[FSASoundManager instance] getSound:@"rest"]) {
        return _rest;
    }

    return [[[BounceNote alloc] initWithSound:sound label:label] autorelease];
}

-(BounceNote*)getRest {
    return _rest;
}

+(BounceNoteManager*)instance {
    return bounceNoteManager;
}

+(void)initialize {
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        bounceNoteManager = [[BounceNoteManager alloc] init];
    }
}

-(void)dealloc {
    free(_major_intervals);
    free(_minor_intervals);
    [_sounds release];
    [_rest release];
    [super dealloc];
}

@end

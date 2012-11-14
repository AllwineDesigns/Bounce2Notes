//
//  BounceNoteManager.h
//  ParticleSystem
//
//  Created by John Allwine on 8/14/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BounceSound.h"

#define BOUNCE_MIDI_A0 21
#define BOUNCE_MIDI_A_SHARP0 22
#define BOUNCE_MIDI_B0 23
#define BOUNCE_MIDI_B_SHARP0 24
#define BOUNCE_MIDI_B_FLAT0 22
#define BOUNCE_MIDI_C1 24
#define BOUNCE_MIDI_C_SHARP1 25
#define BOUNCE_MIDI_C_FLAT1 23
#define BOUNCE_MIDI_D1 26
#define BOUNCE_MIDI_D_SHARP1 27
#define BOUNCE_MIDI_D_FLAT1 25
#define BOUNCE_MIDI_E1 28
#define BOUNCE_MIDI_E_SHARP1 29
#define BOUNCE_MIDI_E_FLAT1 27
#define BOUNCE_MIDI_F1 29
#define BOUNCE_MIDI_F_SHARP1 30
#define BOUNCE_MIDI_F_FLAT1 28
#define BOUNCE_MIDI_G1 31
#define BOUNCE_MIDI_G_SHARP1 32
#define BOUNCE_MIDI_G_FLAT1 30
#define BOUNCE_MIDI_A1 33
#define BOUNCE_MIDI_A_SHARP1 34
#define BOUNCE_MIDI_A_FLAT1 32
#define BOUNCE_MIDI_B1 35
#define BOUNCE_MIDI_B_SHARP1 36
#define BOUNCE_MIDI_B_FLAT1 34
#define BOUNCE_MIDI_C2 36
#define BOUNCE_MIDI_C_SHARP2 37
#define BOUNCE_MIDI_C_FLAT2 35
#define BOUNCE_MIDI_D2 38
#define BOUNCE_MIDI_D_SHARP2 39
#define BOUNCE_MIDI_D_FLAT2 37
#define BOUNCE_MIDI_E2 40
#define BOUNCE_MIDI_E_SHARP2 41
#define BOUNCE_MIDI_E_FLAT2 39
#define BOUNCE_MIDI_F2 41
#define BOUNCE_MIDI_F_SHARP2 42
#define BOUNCE_MIDI_F_FLAT2 40
#define BOUNCE_MIDI_G2 43
#define BOUNCE_MIDI_G_SHARP2 44
#define BOUNCE_MIDI_G_FLAT2 42
#define BOUNCE_MIDI_A2 45
#define BOUNCE_MIDI_A_SHARP2 46
#define BOUNCE_MIDI_A_FLAT2 44
#define BOUNCE_MIDI_B2 47
#define BOUNCE_MIDI_B_SHARP2 48
#define BOUNCE_MIDI_B_FLAT2 46
#define BOUNCE_MIDI_C3 48
#define BOUNCE_MIDI_C_SHARP3 49
#define BOUNCE_MIDI_C_FLAT3 47
#define BOUNCE_MIDI_D3 50
#define BOUNCE_MIDI_D_SHARP3 51
#define BOUNCE_MIDI_D_FLAT3 49
#define BOUNCE_MIDI_E3 52
#define BOUNCE_MIDI_E_SHARP3 53
#define BOUNCE_MIDI_E_FLAT3 51
#define BOUNCE_MIDI_F3 53
#define BOUNCE_MIDI_F_SHARP3 54
#define BOUNCE_MIDI_F_FLAT3 52
#define BOUNCE_MIDI_G3 55
#define BOUNCE_MIDI_G_SHARP3 56
#define BOUNCE_MIDI_G_FLAT3 54
#define BOUNCE_MIDI_A3 57
#define BOUNCE_MIDI_A_SHARP3 58
#define BOUNCE_MIDI_A_FLAT3 56
#define BOUNCE_MIDI_B3 59
#define BOUNCE_MIDI_B_SHARP3 60
#define BOUNCE_MIDI_B_FLAT3 58
#define BOUNCE_MIDI_C4 60
#define BOUNCE_MIDI_C_SHARP4 61
#define BOUNCE_MIDI_C_FLAT4 59
#define BOUNCE_MIDI_D4 62
#define BOUNCE_MIDI_D_SHARP4 63
#define BOUNCE_MIDI_D_FLAT4 61
#define BOUNCE_MIDI_E4 64
#define BOUNCE_MIDI_E_SHARP4 65
#define BOUNCE_MIDI_E_FLAT4 63
#define BOUNCE_MIDI_F4 65
#define BOUNCE_MIDI_F_SHARP4 66
#define BOUNCE_MIDI_F_FLAT4 64
#define BOUNCE_MIDI_G4 67
#define BOUNCE_MIDI_G_SHARP4 68
#define BOUNCE_MIDI_G_FLAT4 66
#define BOUNCE_MIDI_A4 69
#define BOUNCE_MIDI_A_SHARP4 70
#define BOUNCE_MIDI_A_FLAT4 68
#define BOUNCE_MIDI_B4 71
#define BOUNCE_MIDI_B_SHARP4 72
#define BOUNCE_MIDI_B_FLAT4 70
#define BOUNCE_MIDI_C5 72
#define BOUNCE_MIDI_C_SHARP5 73
#define BOUNCE_MIDI_C_FLAT5 71
#define BOUNCE_MIDI_D5 74
#define BOUNCE_MIDI_D_SHARP5 75
#define BOUNCE_MIDI_D_FLAT5 73
#define BOUNCE_MIDI_E5 76
#define BOUNCE_MIDI_E_SHARP5 77
#define BOUNCE_MIDI_E_FLAT5 75
#define BOUNCE_MIDI_F5 77
#define BOUNCE_MIDI_F_SHARP5 78
#define BOUNCE_MIDI_F_FLAT5 76
#define BOUNCE_MIDI_G5 79
#define BOUNCE_MIDI_G_SHARP5 80
#define BOUNCE_MIDI_G_FLAT5 78
#define BOUNCE_MIDI_A5 81
#define BOUNCE_MIDI_A_SHARP5 82
#define BOUNCE_MIDI_A_FLAT5 80
#define BOUNCE_MIDI_B5 83
#define BOUNCE_MIDI_B_SHARP5 84
#define BOUNCE_MIDI_B_FLAT5 82
#define BOUNCE_MIDI_C6 84
#define BOUNCE_MIDI_C_SHARP6 85
#define BOUNCE_MIDI_C_FLAT6 83
#define BOUNCE_MIDI_D6 86
#define BOUNCE_MIDI_D_SHARP6 87
#define BOUNCE_MIDI_D_FLAT6 85
#define BOUNCE_MIDI_E6 88
#define BOUNCE_MIDI_E_SHARP6 89
#define BOUNCE_MIDI_E_FLAT6 87
#define BOUNCE_MIDI_F6 89
#define BOUNCE_MIDI_F_SHARP6 90
#define BOUNCE_MIDI_F_FLAT6 88
#define BOUNCE_MIDI_G6 91
#define BOUNCE_MIDI_G_SHARP6 92
#define BOUNCE_MIDI_G_FLAT6 90
#define BOUNCE_MIDI_A6 93
#define BOUNCE_MIDI_A_SHARP6 94
#define BOUNCE_MIDI_A_FLAT6 92
#define BOUNCE_MIDI_B6 95
#define BOUNCE_MIDI_B_SHARP6 96
#define BOUNCE_MIDI_B_FLAT6 94
#define BOUNCE_MIDI_C7 96
#define BOUNCE_MIDI_C_SHARP7 97
#define BOUNCE_MIDI_C_FLAT7 95
#define BOUNCE_MIDI_D7 98
#define BOUNCE_MIDI_D_SHARP7 99
#define BOUNCE_MIDI_D_FLAT7 97
#define BOUNCE_MIDI_E7 100
#define BOUNCE_MIDI_E_SHARP7 101
#define BOUNCE_MIDI_E_FLAT7 99
#define BOUNCE_MIDI_F7 101
#define BOUNCE_MIDI_F_SHARP7 102
#define BOUNCE_MIDI_F_FLAT7 100
#define BOUNCE_MIDI_G7 103
#define BOUNCE_MIDI_G_SHARP7 104
#define BOUNCE_MIDI_G_FLAT7 102
#define BOUNCE_MIDI_A7 105
#define BOUNCE_MIDI_A_SHARP7 106
#define BOUNCE_MIDI_A_FLAT7 104
#define BOUNCE_MIDI_B7 107
#define BOUNCE_MIDI_B_SHARP7 108
#define BOUNCE_MIDI_B_FLAT7 106
#define BOUNCE_MIDI_C8 108
#define BOUNCE_MIDI_C_FLAT8 107

typedef unsigned int BounceMidiNumber;

#define BOUNCE_QUARTER_NOTE .25f
#define BOUNCE_EIGHTH_NOTE .125f
#define BOUNCE_SIXTEENTH_NOTE .0625f
#define BOUNCE_HALF_NOTE .5f
#define BOUNCE_WHOLE_NOTE 1.0f

typedef float BounceDuration;

typedef struct {
    BounceMidiNumber note;
    BounceDuration duration;
} BounceNoteDuration;

@interface BounceNoteManager : NSObject {
    int *_intervals;
    
    int *_major_intervals;
    int *_minor_intervals;
    
    NSString *_key;
    int _octave;
    
    NSArray *_sounds;
    BounceNote *_rest;
    
    NSDictionary *_keyIndices;
    NSDictionary *_keySharpsAndFlats;
}

@property (nonatomic,retain) NSString* key;
@property (nonatomic) int octave;

-(void)useMinorIntervals;
-(void)useMajorIntervals;

-(NSString*)getLabelForIndex:(int)index;
-(NSString*)getLabelForIndex:(int)index forKey:(NSString*)key;

-(FSASound*)getSound:(int)index forKey:(NSString*)key forOctave:(int)octave;
-(FSASound*)getSound:(int)index;
-(BounceNote*)getNote:(int)index;
-(BounceNote*)getRest;
-(FSASound*)getSoundWithMidiNumber:(BounceMidiNumber)m;

+(BounceNoteManager*)instance;

@end

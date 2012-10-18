//
//  BounceNoteManager.h
//  ParticleSystem
//
//  Created by John Allwine on 8/14/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BounceSound.h"

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

+(BounceNoteManager*)instance;

@end

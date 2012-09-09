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
    unsigned int *_intervals;
    
    unsigned int *_major_intervals;
    unsigned int *_minor_intervals;
    
    NSString *_key;
    unsigned int _octave;
    
    NSArray *_sounds;
    BounceNote *_rest;
    
    NSDictionary *_keyIndices;
    NSDictionary *_keySharpsAndFlats;
}

@property (nonatomic,retain) NSString* key;
@property (nonatomic) unsigned int octave;

-(void)useMinorIntervals;
-(void)useMajorIntervals;

-(NSString*)getLabelForIndex:(unsigned int)index;
-(FSASound*)getSound:(unsigned int)index;
-(BounceNote*)getNote:(unsigned int)index;
-(BounceNote*)getRest;

+(BounceNoteManager*)instance;

@end

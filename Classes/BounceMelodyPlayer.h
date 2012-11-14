//
//  BounceMelodyPlayer.h
//  ParticleSystem
//
//  Created by John Allwine on 11/9/12.
//
//

#import <Foundation/Foundation.h>

#import "BounceNoteManager.h"
#import "MidiParser.h"
#import "MainBounceSimulation.h"

@interface BounceMelodyEvent : NSObject

@property (nonatomic) BOOL on;
@property (nonatomic) BounceMidiNumber note;
@property (nonatomic) float volume;
@property (nonatomic) float dt;

-(id)initOnEventWithNote:(BounceMidiNumber)n volume:(float)v dt:(float)dt;
-(id)initOffEventWithNote:(BounceMidiNumber)n dt:(float)dt;
@end

@interface BounceMelody : NSObject <MidiParserDelegate>

-(NSArray*)eventsWithinTimeInterval:(NSTimeInterval)interval;
-(id)initWithBounceNoteDurations:(BounceNoteDuration*)notes numNotes:(unsigned int)numNotes;
-(id)initWithMidiFile:(NSString*)file;

-(void)addChord:(BounceMidiNumber*)notes numNotes:(unsigned int)numNotes duration:(BounceDuration)dur;

@end

@interface BounceMelodyPlayerNoteEvent : NSObject

@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSTimeInterval lastPlayed;
@end

@interface BounceMelodyPlayer : NSObject

@property (nonatomic, retain) MainBounceSimulation* simulation;

-(void)playMelody:(BounceMelody*)melody;
-(void)step;
-(void)start;
-(void)stop;

@end

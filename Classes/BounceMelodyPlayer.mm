//
//  BounceMelodyPlayer.m
//  ParticleSystem
//
//  Created by John Allwine on 11/9/12.
//
//

#import "BounceMelodyPlayer.h"
#import "MidiParser.h"
#import "BounceFileManager.h"

@implementation BounceMelodyEvent {
    BounceMidiNumber _note;
    BOOL _on;
    float _volume;
    float _dt;
}

@synthesize on = _on;
@synthesize volume = _volume;
@synthesize note = _note;
@synthesize dt = _dt;

-(id)initOffEventWithNote:(BounceMidiNumber)n dt:(float)dt {
    _on = NO;
    _note = n;
    _dt = dt;
    
    return self;
}

-(id)initOnEventWithNote:(BounceMidiNumber)n volume:(float)v dt:(float)dt {
    _on = YES;
    _note = n;
    _volume = v;
    _dt = dt;
    
    return self;
}

-(NSString*)description {
    if(_on) {
        return [NSString stringWithFormat:@"On Event: note = %u, volume = %f, _dt = %f", _note, _volume, _dt ];
    }
                
    return [NSString stringWithFormat:@"Off Event: note = %u, _dt = %f", _note, _dt ];

}

@end

@implementation BounceMelody {
    NSMutableArray *_events;
    NSMutableArray *_eventsCopy;
}

-(id)init {
    _events = [[NSMutableArray alloc] initWithCapacity:5];
    
    
    return self;
}

-(id)initWithBounceNoteDurations:(BounceNoteDuration *)notes numNotes:(unsigned int)numNotes {
    self = [self init];
    
    if(self) {
        for(int i = 0; i < numNotes; i++) {
            BounceNoteDuration note = notes[i];
            BounceMelodyEvent *event = [[BounceMelodyEvent alloc] initOnEventWithNote:note.note volume:.2 dt:0];
            [_events addObject:event];
            [event release];
            
            event = [[BounceMelodyEvent alloc] initOffEventWithNote:note.note dt:note.duration*2];
            [_events addObject:event];
            [event release];
        }
        
        _eventsCopy = [_events copy];
        
    }
    
    return self;
}

-(id)initWithMidiFile:(NSString *)file {
    self = [self init];
    
    if(self) {        
        NSString *path = [[BounceFileManager instance] pathToMidiFile:file];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        MidiParser *parser = [[MidiParser alloc] initWithDelegate:self];
        
        [parser parseData:data];
       // NSLog(@"%@", parser.log);
        
        [parser release];
    }
    
    return self;
}

-(void)readNoteOff:(UInt8)channel parameter1:(UInt8)p1 parameter2:(UInt8)p2 deltaTime:(UInt32)deltaTime track:(UInt16)track {
   // if(track != 5) return;

    float dt = deltaTime/960.;
    
    if(channel >= 9) {
        p1 = 0;
    }

    BounceMelodyEvent *event = [[BounceMelodyEvent alloc] initOffEventWithNote:p1 dt:dt];
    [_events addObject:event];
    [event release];
}

-(void)readNoteOn:(UInt8)channel parameter1:(UInt8)p1 parameter2:(UInt8)p2 deltaTime:(UInt32)deltaTime track:(UInt16)track {
    //if(track != 5) return;
    float dt = deltaTime/960.;
    //float v = .05+.15*(p2/127.);
    if(channel >= 9) {
        p1 = 0;
    }
    float v = .2;
    BounceMelodyEvent *event = [[BounceMelodyEvent alloc] initOnEventWithNote:p1 volume:v dt:dt];
    [_events addObject:event];
    [event release];
}

-(void)addChord:(BounceMidiNumber *)notes numNotes:(unsigned int)numNotes duration:(BounceDuration)dur {
    for(int i = 0; i < numNotes; i++) {
        BounceMelodyEvent *event = [[BounceMelodyEvent alloc] initOnEventWithNote:notes[i] volume:.2 dt:0];
        [_events addObject:event];
        [event release];
    }
    
    for(int i = 0; i < numNotes; i++) {
        BounceDuration d = 0;
        if(i == 0) {
            d = dur*2;
        }
        BounceMelodyEvent *event = [[BounceMelodyEvent alloc] initOffEventWithNote:notes[i] dt:d];
        [_events addObject:event];
        [event release];
    }
}

-(NSArray*)eventsWithinTimeInterval:(NSTimeInterval)interval {
    NSMutableArray *events = [[NSMutableArray alloc] initWithCapacity:5];
    
    if([_events count] > 0) {
        BounceMelodyEvent *event = [_events objectAtIndex:0];
        BOOL empty = NO;
        while(!empty && event.dt < interval) {
            interval -= event.dt;

            [events addObject:event];
            [_events removeObjectAtIndex:0];
            
            if([_events count] > 0) {
                event = [_events objectAtIndex:0];
            } else {
                empty = YES;
            }
        }
    }
    
    return [events autorelease];
}

-(void)dealloc {
    [_events release];
    [_eventsCopy release];
    [super dealloc];
}

@end

@implementation BounceMelodyPlayerNoteEvent {
    NSTimeInterval _time;
    NSTimeInterval _lastPlayed;
}

@synthesize time = _time;
@synthesize lastPlayed = _lastPlayed;

@end

@implementation BounceMelodyPlayer {
    BounceMelody* _melody;
    NSTimeInterval _lastStep;
    NSTimeInterval _leftOver;
    
    NSDictionary *_noteEvents;
    NSMutableSet *_currentEvents;
    
    MainBounceSimulation *_simulation;
}

@synthesize simulation = _simulation;

-(id)init {
    NSMutableDictionary *noteEvents = [[NSMutableDictionary alloc] initWithCapacity:88];
    
    for(BounceMidiNumber i = BOUNCE_MIDI_A0; i <= BOUNCE_MIDI_C8; i++) {
        NSNumber *num = [NSNumber numberWithUnsignedInt:i];
        BounceMelodyPlayerNoteEvent *event = [[BounceMelodyPlayerNoteEvent alloc] init];
        
        [noteEvents setObject:event forKey:num];
        [event release];
    }
    _noteEvents = noteEvents;
    
    _currentEvents = [[NSMutableSet alloc] initWithCapacity:5];
    
    return self;
}

-(void)playMelody:(BounceMelody *)melody {
    [melody retain];
    [_melody release];
    _melody = melody;
    _lastStep = [[NSProcessInfo processInfo] systemUptime];
}

-(void)start {
    
}

-(void)stop {
    
}

-(void)step {
    NSTimeInterval now = [[NSProcessInfo processInfo] systemUptime];
    NSTimeInterval dt = now-_lastStep;
    
    if(_simulation) {
        NSMutableArray *curSounds = [NSMutableArray arrayWithCapacity:5];
        
        for(NSNumber *num in _currentEvents) {
            FSASound *s = [[BounceNoteManager instance] getSoundWithMidiNumber:num.unsignedIntValue];
            [curSounds addObject:s];
        }
        
        BounceRandomSounds *sound = [[BounceRandomSounds alloc] initWithSounds:curSounds label:@"" volume:.2];
        [_simulation setSound:sound];
    }
    
    if(!_simulation) {
        for(NSNumber *num in _currentEvents) {
            BounceMelodyPlayerNoteEvent *onEvent = [_noteEvents objectForKey:num];
            onEvent.time += dt;
            float fade = 1;
            if(onEvent.time > .5) {
                fade = 0;
            } else {
                fade = 1-onEvent.time/.5;
            }
            if(now-onEvent.lastPlayed > .02) {
                [[[BounceNoteManager instance] getSoundWithMidiNumber:num.unsignedIntValue] play:.2*fade];
                onEvent.lastPlayed = now;
            }
        }
    }
    
    dt += _leftOver;
    
    NSArray *events = [_melody eventsWithinTimeInterval:dt];
    for(BounceMelodyEvent *event in events) {
        dt -= event.dt;
        BounceMidiNumber midiNumber = event.note;
        NSNumber *num = [NSNumber numberWithUnsignedInt:event.note];
        BounceMelodyPlayerNoteEvent *onEvent = [_noteEvents objectForKey:num];

        if(event.on) {
            onEvent.time = 0;
            onEvent.lastPlayed = now;
            if(!_simulation && ![_currentEvents containsObject:num]) {
                [[[BounceNoteManager instance] getSoundWithMidiNumber:midiNumber] play:.2];
            }
        
            [_currentEvents addObject:num];
        } else {
            if(!onEvent) {
                NSLog(@"warning: off event occured without an on event: %u", midiNumber);
            } else {
                [_currentEvents removeObject:num];
            }
        }
    }
    
    _leftOver = dt;
    _lastStep = now;
}

-(void)dealloc {
    [_currentEvents release];
    [_noteEvents release];
    [_melody release];
    [super dealloc];
}
@end

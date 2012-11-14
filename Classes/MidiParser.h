// MidiParser.h

#import <Foundation/Foundation.h>

@protocol MidiParserDelegate <NSObject>

@optional
- (void) readNoteOff: (UInt8) channel parameter1: (UInt8) p1 parameter2: (UInt8) p2 deltaTime:(UInt32)deltaTime track:(UInt16)track;
- (void) readNoteOn: (UInt8) channel parameter1: (UInt8) p1 parameter2: (UInt8) p2 deltaTime:(UInt32)deltaTime track:(UInt16)track;

@end

typedef enum tagMidiTimeFormat
{
    MidiTimeFormatTicksPerBeat,
    MidiTimeFormatFramesPerSecond
} MidiTimeFormat;

@interface MidiParser : NSObject
{
    NSMutableString *log;
    NSData *data;
    NSUInteger offset;
    
    UInt16 format;
    UInt16 trackCount;
    MidiTimeFormat timeFormat;
    
    UInt16 ticksPerBeat;
    UInt16 framesPerSecond;
    UInt16 ticksPerFrame;
    
    id<MidiParserDelegate> _delegate;
}

-(id)initWithDelegate:(id<MidiParserDelegate>)delegate;

@property (nonatomic, retain) id<MidiParserDelegate> delegate;
@property (nonatomic, retain) NSMutableString *log;

@property (readonly) UInt16 format;
@property (readonly) UInt16 trackCount;
@property (readonly) MidiTimeFormat timeFormat;

- (BOOL) parseData: (NSData *) midiData;

@end

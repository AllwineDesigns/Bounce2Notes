//
//  FSAMultiTapAndDragRecognizer.m
//  ParticleSystem
//
//  Created by John Allwine on 4/28/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSAMultiTapAndDragRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation FSAMultiTapAndDragRecognizer

@synthesize target;

-(void)handle {
    // should never happen
}

-(id)initWithTarget:(id)t {
    self.target = t;

    oneFingerTouches = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    delayedLongTaps = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    dragGestures = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
    self.state = UIGestureRecognizerStatePossible;
    [super initWithTarget:self action:@selector(handle)];
    return self;
}

-(void)dealloc {
    self.target = nil;
    CFRelease(oneFingerTouches);
    oneFingerTouches = nil;
    CFRelease(delayedLongTaps);
    delayedLongTaps = nil;
    CFRelease(dragGestures);
    dragGestures = nil;
    [super dealloc];
}

- (void)doLongTap:(FSAOneFingerTouch*)oft { 
    UIEvent *event = (UIEvent*)CFDictionaryGetValue(delayedLongTaps, oft);
    [self ignoreTouch:oft.touch forEvent:event];
    CFDictionaryRemoveValue(delayedLongTaps, oft);
    
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    gesture.location = [oft.touch locationInView:self.view];
    gesture.beginLocation = oft.beginLocation;
    gesture.timestamp = oft.touch.timestamp;
    gesture.beginTimestamp = oft.beginTimestamp;
    [gesture autorelease];
    [target performSelector:@selector(longTap:) withObject:gesture];
    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
}

- (void)doSingleTap:(FSAOneFingerTouch*)oft { 
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    gesture.location = [oft.touch locationInView:self.view];
    gesture.beginLocation = oft.beginLocation;
    gesture.timestamp = oft.touch.timestamp;
    gesture.beginTimestamp = oft.beginTimestamp;
    [gesture autorelease];
    [target performSelector:@selector(singleTap:) withObject:gesture];
    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
}

-(void)doDrag:(FSAOneFingerTouch*)oft {
    FSAMultiGesture *gesture;

    if(CFDictionaryContainsKey(dragGestures, oft)) {
        gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, oft);
    } else {
        gesture = [[FSAMultiGesture alloc] init];
        gesture.beginTimestamp = oft.beginTimestamp;
        gesture.beginLocation = oft.beginLocation;
        CFDictionarySetValue(dragGestures, oft, gesture);
        [gesture release];
    }
    gesture.location = [oft.touch locationInView:self.view];
    gesture.timestamp = oft.touch.timestamp;

    [target performSelector:@selector(drag:) withObject:gesture];
}

-(void)doEndDrag:(FSAOneFingerTouch*)oft {    
    FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, oft);
    gesture.location = [oft.touch locationInView:self.view];
    gesture.timestamp = oft.touch.timestamp;
    
    [gesture retain];
    CFDictionaryRemoveValue(dragGestures, oft);
    [gesture autorelease];
    
    [target performSelector:@selector(endDrag:) withObject:gesture];
}

-(void)doCancelDrag:(FSAOneFingerTouch*)oft {
    FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, oft);
    gesture.location = [oft.touch locationInView:self.view];
    gesture.timestamp = oft.touch.timestamp;
    
    [gesture retain];
    CFDictionaryRemoveValue(dragGestures, oft);
    [gesture autorelease];
    
    [target performSelector:@selector(cancelDrag:) withObject:gesture];
}

-(void)doFlick:(FSAOneFingerTouch*)oft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    gesture.location = [oft.touch locationInView:self.view];
    gesture.beginLocation = oft.beginLocation;
    gesture.timestamp = oft.touch.timestamp;
    gesture.beginTimestamp = oft.beginTimestamp;
    [gesture autorelease];
    [target performSelector:@selector(flick:) withObject:gesture];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        FSAOneFingerTouch *oft = [FSAOneFingerTouch touchWithTouch:touch atTimestamp:event.timestamp];
        CFDictionaryAddValue(delayedLongTaps, oft, event);
        [self performSelector:@selector(doLongTap:) withObject:oft afterDelay:FSA_LONGTAP_THRESHOLD];
        CFDictionaryAddValue(oneFingerTouches, oft.touch, oft);
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableSet *currentOneFingerTouches = [NSMutableSet setWithCapacity:4];
    
    for(UITouch *touch in touches) {
        if(CFDictionaryContainsKey(oneFingerTouches, touch)) {
            [currentOneFingerTouches addObject:(FSAOneFingerTouch*)CFDictionaryGetValue(oneFingerTouches, touch)];
        } else {
            NSLog(@"unknown touch: %@", touch);
        }
    }
    
    for(FSAOneFingerTouch* oft in currentOneFingerTouches) {
        if(CFDictionaryContainsKey(delayedLongTaps, oft)) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLongTap:) object:oft];
            CFDictionaryRemoveValue(delayedLongTaps, oft);
        }
        if(oft.touch.timestamp-oft.beginTimestamp > FSA_FLICK_THRESHOLD) {
            [self doDrag:oft];
        }
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableSet *currentOneFingerTouches = [NSMutableSet setWithCapacity:4];
    
    for(UITouch *touch in touches) {
        if(CFDictionaryContainsKey(oneFingerTouches, touch)) {
            [currentOneFingerTouches addObject:(FSAOneFingerTouch*)CFDictionaryGetValue(oneFingerTouches, touch)];
        } else {
            NSLog(@"unknown touch: %@", touch);
        }
    }
    
    for(FSAOneFingerTouch* oft in currentOneFingerTouches) {
        if(CFDictionaryContainsKey(delayedLongTaps, oft)) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLongTap:) object:oft];
            CFDictionaryRemoveValue(delayedLongTaps, oft);
        }
        if(oft.touch.tapCount > 0) {
            [self doSingleTap:oft];
        } else { // tapCount == 0
            if(oft.touch.timestamp-oft.beginTimestamp > FSA_FLICK_THRESHOLD) {
                CGPoint loc = [oft.touch locationInView:self.view];
                CGPoint begin = oft.beginLocation;

                if(!CGPointEqualToPoint(loc, begin)) {
                    [self doEndDrag:oft];
                }
            } else {
                [self doFlick:oft];
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //    NSLog(@"In touchesCancelled - event: %@\n\n\n", event);
    NSMutableSet *currentOneFingerTouches = [NSMutableSet setWithCapacity:4];
    
    for(UITouch *touch in touches) {
        if(CFDictionaryContainsKey(oneFingerTouches, touch)) {
            [currentOneFingerTouches addObject:(FSAOneFingerTouch*)CFDictionaryGetValue(oneFingerTouches, touch)];
        } else {
            NSLog(@"unknown touch: %@", touch);
        }
    }
    
    for(FSAOneFingerTouch* oft in currentOneFingerTouches) {
        if(CFDictionaryContainsKey(delayedLongTaps, oft)) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLongTap:) object:oft];
            CFDictionaryRemoveValue(delayedLongTaps, oft);
        }
        if(oft.touch.timestamp-oft.beginTimestamp > FSA_FLICK_THRESHOLD) {
            CGPoint loc = [oft.touch locationInView:self.view];
            CGPoint begin = oft.beginLocation;
            
            if(!CGPointEqualToPoint(loc, begin)) {
                [self doCancelDrag:oft];
            }
        }
    }
    
    
}


@end

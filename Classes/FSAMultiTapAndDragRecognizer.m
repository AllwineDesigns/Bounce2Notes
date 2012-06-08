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

    dragGestures = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
    self.state = UIGestureRecognizerStatePossible;
    [super initWithTarget:self action:@selector(handle)];
    return self;
}

-(void)dealloc {
    self.target = nil;
    CFRelease(oneFingerTouches);
    oneFingerTouches = nil;

    CFRelease(dragGestures);
    dragGestures = nil;

    [super dealloc];
}

- (void)doLongTouch:(FSAOneFingerTouch*)oft { 
    FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, oft);

    oft.hasLongTouched = YES;
    gesture.location = [oft.touch locationInView:self.view];
    gesture.timestamp = oft.touch.timestamp;
    
    [target performSelector:@selector(longTouch:) withObject:gesture];
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

-(void)doBeginDrag:(FSAOneFingerTouch*)oft {
    [self performSelector:@selector(doLongTouch:) withObject:oft afterDelay:FSA_LONGTOUCH_THRESHOLD];
    
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    gesture.location = [oft.touch locationInView:self.view];
    gesture.beginLocation = oft.beginLocation;
    gesture.timestamp = oft.touch.timestamp;
    gesture.beginTimestamp = oft.beginTimestamp;
    CFDictionarySetValue(dragGestures, oft, gesture);
    [gesture release];
    [target performSelector:@selector(beginDrag:) withObject:gesture];
}

-(void)doDrag:(FSAOneFingerTouch*)oft {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLongTouch:) object:oft];
    [self performSelector:@selector(doLongTouch:) withObject:oft afterDelay:FSA_LONGTOUCH_THRESHOLD];
    
    FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, oft);
    oft.hasDragged = YES;
    
    gesture.location = [oft.touch locationInView:self.view];
    gesture.timestamp = oft.touch.timestamp;
    CGPoint last_loc = [oft.touch previousLocationInView:self.view];
    gesture.velocity = CGPointMake(gesture.location.x-last_loc.x, gesture.location.y-last_loc.y);

    [target performSelector:@selector(drag:) withObject:gesture];
}

-(void)doEndDrag:(FSAOneFingerTouch*)oft {  
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLongTouch:) object:oft];

    FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, oft);
    gesture.location = [oft.touch locationInView:self.view];
    gesture.timestamp = oft.touch.timestamp;
    
    [target performSelector:@selector(endDrag:) withObject:gesture];
    
    CFDictionaryRemoveValue(oneFingerTouches, oft);
    CFDictionaryRemoveValue(dragGestures, oft);

}

-(void)doCancelDrag:(FSAOneFingerTouch*)oft {
    if(CFDictionaryContainsKey(dragGestures, oft)) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doLongTouch:) object:oft];

        FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, oft);
        gesture.location = [oft.touch locationInView:self.view];
        gesture.timestamp = oft.touch.timestamp;
        
        [target performSelector:@selector(cancelDrag:) withObject:gesture];
        CFDictionaryRemoveValue(dragGestures, oft);
    }
}

-(void)doFlick:(FSAOneFingerTouch*)oft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    gesture.location = [oft.touch locationInView:self.view];
    gesture.beginLocation = oft.beginLocation;
    gesture.timestamp = oft.touch.timestamp;
    gesture.beginTimestamp = oft.beginTimestamp;
    [target performSelector:@selector(flick:) withObject:gesture];
    [gesture release];
    CFDictionaryRemoveValue(oneFingerTouches, oft);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        FSAOneFingerTouch *oft = [FSAOneFingerTouch touchWithTouch:touch atTimestamp:event.timestamp];
        CFDictionaryAddValue(oneFingerTouches, oft.touch, oft);

        [self doBeginDrag:oft];
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
        CGPoint begin = oft.beginLocation;
        CGPoint end = [oft.touch locationInView:self.view];
        end.x -= begin.x;
        end.y -= begin.y;
        
        float dist = sqrt(end.x*end.x+end.y*end.y);
        if(oft.touch.timestamp-oft.beginTimestamp > FSA_FLICK_THRESHOLD && (oft.hasDragged || dist > 10)) {
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
        if(oft.touch.tapCount > 0 && !oft.hasDragged && !oft.hasLongTouched) {
            [self doCancelDrag:oft];
            [self doSingleTap:oft];
        } else {
            if(oft.touch.timestamp-oft.beginTimestamp > FSA_FLICK_THRESHOLD) {
                CGPoint begin = oft.beginLocation;
                CGPoint end = [oft.touch locationInView:self.view];
                end.x -= begin.x;
                end.y -= begin.y;
                
                float dist = sqrt(end.x*end.x+end.y*end.y);

                if(dist >= 1) {
                    [self doEndDrag:oft];
                } else {
                    [self doCancelDrag:oft];
                    CFDictionaryRemoveValue(oneFingerTouches, oft);
                }
            } else {
                [self doCancelDrag:oft];
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
        [self doCancelDrag:oft];
        CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
    }
}


@end

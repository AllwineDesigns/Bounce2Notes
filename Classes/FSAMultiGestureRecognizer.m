//
//  FSAMultiGestureRecognizer.m
//  ParticleSystem
//
//  Created by John Allwine on 4/28/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSAMultiGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

const float FSA_THREE_FINGER_THRESHOLD = .4;
const float FSA_LONGTOUCH_THRESHOLD = .4;
const float FSA_FLICK_THRESHOLD = .2;
const float FSA_TAP_THRESHOLD = .2;

@implementation FSAOneFingerTouch

@synthesize isThreeFingerDrag;
@synthesize hasLongTouched;
@synthesize hasDragged;
@synthesize touch;
@synthesize beginTimestamp;
@synthesize beginLocation;

+(id)touchWithTouch:(UITouch*)to atTimestamp:(NSTimeInterval)t {
    FSAOneFingerTouch *one_finger = [[FSAOneFingerTouch alloc] initWithTouch:to atTimestamp:t];
    [one_finger autorelease];
    return one_finger;
}
-(id)initWithTouch:(UITouch *)to atTimestamp:(NSTimeInterval)t {
    self.hasLongTouched = NO;
    self.isThreeFingerDrag = NO;
    self.hasDragged = NO;
    self.touch = to;
    self.beginLocation = [to locationInView:nil];
    self.beginTimestamp = t;
    return self;
}
-(void)dealloc {
    self.touch = nil;
    [super dealloc];
}
@end

@implementation FSATwoFingerTouch

@synthesize touches;
@synthesize beginTimestamp;
@synthesize beginLocation;

+(id)touchWithTouch:(UITouch*)touch andTouch:(UITouch*)touch2 atTimestamp:(NSTimeInterval)t {
    FSATwoFingerTouch *two_finger = [[FSATwoFingerTouch alloc] initWithTouch:touch andTouch:touch2 atTimestamp:t];
    [two_finger autorelease];
    return two_finger;
}
-(id)initWithTouch:(UITouch *)touch andTouch:(UITouch *)touch2 atTimestamp:(NSTimeInterval)t {
    self.touches = [NSSet setWithObjects:touch, touch2, nil];
    self.beginTimestamp = t;
    self.beginLocation = [touch locationInView:nil];
    return self;
}
-(NSUInteger)tapCount {
    NSUInteger max = 0;
    
    for(UITouch *t in touches) {
        if(t.tapCount > max) {
            max = t.tapCount;
        }
    }
    return max;
}

-(BOOL)ended {
    for(UITouch *touch in touches) {
        if(touch.phase != UITouchPhaseEnded) {
            return NO;
        }
    }
    return YES;
}
-(NSTimeInterval)timestamp {
    NSTimeInterval time = 0;
    for(UITouch *t in touches) {
        if(t.timestamp > time) {
            time = t.timestamp;
        }
    }
    
    return time;
}
-(CGPoint)locationInView:(UIView*)view {
    CGPoint loc;
    loc.x = 0;
    loc.y = 0;
    
    if([self ended]) {
        NSArray *ts = [touches allObjects];
        UITouch *t0 = [ts objectAtIndex:0];
        UITouch *t1 = [ts objectAtIndex:1];
        NSTimeInterval diff = t0.timestamp-t1.timestamp;
        if(diff > FSA_TAP_THRESHOLD) {
            CGPoint loc0 = [t0 locationInView:view];
            loc.x = loc0.x;
            loc.y = loc0.y;
        } else if(diff < -FSA_TAP_THRESHOLD) {
            CGPoint loc1 = [t1 locationInView:view];
            loc.x = loc1.x;
            loc.y = loc1.y;
        } else {
            CGPoint loc0 = [t0 locationInView:view];
            loc.x = loc0.x;
            loc.y = loc0.y;
            
            CGPoint loc1 = [t1 locationInView:view];
            loc.x += loc1.x;
            loc.y += loc1.y;
            
            loc.x *= .5;
            loc.y *= .5;
        }
    } else {
        int num_touches = 0;

        
        for(UITouch *touch in touches) {
            if(touch.phase != UITouchPhaseEnded) {
                ++num_touches;
                
                CGPoint tloc = [touch locationInView:view];
                loc.x += tloc.x;
                loc.y += tloc.y; 
            }
        }
        if(num_touches > 0) {
            float mult = 1./num_touches;
            loc.x *= mult;
            loc.y *= mult;
        }
    }
    return loc;
}

-(void)dealloc {
    self.touches = nil;
    [super dealloc];
}
@end

@implementation FSAMultiGesture
@synthesize side;
@synthesize beginLocation;
@synthesize location;
@synthesize velocity;
@synthesize beginTimestamp;
@synthesize timestamp;
@end

@implementation FSAMultiGestureRecognizer

@synthesize target;

-(void)handle {
   // should never happen
}

-(id)initWithTarget:(id)t {
    self.target = t;
    delayedSingleTaps = [[NSMutableSet alloc] initWithCapacity:5];
    delayedTwoFingerSingleTaps = [[NSMutableSet alloc] initWithCapacity:5];

    twoFingerTouches = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    oneFingerTouches = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);
    
    self.state = UIGestureRecognizerStatePossible;
    [super initWithTarget:self action:@selector(handle)];
    return self;
}

-(void)dealloc {
    self.target = nil;
    [delayedSingleTaps release];
    [delayedTwoFingerSingleTaps release];
    CFRelease(twoFingerTouches);
    CFRelease(oneFingerTouches);
    [super dealloc];
}

- (void)doSingleTap:(FSAOneFingerTouch*)oft { 
    [delayedSingleTaps removeObject:oft];
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    gesture.location = [oft.touch locationInView:self.view];
    gesture.beginLocation = oft.beginLocation;
    gesture.timestamp = oft.touch.timestamp;
    gesture.beginTimestamp = oft.beginTimestamp;
    [gesture autorelease];
    [target performSelector:@selector(singleTap:) withObject:gesture];
    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
}

-(void)doDoubleTap:(FSAOneFingerTouch*)oft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    gesture.location = [oft.touch locationInView:self.view];
    gesture.beginLocation = oft.beginLocation;
    gesture.timestamp = oft.touch.timestamp;
    gesture.beginTimestamp = oft.beginTimestamp;
    [gesture autorelease];
    [target performSelector:@selector(doubleTap:) withObject:gesture];
    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
}

- (void)doTwoFingerSingleTap:(FSATwoFingerTouch*)tft {
    [delayedTwoFingerSingleTaps removeObject:tft];
    //    NSLog(@"performed a single tap: %@\n\n\n", touch);
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(twoFingerSingleTap:) withObject:gesture];
    for(UITouch *t in tft.touches) {
        CFDictionaryRemoveValue(twoFingerTouches, t);
    }
}

-(void)doTwoFingerDoubleTap:(FSATwoFingerTouch*)tft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(twoFingerDoubleTap:) withObject:gesture];
}

-(void)doTwoFingerDrag:(FSATwoFingerTouch*)tft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(twoFingerDrag:) withObject:gesture];
}

-(void)doEndTwoFingerDrag:(FSATwoFingerTouch*)tft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(endTwoFingerDrag:) withObject:gesture];
}

-(void)doCancelTwoFingerDrag:(FSATwoFingerTouch*)tft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(cancelTwoFingerDrag:) withObject:gesture];
}

-(void)doDrag:(FSAOneFingerTouch*)oft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(drag:) withObject:gesture];
}

-(void)doEndDrag:(FSAOneFingerTouch*)oft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(endDrag:) withObject:gesture];
}

-(void)doCancelDrag:(FSAOneFingerTouch*)oft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(cancelDrag:) withObject:gesture];
}

-(void)doTwoFingerFlick:(FSATwoFingerTouch*)tft {
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    [gesture autorelease];
    [target performSelector:@selector(twoFingerFlick:) withObject:gesture];
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
- (UITouch*)closestTouchTo: (UITouch*)touch ofTouches:(NSSet*)touches dist:(float*)dist {
    CGPoint loc = [touch locationInView:self.view];
    float min_dist = 99999;
    UITouch *closest_touch = nil;
    
    for(UITouch *other_touch in touches) {
        CGPoint other_loc = [other_touch locationInView:self.view];
        
        float length = sqrt((loc.x-other_loc.x)*(loc.x-other_loc.x)+(loc.y-other_loc.y)*(loc.y-other_loc.y));
        if(length < min_dist) {
            min_dist = length;
            closest_touch = other_touch;
        }
    }
    *dist = min_dist;
    return closest_touch;
}

- (FSAOneFingerTouch*)closestTouchTo: (FSAOneFingerTouch*)oft ofOneFingerTouches:(NSSet*)touches dist:(float*)dist {
    CGPoint loc = [oft.touch locationInView:self.view];
    float min_dist = 99999;
    FSAOneFingerTouch *closest_touch = nil;
    
    for(FSAOneFingerTouch *other_oft in touches) {
        CGPoint other_loc = [other_oft.touch locationInView:self.view];
        
        float length = sqrt((loc.x-other_loc.x)*(loc.x-other_loc.x)+(loc.y-other_loc.y)*(loc.y-other_loc.y));
        if(length < min_dist) {
            min_dist = length;
            closest_touch = other_oft;
        }
    }
    *dist = min_dist;
    return closest_touch;
}
- (FSATwoFingerTouch*)closestTouchTo: (FSATwoFingerTouch*)touch ofTwoFingerTouches:(NSSet*)touches dist:(float*)dist {
    CGPoint loc = [touch locationInView:self.view];
    float min_dist = 99999;
    FSATwoFingerTouch *closest_touch = nil;
    
    for(FSATwoFingerTouch *other_touch in touches) {
        CGPoint other_loc = [other_touch locationInView:self.view];
        
        float length = sqrt((loc.x-other_loc.x)*(loc.x-other_loc.x)+(loc.y-other_loc.y)*(loc.y-other_loc.y));
        if(length < min_dist) {
            min_dist = length;
            closest_touch = other_touch;
        }
    }
    *dist = min_dist;
    return closest_touch;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 //   NSLog(@"In touchesBegan - touches: %@, event: %@\n\n\n", touches, event);  
    NSMutableSet *currentOneFingerTouches = [NSMutableSet setWithCapacity:4];
    NSMutableSet *currentTwoFingerTouches = [NSMutableSet setWithCapacity:4];
    
    NSMutableSet *set = [NSMutableSet setWithCapacity:[touches count]];
    for(UITouch *touch in touches) {
        if(touch.tapCount > 2) {
            [self ignoreTouch:touch forEvent:event];
        } else {
            [set addObject:touch];
        }
    }
    
    while([set count] > 0) {
        NSMutableSet *set_copy = [NSMutableSet setWithSet:set];
        
        UITouch *touch = [set anyObject];
        [set removeObject:touch];
        
        float dist;
        // calculate the closest touch to this one
        UITouch *closest = [self closestTouchTo:touch ofTouches:set dist:&dist];
        if(closest != nil) {
            // now see if touch is the closest touch to closest_touch
            // if it is, and its less than a certain distance, than its a two finger touch
            [set_copy removeObject:closest];
            UITouch *closest2 = [self closestTouchTo:closest ofTouches:set_copy dist:&dist];
        
            if(closest2 == touch) {
                [set removeObject:closest];

                if(dist < 150 && touch.tapCount == closest.tapCount) {
                    // touch and closest are a two finger touch
                    FSATwoFingerTouch *tft = [FSATwoFingerTouch touchWithTouch:touch andTouch:closest atTimestamp:event.timestamp];
                    [currentTwoFingerTouches addObject:tft];
                } else {
                    [currentOneFingerTouches addObject:[FSAOneFingerTouch touchWithTouch:touch atTimestamp:event.timestamp]];
                    [currentOneFingerTouches addObject:[FSAOneFingerTouch touchWithTouch:closest atTimestamp:event.timestamp]];
                }
            } else {
                [currentOneFingerTouches addObject:[FSAOneFingerTouch touchWithTouch:touch atTimestamp:event.timestamp]];
            }
        } else {
            [currentOneFingerTouches addObject:[FSAOneFingerTouch touchWithTouch:touch atTimestamp:event.timestamp]];
        }
    }
    
    for(FSATwoFingerTouch* tft in currentTwoFingerTouches) {
        if(tft.tapCount == 2) {
            float dist;
            FSATwoFingerTouch *closest_tft = [self closestTouchTo:tft ofTwoFingerTouches:delayedTwoFingerSingleTaps dist:&dist];
            
            if(closest_tft != nil) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doTwoFingerSingleTap:) object:closest_tft];
                for(UITouch *t in closest_tft.touches) {
                    CFDictionaryRemoveValue(twoFingerTouches, t);
                }
                
                for(UITouch *t in tft.touches) {
                    CFDictionaryAddValue(twoFingerTouches, t, tft);
                }
                [delayedTwoFingerSingleTaps removeObject:closest_tft];
            } else {
                for(UITouch *t in tft.touches) {
                    [self ignoreTouch:t forEvent:event];
                }
            }
        } else {
            for(UITouch *t in tft.touches) {
                CFDictionaryAddValue(twoFingerTouches, t, tft);
            }
        }
        
    }
    
    for(FSAOneFingerTouch* oft in currentOneFingerTouches) {
        if(oft.touch.tapCount == 2 ) {
            float dist;
            FSAOneFingerTouch *other_oft = [self closestTouchTo:oft ofOneFingerTouches:delayedSingleTaps dist:&dist];
            if(other_oft != nil) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doSingleTap:) object:other_oft];
                
                CFDictionaryRemoveValue(oneFingerTouches, other_oft.touch);
                CFDictionaryAddValue(oneFingerTouches, oft.touch, oft);
                [delayedSingleTaps removeObject:other_oft];
            } else {
                [self ignoreTouch:oft.touch forEvent:event];
            }
        } else {
            CFDictionaryAddValue(oneFingerTouches, oft.touch, oft);
        }
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //    NSLog(@"In touchesMoved - event: %@\n\n\n", event);
    NSMutableSet *currentTwoFingerTouches = [NSMutableSet setWithCapacity:4];
    NSMutableSet *currentOneFingerTouches = [NSMutableSet setWithCapacity:4];
    
    for(UITouch *touch in touches) {
        if(CFDictionaryContainsKey(twoFingerTouches, touch)) {
            [currentTwoFingerTouches addObject:(FSATwoFingerTouch*)CFDictionaryGetValue(twoFingerTouches, touch)];
        } else if(CFDictionaryContainsKey(oneFingerTouches, touch)) {
            [currentOneFingerTouches addObject:(FSAOneFingerTouch*)CFDictionaryGetValue(oneFingerTouches, touch)];
        } else {
            NSLog(@"unknown touch: %@", touch);
        }
    }
    
    for(FSATwoFingerTouch* tft in currentTwoFingerTouches) {
        if([tft timestamp]-tft.beginTimestamp > FSA_FLICK_THRESHOLD) {
            [self doTwoFingerDrag:tft];
        }
    }
    
    for(FSAOneFingerTouch* oft in currentOneFingerTouches) {
        if(oft.touch.timestamp-oft.beginTimestamp > FSA_FLICK_THRESHOLD) {
            [self doDrag:oft];
        }
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"In touchesEnded - touches: %@, event: %@\n\n\n", touches, event);
    NSMutableSet *currentTwoFingerTouches = [NSMutableSet setWithCapacity:4];
    NSMutableSet *currentOneFingerTouches = [NSMutableSet setWithCapacity:4];
    
    for(UITouch *touch in touches) {
        if(CFDictionaryContainsKey(twoFingerTouches, touch)) {
            [currentTwoFingerTouches addObject:(FSATwoFingerTouch*)CFDictionaryGetValue(twoFingerTouches, touch)];
        } else if(CFDictionaryContainsKey(oneFingerTouches, touch)) {
            [currentOneFingerTouches addObject:(FSAOneFingerTouch*)CFDictionaryGetValue(oneFingerTouches, touch)];
        } else {
            NSLog(@"unknown touch: %@", touch);
        }
    }
    
    for(FSATwoFingerTouch* tft in currentTwoFingerTouches) {
        if([tft ended]) {
            if(tft.tapCount == 1) {
                [self performSelector:@selector(doTwoFingerSingleTap:) withObject:tft afterDelay:FSA_TAP_THRESHOLD];
                [delayedTwoFingerSingleTaps addObject:tft];
            } else if(tft.tapCount == 2) {
                [self doTwoFingerDoubleTap:tft];
            } else { // tapCount == 0
                if([tft timestamp]-tft.beginTimestamp > FSA_FLICK_THRESHOLD) {
                    if(!CGPointEqualToPoint(tft.beginLocation, [tft locationInView:self.view])) {
                        [self doEndTwoFingerDrag:tft];
                    }
                } else {
                    [self doTwoFingerFlick:tft];
                }
            }
        }
    }
    
    for(FSAOneFingerTouch* oft in currentOneFingerTouches) {
        if(oft.touch.tapCount == 1) {
            [self performSelector:@selector(doSingleTap:) withObject:oft afterDelay:FSA_TAP_THRESHOLD];
            [delayedSingleTaps addObject:oft];
        } else if(oft.touch.tapCount == 2) {
            [self doDoubleTap:oft];
        } else { // tapCount == 0
            if(oft.touch.timestamp-oft.beginTimestamp > FSA_FLICK_THRESHOLD) {
                if(!CGPointEqualToPoint(oft.beginLocation, [oft.touch locationInView:self.view])) {
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
}


@end

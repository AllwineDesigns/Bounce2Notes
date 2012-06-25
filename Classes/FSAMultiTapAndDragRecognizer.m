//
//  FSAMultiTapAndDragRecognizer.m
//  ParticleSystem
//
//  Created by John Allwine on 4/28/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "FSAMultiTapAndDragRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "FSAUtil.h"

@implementation FSAMultiTapAndDragRecognizer

@synthesize target;
@synthesize view;

-(void)handle {
    // should never happen
}

-(id)initWithTarget:(id)t {
    
    self = [super init];
    
    if(self) {
        self.target = t;

        oneFingerTouches = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, & kCFTypeDictionaryValueCallBacks);

        dragGestures = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        threeFingerTopDrags = [[NSMutableSet alloc] initWithCapacity:3];
        threeFingerBottomDrags = [[NSMutableSet alloc] initWithCapacity:3];
        threeFingerLeftDrags = [[NSMutableSet alloc] initWithCapacity:3];
        threeFingerRightDrags = [[NSMutableSet alloc] initWithCapacity:3];
        
        edgeWidth = 30;
        NSString *device = machineName();
        if([device hasPrefix:@"iPad"]) {
            edgeWidth = 100;
        }
    }

        
//    self.state = UIGestureRecognizerStatePossible;
 //   [super initWithTarget:self action:@selector(handle)];
    return self;
}

-(void)dealloc {
    self.target = nil;
    CFRelease(oneFingerTouches);
    oneFingerTouches = nil;

    CFRelease(dragGestures);
    dragGestures = nil;
    
    [threeFingerTopDrags release]; threeFingerTopDrags = nil;
    [threeFingerBottomDrags release]; threeFingerBottomDrags = nil;
    [threeFingerLeftDrags release]; threeFingerLeftDrags = nil;
    [threeFingerRightDrags release]; threeFingerRightDrags = nil;


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
    
    if(!oft.isThreeFingerDrag) {
        if([threeFingerTopDrags containsObject:oft]) {
            [threeFingerTopDrags removeObject:oft];
        } else if([threeFingerBottomDrags containsObject:oft]) {
            [threeFingerBottomDrags removeObject:oft];
        } else if([threeFingerRightDrags containsObject:oft]) {
            [threeFingerRightDrags removeObject:oft];
        } else if([threeFingerLeftDrags containsObject:oft]) {
            [threeFingerLeftDrags removeObject:oft];
        }
    }
    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);

}

-(void)doBeginThreeFingerDrag: (NSSet*)drags from:(FSAMultiGestureSide)side {
    CGPoint beginLocation = [((FSAOneFingerTouch*)[drags anyObject]).touch locationInView:self.view];
    NSTimeInterval beginTimestamp = ((FSAOneFingerTouch*)[drags anyObject]).beginTimestamp;
    
    CGPoint location = beginLocation;
    NSTimeInterval timestamp = beginTimestamp;
    
    for(FSAOneFingerTouch *oft in drags) {
        oft.isThreeFingerDrag = YES;

        [self doCancelDrag:oft];

        CGPoint loc = [oft.touch locationInView:self.view];
        if(oft.beginTimestamp < beginTimestamp) {
            beginTimestamp = oft.beginTimestamp;
        }
        if(oft.touch.timestamp > timestamp) {
            timestamp = oft.touch.timestamp;
        }
        
        if(loc.x < beginLocation.x) {
            beginLocation.x = loc.x;
        }
        
        if(loc.y < beginLocation.y) {
            beginLocation.y = loc.y;
        }
        
        if(loc.x > location.x) {
            location.x = loc.x;
        }
        
        if(loc.y > location.y) {
            location.y = loc.y;
        }
    }
    
    FSAMultiGesture *gesture = [[FSAMultiGesture alloc] init];
    gesture.location = location;
    gesture.beginLocation = beginLocation;
    gesture.timestamp = timestamp;
    gesture.beginTimestamp = beginTimestamp;
    gesture.side = side;
    
    for(FSAOneFingerTouch *oft in drags) {
        CFDictionarySetValue(dragGestures, oft, gesture);
    }
    [gesture release];
    
    [target performSelector:@selector(beginThreeFingerDrag:) withObject:gesture];
}

-(void)doThreeFingerDrag: (NSSet*)drags from:(FSAMultiGestureSide)side {
    CGPoint beginLocation = [((FSAOneFingerTouch*)[drags anyObject]).touch locationInView:self.view];
    NSTimeInterval beginTimestamp = ((FSAOneFingerTouch*)[drags anyObject]).beginTimestamp;
    
    CGPoint location = beginLocation;
    NSTimeInterval timestamp = beginTimestamp;
    
    for(FSAOneFingerTouch *oft in drags) {
        CGPoint loc = [oft.touch locationInView:self.view];
        if(oft.beginTimestamp < beginTimestamp) {
            beginTimestamp = oft.beginTimestamp;
        }
        if(oft.touch.timestamp > timestamp) {
            timestamp = oft.touch.timestamp;
        }
        
        if(loc.x < beginLocation.x) {
            beginLocation.x = loc.x;
        }
        
        if(loc.y < beginLocation.y) {
            beginLocation.y = loc.y;
        }
        
        if(loc.x > location.x) {
            location.x = loc.x;
        }
        
        if(loc.y > location.y) {
            location.y = loc.y;
        }
    }
    
    FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, [drags anyObject]);

    gesture.location = location;
    gesture.beginLocation = beginLocation;
    gesture.timestamp = timestamp;
    gesture.beginTimestamp = beginTimestamp;
    gesture.side = side;
    
    [target performSelector:@selector(threeFingerDrag:) withObject:gesture];
}

-(void)doEndThreeFingerDrag: (NSMutableSet*)drags from:(FSAMultiGestureSide)side {
    FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, [drags anyObject]);
    gesture.side = side;
    
    [target performSelector:@selector(endThreeFingerDrag:) withObject:gesture];

    NSArray *ofts = [drags allObjects];
    for(FSAOneFingerTouch *oft in ofts) {
        CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
        CFDictionaryRemoveValue(dragGestures, oft); 
        [drags removeObject:oft];
    }
    
}

-(void)doCancelThreeFingerDrag: (NSMutableSet*)drags from:(FSAMultiGestureSide)side {
    FSAMultiGesture *gesture = (FSAMultiGesture*)CFDictionaryGetValue(dragGestures, [drags anyObject]);
    gesture.side = side;
    
    [target performSelector:@selector(cancelThreeFingerDrag:) withObject:gesture];
    
    NSArray *ofts = [drags allObjects];
    for(FSAOneFingerTouch *oft in ofts) {
        CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
        CFDictionaryRemoveValue(dragGestures, oft); 
        [drags removeObject:oft];
    }
}

-(BOOL)isThreeFingerDrag: (NSSet*)drags {
    return ((FSAOneFingerTouch*)[drags anyObject]).isThreeFingerDrag;
}

-(BOOL)addOneFingerTouch: (FSAOneFingerTouch*)oft toThreeFingerDrags: (NSMutableSet*)drags {
    if([drags count] < 3 && ![self isThreeFingerDrag:drags]) {
        float timestamp = oft.beginTimestamp;
        
        NSArray *ofts = [drags allObjects];
        for(FSAOneFingerTouch *o in ofts) {
            if(timestamp-o.beginTimestamp > FSA_THREE_FINGER_THRESHOLD) {
                [drags removeObject:o];
            }
        }
        [drags addObject:oft];
        
        if([drags count] == 3) {
            return YES;
        }
    }
    
    return NO;

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

    if(!oft.isThreeFingerDrag) {
        if([threeFingerTopDrags containsObject:oft]) {
            [threeFingerTopDrags removeObject:oft];
        } else if([threeFingerBottomDrags containsObject:oft]) {
            [threeFingerBottomDrags removeObject:oft];
        } else if([threeFingerRightDrags containsObject:oft]) {
            [threeFingerRightDrags removeObject:oft];
        } else if([threeFingerLeftDrags containsObject:oft]) {
            [threeFingerLeftDrags removeObject:oft];
        }
    }
    
    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
    CFDictionaryRemoveValue(dragGestures, oft);
}

-(void)doCancelDrag:(FSAOneFingerTouch*)oft {
    if(!oft.isThreeFingerDrag) {
        if([threeFingerTopDrags containsObject:oft]) {
            [threeFingerTopDrags removeObject:oft];
        } else if([threeFingerBottomDrags containsObject:oft]) {
            [threeFingerBottomDrags removeObject:oft];
        } else if([threeFingerRightDrags containsObject:oft]) {
            [threeFingerRightDrags removeObject:oft];
        } else if([threeFingerLeftDrags containsObject:oft]) {
            [threeFingerLeftDrags removeObject:oft];
        }
    }
    
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

    if(!oft.isThreeFingerDrag) {
        if([threeFingerTopDrags containsObject:oft]) {
            [threeFingerTopDrags removeObject:oft];
        } else if([threeFingerBottomDrags containsObject:oft]) {
            [threeFingerBottomDrags removeObject:oft];
        } else if([threeFingerRightDrags containsObject:oft]) {
            [threeFingerRightDrags removeObject:oft];
        } else if([threeFingerLeftDrags containsObject:oft]) {
            [threeFingerLeftDrags removeObject:oft];
        }
    }
    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 //   self.state = UIGestureRecognizerStatePossible;
    
    for(UITouch *touch in touches) {
        FSAOneFingerTouch *oft = [FSAOneFingerTouch touchWithTouch:touch atTimestamp:event.timestamp];
        
        CFDictionaryAddValue(oneFingerTouches, oft.touch, oft);

        [self doBeginDrag:oft];

        if(oft.beginLocation.y < edgeWidth) {
            if([self addOneFingerTouch:oft toThreeFingerDrags:threeFingerTopDrags]) {
                [self doBeginThreeFingerDrag:threeFingerTopDrags from:FSA_TOP];
            }
        } else if(oft.beginLocation.y > self.view.frame.size.height-edgeWidth) {
            if([self addOneFingerTouch:oft toThreeFingerDrags:threeFingerBottomDrags]) {
                [self doBeginThreeFingerDrag:threeFingerBottomDrags from:FSA_BOTTOM];
            }
        } else if(oft.beginLocation.x > self.view.frame.size.width-edgeWidth) {
            if([self addOneFingerTouch:oft toThreeFingerDrags:threeFingerRightDrags]) {
                [self doBeginThreeFingerDrag:threeFingerRightDrags from:FSA_RIGHT];
            }
        } else if(oft.beginLocation.x < edgeWidth) {
            if([self addOneFingerTouch:oft toThreeFingerDrags:threeFingerLeftDrags]) {
                [self doBeginThreeFingerDrag:threeFingerLeftDrags from:FSA_LEFT];
            }
        }
 
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

    NSArray *curTouches = [currentOneFingerTouches allObjects];
    BOOL doTop = NO;
    BOOL doBottom = NO;
    BOOL doLeft = NO;
    BOOL doRight = NO;
    for(FSAOneFingerTouch* oft in curTouches) {
        if(oft.isThreeFingerDrag) {
            if([threeFingerTopDrags containsObject:oft]) {
                doTop = YES;
                [currentOneFingerTouches removeObject:oft];
            } else if([threeFingerBottomDrags containsObject:oft]) {
                doBottom = YES;
                [currentOneFingerTouches removeObject:oft];
            } else if([threeFingerLeftDrags containsObject:oft]) {
                doLeft = YES;
                [currentOneFingerTouches removeObject:oft];
            } else if([threeFingerRightDrags containsObject:oft]) {
                doRight = YES;
                [currentOneFingerTouches removeObject:oft];
            }
        }
    }
    
    if(doTop) {
        [self doThreeFingerDrag:threeFingerTopDrags from:FSA_TOP];
    } else if(doBottom) {
        [self doThreeFingerDrag:threeFingerBottomDrags from:FSA_BOTTOM];
    } else if(doRight) {
        [self doThreeFingerDrag:threeFingerRightDrags from:FSA_RIGHT];
    } else if(doLeft) {
        [self doThreeFingerDrag:threeFingerLeftDrags from:FSA_LEFT];
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
 //   self.state = UIGestureRecognizerStateRecognized;

    NSMutableSet *currentOneFingerTouches = [NSMutableSet setWithCapacity:4];
    
    for(UITouch *touch in touches) {
        if(CFDictionaryContainsKey(oneFingerTouches, touch)) {
            [currentOneFingerTouches addObject:(FSAOneFingerTouch*)CFDictionaryGetValue(oneFingerTouches, touch)];
        } else {
            NSLog(@"unknown touch: %@", touch);
        }
    }

    for(FSAOneFingerTouch* oft in currentOneFingerTouches) {
        if(oft.isThreeFingerDrag) {
            if([threeFingerTopDrags containsObject:oft]) {
                if([threeFingerTopDrags count] == 1) {
                    [self doEndThreeFingerDrag:threeFingerTopDrags from:FSA_TOP];
                } else {
                    [threeFingerTopDrags removeObject:oft];
                    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
                    CFDictionaryRemoveValue(dragGestures, oft);
                }
            } else if([threeFingerBottomDrags containsObject:oft]) {
                if([threeFingerBottomDrags count] == 1) {
                    [self doEndThreeFingerDrag:threeFingerBottomDrags from:FSA_BOTTOM];
                } else {
                    [threeFingerBottomDrags removeObject:oft];
                    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
                    CFDictionaryRemoveValue(dragGestures, oft);
                }
            } else if([threeFingerLeftDrags containsObject:oft]) {
                if([threeFingerLeftDrags count] == 1) {
                    [self doEndThreeFingerDrag:threeFingerLeftDrags from:FSA_LEFT];
                } else {
                    [threeFingerLeftDrags removeObject:oft];
                    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
                    CFDictionaryRemoveValue(dragGestures, oft);
                }
            } else if([threeFingerRightDrags containsObject:oft]) {
                if([threeFingerRightDrags count] == 1) {
                    [self doEndThreeFingerDrag:threeFingerRightDrags from:FSA_RIGHT];
                } else {
                    [threeFingerRightDrags removeObject:oft];
                    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
                    CFDictionaryRemoveValue(dragGestures, oft);
                }
            }
        } else {
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

                        CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
                    }
                } else {
                    [self doCancelDrag:oft];

                    CFDictionaryRemoveValue(oneFingerTouches, oft.touch);

                    [self doFlick:oft];
                }
                 
            }
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
 //   self.state = UIGestureRecognizerStateRecognized;

    NSMutableSet *currentOneFingerTouches = [NSMutableSet setWithCapacity:4];
    
    for(UITouch *touch in touches) {
        if(CFDictionaryContainsKey(oneFingerTouches, touch)) {
            [currentOneFingerTouches addObject:(FSAOneFingerTouch*)CFDictionaryGetValue(oneFingerTouches, touch)];
        } else {
            NSLog(@"unknown touch: %@", touch);
        }
    }

    for(FSAOneFingerTouch* oft in currentOneFingerTouches) {
        if(oft.isThreeFingerDrag) {
            if([threeFingerTopDrags containsObject:oft]) {
                if([threeFingerTopDrags count] == 1) {
                    [self doCancelThreeFingerDrag:threeFingerTopDrags from:FSA_TOP];
                } else {
                    [threeFingerTopDrags removeObject:oft];
                    CFDictionaryRemoveValue(dragGestures, oft);
                }
            } else if([threeFingerBottomDrags containsObject:oft]) {
                if([threeFingerBottomDrags count] == 1) {
                    [self doCancelThreeFingerDrag:threeFingerBottomDrags from:FSA_BOTTOM];
                } else {
                    [threeFingerBottomDrags removeObject:oft];
                    CFDictionaryRemoveValue(dragGestures, oft);
                }
            } else if([threeFingerLeftDrags containsObject:oft]) {
                if([threeFingerLeftDrags count] == 1) {
                    [self doCancelThreeFingerDrag:threeFingerLeftDrags from:FSA_LEFT];
                } else {
                    [threeFingerLeftDrags removeObject:oft];
                    CFDictionaryRemoveValue(dragGestures, oft);
                }
            } else if([threeFingerRightDrags containsObject:oft]) {
                if([threeFingerRightDrags count] == 1) {
                    [self doCancelThreeFingerDrag:threeFingerRightDrags from:FSA_RIGHT];
                } else {
                    [threeFingerRightDrags removeObject:oft];
                    CFDictionaryRemoveValue(dragGestures, oft);
                }
            }
        } else {
            [self doCancelDrag:oft];
        }
            
        CFDictionaryRemoveValue(oneFingerTouches, oft.touch);
    }
}


@end

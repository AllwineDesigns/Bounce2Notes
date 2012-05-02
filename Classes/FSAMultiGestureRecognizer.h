//
//  FSAMultiGestureRecognizer.h
//  ParticleSystem
//
//  Created by John Allwine on 4/28/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>

const float FSA_FLICK_THRESHOLD = .3;
const float FSA_TAP_THRESHOLD = .2;

@interface FSAOneFingerTouch : NSObject {
    UITouch *touch;
    NSTimeInterval beginTimestamp;
    CGPoint beginLocation;
}

@property (retain,nonatomic) UITouch* touch;
@property (nonatomic) NSTimeInterval beginTimestamp;
@property (nonatomic) CGPoint beginLocation;

+(id)touchWithTouch: (UITouch*)touch atTimestamp:(NSTimeInterval)t;
-(id)initWithTouch: (UITouch*)touch atTimestamp:(NSTimeInterval)t;

@end

@interface FSATwoFingerTouch : NSObject {
    NSSet *touches; // pair UITouch objects
    NSTimeInterval timestamp;
    CGPoint beginLocation;
    
};

@property (retain,nonatomic) NSSet* touches;
@property (nonatomic) NSTimeInterval beginTimestamp;
@property (nonatomic) CGPoint beginLocation;

+(id)touchWithTouch: (UITouch*)touch andTouch:(UITouch*)touch2 atTimestamp:(NSTimeInterval)t;
-(id)initWithTouch: (UITouch*)touch andTouch:(UITouch*)touch2 atTimestamp:(NSTimeInterval)t;
-(BOOL)ended;
-(NSUInteger)tapCount;
-(NSTimeInterval)timestamp;
-(CGPoint) locationInView:(UIView*)view;

@end

@interface FSAMultiGesture : NSObject {
    CGPoint beginLocation;
    CGPoint location;
    NSTimeInterval beginTimestamp;
    NSTimeInterval timestamp;
}
@property (nonatomic) CGPoint beginLocation;
@property (nonatomic) CGPoint location;
@property (nonatomic) NSTimeInterval beginTimestamp;
@property (nonatomic) NSTimeInterval timestamp;
@end

@interface FSAMultiGestureRecognizer : UIGestureRecognizer {
    NSMutableSet *delayedSingleTaps;
    NSMutableSet *delayedTwoFingerSingleTaps;
    
    CFMutableDictionaryRef oneFingerTouches;
    CFMutableDictionaryRef twoFingerTouches;
    id target;
}
@property (retain, nonatomic) id target;
-(id)initWithTarget:(id)target;

@end

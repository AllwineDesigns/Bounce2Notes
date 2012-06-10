//
//  FSAMultiGestureRecognizer.h
//  ParticleSystem
//
//  Created by John Allwine on 4/28/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FSA_TOP,
    FSA_BOTTOM,
    FSA_LEFT,
    FSA_RIGHT
} FSAMultiGestureSide;

extern const float FSA_THREE_FINGER_THRESHOLD;
extern const float FSA_LONGTOUCH_THRESHOLD;
extern const float FSA_FLICK_THRESHOLD;
extern const float FSA_TAP_THRESHOLD;

@interface FSAOneFingerTouch : NSObject {
    BOOL isThreeFingerDrag;
    BOOL hasDragged;
    BOOL hasLongTouched;
    UITouch *touch;
    NSTimeInterval beginTimestamp;
    CGPoint beginLocation;
}
@property (nonatomic) BOOL isThreeFingerDrag;
@property (nonatomic) BOOL hasDragged;
@property (nonatomic) BOOL hasLongTouched;
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
    FSAMultiGestureSide side;
    CGPoint beginLocation;
    CGPoint location;
    CGPoint velocity;
    NSTimeInterval beginTimestamp;
    NSTimeInterval timestamp;
}
@property (nonatomic) FSAMultiGestureSide side;
@property (nonatomic) CGPoint beginLocation;
@property (nonatomic) CGPoint location;
@property (nonatomic) CGPoint velocity;
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

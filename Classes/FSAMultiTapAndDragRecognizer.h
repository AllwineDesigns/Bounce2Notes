//
//  FSAMultiTapAndDragRecognizer.h
//  ParticleSystem
//
//  Created by John Allwine on 4/28/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSAMultiGestureRecognizer.h"

@interface FSAMultiTapAndDragRecognizer : NSObject {    
    CFMutableDictionaryRef oneFingerTouches;
    CFMutableDictionaryRef dragGestures;
    NSMutableSet *threeFingerTopDrags;
    NSMutableSet *threeFingerLeftDrags;
    NSMutableSet *threeFingerBottomDrags;
    NSMutableSet *threeFingerRightDrags;
    
    UIView *view;
    
    float edgeWidth;
    
    id target;
}
@property (retain, nonatomic) UIView* view;
@property (retain, nonatomic) id target;
-(id)initWithTarget:(id)target;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end

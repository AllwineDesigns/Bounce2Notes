//
//  FSAMultiTapAndDragRecognizer.h
//  ParticleSystem
//
//  Created by John Allwine on 4/28/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSAMultiGestureRecognizer.h"

@interface FSAMultiTapAndDragRecognizer : UIGestureRecognizer {    
    CFMutableDictionaryRef oneFingerTouches;
    CFMutableDictionaryRef delayedLongTaps;
    CFMutableDictionaryRef dragGestures;
    id target;
}
@property (retain, nonatomic) id target;
-(id)initWithTarget:(id)target;

@end

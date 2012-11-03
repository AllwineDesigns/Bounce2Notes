//
//  BounceLock.h
//  ParticleSystem
//
//  Created by John Allwine on 10/22/12.
//
//

#import "BounceRenderable.h"
#import <Foundation/Foundation.h>
#import "BouncePane.h"

@interface BounceLock : NSObject {
    BounceRenderable *_renderable;
    BounceRenderableData _data;
    BOOL _isLocked;
    BOOL _isActivated;
    BOOL _isToggling;
    
    vec4 _color;
    
    NSTimeInterval _activatedTimestamp;
    NSTimeInterval _deactivatedTimestamp;
    NSTimeInterval _togglingTimestamp;

    
    vec2 _springLoc;
    vec2 _vel;
    
    float _springAngle;
    float _angVel;
    
    void* _gestureId;
}
-(void)setToggling:(BOOL)toggling;
-(BOOL)isToggling;
-(void)setActivated:(BOOL)activated;
-(BOOL)isActivated;
-(void)setLocked:(BOOL)locked;
-(void)toggleLocked;
-(BOOL)isLocked;
-(void)setOrientation:(BouncePaneOrientation)orientation;
-(void)step:(float)dt;
-(void)draw;

-(BOOL)singleTap: (void*)uniqueId at:(const vec2&)loc;
-(BOOL)flick:(void*)uniqueId at:(const vec2&)loc inDirection:(const vec2&)dir time:(NSTimeInterval)time;

-(BOOL)beginDrag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)drag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)endDrag:(void*)uniqueId at:(const vec2&)loc;
-(BOOL)cancelDrag:(void*)uniqueId at:(const vec2&)loc;

@end

//
//  ChipmunkObject.h
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <chipmunk/chipmunk.h>
#import <fsa/Vector.hpp>

using namespace fsa;

@interface ChipmunkObject : NSObject {
    cpSpace *_space;
    cpBody *_body;
    cpShape **_shapes;
    int _numShapes;
    int _allocatedShapes;
    
    bool _isInitializedRogue;
    
    float _mass;
    float _moment;
}
@property (nonatomic, readonly) cpSpace* space;
@property (nonatomic, readonly) cpBody* body;
@property (nonatomic, readonly) cpShape** shapes;
@property (nonatomic, readonly) int numShapes;

-(id)init;
-(id)initRogue;
-(id)initStatic;

-(void)addToSpace:(cpSpace*)space;
-(void)removeFromSpace;

-(void)addShape:(cpShape*)shape;

-(const vec2)velocity;
-(void)setVelocity:(const vec2&)vel;

-(const vec2)position;
-(void)setPosition:(const vec2&)loc;

-(float)angle;
-(void)setAngle:(float)a;

-(float)angVel;
-(void)setAngVel:(float)a;

-(float)mass;
-(void)setMass:(float)m;

-(float)moment;
-(void)setMoment:(float)m;

-(BOOL)isRogue;
-(void)makeRogue;

-(BOOL)isStatic;
-(void)makeStatic;

-(BOOL)isSimulated;
-(void)makeSimulated;

@end


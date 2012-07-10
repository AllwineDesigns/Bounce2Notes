//
//  ConfigurationBounceSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationSimulation.h"
#import "BounceConfigurationObject.h"

@implementation BounceConfigurationSimulation

-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation *)sim {
    self = [super initWithRect:rect];
    
    if(self) {
        _simulation = sim;
        [_simulation retain];
    }
    return self;
}

-(void)beginCreate:(void *)uniqueId at:(const vec2 &)loc {
}
-(void)beginTransform:(void *)uniqueId object:(BounceObject *)obj at:(const vec2 &)loc {
}

-(void)tapObject:(BounceObject *)obj {
}

-(void)tapSpaceAt:(const vec2 &)loc {
}

-(void)flickObjectsAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {
    BounceConfigurationObject *configObj;
    if((configObj = (BounceConfigurationObject*)[self objectAt:loc])) {         
        vec2 pos = configObj.position;
        BounceObject *obj = [_simulation addObjectAt:pos];
        
        obj.velocity = vel;
        
        [configObj setPreviewObject:obj];
        [configObj finalizeChange];
    }
    [super flickObjectsAt:loc withVelocity:vel];
}

-(void)flickSpaceAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {

}

-(void)longTouch:(void *)uniqueId at:(const vec2 &)loc {
    
}

-(void)drag:(void *)uniqueId at:(const vec2 &)loc {
    [super drag:uniqueId at:loc];
    
    BounceObject *obj = [_simulation objectAt:loc];
    
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    if(gesture) {
        BounceConfigurationObject *configObj = (BounceConfigurationObject*)gesture.object;
        if(!obj || ![self isObjectBeingPreviewed:obj]) {
            [configObj setPreviewObject:obj];
        }
    }
}

-(void)endDrag:(void *)uniqueId at:(const vec2 &)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    if(gesture) {
        BounceConfigurationObject *configObj = (BounceConfigurationObject*)gesture.object;
        
        BounceObject *obj = [configObj previewObject];
        if(obj) {
            [configObj finalizeChange];
        } else if(![self isInBoundsAt:loc]) {
            vec2 pos = configObj.position;
            BounceObject *obj = [_simulation addObjectAt:pos];
            
            obj.velocity = configObj.velocity;
            obj.angle = configObj.angle;
            obj.angVel = configObj.angVel;
            
            [configObj setPreviewObject:obj];
            [configObj finalizeChange];
        }
    
        [super endDrag:uniqueId at:loc];
    }

}

-(void)cancelDrag:(void *)uniqueId at:(const vec2 &)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    if(gesture) {
        BounceConfigurationObject *configObj = (BounceConfigurationObject*)gesture.object;
        [configObj cancelChange];
    
        [super cancelDrag:uniqueId at:loc];
    }
}

-(BOOL)isAnyObjectBeingPreviewed {
    for(BounceConfigurationObject *o in _objects) {
        if(o.previewObject) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isAnyObjectInBounds {
    for(BounceConfigurationObject *o in _objects) {
        vec2 pos = o.position;
        if([_simulation isInBoundsAt:pos]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isObjectBeingPreviewed:(BounceObject*)obj {
    for(BounceConfigurationObject *o in _objects) {
        if(o.previewObject == obj) {
            return YES;
        }
    }
    
    return NO;
}

-(void)draw {
    for(BounceObject *obj in _objects) {
        vec2 pos = obj.position;
        
        if([_simulation isInBoundsAt:pos]) {
            [obj draw];
        }
    }
}


-(void)dealloc {
    [_simulation release]; _simulation = nil;
    [super dealloc];
}

@end

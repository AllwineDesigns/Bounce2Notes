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

-(void)tapObject:(BounceObject *)obj at:(const vec2&)loc {
    if([obj isKindOfClass:[BounceConfigurationObject class]]) {
        BounceConfigurationObject *configObj = (BounceConfigurationObject*)obj;
        vec2 pos = configObj.position;
        BounceObject *newobj = [BounceObject randomObjectAt:pos];
        
        if([self isInBoundsAt:pos]) {
            newobj.position = vec2();
        }
        
        [configObj setPreviewObject:newobj];
        [configObj finalizeChange];
        [newobj addToSimulation:_simulation];
        [newobj playSound:.2];
    }

    [super tapObject:obj at:loc];
}

-(void)tapSpaceAt:(const vec2 &)loc {
}

-(void)flickObjectsAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {

}

-(void)flickObject:(BounceObject *)obj withVelocity:(const vec2 &)vel {
    if([obj isKindOfClass:[BounceConfigurationObject class]]) {
        BounceConfigurationObject *configObj = (BounceConfigurationObject*)obj;
        vec2 pos = configObj.position;
        BounceObject *newobj = [_simulation addObjectAt:pos];
            
        newobj.velocity = vel;
            
        [configObj setPreviewObject:newobj];
        [configObj finalizeChange];
    }
    
    [super flickObject:obj withVelocity:vel];
}

-(void)flickSpaceAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {

}

-(void)step:(float)t {
    [super step:t];
    
    for(BounceObject *bobj in _objects) {
        if([bobj isKindOfClass:[BounceConfigurationObject class]]) {
            BounceConfigurationObject *obj = (BounceConfigurationObject*)bobj;
            float timeSinceLastCreate = obj.timeSinceLastCreate;
            if(obj.painting && timeSinceLastCreate > .1) {
                [self tapObject:obj at:vec2()];
                obj.timeSinceLastCreate = 0;
            }
        }
    }
}

-(void)longTouch:(void *)uniqueId at:(const vec2 &)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];

    if(gesture) {
        if([[gesture object] isKindOfClass:[BounceConfigurationObject class]]) {
            BounceConfigurationObject *configObj = (BounceConfigurationObject*)[gesture object];
            configObj.painting = YES;
        }
    }
}

-(void)drag:(void *)uniqueId at:(const vec2 &)loc {
    [super drag:uniqueId at:loc];
    
    BounceObject *obj = [_simulation objectAt:loc];
    
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    if(gesture) {
        if([[gesture object] isKindOfClass:[BounceConfigurationObject class]]) {
            BounceConfigurationObject *configObj = (BounceConfigurationObject*)gesture.object;

            if([self isInBoundsAt:loc]) {
                [configObj setPreviewObject:nil];
            } else {
                if(!obj || (![self isObjectBeingPreviewed:obj] && [obj isPreviewable])) {
                    [configObj setPreviewObject:obj];
                } else if(configObj.painting) {
                    [self tapObject:configObj at:vec2()];
                }
            }
        }
    }
}

-(void)endDrag:(void *)uniqueId at:(const vec2 &)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    if(gesture) {
        if([[gesture object] isKindOfClass:[BounceConfigurationObject class]]) {

            BounceConfigurationObject *configObj = (BounceConfigurationObject*)gesture.object;
            
            BounceObject *obj = [configObj previewObject];
            if(obj) {
                if([self isInBoundsAt:loc]) {
                    [configObj cancelChange];
                } else {
                    [configObj finalizeChange];
                }
            } else if(![self isInBoundsAt:loc]) {
                vec2 pos = configObj.position;
                BounceObject *obj = [_simulation addObjectAt:pos];
                
                obj.velocity = configObj.velocity;
                obj.angle = configObj.angle;
                obj.angVel = configObj.angVel;
                
                [configObj setPreviewObject:obj];
                [configObj finalizeChange];
            }
            configObj.painting = NO;
        }

        [super endDrag:uniqueId at:loc];
    }

}

-(void)cancelDrag:(void *)uniqueId at:(const vec2 &)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    if(gesture) {
        if([[gesture object] isKindOfClass:[BounceConfigurationObject class]]) {
            BounceConfigurationObject *configObj = (BounceConfigurationObject*)gesture.object;
            [configObj cancelChange];
        }
    
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
        if([_simulation isInBoundsAt:pos withPadding:o.size]) {
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
        
        if([_simulation isInBoundsAt:pos withPadding:obj.size]) {
            [obj draw];
        }
    }
}


-(void)dealloc {
    [_simulation release]; _simulation = nil;
    [super dealloc];
}

@end

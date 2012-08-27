//
//  ConfigurationBounceSimulation.m
//  ParticleSystem
//
//  Created by John Allwine on 6/27/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "BounceConfigurationSimulation.h"
#import "BounceConfigurationObject.h"
#import "BounceSettings.h"

@implementation BounceConfigurationSimulation

-(id)initWithRect:(CGRect)rect bounceSimulation:(BounceSimulation *)sim {
    self = [super initWithRect:rect];
    
    if(self) {
        _simulation = sim;
        [_simulation retain];
        
       // [_arena makeHeavyRogue];
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
            [newobj setPosition:vec2()];
        }
        
        [configObj setConfigurationValueForObject:newobj];

        [newobj addToSimulation:_simulation];
        
        if(![configObj isKindOfClass:[BounceNoteConfigurationObject class]]) {
            [newobj playSound:.2];
        }
    }

    [super tapObject:obj at:loc];
}

-(void)tapSpaceAt:(const vec2 &)loc {
}

-(void)flickObjectsAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {

}

-(void)flickObject:(BounceObject *)obj at:(const vec2&)loc withVelocity:(const vec2 &)vel {
    if([obj isKindOfClass:[BounceConfigurationObject class]]) {
        BounceConfigurationObject *configObj = (BounceConfigurationObject*)obj;
        vec2 pos = configObj.position;
        BounceObject *newobj = [_simulation addObjectAt:pos];
            
        newobj.velocity = vel;
        
        [configObj setConfigurationValueForObject:newobj];
    }
    
    [super flickObject:obj at:loc withVelocity:vel];
}

-(void)flickSpaceAt:(const vec2 &)loc withVelocity:(const vec2 &)vel {

}

-(void)randomizeColor {
    for(BounceObject *obj in _objects) {
        vec4 color = [[[BounceSettings instance] colorGenerator] randomColor];
        [obj setColor:color];
    }
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
    
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    if(gesture) {
        if([[gesture object] isKindOfClass:[BounceConfigurationObject class]]) {
            BounceConfigurationObject *configObj = (BounceConfigurationObject*)gesture.object;

            if([self isInBoundsAt:loc]) {
                [configObj setPreviewObject:nil];
            } else {
               // BounceObject *obj = [_simulation objectAt:loc];
                NSSet *objects = [_simulation objectsAt:loc withinRadius:configObj.size];
                NSMutableSet *previewableObjects = [NSMutableSet setWithCapacity:10];
                for(BounceObject *obj in objects) {
                    if([obj isPreviewable] && (![self isObjectBeingPreviewed:obj] || [configObj.previewObjects containsObject:obj])) {
                        [previewableObjects addObject:obj];
                    }
                }
                if(configObj.painting) {
                    [self tapObject:configObj at:vec2()];
                }
                [configObj setPreviewObjects:previewableObjects];
            }
        }
    }
}

-(void)endDrag:(void *)uniqueId at:(const vec2 &)loc {
    BounceGesture *gesture = [self gestureForKey:uniqueId];
    
    if(gesture) {
        if([[gesture object] isKindOfClass:[BounceConfigurationObject class]]) {

            BounceConfigurationObject *configObj = (BounceConfigurationObject*)gesture.object;
            NSSet *previewObjects = configObj.previewObjects;
            
            if([previewObjects count] > 0) {
                [configObj finalizeChanges];
            } else if(![self isInBoundsAt:loc]) {
                vec2 pos = configObj.position;
                BounceObject *obj = [_simulation addObjectAt:pos];
                
                [obj setVelocity:configObj.velocity];
                obj.angle = configObj.angle;
                obj.angVel = configObj.angVel;
                
                [configObj setConfigurationValueForObject:obj];
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
            [configObj cancelChanges];
        }
    
        [super cancelDrag:uniqueId at:loc];
    }
}

-(BOOL)isAnyObjectBeingPreviewed {
    for(BounceObject *o in _objects) {
        if([o isKindOfClass:[BounceConfigurationObject class]]) {
            BounceConfigurationObject *obj = (BounceConfigurationObject*)o;
            if([obj.previewObjects count] > 0) {
                return YES;
            }
        }
    }
    
    return NO;
}

-(BOOL)isAnyObjectInBounds {
    for(BounceObject *o in _objects) {
        vec2 pos = o.position;
        if([_simulation isInBounds:o]) {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isObjectBeingPreviewed:(BounceObject*)obj {
    for(BounceObject *o in _objects) {
        if([o isKindOfClass:[BounceConfigurationObject class]]) {
            BounceConfigurationObject *ob = (BounceConfigurationObject*)o;
            NSSet *previewObjects = ob.previewObjects;
            if([previewObjects containsObject:obj]) {
                return YES;
            }
        }
    }
    
    return NO;
}

-(void)draw {
    for(BounceObject *obj in _objects) {
        vec2 pos = obj.position;
        
        if([_simulation isInBounds:obj] && obj.simulationWillDraw) {
            [obj draw];
        }
    }
}

-(void)setBounceShapesWithGenerator:(BounceShapeGenerator *)gen {
    for(BounceObject *obj in _objects) {
        if([obj isKindOfClass:[BounceConfigurationObject class]]) {
            [obj setBounceShape:[gen bounceShape]];
        }
    }
}

-(void)setBounceShape:(BounceShape)bounceshape {
    for(BounceObject *obj in _objects) {
        if([obj isKindOfClass:[BounceConfigurationObject class]]) {
            [obj setBounceShape:bounceshape];
        }
    }
}
-(void)setPatternTexture:(FSATexture *)patternTexture {
    for(BounceObject *obj in _objects) {
        if([obj isKindOfClass:[BounceConfigurationObject class]]) {
            [obj setPatternTexture:patternTexture];
        }
    }
}


-(void)dealloc {
    [_simulation release]; _simulation = nil;
    [super dealloc];
}

@end

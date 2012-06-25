//
//  ChipmunkObject.m
//  ParticleSystem
//
//  Created by John Allwine on 6/18/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#import "ChipmunkObject.h"

@implementation ChipmunkObject

@synthesize space = _space;
@synthesize body = _body;
@synthesize shapes = _shapes;
@synthesize numShapes = _numShapes;

-(id)init {
    self = [super init];
    
    if(self) {
        _isRogue = NO;
        _shapes = (cpShape**)malloc(sizeof(cpShape*));
        _numShapes = 0;
        _allocatedShapes = 1;
        
        _space = NULL;
        
        _body = cpBodyNew(1, 1);
        _mass = 1;
        _moment = 1;
    }
    return self;
}
-(id)initRogue {
    self = [super init];
    
    if(self) {
        _isRogue = YES;
        _shapes = (cpShape**)malloc(sizeof(cpShape*));
        _numShapes = 0;
        _allocatedShapes = 1;
        
        _body = cpBodyNew(1, 1);
        _mass = 1;
        _moment = 1;
    }
    return self;
}
-(id)initStatic {
    self = [super init];
    
    if(self) {
        _isRogue = NO;
        _shapes = (cpShape**)malloc(sizeof(cpShape*));
        _numShapes = 0;
        _allocatedShapes = 1;
        
        _body = cpBodyNewStatic();
        _mass = 1;
        _moment = 1;
    }
    return self;
}

-(void)addCircleShapeWithRadius: (float)radius withOffset: (const vec2&)offset {
    cpShape* shape = cpCircleShapeNew(_body, radius, (const cpVect&)offset);
    [self addShape:shape];
}

-(void)addSegmentShapeWithRadius: (float)radius fromA:(const vec2&)a toB:(const vec2&)b {
    cpShape* shape = cpSegmentShapeNew(_body, (const cpVect&)a, (const cpVect&)b, radius);
    [self addShape:shape];
}

-(void)addPolyShapeWithNumVerts: (int)numVerts withVerts:(vec2*)verts withOffset:(const vec2&)offset {
    cpShape* shape = cpPolyShapeNew(_body, numVerts, (cpVect*)verts, (const cpVect&)offset);
    [self addShape:shape];
}

-(void)addShape:(cpShape*)shape {
    if(_numShapes == _allocatedShapes) {
        _allocatedShapes *= 2;
        _shapes = (cpShape**)realloc(_shapes, _allocatedShapes*sizeof(cpShape*));
    }
    _shapes[_numShapes] = shape;
    if(_space != NULL) {
        cpSpaceAddShape(_space, shape);
    }
    _numShapes++;
}

-(void)removeAllShapes {
    if(_space != NULL) {
        for(int i = 0; i < _numShapes; ++i) {
            cpSpaceRemoveShape(_space, _shapes[i]);
        }
    }
    for(int i = 0; i < _numShapes; ++i) {
        cpShapeFree(_shapes[i]);
    }
    _numShapes = 0;
}

-(const vec2)velocity {
    vec2 vel(cpBodyGetVel(_body));
    
    return vel;
}
-(void)setVelocity:(const vec2&)vel {
    cpBodySetVel(_body, (const cpVect&)vel);
}

-(const vec2)position {
    vec2 pos(cpBodyGetPos(_body));
    
    return pos;
}
-(void)setPosition:(const vec2&)loc {
    cpBodySetPos(_body, (const cpVect&)loc);
}

-(float)angle {
    return cpBodyGetAngle(_body);
}
-(void)setAngle:(float)a {    
    cpBodySetAngle(_body, a);
}

-(float)angVel {
    return cpBodyGetAngVel(_body);
}

-(void)setAngVel:(float)a {
    cpBodySetAngVel(_body, a);
}

-(void)addToSpace:(cpSpace*)space {
    _space = space;
    if(!cpBodyIsStatic(_body) && !_isRogue) {
        cpSpaceAddBody(_space, _body);
    }
    for(int i = 0; i < _numShapes; i++) {
        cpSpaceAddShape(space, _shapes[i]);
    }
}
-(void)removeFromSpace {
    if(!cpBodyIsRogue(_body)) {
        cpSpaceRemoveBody(_space, _body);
    }
    for(int i = 0; i < _numShapes; i++) {
        cpSpaceRemoveShape(_space, _shapes[i]);
    }
    
    _space = NULL;
}
-(BOOL)hasBeenAddedToSpace {
    return _space != NULL;
}

-(float)mass {
    return _mass;
}
-(void)setMass:(float)m {
    _mass = m;
    if(!cpBodyIsStatic(_body)) {
        cpBodySetMass(_body, _mass);
    }
}

-(float)moment {
    return _moment;
}
-(void)setMoment:(float)m {
    _moment = m;
    if(!cpBodyIsStatic(_body)) {
        cpBodySetMoment(_body, _moment);
    }
}

-(BOOL)isRogue {
    return cpBodyIsRogue(_body) && !cpBodyIsStatic(_body);
}
-(void)makeRogue { // if static, makes 
    _isRogue = YES;
    if(cpBodyIsStatic(_body)) {
        [self makeSimulated];
    }
    
    if(_space != NULL) {
        if(!cpBodyIsRogue(_body)) {
            cpSpaceRemoveBody(_space, _body);
        }
    }
    
    cpBodySetMass(_body, _mass);
    cpBodySetMoment(_body, _moment);
}

-(BOOL)isStatic {
    return cpBodyIsStatic(_body);
}
-(void)makeStatic {
    _isRogue = NO;
    if(_space != NULL) {
        if(!cpBodyIsRogue(_body)) {
            cpSpaceRemoveBody(_space, _body);
        }
    }
    
    if(!cpBodyIsStatic(_body)) {
        if(_space != NULL) {
            for(int i = 0; i < _numShapes; i++) {
                cpSpaceRemoveShape(_space, _shapes[i]);
            }
        }
        
        CP_PRIVATE(_body->node).idleTime = (cpFloat)INFINITY;
        cpBodySetMass(_body, (cpFloat)INFINITY);
        cpBodySetMoment(_body, (cpFloat)INFINITY);
        
        if(_space != NULL) {
            for(int i = 0; i < _numShapes; i++) {
                cpSpaceAddShape(_space, _shapes[i]);
            }
            cpSpaceReindexStatic(_space);
        }
        
        cpBodySetVel(_body, cpvzero);
        cpBodySetAngVel(_body, 0);
    }
}

-(BOOL)isSimulated {
    return !cpBodyIsRogue(_body);
}
-(void)makeSimulated {
    bool wasStatic = cpBodyIsStatic(_body);
    
    _isRogue = NO;
    if(cpBodyIsRogue(_body)) {
        
        if(_space != NULL) {
            for(int i = 0; i < _numShapes; i++) {
                cpSpaceRemoveShape(_space, _shapes[i]);
            }
        }
        
        CP_PRIVATE(_body->node).idleTime = (cpFloat)0;
        cpBodySetMass(_body, _mass);
        cpBodySetMoment(_body, _moment);
        
        if(_space != NULL) {
            for(int i = 0; i < _numShapes; i++) {
                cpSpaceAddShape(_space, _shapes[i]);
            }
            
            
            cpSpaceAddBody(_space, _body);
            
            if(wasStatic) {
                cpSpaceReindexStatic(_space);
            }
        }

    }
}

-(void)dealloc {
    for(int i = 0; i < _numShapes; i++) {
        cpShapeFree(_shapes[i]);
    }
    cpBodyFree(_body);
    
    free(_shapes);
    
    [super dealloc];
}

@end

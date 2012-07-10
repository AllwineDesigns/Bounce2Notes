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
        _state = CHIPMUNK_OBJECT_SIMULATED;
        _shapes = (cpShape**)malloc(sizeof(cpShape*));
        _numShapes = 0;
        _allocatedShapes = 1;
        
        _space = NULL;
        
        _body = cpBodyNew(1, 1);
        cpBodySetUserData(_body, self);

        _mass = 1;
        _moment = 1;
    }
    return self;
}
-(id)initRogue {
    self = [super init];
    
    if(self) {
        _state = CHIPMUNK_OBJECT_ROGUE;
        _shapes = (cpShape**)malloc(sizeof(cpShape*));
        _numShapes = 0;
        _allocatedShapes = 1;
        
        _body = cpBodyNew(1, 1);
        cpBodySetUserData(_body, self);

        _mass = 1;
        _moment = 1;
    }
    return self;
}

-(id)initHeavyRogue {
    self = [super init];
    
    if(self) {
        _state = CHIPMUNK_OBJECT_HEAVY_ROGUE;
        _shapes = (cpShape**)malloc(sizeof(cpShape*));
        _numShapes = 0;
        _allocatedShapes = 1;
        
        _body = cpBodyNew(1, 1);
        cpBodySetUserData(_body, self);

        _mass = 999999;
        _moment = 999999;
    }
    return self;
}

-(id)initStatic {
    self = [super init];
    
    if(self) {
        _state = CHIPMUNK_OBJECT_STATIC;
        _shapes = (cpShape**)malloc(sizeof(cpShape*));
        _numShapes = 0;
        _allocatedShapes = 1;
        
        _body = cpBodyNewStatic();
        cpBodySetUserData(_body, self);
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
    if(_space != NULL) {
        cpSpaceReindexShapesForBody(_space, _body);
        
        if(_state == CHIPMUNK_OBJECT_STATIC) {
            cpSpaceReindexStatic(_space);
        }
    }

}

-(float)angle {
    return cpBodyGetAngle(_body);
}
-(void)setAngle:(float)a {    
    cpBodySetAngle(_body, a);
    if(_space != NULL) {
        cpSpaceReindexShapesForBody(_space, _body);
        if(_state == CHIPMUNK_OBJECT_STATIC) {
            cpSpaceReindexStatic(_space);
        }
    }
}

-(float)angVel {
    return cpBodyGetAngVel(_body);
}

-(void)setAngVel:(float)a {
    cpBodySetAngVel(_body, a);
}

-(void)addToSpace:(cpSpace*)space {
    _space = space;
    if(_state == CHIPMUNK_OBJECT_SIMULATED) {
        cpSpaceAddBody(_space, _body);
    }
    for(int i = 0; i < _numShapes; i++) {
        cpSpaceAddShape(space, _shapes[i]);
    }
}
-(void)removeFromSpace {
    if(_state == CHIPMUNK_OBJECT_SIMULATED) {
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
    if(_state == CHIPMUNK_OBJECT_SIMULATED || _state == CHIPMUNK_OBJECT_ROGUE) {
        cpBodySetMass(_body, _mass);
    }
}

-(float)moment {
    return _moment;
}
-(void)setMoment:(float)m {
    _moment = m;
    if(_state == CHIPMUNK_OBJECT_SIMULATED || _state == CHIPMUNK_OBJECT_ROGUE) {
        cpBodySetMoment(_body, _moment);
    }
}

-(BOOL)isSimulated {
    return _state == CHIPMUNK_OBJECT_SIMULATED;
}

-(BOOL)isHeavyRogue {
    return _state == CHIPMUNK_OBJECT_HEAVY_ROGUE;
}

-(BOOL)isStatic {
    return _state == CHIPMUNK_OBJECT_STATIC;
}
-(BOOL)isRogue {
    return _state == CHIPMUNK_OBJECT_ROGUE;
}


/*
-(void)createNewBody {
    cpBody *body;
    switch(_state) {
        case CHIPMUNK_OBJECT_ROGUE:
            body = cpBodyNew(_mass, _moment);
            break;
        case CHIPMUNK_OBJECT_HEAVY_ROGUE:
            body = cpBodyNew(999999,999999);
            break;
        case CHIPMUNK_OBJECT_SIMULATED:
            body = cpBodyNew(_mass, _moment);
            break;
        case CHIPMUNK_OBJECT_STATIC:
            body = cpBodyNewStatic();
            break;
    }
    
    body->p = _body->p;
    body->v = _body->v;
    body->a = _body->a;
    body->w = _body->w;
    
    if(_space != NULL) {
        for(int i = 0; i < _numShapes; i++) {
            cpSpaceRemoveShape(_space, _shapes[i]);
        }
        if(!cpBodyIsRogue(_body)) {
            cpSpaceRemoveBody(_space, _body);
        }
    }
    cpBodyFree(_body);
    
    _body = body;
    cpBodySetUserData(_body, self);
    
    for(int i = 0; i < _numShapes; i++) {
        cpShapeSetBody(_shapes[i], _body);
    }
    
    if(_space != NULL) {
        for(int i = 0; i < _numShapes; i++) {
            cpSpaceAddShape(_space, _shapes[i]);
        }
        if(_state == CHIPMUNK_OBJECT_SIMULATED) {
            cpSpaceAddBody(_space, _body);
        }
    }
    if(_space != NULL) {
        cpSpaceReindexShapesForBody(_space, _body);
    }
}
*/



-(void)makeRogue {
    
   // [self createNewBody];

    if(cpBodyIsStatic(_body)) {
        [self makeSimulated];
    }
    
    _state = CHIPMUNK_OBJECT_ROGUE;

    
    if(_space != NULL) {
        if(!cpBodyIsRogue(_body)) {
            cpSpaceRemoveBody(_space, _body);
        }
    }
    
    cpBodySetMass(_body, _mass);
    cpBodySetMoment(_body, _moment);
    
}

-(void)makeHeavyRogue {
    
   // [self createNewBody];

    if(cpBodyIsStatic(_body)) {
        [self makeSimulated];
    }
    
    _state = CHIPMUNK_OBJECT_HEAVY_ROGUE;

    if(_space != NULL) {
        if(!cpBodyIsRogue(_body)) {
            cpSpaceRemoveBody(_space, _body);
        }
    }
    
    cpBodySetMass(_body, 999999);
    cpBodySetMoment(_body, 999999);
}

-(void)makeStatic {
    
  //  [self createNewBody];
    
    [self makeSimulated];
    
    _state = CHIPMUNK_OBJECT_STATIC;

    
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

-(void)makeSimulated {
    _state = CHIPMUNK_OBJECT_SIMULATED;

   // [self createNewBody];
    
    bool wasStatic = cpBodyIsStatic(_body);
    
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

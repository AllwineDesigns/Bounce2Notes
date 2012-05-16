//
//  ChipmunkSimulation.cpp
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#include "ChipmunkSimulation.h"
#include <fsa/Noise.hpp>
#include <chipmunk/chipmunk_unsafe.h>

int collisionBegin(cpArbiter *arb, cpSpace *space, void *data) {
    return 1;
}
int preSolve(cpArbiter *arb, cpSpace *space, void *data) {
//    ChipmunkSimulation *simulation = (ChipmunkSimulation*)data;
//    unsigned int numBalls = simulation->numBalls();
    cpBody *body1;
    cpBody *body2;
    cpShape *shape1;
    cpShape *shape2;
    cpArbiterGetBodies(arb, &body1, &body2);
    cpArbiterGetShapes(arb, &shape1, &shape2);
    
    cpCollisionType t1 = cpShapeGetCollisionType(shape1);
    cpCollisionType t2 = cpShapeGetCollisionType(shape2);
    
    if(t1 == BALL_TYPE) {
        BallData* ballData = (BallData*)cpBodyGetUserData(body1);
        cpVect vel = cpBodyGetVel(body1);
        vec2 v(vel.x, vel.y);
        
        ballData->last_vel = v;
    }
    
    if(t2 == BALL_TYPE) {
        BallData* ballData = (BallData*)cpBodyGetUserData(body2);
        cpVect vel = cpBodyGetVel(body2);
        vec2 v(vel.x, vel.y);
        
        ballData->last_vel = v;
    }
   
    return 1;
}
void postSolve(cpArbiter *arb, cpSpace *space, void *data) {
    ChipmunkSimulation *simulation = (ChipmunkSimulation*)data;

    cpBody *body1;
    cpBody *body2;
    cpShape *shape1;
    cpShape *shape2;
    cpArbiterGetBodies(arb, &body1, &body2);
    cpArbiterGetShapes(arb, &shape1, &shape2);
        
    cpCollisionType t1 = cpShapeGetCollisionType(shape1);
    cpCollisionType t2 = cpShapeGetCollisionType(shape2);

    float ke = 0; 
    
    BallData* ballData1 = (BallData*)cpBodyGetUserData(body1);
    BallData* ballData2 = (BallData*)cpBodyGetUserData(body2);
    
    int note1 = -1;
    int note2 = -1;
    
    float vol1;
    float vol2;
    
    if(t1 == BALL_TYPE) {
        BallData* ballData = ballData1;
        
        float radius = cpCircleShapeGetRadius(shape1);
        float last_mag = ballData->last_vel.length();
        
        ke += (last_mag*last_mag);
    }

    if(t2 == BALL_TYPE) {
        BallData* ballData = ballData2;
        cpVect vel = cpBodyGetVel(body2);
        vec2 v(vel);
        
        float radius = cpCircleShapeGetRadius(shape2);
        float last_mag = ballData->last_vel.length();
        ke += (last_mag*last_mag);
    }
    
    if(t1 == BALL_TYPE && t2 == BALL_TYPE) {
        ke *= .5;
    }
    
    if(t1 == BALL_TYPE) {
        float radius = cpCircleShapeGetRadius(shape1);
        note1 = (1-radius)*(1-radius)*[simulation->getAudioPlayer() numSounds];

        vol1 = .1*(radius*ke > 1 ? 1 : radius*ke);

        if(vol1 > 0.001) {
            [simulation->getAudioPlayer() playSound:note1 volume:vol1];
        }
        
        ballData1->intensity += .05*ke/radius;
        if(ballData1->intensity > 2.2) {
            ballData1->intensity = 2.2;
        }
    }
    
    if(t2 == BALL_TYPE) {

        float radius = cpCircleShapeGetRadius(shape2);
        note2 = (1-radius)*(1-radius)*[simulation->getAudioPlayer() numSounds];
        vol2 = .1*(radius*ke > 1 ? 1 : radius*ke);
        if(vol2 > 0.001) {
            [simulation->getAudioPlayer() playSound:note2 volume:vol2];
        }
        
        ballData2->intensity += .05*ke/radius;
        if(ballData2->intensity > 2.2) {
            ballData2->intensity = 2.2;
        }
    }

}
void separate(cpArbiter *arb, cpSpace *space, void *data) {
    
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	//NSLog(@"Hue %f",h);
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

ChipmunkSimulation::ChipmunkSimulation(float aspect) : dt(.02), time_remainder(0) {
   // sound_manager = [[SoundManager alloc] initWithSounds:[NSArray arrayWithObjects:@"c", @"d", @"e", @"f", @"g", @"a", @"b", @"c2", nil]];
 //  audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c", @"d", @"e", @"f", @"g", @"a", @"b", @"c2", nil]];

//    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c", @"e", @"g", @"a", @"c2", nil]];
//    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c_1", @"e_1",@"g_1", @"a_1", @"c_2", @"e_2", @"g_2", @"a_2", @"c_3", nil]];
//    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c_1", @"e_1",@"g_1", @"a_1", @"b_1", @"c_2", nil]];
    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"marimba_c1", @"marimba_e1", @"marimba_g1", @"marimba_a1", @"marimba_c2", nil]];


//    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"guitarStereo", nil]];

    [audio_player startAUGraph];
    
    creating = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    grabbing = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    
    space = cpSpaceNew();
    cpSpaceSetGravity(space, *((cpVect*)(&gravity)));
//    cpSpaceSetDamping(space, .5);
    cpSpaceSetCollisionSlop(space, .02);
    
//    cpSpaceUseSpatialHash(space, .3, 3000);
    
    cpSpaceSetDefaultCollisionHandler(space, collisionBegin, preSolve, postSolve, separate, this);

//    bottom = cpSegmentShapeNew(space->staticBody, cpv(-1, -2.6), cpv(1, -2.6), 1.11);
//    top = cpSegmentShapeNew(space->staticBody, cpv(-1, 2.6), cpv(1, 2.6), 1.11);
//    right = cpSegmentShapeNew(space->staticBody, cpv(2.1, 1.5), cpv(2.1, -1.5), 1.11);
//    left = cpSegmentShapeNew(space->staticBody, cpv(-2.1, 1.5), cpv(-2.1, -1.5), 1.11);
    float inv_aspect = 1./aspect;
    bottom = cpSegmentShapeNew(space->staticBody, cpv(-1, -inv_aspect-1.1), cpv(1, -inv_aspect-1.1), 1.11);
    top = cpSegmentShapeNew(space->staticBody, cpv(-1, inv_aspect+1.1), cpv(1, inv_aspect+1.1), 1.11);
    right = cpSegmentShapeNew(space->staticBody, cpv(2.1, inv_aspect), cpv(2.1, -inv_aspect), 1.11);
    left = cpSegmentShapeNew(space->staticBody, cpv(-2.1, inv_aspect), cpv(-2.1, -inv_aspect), 1.11);

    
    cpShapeSetFriction(bottom,.1);
    cpShapeSetFriction(top, .1);
    cpShapeSetFriction(right, .1);
    cpShapeSetFriction(left, .1);
    
    cpShapeSetElasticity(bottom,1.);
    cpShapeSetElasticity(top, 1.);
    cpShapeSetElasticity(right, 1.);
    cpShapeSetElasticity(left, 1.);
    
    cpShapeSetCollisionType(bottom,WALL_TYPE);
    cpShapeSetCollisionType(top, WALL_TYPE);
    cpShapeSetCollisionType(right, WALL_TYPE);
    cpShapeSetCollisionType(left, WALL_TYPE);
    
    cpSpaceAddShape(space, bottom);
    cpSpaceAddShape(space, top);
    cpSpaceAddShape(space, right);
    cpSpaceAddShape(space, left);
    
//    for(int i = 0; i < 300; i++) {
    for(int i = 0; i < 1; i++) {

        cpFloat radius = 1.5*(random(i*1.234)*.075+.05);
        cpFloat mass = 100*radius*radius;

        cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
       
        HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
        ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);

//        ballData->color = vec4((ballData->color.x+1)*.4,(ballData->color.y+1)*.4,(ballData->color.z+1)*.4,1);
//        sqrt( 0.241*R^2 + 0.691*G^2 + 0.068*B^2 )
        /*
        HSVtoRGB(&(ballData->color.x), &(ballData->color.x), &(ballData->color.x), 360.*random(64.28327*i), .5*random(273.2932*i), 1   );
        
        float lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
        int tries = 1;
        while((lum < .25 || lum > .75) && tries < 100) {
//            col = vec3(random(64.7263*i+7.2893*tries), random(91.23819*i+928.233588*tries), random(342.123*i+316.1928274*tries));
//            lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
            ++tries;
        }
        */
        /*
         ballData->color.x = col.x;
         ballData->color.y = col.y;
         ballData->color.z = col.z;
        */
//        HSVtoRGB(&(ballData->color.x), &(ballData->color.x), &(ballData->color.x), 360.*random(64.28327*i), .5*random(273.2932*i), 1   );
        cpBody *ballBody = cpSpaceAddBody(space, cpBodyNew(mass, moment));
        cpBodySetPos(ballBody, cpv(random(2.3234*i)-.5, random(4.59234*i)-.5));
        cpBodySetVel(ballBody, cpv(5*(random(92.11234*i)-.5), 5*(random(23.234934*i)-.5)));
        cpBodySetVelLimit(ballBody, 5);
        cpBodySetUserData(ballBody, ballData);

        cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
        cpShapeSetFriction(ballShape, .1);
        cpShapeSetElasticity(ballShape, .95);
        cpShapeSetCollisionType(ballShape, BALL_TYPE);
        
        bodies.push_back(ballBody);
        shapes.push_back(ballShape);
    }
    
}

static void getShapesQueryFunc(cpShape *shape, cpContactPointSet *points, void* data) {
    std::vector<cpShape*> *shapes = (std::vector<cpShape*>*)data;
    shapes->push_back(shape);
}

FSAAudioPlayer* ChipmunkSimulation::getAudioPlayer() {
    return audio_player;
}

//SoundManager* ChipmunkSimulation::getSoundManager() {
//    return sound_manager;
//}

void ChipmunkSimulation::next() {
    cpSpaceStep(space, dt);
    
    std::vector<cpBody*>::iterator itr = bodies.begin();
    while(itr != bodies.end()) {
        BallData* ballData = (BallData*)cpBodyGetUserData(*itr);
        ballData->intensity *= .9;
//        cpVect v = cpBodyGetVel(*itr);
//        vec2 vel(v.x,v.y);
//        ballData->intensity = .2*vel.length();
        ++itr;
    }
    
}

void ChipmunkSimulation::addToVelocity(const vec2& v) {
    std::vector<cpBody*>::iterator itr = bodies.begin();
    while(itr != bodies.end()) {
        if(!cpBodyIsStatic(*itr)) {
            cpVect vel = cpBodyGetVel(*itr);
            vel.x += v.x;
            vel.y += v.y;
            cpBodySetVel(*itr, vel);
        }
        ++itr;
    }
}

bool ChipmunkSimulation::isBallAt(const vec2& loc) {
    return getShapeAt(loc) != NULL;
}

static void shapeQueryFunc(cpShape *shape, cpContactPointSet *points, void* data) {
    cpBody *body = cpShapeGetBody(shape);
    if(body != NULL && !cpBodyIsStatic(body)) {
        vec2 v(cpBodyGetVel(body));
        v += *(vec2*)data;
        cpBodySetVel(body, (const cpVect&)v);
    }
}

bool ChipmunkSimulation::anyBallsAt(const vec2& loc, float radius) {
    cpBody *b = cpBodyNew(1,1);
    cpBodySetPos(b, (const cpVect&)loc);
    cpShape *sensor = cpCircleShapeNew(b, radius, cpvzero);
    
    bool ret = cpSpaceShapeQuery(space, sensor, NULL, NULL);
    cpShapeFree(sensor);
    cpBodyFree(b);
    return ret;
}

cpShape* ChipmunkSimulation::getShapeAt(const vec2& loc) {
    cpBody *body = cpBodyNew(1, 1);
    cpBodySetPos(body, (const cpVect&)loc);
    cpShape *sensor = cpCircleShapeNew(body, .1, cpvzero);
    std::vector<cpShape*> del_shapes;
    cpSpaceShapeQuery(space, sensor, getShapesQueryFunc, (void*)&del_shapes);
    std::vector<cpShape*>::iterator itr = del_shapes.begin();
    
    cpShape *closestShape = NULL;
    float min_dist = 99999;
    
    while(itr != del_shapes.end()) {
        if(bottom == *itr || top == *itr || left == *itr || right == *itr) {
            ++itr;
            continue;
        }
        cpBody *b = cpShapeGetBody(*itr);
        vec2 pos(cpBodyGetPos(b));
        pos -= loc;
        float dist = pos.length();
        if(dist < min_dist) {
            closestShape = *itr;
            min_dist = dist;
        }
        
        ++itr;
    }
    
    cpShapeFree(sensor);
    cpBodyFree(body);
    
    return closestShape;
 
}

void ChipmunkSimulation::removeBallAt(const vec2& loc) {
    cpShape* shape = getShapeAt(loc);
    
    bool ballBeingGrabbedOrCreated = false;
    int size = CFDictionaryGetCount(grabbing);
    CFTypeRef *keysTypeRef = (CFTypeRef *) malloc( size * sizeof(CFTypeRef) );
    CFDictionaryGetKeysAndValues(grabbing, (const void **) keysTypeRef, NULL);
    const void **keys = (const void **) keysTypeRef;
    for(int i = 0; i < size; ++i) {
        cpShape *grabbedShape = (cpShape*)CFDictionaryGetValue(grabbing, keys[i]);
        if(grabbedShape == shape) {
            ballBeingGrabbedOrCreated = true;
            break;
        }
    }
    free(keys);
    
    size = CFDictionaryGetCount(creating);
    keysTypeRef = (CFTypeRef *) malloc( size * sizeof(CFTypeRef) );
    CFDictionaryGetKeysAndValues(creating, (const void **) keysTypeRef, NULL);
    keys = (const void **) keysTypeRef;
    
    for(int i = 0; i < size; ++i) {
        cpShape* s = (cpShape*)CFDictionaryGetValue(creating, keys[i]);
        if(s == shape) {
            ballBeingGrabbedOrCreated = true;
            break;
        }
    }
    free(keys);
    
    if(ballBeingGrabbedOrCreated) {
        return;
    }

    if(shape != NULL) {
        cpBody* body = cpShapeGetBody(shape);
        if(cpSpaceContainsBody(space, body)) {
            cpSpaceRemoveBody(space, body);
        }
        cpSpaceRemoveShape(space, shape);
        for(int i = shapes.size()-1; i >= 0; i--) {
            if(shapes[i] == shape) {
                shapes.erase(shapes.begin()+i);
                bodies.erase(bodies.begin()+i);
            }
        }
        
        cpShapeFree(shape);
        cpBodyFree(body);
    }
}
void ChipmunkSimulation::addVelocityToBallsAt(const vec2 &loc, const vec2& vel, float radius) {
    cpBody *body = cpBodyNew(1, 1);
    cpBodySetPos(body, (const cpVect&)loc);
    cpShape *sensor = cpCircleShapeNew(body, radius, cpvzero);
    cpSpaceShapeQuery(space, sensor, shapeQueryFunc, (void*)&vel);
    
    cpShapeFree(sensor);
    cpBodyFree(body);
}

void ChipmunkSimulation::addBallWithVelocity(const vec2& loc, const vec2& vel) {
    float i = loc.x*loc.y;
    cpFloat radius = 1.5*(random(i*1.234)*.075+.05);
    cpFloat mass = 100*radius*radius;
    
    cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
    BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
    HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
    ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
    ballData->intensity = 2;

    /*
    vec3 col(ballData->color.xyz());
    //        sqrt( 0.241*R^2 + 0.691*G^2 + 0.068*B^2 )
    float lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
    int tries = 1;
    while((lum < .25 || lum > .75) && tries < 100) {
        col = vec3(random(64.7263*i+7.2893*tries), random(91.23819*i+928.233588*tries), random(342.123*i+316.1928274*tries));
        lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
        
        ++tries;
    }
    ballData->color.x = col.x;
    ballData->color.y = col.y;
    ballData->color.z = col.z;
     */
    
    cpBody *ballBody = cpSpaceAddBody(space, cpBodyNew(mass, moment));
    //    cpBody *ballBody = cpBodyNew(mass, moment);
    //cpBody *ballBody = cpBodyNewStatic();
    
    
    cpBodySetPos(ballBody, (const cpVect&)loc);
    cpBodySetVel(ballBody, (const cpVect&)vel);
    cpBodySetVelLimit(ballBody, 5);
    cpBodySetUserData(ballBody, ballData);
    
    //    cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
    cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
    
    cpShapeSetFriction(ballShape, .1);
    cpShapeSetElasticity(ballShape, .95);
    cpShapeSetCollisionType(ballShape, BALL_TYPE);
    
    bodies.push_back(ballBody);
    shapes.push_back(ballShape);
}

void ChipmunkSimulation::addBallAt(const vec2& loc) {
    float i = loc.x*loc.y;
    cpFloat radius = 1.5*(random(i*1.234)*.075+.05);
    cpFloat mass = 100*radius*radius;
    
    cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
    BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
    HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
    ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
    ballData->intensity = 2;

    /*
    vec3 col(ballData->color.xyz());
    //        sqrt( 0.241*R^2 + 0.691*G^2 + 0.068*B^2 )
    float lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
    int tries = 1;
    while((lum < .25 || lum > .75) && tries < 100) {
        col = vec3(random(64.7263*i+7.2893*tries), random(91.23819*i+928.233588*tries), random(342.123*i+316.1928274*tries));
        lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
        
        ++tries;
    }
    ballData->color.x = col.x;
    ballData->color.y = col.y;
    ballData->color.z = col.z;
     */
    
    cpBody *ballBody = cpSpaceAddBody(space, cpBodyNew(mass, moment));
//    cpBody *ballBody = cpBodyNew(mass, moment);
//    cpBody *ballBody = cpBodyNewStatic();

    
    cpBodySetPos(ballBody, (const cpVect&)loc);
//    cpBodySetVel(ballBody, cpv(5*(random(92.11234*i)-.5), 5*(random(23.234934*i)-.5)));
    cpBodySetVelLimit(ballBody, 5);
    cpBodySetUserData(ballBody, ballData);
    
    cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));

    cpShapeSetFriction(ballShape, .1);
    cpShapeSetElasticity(ballShape, .95);
    cpShapeSetCollisionType(ballShape, BALL_TYPE);
    cpSpaceReindexStatic(space);
    
    bodies.push_back(ballBody);
    shapes.push_back(ballShape);
}

void ChipmunkSimulation::toggleStaticAt(const vec2& loc) {
    cpShape *shape = getShapeAt(loc);
    cpBody *body = cpShapeGetBody(shape);
    
    if(cpBodyIsStatic(body)) {
        float radius = cpCircleShapeGetRadius(shape);
        float mass = 100*radius*radius;
        cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData *data = (BallData*)cpBodyGetUserData(body);
        cpVect pos = cpBodyGetPos(body);
        cpVect vel = cpBodyGetVel(body);

        cpBody *new_body = cpSpaceAddBody(space, cpBodyNew(mass, moment));
        cpShape *new_shape = cpSpaceAddShape(space, cpCircleShapeNew(new_body, radius, cpvzero));
        cpBodySetPos(new_body, pos);
        cpBodySetVel(new_body, vel);
        cpBodySetVelLimit(new_body, 5);
        cpBodySetUserData(new_body, data);
        
        cpShapeSetFriction(new_shape,.1);
        cpShapeSetElasticity(new_shape, .95);
        cpShapeSetCollisionType(new_shape, BALL_TYPE);
        
        cpSpaceRemoveShape(space, shape);
        cpShapeFree(shape);
        cpBodyFree(body);
        
        for(int i = shapes.size()-1; i >= 0; i--) {
            if(shapes[i] == shape) {
                shapes[i] = new_shape;
                bodies[i] = new_body;
            }
        }
    } else {
        float radius = cpCircleShapeGetRadius(shape);
        BallData *data = (BallData*)cpBodyGetUserData(body);
        cpVect pos = cpBodyGetPos(body);
        
        cpBody *new_body = cpBodyNewStatic();
        cpShape *new_shape = cpSpaceAddShape(space, cpCircleShapeNew(new_body, radius, cpvzero));

        cpBodySetUserData(new_body, data);
        
        cpBodySetPos(new_body, pos);
        cpBodySetUserData(new_body, data);
        
        cpShapeSetFriction(new_shape, .1);
        cpShapeSetElasticity(new_shape, .95);
        cpShapeSetCollisionType(new_shape, BALL_TYPE);
        
        cpSpaceRemoveShape(space, shape);
        cpSpaceRemoveBody(space, body);

        cpShapeFree(shape);
        cpBodyFree(body);
        
        cpSpaceReindexStatic(space);
        
        for(int i = shapes.size()-1; i >= 0; i--) {
            if(shapes[i] == shape) {
                shapes[i] = new_shape;
                bodies[i] = new_body;
            }
        }
    }
}

void ChipmunkSimulation::addStaticBallAt(const vec2& loc) {
    float i = loc.x*loc.y;
    cpFloat radius = 1.5*(random(i*1.234)*.075+.05);
//    cpFloat mass = 100*radius*radius;
    
//    cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
    BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
    HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
    ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
    ballData->intensity = 4;
    
    /*
     vec3 col(ballData->color.xyz());
     //        sqrt( 0.241*R^2 + 0.691*G^2 + 0.068*B^2 )
     float lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
     int tries = 1;
     while((lum < .25 || lum > .75) && tries < 100) {
     col = vec3(random(64.7263*i+7.2893*tries), random(91.23819*i+928.233588*tries), random(342.123*i+316.1928274*tries));
     lum = sqrt(.241*col.x*col.x+.691*col.y*col.y+.068*col.z*col.z);
     
     ++tries;
     }
     ballData->color.x = col.x;
     ballData->color.y = col.y;
     ballData->color.z = col.z;
     */
    
    //cpBody *ballBody = cpSpaceAddBody(space, cpBodyNew(mass, moment));
    //cpBody *ballBody = cpBodyNew(mass, moment);
    cpBody *ballBody = cpBodyNewStatic();
    
    
    cpBodySetPos(ballBody, (const cpVect&)loc);
    //    cpBodySetVel(ballBody, cpv(5*(random(92.11234*i)-.5), 5*(random(23.234934*i)-.5)));
    cpBodySetVelLimit(ballBody, 5);
    cpBodySetUserData(ballBody, ballData);
    
    cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
    
    cpShapeSetFriction(ballShape, .1);
    cpShapeSetElasticity(ballShape, .95);
    cpShapeSetCollisionType(ballShape, BALL_TYPE);
    cpSpaceReindexStatic(space);
    
    bodies.push_back(ballBody);
    shapes.push_back(ballShape);
}

void ChipmunkSimulation::step(float t) {
    t += time_remainder;
    
    while(t > dt) {
        next();
        t -= dt;
    }
    
    time_remainder = t;
}

/*
bool ChipmunkSimulation::isGrabbingBall(void *uniqueId) {
    return CFDictionaryContainsKey(grabbing, uniqueId);
}

void ChipmunkSimulation::grabbingBallAt(const vec2& loc, void *uniqueId) {
    if(CFDictionaryContainsKey(grabbing, uniqueId)) {
        GrabData *gdata = (GrabData*)CFDictionaryGetValue(grabbing, uniqueId);
        cpBody *body = cpShapeGetBody(gdata->grabbingShape);
        
        cpBodySetPos(body, (cpVect&)loc);
       // cpBodySetVel(body, (cpVect&)vel);
        cpSpaceReindexShapesForBody(space, body);
    } else {
        cpShape* shape = getShapeAt(loc);
        cpBody* body = cpShapeGetBody(shape);
        if(!cpBodyIsStatic(body)) {
            GrabData *gdata = new GrabData;
            gdata->grabbedShape = shape;
         //   float mass = 99999;
       //     float moment = cpMomentForCircle(mass, 0, .1, cpvzero);
            
            cpBody *grabbing_body = cpBodyNewStatic();
            cpBodySetPos(grabbing_body, (cpVect&)loc);
            
            BallData *data = new BallData(vec4(1,1,1,1));
            cpBodySetUserData(grabbing_body, data);
            gdata->grabbingShape = cpSpaceAddShape(space, cpCircleShapeNew(grabbing_body, .1, cpvzero));
            cpShapeSetSensor(gdata->grabbingShape, true);
            
            cpVect pos1 = cpBodyGetPos(body);
            cpVect pos2 = cpBodyGetPos(grabbing_body);
            
            vec2 pos1v(pos1);
            vec2 pos2v(pos2);
            vec2 diff = pos1v-pos2v;
            
            gdata->constraint = cpPinJointNew(body, grabbing_body, cpvzero, cpvzero);
        //    cpPinJointSetDist(gdata->constraint, 0);
           // gdata->constraint = cpDampedSpringNew(body, grabbing_body, cpvzero, cpvzero, diff.length(), 10000, 100);

            cpSpaceAddConstraint(space, gdata->constraint);
            CFDictionarySetValue(grabbing, uniqueId, gdata);
        }
    }
}
void ChipmunkSimulation::releaseBall(void* uniqueId) {
    GrabData *gdata = (GrabData*)CFDictionaryGetValue(grabbing, uniqueId);
    cpSpaceRemoveConstraint(space, gdata->constraint);
    cpSpaceRemoveShape(space, gdata->grabbingShape);
    cpBody *grabbingBody = cpShapeGetBody(gdata->grabbingShape);

    cpConstraintFree(gdata->constraint);
    cpShapeFree(gdata->grabbingShape);
    cpBodyFree(grabbingBody);
    
    delete gdata;
    CFDictionaryRemoveValue(grabbing, uniqueId);
}
 */

bool ChipmunkSimulation::isGrabbingBall(void *uniqueId) {
    return CFDictionaryContainsKey(grabbing, uniqueId);
}

void ChipmunkSimulation::grabbingBallAt(const vec2& loc, const vec2& vel, void *uniqueId) {
    if(CFDictionaryContainsKey(grabbing, uniqueId)) {
        cpShape *shape = (cpShape*)CFDictionaryGetValue(grabbing, uniqueId);
        cpBody *body = cpShapeGetBody(shape);
        
        vec2 f(vel);
        
        f *= 100;
        
        cpBodySetPos(body, (cpVect&)loc);
        cpBodySetVel(body, (cpVect&)vel);
        cpSpaceReindexShapesForBody(space, body);
    } else {
        cpShape* shape = getShapeAt(loc);
        cpBody* body = cpShapeGetBody(shape);
        if(!cpBodyIsStatic(body)) {
            cpSpaceRemoveBody(space, body);
        }
        CFDictionarySetValue(grabbing, uniqueId, shape);
    }
}
void ChipmunkSimulation::releaseBall(const vec2& vel, void* uniqueId) {
    cpShape* shape = (cpShape*)CFDictionaryGetValue(grabbing, uniqueId);
    cpBody* body = cpShapeGetBody(shape);
    if(cpBodyIsStatic(body)) {
        cpBodySetVel(body, cpvzero);
    } else {
        cpSpaceAddBody(space, body);
        cpBodySetVel(body, (cpVect&)vel);
    }
    
    CFDictionaryRemoveValue(grabbing, uniqueId);
}

bool ChipmunkSimulation::isCreatingBall(void *uniqueId) {
    return CFDictionaryContainsKey(creating, uniqueId);
}

void ChipmunkSimulation::creatingBallAt(const vec2& loc, float radius, void* uniqueId) {
    if(CFDictionaryContainsKey(creating, uniqueId)) {
        cpShape *shape = (cpShape*)CFDictionaryGetValue(creating, uniqueId);
        cpCircleShapeSetRadius(shape, radius);
        cpSpaceReindexShapesForBody(space, cpShapeGetBody(shape));
    } else {
        // NSLog(@"first time dragged - %@\n", uniqueId);
        float i = loc.x*loc.y;        
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
        HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
        ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
        ballData->intensity = 2;
        
        cpBody *ballBody = cpBodyNewStatic();
        
        cpBodySetPos(ballBody, (const cpVect&)loc);
        cpBodySetVelLimit(ballBody, 5);
        cpBodySetUserData(ballBody, ballData);
        
        cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
        
        cpShapeSetFriction(ballShape, .1);
        cpShapeSetElasticity(ballShape, .95);
        cpShapeSetCollisionType(ballShape, BALL_TYPE);
        cpSpaceReindexStatic(space);
        
        bodies.push_back(ballBody);
        shapes.push_back(ballShape);
        CFDictionaryAddValue(creating, uniqueId, ballShape);
    }
}

void ChipmunkSimulation::cancelBall(void *uniqueId) {
    if(CFDictionaryContainsKey(creating, uniqueId)) {
        cpShape *shape = (cpShape*)CFDictionaryGetValue(creating, uniqueId);
        cpBody *body = cpShapeGetBody(shape);
        for(int i = shapes.size()-1; i >= 0; i--) {
            if(shapes[i] == shape) {
                shapes.erase(shapes.begin()+i);
                bodies.erase(bodies.begin()+i);
            }
        }
        CFDictionaryRemoveValue(creating, uniqueId);
        
        cpSpaceRemoveShape(space, shape);
        cpShapeFree(shape);
        cpBodyFree(body);
    }
}

void ChipmunkSimulation::createBall(void* uniqueId) {
    if(CFDictionaryContainsKey(creating, uniqueId)) {
        cpShape *shape = (cpShape*)CFDictionaryGetValue(creating, uniqueId);
        cpBody *body = cpShapeGetBody(shape);
        
        float radius = cpCircleShapeGetRadius(shape);
        float mass = 100*radius*radius;
        cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData *data = (BallData*)cpBodyGetUserData(body);
        cpVect pos = cpBodyGetPos(body);
        cpVect vel = cpBodyGetVel(body);
        
        cpBody *new_body = cpSpaceAddBody(space, cpBodyNew(mass, moment));
        cpShape *new_shape = cpSpaceAddShape(space, cpCircleShapeNew(new_body, radius, cpvzero));
        cpBodySetPos(new_body, pos);
        cpBodySetVel(new_body, vel);
        cpBodySetVelLimit(new_body, 5);
        cpBodySetUserData(new_body, data);
        
        cpShapeSetFriction(new_shape, .1);
        cpShapeSetElasticity(new_shape, .95);
        cpShapeSetCollisionType(new_shape, BALL_TYPE);
        
        cpSpaceRemoveShape(space, shape);
        cpShapeFree(shape);
        cpBodyFree(body);
        
        for(int i = shapes.size()-1; i >= 0; i--) {
            if(shapes[i] == shape) {
                shapes[i] = new_shape;
                bodies[i] = new_body;
            }
        }
        CFDictionaryRemoveValue(creating, uniqueId);
    }
}

void ChipmunkSimulation::setGravity(const vec2& accel) {
    cpSpaceSetGravity(space, (const CGPoint&)accel);
}

unsigned int ChipmunkSimulation::numBalls() {
    return bodies.size();
}

cpShape* const* ChipmunkSimulation::shapesPointer() {
    return &shapes[0];
}

cpBody* const* ChipmunkSimulation::bodiesPointer() {
    return &bodies[0];
}

ChipmunkSimulation::~ChipmunkSimulation() {
//    [sound_manager release];
    [audio_player release];
    
    CFRelease(creating);
    CFRelease(grabbing);
    
    cpShapeFree(bottom);
    cpShapeFree(top);
    cpShapeFree(right);
    cpShapeFree(left);
    
    std::vector<cpShape*>::iterator shape_itr = shapes.begin();
    while(shape_itr != shapes.end()) {
        cpShapeFree(*shape_itr);
        ++shape_itr;
    }
    
    std::vector<cpBody*>::iterator body_itr = bodies.begin();
    while(body_itr != bodies.end()) {
        BallData *data = (BallData*)cpBodyGetUserData(*body_itr);
        delete data;
        cpBodyFree(*body_itr);
        ++body_itr;
    }
    
    cpSpaceFree(space);

}


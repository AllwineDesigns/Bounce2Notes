//
//  ChipmunkSimulation.cpp
//  ParticleSystem
//
//  Created by John Allwine on 4/24/12.
//  Copyright (c) 2012 John Allwine. All rights reserved.
//

#include "ChipmunkSimulation.h"
#include <fsa/Noise.hpp>

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
    unsigned int numBalls = simulation->numBalls();
    cpBody *body1;
    cpBody *body2;
    cpShape *shape1;
    cpShape *shape2;
    cpArbiterGetBodies(arb, &body1, &body2);
    cpArbiterGetShapes(arb, &shape1, &shape2);
    
    cpCollisionType t1 = cpShapeGetCollisionType(shape1);
    cpCollisionType t2 = cpShapeGetCollisionType(shape2);

    cpVect impulse = cpArbiterTotalImpulseWithFriction(arb);
    vec2 imp(impulse.x, impulse.y);
    float ke = .05*imp.length()/sqrt(numBalls)*15; 
//    float ke = .1*cpArbiterTotalKE(arb);
    
    if(t1 == BALL_TYPE && t2 == BALL_TYPE) {
        ke *= .5;
    }
    
    BOOL isStatic1 = NO;
    BOOL isStatic2 = NO;
    
    BallData* ballData1 = (BallData*)cpBodyGetUserData(body1);
    BallData* ballData2 = (BallData*)cpBodyGetUserData(body2);

    
    if(t1 == BALL_TYPE) {
        BallData* ballData = ballData1;
        cpVect vel = cpBodyGetVel(body1);
        vec2 v(vel.x, vel.y);
        
        float mag = v.length();
        float dot = v.dot(ballData->last_vel);
        float last_mag = ballData->last_vel.length();

        if(dot < -.1 || mag-last_mag > .1) {
            ballData->intensity = 1.2*mag > 2 ? 2 : 1.2*mag;
        } else if(cpBodyIsStatic(body1)) {
            isStatic1 = YES;
        }
//        ballData->intensity = .5*(ballData->intensity+mag);
//        ballData->intensity += ke;
        
//        [simulation->getSounds()[ballData->note] play];
        float vol = (.25*ballData->intensity > 1) ? 1 : (.25*ballData->intensity);
        if(vol > .07) {
          //  [simulation->getSoundManager() playSound:ballData->note volume:vol];
        }
    }

    if(t2 == BALL_TYPE) {
        BallData* ballData = ballData2;
        cpVect vel = cpBodyGetVel(body2);
        vec2 v(vel.x, vel.y);
        
        float mag = v.length();
        float dot = v.dot(ballData->last_vel);
        float last_mag = ballData->last_vel.length();

        if(dot < -.1 || mag-last_mag > .1) {
            ballData->intensity = 1.2*mag > 2 ? 2 : 1.2*mag;
        } else if(cpBodyIsStatic(body2)) {
            isStatic2 = YES;
        }
//        ballData->intensity = .5*(ballData->intensity+mag);
//        ballData->intensity += ke;
//        [simulation->getSounds()[ballData->note] play];
        float vol = (.25*ballData->intensity > 1) ? 1 : (.25*ballData->intensity);
        if(vol > .07) {
         //   [simulation->getSoundManager() playSound:ballData->note volume:vol];
        }
    }
    
    if(isStatic1) {
        ballData1->intensity = 2*ballData2->intensity;
    }
    
    if(isStatic2) {
        ballData2->intensity = 2*ballData1->intensity;
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
    sound_manager = [[SoundManager alloc] initWithSounds:[NSArray arrayWithObjects:@"c", @"d", @"e", @"f", @"g", @"a", @"b", @"c2", nil]];
    
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

    
    cpShapeSetFriction(bottom,0.);
    cpShapeSetFriction(top, 0.);
    cpShapeSetFriction(right, 0.);
    cpShapeSetFriction(left, 0.);
    
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

        cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
       
        HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
        ballData->note = (int)8*random(928.2837776222*i);

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
        cpShapeSetFriction(ballShape, 0.);
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

SoundManager* ChipmunkSimulation::getSoundManager() {
    return sound_manager;
}

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
    
    cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
    BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
    HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
    ballData->note = (int)8*random(928.2837776222*i);
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
    
    cpShapeSetFriction(ballShape, 0.);
    cpShapeSetElasticity(ballShape, .95);
    cpShapeSetCollisionType(ballShape, BALL_TYPE);
    
    bodies.push_back(ballBody);
    shapes.push_back(ballShape);
}

void ChipmunkSimulation::addBallAt(const vec2& loc) {
    float i = loc.x*loc.y;
    cpFloat radius = 1.5*(random(i*1.234)*.075+.05);
    cpFloat mass = 100*radius*radius;
    
    cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
    BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
    HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
    ballData->note = (int)8*random(928.2837776222*i);
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

    cpShapeSetFriction(ballShape, 0.);
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
        cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData *data = (BallData*)cpBodyGetUserData(body);
        cpVect pos = cpBodyGetPos(body);
        cpVect vel = cpBodyGetVel(body);

        cpBody *new_body = cpSpaceAddBody(space, cpBodyNew(mass, moment));
        cpShape *new_shape = cpSpaceAddShape(space, cpCircleShapeNew(new_body, radius, cpvzero));
        cpBodySetPos(new_body, pos);
        cpBodySetVel(new_body, vel);
        cpBodySetVelLimit(new_body, 5);
        cpBodySetUserData(new_body, data);
        
        cpShapeSetFriction(new_shape, 0.);
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
        
        cpShapeSetFriction(new_shape, 0.);
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
    ballData->note = (int)8*random(928.2837776222*i);
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
    
    cpShapeSetFriction(ballShape, 0.);
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

void ChipmunkSimulation::creatingBallAt(const vec2& loc, float radius, void* uniqueId) {
    if(CFDictionaryContainsKey(creating, uniqueId)) {
        cpShape *shape = (cpShape*)CFDictionaryGetValue(creating, uniqueId);
        cpSpaceRemoveShape(space,shape);
        cpShapeFree(shape);
        
        cpBody* body = cpShapeGetBody(shape);
        cpShape *new_shape = cpSpaceAddShape(space, cpCircleShapeNew(body, radius, cpvzero));
        
        cpShapeSetFriction(new_shape, 0.);
        cpShapeSetElasticity(new_shape, .95);
        cpShapeSetCollisionType(new_shape, BALL_TYPE);
        
        for(int i = shapes.size()-1; i >= 0; i--) {
            if(shapes[i] == shape) {
                shapes[i] = new_shape;
            }
        }
        CFDictionarySetValue(creating, uniqueId, new_shape);
    } else {
       // NSLog(@"first time dragged - %@\n", uniqueId);
        float i = loc.x*loc.y;        
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
        HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );
        ballData->note = (int)8*random(928.2837776222*i);
        ballData->intensity = 2;
                
        cpBody *ballBody = cpBodyNewStatic();
            
        cpBodySetPos(ballBody, (const cpVect&)loc);
        cpBodySetVelLimit(ballBody, 5);
        cpBodySetUserData(ballBody, ballData);
        
        cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
        
        cpShapeSetFriction(ballShape, 0.);
        cpShapeSetElasticity(ballShape, .95);
        cpShapeSetCollisionType(ballShape, BALL_TYPE);
        cpSpaceReindexStatic(space);
        
        bodies.push_back(ballBody);
        shapes.push_back(ballShape);
        CFDictionaryAddValue(creating, uniqueId, ballShape);
    }
}

void ChipmunkSimulation::createBall(void* uniqueId) {
    if(CFDictionaryContainsKey(creating, uniqueId)) {
        cpShape *shape = (cpShape*)CFDictionaryGetValue(creating, uniqueId);
        cpBody *body = cpShapeGetBody(shape);
        
        float radius = cpCircleShapeGetRadius(shape);
        float mass = 100*radius*radius;
        cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData *data = (BallData*)cpBodyGetUserData(body);
        cpVect pos = cpBodyGetPos(body);
        cpVect vel = cpBodyGetVel(body);
        
        cpBody *new_body = cpSpaceAddBody(space, cpBodyNew(mass, moment));
        cpShape *new_shape = cpSpaceAddShape(space, cpCircleShapeNew(new_body, radius, cpvzero));
        cpBodySetPos(new_body, pos);
        cpBodySetVel(new_body, vel);
        cpBodySetVelLimit(new_body, 5);
        cpBodySetUserData(new_body, data);
        
        cpShapeSetFriction(new_shape, 0.);
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
    [sound_manager release];
    
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


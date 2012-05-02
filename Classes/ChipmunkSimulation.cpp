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
    
    if(t1 == BALL_TYPE) {
        BallData* ballData = (BallData*)cpBodyGetUserData(body1);
        cpVect vel = cpBodyGetVel(body1);
        vec2 v(vel.x, vel.y);
        
        float mag = v.length();
        float dot = v.dot(ballData->last_vel);
        float last_mag = ballData->last_vel.length();

        if(dot < -.1 || mag-last_mag > .1) {
            ballData->intensity = 1.2*mag;
        }
//        ballData->intensity = .5*(ballData->intensity+mag);
//        ballData->intensity += ke;
        
    }

    if(t2 == BALL_TYPE) {
        BallData* ballData = (BallData*)cpBodyGetUserData(body2);
        cpVect vel = cpBodyGetVel(body2);
        vec2 v(vel.x, vel.y);
        
        float mag = v.length();
        float dot = v.dot(ballData->last_vel);
        float last_mag = ballData->last_vel.length();

        if(dot < -.1 || mag-last_mag > .1) {
            ballData->intensity = 1.2*mag;
        }
//        ballData->intensity = .5*(ballData->intensity+mag);
//        ballData->intensity += ke;
        
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

ChipmunkSimulation::ChipmunkSimulation() : dt(.02), time_remainder(0) {
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

    bottom = cpSegmentShapeNew(space->staticBody, cpv(-1, -2.43333333), cpv(1, -2.43333333333), 1.11);
    top = cpSegmentShapeNew(space->staticBody, cpv(-1, 2.4333333333), cpv(1, 2.43333333333), 1.11);
    right = cpSegmentShapeNew(space->staticBody, cpv(2.1, 1.333333333), cpv(2.1, -1.3333333333), 1.11);
    left = cpSegmentShapeNew(space->staticBody, cpv(-2.1, 1.333333333), cpv(-2.1, -1.3333333333), 1.11);

    
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
    for(int i = 0; i < 10; i++) {

        cpFloat radius = 1.5*(random(i*1.234)*.075+.05);
        cpFloat mass = 100*radius*radius;

        cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
       
        HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), 360.*random(64.28327*i), .4, .05*random(736.2827*i)+.75   );

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
    return cpSpacePointQueryFirst(space, (const cpVect&)loc, CP_ALL_LAYERS, CP_NO_GROUP) != NULL;
}


static void shapeQueryFunc(cpShape *shape, cpContactPointSet *points, void* data) {
    cpBody *body = cpShapeGetBody(shape);
    if(body != NULL && !cpBodyIsStatic(body)) {
        vec2 v(cpBodyGetVel(body));
        v += *(vec2*)data;
        cpBodySetVel(body, (const cpVect&)v);
    }
}
static void getShapesQueryFunc(cpShape *shape, cpContactPointSet *points, void* data) {
    std::vector<cpShape*> *shapes = (std::vector<cpShape*>*)data;
    shapes->push_back(shape);
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

void ChipmunkSimulation::removeBallsAt(const vec2& loc, float radius) {
    cpBody *body = cpBodyNew(1, 1);
    cpBodySetPos(body, (const cpVect&)loc);
    cpShape *sensor = cpCircleShapeNew(body, radius, cpvzero);
    std::vector<cpShape*> del_shapes;
    cpSpaceShapeQuery(space, sensor, getShapesQueryFunc, (void*)&del_shapes);
    std::vector<cpShape*>::iterator itr = del_shapes.begin();
    while(itr != del_shapes.end()) {
        if(bottom == *itr || top == *itr || left == *itr || right == *itr) {
            ++itr;
            continue;
        }
        cpBody *b = cpShapeGetBody(*itr);
        
        if(cpSpaceContainsBody(space, b)) {
            cpSpaceRemoveBody(space, b);
        }
        cpSpaceRemoveShape(space, *itr);
        for(int i = shapes.size()-1; i >= 0; i--) {
            if(shapes[i] == *itr) {
                shapes.erase(shapes.begin()+i);
                bodies.erase(bodies.begin()+i);
            }
        }

        cpShapeFree(*itr);
        cpBodyFree(b);
        ++itr;
    }
    
    cpShapeFree(sensor);
    cpBodyFree(body);
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
    
//    cpBody *ballBody = cpSpaceAddBody(space, cpBodyNew(mass, moment));
//    cpBody *ballBody = cpBodyNew(mass, moment);
    cpBody *ballBody = cpBodyNewStatic();

    
    cpBodySetPos(ballBody, (const cpVect&)loc);
//    cpBodySetVel(ballBody, cpv(5*(random(92.11234*i)-.5), 5*(random(23.234934*i)-.5)));
    cpBodySetVelLimit(ballBody, 5);
    cpBodySetUserData(ballBody, ballData);
    
//    cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
    cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));

    cpShapeSetFriction(ballShape, 0.);
    cpShapeSetElasticity(ballShape, 1);
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
        cpBodyFree(*body_itr);
        ++body_itr;
    }
    
    cpSpaceFree(space);

}


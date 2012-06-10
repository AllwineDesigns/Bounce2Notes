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

#define BOUNCE_DEFAULT_HUE 360.*random(64.28327*i)
#define BOUNCE_DEFAULT_VALUE .05*random(736.2827*i)+.75
#define BOUNCE_DEFAULT_SATURATION .4
#define BOUNCE_DEFAULT_SOUNDS [NSArray arrayWithObjects:@"c_1", @"e_1",@"g_1", @"a_1", @"b_1", @"c_2", nil]
#define BOUNCE_DEFAULT_VOLUME 10

int presolve_kill(cpArbiter *arb, cpSpace *space, void *data) {
    ChipmunkSimulation *simulation = (ChipmunkSimulation*)data;
    cpBody *body1;
    cpShape *shape1;
    
    cpBody *body2;
    cpShape *shape2;
    cpArbiterGetBodies(arb, &body1, &body2);
    cpArbiterGetShapes(arb, &shape1, &shape2);
        
    if(simulation->killTop && shape2 == simulation->killTopShape && !simulation->isShapeParticipatingInGesture(shape1)) {
        simulation->queueRemoveBall(shape1);
    }
    
    if(simulation->killBottom && shape2 == simulation->killBottomShape && !simulation->isShapeParticipatingInGesture(shape1)) {
        simulation->queueRemoveBall(shape1);
    }
    
    if(simulation->killLeft && shape2 == simulation->killLeftShape && !simulation->isShapeParticipatingInGesture(shape1)) {
        simulation->queueRemoveBall(shape1);
    }
    
    if(simulation->killRight && shape2 == simulation->killRightShape && !simulation->isShapeParticipatingInGesture(shape1)) {
        simulation->queueRemoveBall(shape1);
    }
    
    return 1;
}

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
        
        float last_mag = ballData->last_vel.length();
        
        ke += (last_mag*last_mag);
    }

    if(t2 == BALL_TYPE) {
        BallData* ballData = ballData2;
        cpVect vel = cpBodyGetVel(body2);
        vec2 v(vel);
        
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
    /*
    
    cpBody *staticBody = NULL;
    cpShape *staticShape = NULL;
    cpBody *otherBody = NULL;
    cpShape *otherShape = NULL;
    if(cpBodyIsStatic(body1) && t1 == BALL_TYPE) {
        staticBody = body1;
        staticShape = shape1;
    }
    if(cpBodyIsStatic(body2) && t2 == BALL_TYPE) {
        staticBody = body2;
        staticShape = shape2;
    }
    
    if(!cpBodyIsStatic(body1) && t1 == BALL_TYPE) {
        otherBody = body1;
        otherShape = shape1;
    }
    if(!cpBodyIsStatic(body2) && t2 == BALL_TYPE) {
        otherBody = body2;
        otherShape = shape2;
    }
    
    if(otherBody == NULL || staticBody == NULL) {
        return;
    }
    
    cpVect v = cpBodyGetVel(staticBody);
    NSLog(@"vel: %f, %f\n", v.x, v.y);
    NSLog(@"elasticity: %f\n", cpShapeGetElasticity(staticShape));
    
    BallData *bdata = (BallData*)cpBodyGetUserData(otherBody);
    vec2 vel(cpBodyGetVel(otherBody));
    float speed = vel.length();
    
    vec2 last_vel(bdata->last_vel);
    float last_speed = last_vel.length();
    NSLog(@"speed: %f, last_speed: %f\n", speed, last_speed);
    NSLog(@"quotient: %f\n", speed/last_speed);
    
    NSLog(@"\n");
    */
}
void separate(cpArbiter *arb, cpSpace *space, void *data) {
    cpBody *body1;
    cpBody *body2;
    cpShape *shape1;
    cpShape *shape2;
    cpArbiterGetBodies(arb, &body1, &body2);
    cpArbiterGetShapes(arb, &shape1, &shape2);
    
    cpCollisionType t1 = cpShapeGetCollisionType(shape1);
    cpCollisionType t2 = cpShapeGetCollisionType(shape2);
        
    BallData* ballData1 = (BallData*)cpBodyGetUserData(body1);
    BallData* ballData2 = (BallData*)cpBodyGetUserData(body2);
    cpContactPointSet set = cpArbiterGetContactPointSet(arb);
    
    if(t1 == BALL_TYPE) {
        float radius1 = cpCircleShapeGetRadius(shape1);
        
        float angle1 = cpBodyGetAngle(body1);    
        vec2 pos1(cpBodyGetPos(body1));   
        vec2 vel1(cpBodyGetVel(body1));
        float cos1 = cos(angle1);
        float sin1 = sin(angle1);
        
        vec2 tl1(-radius1, radius1);
        vec2 tr1(radius1, radius1);
        vec2 bl1(-radius1, -radius1);
        vec2 br1(radius1, -radius1);
        
        for(int i=0; i<set.count; i++){
            vec2 p1(set.points[i].point);
            p1 -= pos1;
            
            vec2 n1(set.points[i].normal);
            
            p1.rotate(cos1,sin1);
            n1.rotate(cos1,sin1);
            
            if(p1.dot(n1) > 0) {
                n1 *= -1;
            }
            
            float tld1 = (p1-tl1).length();
            float trd1 = (p1-tr1).length();
            float bld1 = (p1-bl1).length();
            float brd1 = (p1-br1).length();
            
            float tl_w1 = 1./(tld1*tld1);
            float tr_w1 = 1./(trd1*trd1);
            float bl_w1 = 1./(bld1*bld1);
            float br_w1 = 1./(brd1*brd1);
            
            if(tl_w1 >= tr_w1 && tl_w1 >= bl_w1 && tl_w1 >= br_w1) {
                //ballData1->tl += scale*last_mag*radius1*n1;
                //ballData1->tl.clamp(-halfradius1, halfradius1);
                ballData1->tlv += vel1; 
            } else if(tr_w1 >= bl_w1 && tr_w1 >= br_w1) {
                //ballData1->tr += scale*last_mag*radius1*n1;
                //ballData1->tr.clamp(-halfradius1, halfradius1);
                ballData1->trv += vel1; 
            } else if(bl_w1 >= br_w1) {
                //ballData1->bl += scale*last_mag*radius1*n1;
                //ballData1->bl.clamp(-halfradius1, halfradius1);
                ballData1->blv += vel1;
            } else {
                //ballData1->br += scale*last_mag*radius1*n1;
                //ballData1->br.clamp(-halfradius1, halfradius1); 
                ballData1->brv += vel1; 
            }
        }
    }
    
    
    if(t2 == BALL_TYPE) {
        float radius2 = cpCircleShapeGetRadius(shape2);
        float angle2 = cpBodyGetAngle(body2);
        vec2 pos2(cpBodyGetPos(body2));
        vec2 vel2(cpBodyGetVel(body2));
        float cos2 = cos(angle2);
        float sin2 = sin(angle2);
        
        vec2 tl2(-radius2, radius2);
        vec2 tr2(radius2, radius2);
        vec2 bl2(-radius2, -radius2);
        vec2 br2(radius2, -radius2);
        
        
        for(int i=0; i<set.count; i++){
            vec2 p2(set.points[i].point);
            p2 -= pos2;
            
            vec2 n2(set.points[i].normal);
            
            p2.rotate(cos2,sin2);
            n2.rotate(cos2,sin2);
            
            if(p2.dot(n2) > 0) {
                n2 *= -1;
            }
            
            float tld2 = (p2-tl2).length();
            float trd2 = (p2-tr2).length();
            float bld2 = (p2-bl2).length();
            float brd2 = (p2-br2).length();
            
            float tl_w2 = 1./(tld2*tld2);
            float tr_w2 = 1./(trd2*trd2);
            float bl_w2 = 1./(bld2*bld2);
            float br_w2 = 1./(brd2*brd2);
            
            if(tl_w2 >= tr_w2 && tl_w2 >= bl_w2 && tl_w2 >= br_w2) {
                //ballData2->tl += scale*last_mag*radius2*n2;
                //ballData2->tl.clamp(-halfradius2, halfradius2);
                ballData2->tlv += vel2;
            } else if(tr_w2 >= bl_w2 && tr_w2 >= br_w2) {
                //ballData2->tr += scale*last_mag*radius2*n2;
                //ballData2->tr.clamp(-halfradius2, halfradius2);
                ballData2->trv += vel2;
                
            } else if(bl_w2 >= br_w2) {
                //ballData2->bl += scale*last_mag*radius2*n2;
                //ballData2->bl.clamp(-halfradius2, halfradius2);
                ballData2->blv += vel2;
                
            } else {
                //ballData2->br += scale*last_mag*radius2*n2;
                //ballData2->br.clamp(-halfradius2, halfradius2); 
                ballData2->brv += vel2;
                
            }
        }
    }
    

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

ChipmunkSimulation::ChipmunkSimulation(float a) : dt(.02), time_remainder(0) {
   // sound_manager = [[SoundManager alloc] initWithSounds:[NSArray arrayWithObjects:@"c", @"d", @"e", @"f", @"g", @"a", @"b", @"c2", nil]];
 //  audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c", @"d", @"e", @"f", @"g", @"a", @"b", @"c2", nil]];

//    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c", @"e", @"g", @"a", @"c2", nil]];
    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"c_1", @"d_1", @"e_1", @"f_1", @"g_1", @"a_1", @"b_1", @"c_2", @"d_2", @"e_2", @"f_2", @"g_2", @"a_2", @"b_2", @"c_3", @"d_3", @"e_3", @"f_3", @"g_3", @"a_3", @"b_3", @"c_4", nil] volume:10];
//    audio_player = [[FSAAudioPlayer alloc] initWithSounds:BOUNCE_DEFAULT_SOUNDS volume:BOUNCE_DEFAULT_VOLUME];
 //   audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"marimba_c1", @"marimba_e1", @"marimba_g1", @"marimba_a1", @"marimba_c2", nil]];
//    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"marimba_a1", nil]];



//    audio_player = [[FSAAudioPlayer alloc] initWithSounds:[NSArray arrayWithObjects:@"guitarStereo", nil]];

    [audio_player startAUGraph];
    
    gestures = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);

    space = cpSpaceNew();
    cpSpaceSetGravity(space, *((cpVect*)(&gravity)));
//    cpSpaceSetDamping(space, .5);
    cpSpaceSetCollisionSlop(space, .02);
    
//    cpSpaceUseSpatialHash(space, .3, 3000);
    
    cpSpaceAddCollisionHandler(space, BALL_TYPE, BALL_TYPE, collisionBegin, preSolve, postSolve, separate, this);
    cpSpaceAddCollisionHandler(space, BALL_TYPE, WALL_TYPE, collisionBegin, preSolve, postSolve, separate, this);
//    cpSpaceSetDefaultCollisionHandler(space, collisionBegin, preSolve, postSolve, separate, this);
//    cpSpaceAddCollisionHandler(space, BALL_TYPE, KILL_TYPE, NULL, presolve_kill, NULL, NULL, this);


//    bottom = cpSegmentShapeNew(space->staticBody, cpv(-1, -2.6), cpv(1, -2.6), 1.11);
//    top = cpSegmentShapeNew(space->staticBody, cpv(-1, 2.6), cpv(1, 2.6), 1.11);
//    right = cpSegmentShapeNew(space->staticBody, cpv(2.1, 1.5), cpv(2.1, -1.5), 1.11);
//    left = cpSegmentShapeNew(space->staticBody, cpv(-2.1, 1.5), cpv(-2.1, -1.5), 1.11);
    aspect = a;
    inv_aspect = 1./aspect;
    bottom = cpSegmentShapeNew(space->staticBody, cpv(-1, -inv_aspect-1.1), cpv(1, -inv_aspect-1.1), 1.11);
    top = cpSegmentShapeNew(space->staticBody, cpv(-1, inv_aspect+1.1), cpv(1, inv_aspect+1.1), 1.11);
    right = cpSegmentShapeNew(space->staticBody, cpv(2.1, inv_aspect), cpv(2.1, -inv_aspect), 1.11);
    left = cpSegmentShapeNew(space->staticBody, cpv(-2.1, inv_aspect), cpv(-2.1, -inv_aspect), 1.11);
    
    killBody = cpBodyNew(9999, 99999);
    
    killTopShape = cpSegmentShapeNew(killBody, cpv(-1, inv_aspect), cpv(1,inv_aspect), 0);
    killBottomShape = cpSegmentShapeNew(killBody, cpv(-1, -inv_aspect), cpv(1,-inv_aspect), 0);
    killLeftShape = cpSegmentShapeNew(killBody, cpv(-1, inv_aspect), cpv(-1,-inv_aspect), 0);
    killRightShape = cpSegmentShapeNew(killBody, cpv(1, inv_aspect), cpv(1,-inv_aspect), 0);
    
    killTop = false;
    killBottom = false;
    killLeft = false;
    killRight = false;
    
    cpShapeSetSensor(killTopShape, true);
    cpShapeSetSensor(killBottomShape, true);
    cpShapeSetSensor(killRightShape, true);
    cpShapeSetSensor(killLeftShape, true);
    
    cpShapeSetCollisionType(killTopShape,KILL_TOP_TYPE);
    cpShapeSetCollisionType(killBottomShape, KILL_BOTTOM_TYPE);
    cpShapeSetCollisionType(killLeftShape, KILL_LEFT_TYPE);
    cpShapeSetCollisionType(killRightShape, KILL_RIGHT_TYPE);
    
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
    
    cpSpaceAddShape(space, killBottomShape);
    cpSpaceAddShape(space, killTopShape);
    cpSpaceAddShape(space, killRightShape);
    cpSpaceAddShape(space, killLeftShape);
    
    
//    for(int i = 0; i < 300; i++) {
    for(int i = 0; i < 1; i++) {

        cpFloat radius = 1.5*(random(i*1.234)*.075+.05);
        cpFloat mass = 100*radius*radius;

        cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
       
        HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), BOUNCE_DEFAULT_HUE, BOUNCE_DEFAULT_SATURATION, BOUNCE_DEFAULT_VALUE   );
        ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
        ballData->stationary = false;

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
        cpBodySetAngVelLimit(ballBody, 50);

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
    if(!cpShapeGetSensor(shape)) {
        shapes->push_back(shape);
    }
}

FSAAudioPlayer* ChipmunkSimulation::getAudioPlayer() {
    return audio_player;
}

//SoundManager* ChipmunkSimulation::getSoundManager() {
//    return sound_manager;
//}

void ChipmunkSimulation::queueRemoveBall(cpShape *shape) {
    bool hasShape = false;
    std::vector<cpShape*>::iterator itr = removeShapesQueue.begin();
    while(itr != removeShapesQueue.end()) {
        if(*itr == shape) {
            hasShape = true;
            break;
        }
        ++itr;
    }
    
    if(!hasShape) {
        removeShapesQueue.push_back(shape);
    }
}

void ChipmunkSimulation::removeBall(cpShape *shape) {
    cpBody *body = cpShapeGetBody(shape);
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

void ChipmunkSimulation::next() {
    cpSpaceStep(space, dt);
    vec4 col1(1,0,0,1);
    vec4 col2(0,1,0,1);
    
    std::vector<cpBody*>::iterator itr = bodies.begin();
    std::vector<cpShape*>::iterator sitr = shapes.begin();

    while(itr != bodies.end()) {
        BallData* ballData = (BallData*)cpBodyGetUserData(*itr);
        ballData->intensity *= .9;
        ballData->age += dt;
        ballData->tl += ballData->tlv*dt;
        ballData->tr += ballData->trv*dt;
        ballData->bl += ballData->blv*dt;
        ballData->br += ballData->brv*dt;
        
        float spring_k = 200;
        vec2 tla = -spring_k*ballData->tl;
        vec2 tra = -spring_k*ballData->tr;
        vec2 bla = -spring_k*ballData->bl;
        vec2 bra = -spring_k*ballData->br;
        
        float drag = .2;
        ballData->tlv += tla*dt-drag*ballData->tlv;
        ballData->trv += tra*dt-drag*ballData->trv;
        ballData->blv += bla*dt-drag*ballData->blv;
        ballData->brv += bra*dt-drag*ballData->brv;
        
        float radius = cpCircleShapeGetRadius(*sitr);
        float c = .75*radius;
        
        ballData->tl.clamp(-c, c);
        ballData->tr.clamp(-c, c);
        ballData->bl.clamp(-c, c);
        ballData->br.clamp(-c, c);

        /*
        cpVect v = cpBodyGetVel(*itr);
        vec2 vel(v);
        float mag = vel.length();
        mag = mag > 5 ? 5 : mag;
        mag /= 5;
        
        float om = 1-mag;
        
        vec4 c(col1.x*om+col2.x*mag, col1.y*om+col2.y*mag, col1.z*om+col2.z*mag, 1);
        
        ballData->color = c;
        */

//        ballData->intensity = .2*vel.length();
        ++itr;
        ++sitr;
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

bool ChipmunkSimulation::isStationaryBallAt(const vec2& loc) {
    if(isBallAt(loc)) {
        cpShape* shape = getShapeAt(loc);
        cpBody *body = cpShapeGetBody(shape);
        
        BallData *data = (BallData*)cpBodyGetUserData(body);
    
        return data->stationary;
    }
    return false;
}


bool ChipmunkSimulation::isBallAt(const vec2& loc) {
    return getShapeAt(loc) != NULL;
}

static void shapeQueryFunc(cpShape *shape, cpContactPointSet *points, void* data) {
    cpBody *body = cpShapeGetBody(shape);
    if(body != NULL && !cpBodyIsStatic(body) && !cpShapeGetSensor(shape)) {
        vec2 v(cpBodyGetVel(body));
        v += *(vec2*)data;
        cpBodySetVel(body, (const cpVect&)v);
    }
}

bool ChipmunkSimulation::anyBallsAt(const vec2& loc, float radius) {
    cpBody *body = cpBodyNew(1, 1);
    cpBodySetPos(body, (const cpVect&)loc);
    cpShape *sensor = cpCircleShapeNew(body, radius, cpvzero);
    std::vector<cpShape*> shapes;
    cpSpaceShapeQuery(space, sensor, getShapesQueryFunc, (void*)&shapes);
    return shapes.size() > 0;
}

cpShape* ChipmunkSimulation::getShapeAt(const vec2& loc) {
    cpBody *body = cpBodyNew(1, 1);
    cpBodySetPos(body, (const cpVect&)loc);
    cpShape *sensor = cpCircleShapeNew(body, .05, cpvzero);
    std::vector<cpShape*> shapes;
    cpSpaceShapeQuery(space, sensor, getShapesQueryFunc, (void*)&shapes);
    std::vector<cpShape*>::iterator itr = shapes.begin();
    
    cpShape *closestShape = NULL;
    float min_dist = 99999;
    
    while(itr != shapes.end()) {
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

bool ChipmunkSimulation::isBallParticipatingInGestureAt(const vec2& loc) {
    cpShape *shape = getShapeAt(loc);
    
    if(shape != NULL) {
        return isShapeParticipatingInGesture(shape);
    }
    return false;
}

bool ChipmunkSimulation::isBallBeingCreatedOrGrabbedAt(const vec2& loc) {
    cpShape *shape = getShapeAt(loc);
    
    if(shape != NULL) {
        return isShapeBeingCreatedOrGrabbed(shape);
    }
    return false;
}

bool ChipmunkSimulation::isBallBeingTransformedAt(const vec2& loc) {
    cpShape *shape = getShapeAt(loc);
    
    if(shape != NULL) {
        return isShapeBeingTransformed(shape);
    }
    return false;
}

bool ChipmunkSimulation::isShapeParticipatingInGesture(cpShape* shape) {
    bool participating = false;
    int size = CFDictionaryGetCount(gestures);
    CFTypeRef *keysTypeRef = (CFTypeRef *) malloc( size * sizeof(CFTypeRef) );
    CFDictionaryGetKeysAndValues(gestures, (const void **) keysTypeRef, NULL);
    const void **keys = (const void **) keysTypeRef;
    for(int i = 0; i < size; ++i) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, keys[i]);
        if(gdata->shape == shape) {
            participating = true;
            break;
        }
    }
    free(keys);
    
    return participating;
}

bool ChipmunkSimulation::isShapeBeingCreatedOrGrabbed(cpShape* shape) {
    bool ballBeingGrabbedOrCreated = false;
    int size = CFDictionaryGetCount(gestures);
    CFTypeRef *keysTypeRef = (CFTypeRef *) malloc( size * sizeof(CFTypeRef) );
    CFDictionaryGetKeysAndValues(gestures, (const void **) keysTypeRef, NULL);
    const void **keys = (const void **) keysTypeRef;
    for(int i = 0; i < size; ++i) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, keys[i]);
        if(gdata->shape == shape && (gdata->grabbing || gdata->creating)) {
            ballBeingGrabbedOrCreated = true;
            break;
        }
    }
    free(keys);
    
    return ballBeingGrabbedOrCreated;
}

bool ChipmunkSimulation::isShapeBeingTransformed(cpShape* shape) {
    bool transforming = false;
    int size = CFDictionaryGetCount(gestures);
    CFTypeRef *keysTypeRef = (CFTypeRef *) malloc( size * sizeof(CFTypeRef) );
    CFDictionaryGetKeysAndValues(gestures, (const void **) keysTypeRef, NULL);
    const void **keys = (const void **) keysTypeRef;
    for(int i = 0; i < size; ++i) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, keys[i]);
        if(gdata->shape == shape && gdata->transforming) {
            transforming = true;
            break;
        }
    }
    free(keys);
    
    return transforming;
}

GestureData* ChipmunkSimulation::getGestureDataWithParticipatingShape(cpShape* shape) {
    GestureData* ret_gdata = NULL;
    int size = CFDictionaryGetCount(gestures);
    CFTypeRef *keysTypeRef = (CFTypeRef *) malloc( size * sizeof(CFTypeRef) );
    CFDictionaryGetKeysAndValues(gestures, (const void **) keysTypeRef, NULL);
    const void **keys = (const void **) keysTypeRef;
    for(int i = 0; i < size; ++i) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, keys[i]);
        if(gdata->shape == shape) {
            ret_gdata = gdata;
            break;
        }
    }
    free(keys);
    
    return ret_gdata;
}

void ChipmunkSimulation::removeBallAt(const vec2& loc) {
    cpShape* shape = getShapeAt(loc);
    
    assert(shape != NULL);
    assert(!isShapeParticipatingInGesture(shape));
    
    cpBody* body = cpShapeGetBody(shape);
    BallData* data = (BallData*)cpBodyGetUserData(body);
    
    if(data->age >= 1) {
        float radius = cpCircleShapeGetRadius(shape);
        int note = (1-radius)*(1-radius)*[getAudioPlayer() numSounds];
        
        [getAudioPlayer() playSound:note volume:.2];
        
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

void ChipmunkSimulation::addVelocityToBallAt(const vec2 &loc, const vec2& vel) {
    cpShape *shape = getShapeAt(loc);
    assert(shape != NULL);

    cpBody *body = cpShapeGetBody(shape);
    BallData *data = (BallData*)cpBodyGetUserData(body);
    
    if(data->stationary) {
        makeSimulated(shape);
        cpBodySetVel(body, (cpVect&)vel);
        data->stationary = false;
    } else {
        vec2 v(cpBodyGetVel(body));
        
        v += vel;
        
        cpBodySetVel(body, (cpVect&)v);
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
    cpFloat radius = random(i*1.234)*.2+.05;
    cpFloat mass = 100*radius*radius;
    int note = (1-radius)*(1-radius)*[getAudioPlayer() numSounds];
    
    [getAudioPlayer() playSound:note volume:.2];
    
    cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
    BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
    HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), BOUNCE_DEFAULT_HUE, BOUNCE_DEFAULT_SATURATION, BOUNCE_DEFAULT_VALUE   );
    ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
    ballData->stationary = false;
  //  ballData->intensity = 2;

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
    cpFloat radius = random(i*1.234)*.2+.05;
    cpFloat mass = 100*radius*radius;
    int note = (1-radius)*(1-radius)*[getAudioPlayer() numSounds];
    
    [getAudioPlayer() playSound:note volume:.2];
    
    cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
    BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
    HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), BOUNCE_DEFAULT_HUE, BOUNCE_DEFAULT_SATURATION, BOUNCE_DEFAULT_VALUE   );
    ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
    ballData->stationary = false;
  //  ballData->intensity = 2;

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

void ChipmunkSimulation::step(float t) {
    std::vector<cpShape*>::iterator itr = removeShapesQueue.begin();
    while(itr != removeShapesQueue.end()) {
        if(!isShapeParticipatingInGesture(*itr)) {
            float radius = cpCircleShapeGetRadius(*itr);
            int note = (1-radius)*(1-radius)*[getAudioPlayer() numSounds];

            [audio_player playSound:note volume:.2];
            removeBall(*itr);
        }
        ++itr;
    }
    removeShapesQueue.clear();
    
    t += time_remainder;
    
    if(t > 10*dt) {
        t = 10*dt;
    }
    
    while(t > dt) {
        next();
        t -= dt;
    }
    
    time_remainder = t;
}

bool ChipmunkSimulation::isGrabbingBall(void *uniqueId) {
    if( CFDictionaryContainsKey(gestures, uniqueId) ) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        return gdata->grabbing;
    }
    return false;}

void ChipmunkSimulation::beginGrabbingBallAt(const vec2& loc, void *uniqueId) {
    cpShape* shape = getShapeAt(loc);
    
    assert(shape != NULL);
    assert(!isShapeParticipatingInGesture(shape));
    
    GestureData* gdata = (GestureData*)calloc(1,sizeof(GestureData));
    
    cpBody* body = cpShapeGetBody(shape);
    
    vec2 pos(cpBodyGetPos(body));
    
    gdata->grabbing = true;
    gdata->shape = shape;
    gdata->offset = loc-pos;
    gdata->ball_angle = cpBodyGetAngle(body);
    gdata->offset_angle = atan2f(gdata->offset.y, gdata->offset.x);
    gdata->offset_r = gdata->offset.length();
    
    CFDictionarySetValue(gestures, uniqueId, gdata);

}

void ChipmunkSimulation::makeStatic(cpShape* shape) {
    cpBody *body = cpShapeGetBody(shape);
    
    if(!cpBodyIsRogue(body)) {
        cpSpaceRemoveBody(space, body);
    }
    
    if(!cpBodyIsStatic(body)) {
        cpSpaceRemoveShape(space, shape);
        
        CP_PRIVATE(body->node).idleTime = (cpFloat)INFINITY;
        cpBodySetMass(body, (cpFloat)INFINITY);
        cpBodySetMoment(body, (cpFloat)INFINITY);
        
        cpSpaceAddShape(space, shape);
        cpSpaceReindexStatic(space);
    }
}

void ChipmunkSimulation::makeSimulated(cpShape* shape) {
    cpBody *body = cpShapeGetBody(shape);
    if(cpBodyIsRogue(body)) {
        cpSpaceRemoveShape(space, shape);
        float radius = cpCircleShapeGetRadius(shape);
        float mass = 100*radius*radius;
        cpFloat moment = .02*cpMomentForCircle(mass, 0, radius, cpvzero);
            
        CP_PRIVATE(body->node).idleTime = (cpFloat)0;
        cpBodySetMass(body, mass);
        cpBodySetMoment(body, moment);
        cpSpaceAddShape(space, shape);
        
        cpSpaceAddBody(space, body);
    }
}

void ChipmunkSimulation::makeHeavyRogue(cpShape* shape) {
    cpBody *body = cpShapeGetBody(shape);
    if(cpBodyIsStatic(body)) {
        makeSimulated(shape);
    }
    if(!cpBodyIsRogue(body)) {
        cpSpaceRemoveBody(space, body);
    }
    
    cpBodySetMass(body, 99999);
    cpBodySetMoment(body, 99999);
}

void ChipmunkSimulation::grabbingBallAt(const vec2& loc, const vec2& vel, void *uniqueId) {
    if(CFDictionaryContainsKey(gestures, uniqueId)) {

        GestureData* gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        assert(gdata->grabbing);
              
        cpShape *shape = gdata->shape;
        cpBody *body = cpShapeGetBody(shape);
        
        BallData *data = (BallData*)cpBodyGetUserData(body);
        float speed = vel.length();
        
        if(speed > 3) {
            data->stationary = false;
        }
        
        makeHeavyRogue(shape);
        
        vec2 f(vel);
        
        f *= 100;
        
        vec2 l = loc-gdata->offset;
        
        vec2 pos(cpBodyGetPos(body));
        
        vec2 curOffset = loc-pos;
        float curAngle = atan2f(curOffset.y, curOffset.x);
        
        float newAngle = gdata->ball_angle+curAngle-gdata->offset_angle;
        vec2 dir(cos(curAngle), sin(curAngle));
        vec2 newPos = loc-gdata->offset_r*dir;
        
        gdata->offset = gdata->offset_r*dir;
        gdata->offset_angle = curAngle;

        cpBodySetAngVel(body, 100*(newAngle-gdata->ball_angle));
        
        vec2 v = 20*(newPos-pos);
        cpBodySetVel(body, (cpVect&)v);

        gdata->ball_angle = newAngle;
        
        
        
        cpBodySetPos(body, (cpVect&)newPos);
  //      cpBodySetVel(body, (cpVect&)vel);
        cpBodySetAngle(body, newAngle);
        cpSpaceReindexShapesForBody(space, body);
    }
}
void ChipmunkSimulation::releaseBall(const vec2& vel, void* uniqueId) {
    GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
    cpShape* shape = gdata->shape;
    cpBody *body = cpShapeGetBody(shape);
    BallData *data = (BallData*)cpBodyGetUserData(body);
    
    if(!data->stationary) {
        makeSimulated(shape);
        //cpBodySetVel(body, (cpVect&)vel);
    } else {
        makeStatic(shape);
        cpBodySetVel(body, cpvzero);
        cpBodySetAngVel(body, 0);

    }
    
    free(gdata);
    CFDictionaryRemoveValue(gestures, uniqueId);
}

bool ChipmunkSimulation::isCreatingBall(void *uniqueId) {
    if( CFDictionaryContainsKey(gestures, uniqueId) ) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        return gdata->creating;
    }
    return false;
}

void ChipmunkSimulation::creatingBallAt(const vec2& loc, const vec2& loc2, void* uniqueId) {
    float radius = (loc2-loc).length();
    radius = radius > 1 ? 1 : radius;
    radius = radius <= .01 ? .01 : radius;
    
    if(isCreatingBall(uniqueId)) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        cpShape *shape = gdata->shape;
        
        cpBody *body = cpShapeGetBody(shape);
        BallData *ballData = (BallData*)cpBodyGetUserData(body);
        int note = (1-radius)*(1-radius)*[getAudioPlayer() numSounds];
        if(note != ballData->note) {
            [getAudioPlayer() playSound:note volume:.2];
            ballData->note = note;
            
        }
        vec2 offset = loc2-loc;
        gdata->offset = offset;
        
        float angle = atan2f(offset.y, offset.x);
        float oldAngle = cpBodyGetAngle(body);
        float newAngle = angle-gdata->offset_angle;
        cpBodySetAngle(body, newAngle);
        cpBodySetAngVel(body, 100*(newAngle-oldAngle));
        
        cpCircleShapeSetRadius(shape, radius);
        cpSpaceReindexShapesForBody(space, cpShapeGetBody(shape));
    } else {
        // NSLog(@"first time dragged - %@\n", uniqueId);
        float i = loc.x*loc.y;        
        BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
        HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), BOUNCE_DEFAULT_HUE, BOUNCE_DEFAULT_SATURATION, BOUNCE_DEFAULT_VALUE   );
        
        int note = (1-radius)*(1-radius)*[getAudioPlayer() numSounds];
        [getAudioPlayer() playSound:note volume:.2];
        ballData->note = note;
        ballData->stationary = false;

//        ballData->intensity = 2;
        
        cpBody *ballBody = cpBodyNewStatic();
        
        cpBodySetPos(ballBody, (const cpVect&)loc);
        cpBodySetVelLimit(ballBody, 5);
        cpBodySetAngVelLimit(ballBody, 50);
        cpBodySetUserData(ballBody, ballData);
        
        cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
        
        cpShapeSetFriction(ballShape, .1);
        cpShapeSetElasticity(ballShape, .95);
        cpShapeSetCollisionType(ballShape, BALL_TYPE);
        cpSpaceReindexStatic(space);
        
        bodies.push_back(ballBody);
        shapes.push_back(ballShape);
        
        GestureData *gdata = (GestureData*)calloc(1, sizeof(GestureData));
        gdata->shape = ballShape;
        gdata->creating = true;
        gdata->offset = loc2-loc;
        gdata->offset_angle = atan2f(gdata->offset.y, gdata->offset.x);
        
        CFDictionaryAddValue(gestures, uniqueId, gdata);
    }
}

void ChipmunkSimulation::cancelBall(void *uniqueId) {
    if(isCreatingBall(uniqueId)) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        
        cpShape *shape = gdata->shape;
        cpBody *body = cpShapeGetBody(shape);
        for(int i = shapes.size()-1; i >= 0; i--) {
            if(shapes[i] == shape) {
                shapes.erase(shapes.begin()+i);
                bodies.erase(bodies.begin()+i);
            }
        }
        free(gdata);
        CFDictionaryRemoveValue(gestures, uniqueId);
        
        cpSpaceRemoveShape(space, shape);
        cpShapeFree(shape);
        cpBodyFree(body);
    }
}

void ChipmunkSimulation::makeStationary(const vec2& loc, void *uniqueId) {
    if(CFDictionaryGetValue(gestures, uniqueId)) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        cpBody* body = (cpBody*)cpShapeGetBody(gdata->shape);
        BallData *data = (BallData*)cpBodyGetUserData(body);
        
        data->stationary = true;
    }
}

void ChipmunkSimulation::beginGrabbing(const vec2& loc, void* uniqueId) {
    if(isCreatingBall(uniqueId)) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        cpBody *body = cpShapeGetBody(gdata->shape);
        vec2 pos(cpBodyGetPos(body));
        
        BallData *data = (BallData*)cpBodyGetUserData(body);
        
        gdata->creating = false;
        gdata->grabbing = true;
        gdata->offset = loc-pos;
        gdata->ball_angle = cpBodyGetAngle(body);
        gdata->offset_angle = atan2f(gdata->offset.y, gdata->offset.x);
        gdata->offset_r = gdata->offset.length();
        data->stationary = true;
    }
}

void ChipmunkSimulation::createStationaryBallAt(const vec2& loc, void* uniqueId) {
    float i = loc.x*loc.y;
    cpFloat radius = 1.5*(random(i*1.234)*.075+.05);

    BallData* ballData = new BallData(vec4(random(64.7263*i), random(91.23819*i), random(342.123*i), 1.));
    HSVtoRGB(&(ballData->color.x), &(ballData->color.y), &(ballData->color.z), BOUNCE_DEFAULT_HUE, BOUNCE_DEFAULT_SATURATION, BOUNCE_DEFAULT_VALUE   );
    ballData->note = (int)[audio_player numSounds]*random(928.2837776222*i);
//    ballData->intensity = 4;
    
    int note = (1-radius)*(1-radius)*[getAudioPlayer() numSounds];
    [getAudioPlayer() playSound:note volume:.2];
    
    cpBody *ballBody = cpBodyNewStatic();
    
    cpBodySetPos(ballBody, (const cpVect&)loc);
    cpBodySetVelLimit(ballBody, 5);
    cpBodySetAngVelLimit(ballBody, 50);

    cpBodySetUserData(ballBody, ballData);
    
    cpShape *ballShape = cpSpaceAddShape(space, cpCircleShapeNew(ballBody, radius, cpvzero));
    
    cpShapeSetFriction(ballShape, .1);
    cpShapeSetElasticity(ballShape, .95);
    cpShapeSetCollisionType(ballShape, BALL_TYPE);
    cpSpaceReindexStatic(space);
    
    bodies.push_back(ballBody);
    shapes.push_back(ballShape);
    
    GestureData *gdata = (GestureData*)calloc(1, sizeof(GestureData));
    gdata->shape = ballShape;
    gdata->grabbing = true;
    ballData->stationary = true;
    
    CFDictionarySetValue(gestures, uniqueId, gdata);
}

void ChipmunkSimulation::createBall(void* uniqueId) {
    if(isCreatingBall(uniqueId)) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        
        cpShape *shape = gdata->shape;
        cpBody *body = cpShapeGetBody(shape);
        
        BallData *data = (BallData*)cpBodyGetUserData(body);
        
        if(!data->stationary) {
            makeSimulated(shape);
        }
        free(gdata);
        CFDictionaryRemoveValue(gestures, uniqueId);
    }
}

bool ChipmunkSimulation::isTransformingBall(void* uniqueId) {
    if( CFDictionaryContainsKey(gestures, uniqueId) ) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        return gdata->transforming;
    }
    return false;
}

void ChipmunkSimulation::beginTransformingBallAt(const vec2& loc, void* uniqueId) {
    cpShape* shape = getShapeAt(loc);
    
    assert(shape != NULL);
    assert(isShapeBeingCreatedOrGrabbed(shape));
    
    GestureData* gdata = (GestureData*)calloc(1,sizeof(GestureData));
    
    cpBody* body = cpShapeGetBody(shape);
    
    vec2 pos(cpBodyGetPos(body));
    
    GestureData *other_gdata = getGestureDataWithParticipatingShape(shape);
    
    gdata->transforming = true;
    gdata->shape = shape;
    gdata->C = pos;
    gdata->P1 = other_gdata->offset+pos;
    gdata->P2 = loc;
    gdata->P1p = gdata->P1;
    gdata->P2p = gdata->P2;
    gdata->radius = cpCircleShapeGetRadius(shape);
    gdata->rotation = cpBodyGetAngle(body);
    gdata->gdata1 = other_gdata;
    gdata->gdata2 = gdata;
    
    other_gdata->transforming = true;
    other_gdata->creating = false;
    other_gdata->grabbing = false;
    other_gdata->C = pos;
    other_gdata->P1 = gdata->P1;
    other_gdata->P2 = gdata->P2;
    other_gdata->P1p = gdata->P1;
    other_gdata->P2p = gdata->P2;
    other_gdata->radius = gdata->radius;
    other_gdata->rotation = gdata->rotation;
    other_gdata->gdata1 = other_gdata;
    other_gdata->gdata2 = gdata;
    
    CFDictionarySetValue(gestures, uniqueId, gdata);
}
void ChipmunkSimulation::transformBallAt(const vec2& loc, void* uniqueId) {
    
    if(isTransformingBall(uniqueId)) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        if(gdata->gdata1 == gdata) {
            gdata->P1p = loc;
            gdata->gdata2->P1p = loc;
        } else if(gdata->gdata2 == gdata) {
            gdata->P2p = loc;
            gdata->gdata1->P2p = loc;
        }
        
        makeHeavyRogue(gdata->shape);
        
        vec2 M = .5*(gdata->P1+gdata->P2);
        vec2 Mp = .5*(gdata->P1p+gdata->P2p);
        vec2 translate = Mp-M;
        
        vec2 d = gdata->P1-gdata->P2;
        vec2 dp = gdata->P1p-gdata->P2p;
        
        float rotation = atan2f(dp.y, dp.x)-atan2f(d.y, d.x);
        float scale = dp.length()/d.length();
        
        vec2 o = gdata->C-M;
        
        float xp = scale*(o.x*cos(rotation)-o.y*sin(rotation))+translate.x+M.x;
        float yp = scale*(o.x*sin(rotation)+o.y*cos(rotation))+translate.y+M.y;
        
        cpBody *body = cpShapeGetBody(gdata->shape);
        BallData *data = (BallData*)cpBodyGetUserData(body);
        
        CGPoint pos;
        pos.x = xp;
        pos.y = yp;
        
        vec2 old_pos = cpBodyGetPos(body);
        
        vec2 vel = 100*(pos-old_pos);
        
        cpBodySetVel(body, (cpVect&)vel);
        
        cpBodySetPos(body, pos);
        
        float radius = gdata->radius*scale > 1 ? 1 : gdata->radius*scale;
        int note = (1-radius)*(1-radius)*[getAudioPlayer() numSounds];
        if(data->note != note) {
            [audio_player playSound:note volume:.2];
            data->note = note;
        }

        cpCircleShapeSetRadius(gdata->shape, radius);
        cpBodySetAngle(body, gdata->rotation+rotation);
    }

}
void ChipmunkSimulation::makeTransformingBallStationary(const vec2& loc, void* uniqueId) {
}
void ChipmunkSimulation::beginGrabbingTransformingBall(void* uniqueId) {
    if(isTransformingBall(uniqueId)) {
        GestureData *gdata = (GestureData*)CFDictionaryGetValue(gestures, uniqueId);
        GestureData *other_gdata;
        vec2 loc;
        
        cpBody *body = cpShapeGetBody(gdata->shape);
        
        vec2 pos(cpBodyGetPos(body));
        
        if(gdata->gdata1 == gdata) {
            other_gdata = gdata->gdata2;
            loc = gdata->P2p;
        } else {
            other_gdata = gdata->gdata1;
            loc = gdata->P1p;
        }
        
        
        other_gdata->transforming = false;
        other_gdata->grabbing = true;

        other_gdata->offset = loc-pos;
        other_gdata->ball_angle = cpBodyGetAngle(body);
        other_gdata->offset_angle = atan2f(other_gdata->offset.y, other_gdata->offset.x);
        other_gdata->offset_r = other_gdata->offset.length();
        
        free(gdata);
        CFDictionaryRemoveValue(gestures, uniqueId);
    }
}

void ChipmunkSimulation::beginRemovingBallsTop(float y) {
    topY = y;
    killTop = true;
    cpSegmentShapeSetRadius(killTopShape, inv_aspect-y);
    cpSpaceReindexShape(space, killTopShape);
    cpSpaceAddCollisionHandler(space, BALL_TYPE, KILL_TOP_TYPE, NULL, presolve_kill, NULL, NULL, this);

}
void ChipmunkSimulation::updateRemovingBallsTop(float y) {
    topY = y;
    cpSegmentShapeSetRadius(killTopShape, inv_aspect-y);
    cpSpaceReindexShape(space, killTopShape);

    
}
void ChipmunkSimulation::endRemovingBallsTop() {
    killTop = false;
    cpSpaceRemoveCollisionHandler(space, BALL_TYPE, KILL_TOP_TYPE);
}

void ChipmunkSimulation::beginRemovingBallsBottom(float y) {
    bottomY = y;
    killBottom = true;
    cpSegmentShapeSetRadius(killBottomShape, y+inv_aspect);
    cpSpaceReindexShape(space, killBottomShape);
    cpSpaceAddCollisionHandler(space, BALL_TYPE, KILL_BOTTOM_TYPE, NULL, presolve_kill, NULL, NULL, this);
}
void ChipmunkSimulation::updateRemovingBallsBottom(float y) {
    bottomY = y;
    cpSegmentShapeSetRadius(killBottomShape, y+inv_aspect);
    cpSpaceReindexShape(space, killBottomShape);

}
void ChipmunkSimulation::endRemovingBallsBottom() {
    killBottom = false;
    cpSpaceRemoveCollisionHandler(space, BALL_TYPE, KILL_BOTTOM_TYPE);
}

void ChipmunkSimulation::beginRemovingBallsLeft(float x) {
    killLeft = true;
    leftX = x;
    cpSegmentShapeSetRadius(killLeftShape, x+1);
    cpSpaceReindexShape(space, killLeftShape);
    cpSpaceAddCollisionHandler(space, BALL_TYPE, KILL_LEFT_TYPE, NULL, presolve_kill, NULL, NULL, this);
}
void ChipmunkSimulation::updateRemovingBallsLeft(float x) {
    leftX = x;
    cpSegmentShapeSetRadius(killLeftShape, x+1);
    cpSpaceReindexShape(space, killLeftShape);
}
void ChipmunkSimulation::endRemovingBallsLeft() {
    killLeft = false;
    cpSpaceRemoveCollisionHandler(space, BALL_TYPE, KILL_LEFT_TYPE);
}

void ChipmunkSimulation::beginRemovingBallsRight(float x) {
    killRight = true;
    rightX = x;
    cpSegmentShapeSetRadius(killRightShape, 1-x);
    cpSpaceReindexShape(space, killRightShape);
    cpSpaceAddCollisionHandler(space, BALL_TYPE, KILL_RIGHT_TYPE, NULL, presolve_kill, NULL, NULL, this);
}
void ChipmunkSimulation::updateRemovingBallsRight(float x) {
    cpSegmentShapeSetRadius(killRightShape, 1-x);
    rightX = x;
    cpSpaceReindexShape(space, killRightShape);
}
void ChipmunkSimulation::endRemovingBallsRight() {
    killRight = false;
    cpSpaceRemoveCollisionHandler(space, BALL_TYPE, KILL_RIGHT_TYPE);
}

bool ChipmunkSimulation::isRemovingBallsTop() {
    return killTop;
}
bool ChipmunkSimulation::isRemovingBallsBottom() {
    return killBottom;
}
bool ChipmunkSimulation::isRemovingBallsLeft() {
    return killLeft;
}
bool ChipmunkSimulation::isRemovingBallsRight() {
    return killRight;
}
bool ChipmunkSimulation::isRemovingBalls() {
    return killTop || killBottom || killLeft || killRight;
}


float ChipmunkSimulation::removingBallsTopY() {
    return killTop ? topY : 2;
}
float ChipmunkSimulation::removingBallsBottomY() {
    return killBottom ? bottomY : -2;
}
float ChipmunkSimulation::removingBallsLeftX() {
    return killLeft ? leftX : -2;
}
float ChipmunkSimulation::removingBallsRightX() {
    return killRight ? rightX : 2;
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
    
    CFRelease(gestures);
    
    cpSpaceRemoveShape(space, killTopShape);
    cpSpaceRemoveShape(space, killBottomShape);
    cpSpaceRemoveShape(space, killLeftShape);
    cpSpaceRemoveShape(space, killRightShape);
    
    cpBodyFree(killBody);
    cpShapeFree(killTopShape);
    cpShapeFree(killBottomShape);
    cpShapeFree(killLeftShape);
    cpShapeFree(killRightShape);
    
    cpSpaceRemoveShape(space, bottom);
    cpSpaceRemoveShape(space, top);
    cpSpaceRemoveShape(space, left);
    cpSpaceRemoveShape(space, right);
    
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




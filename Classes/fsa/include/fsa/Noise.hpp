#pragma once

#include "Vector.hpp"

#include <limits.h>
#include <math.h>
#include <stdio.h>

#define FNV1_32_INIT ((unsigned int)0x811c9dc5)

namespace fsa {

unsigned int fnv_32a_buf(void *buf, unsigned int len, unsigned int hval);

inline float random(void *buf, unsigned int size, unsigned int hash_init=FNV1_32_INIT) {
    return (float)fnv_32a_buf(buf, size, hash_init)/UINT_MAX;
}

template <class T>
inline float random(T f, unsigned int hash_init=FNV1_32_INIT) {
    return (float)fnv_32a_buf(&f, sizeof(T), hash_init)/UINT_MAX;
}

template <class T>
inline float random(T f, T f2, unsigned int hash_init=FNV1_32_INIT) {
    T buf[2];
    buf[0] = f;
    buf[1] = f2;
    return (float)fnv_32a_buf(buf, 2*sizeof(T), hash_init)/UINT_MAX;
}

template <class T>
inline float random(T f, T f2, T f3, unsigned int hash_init=FNV1_32_INIT) {
    T buf[3];
    buf[0] = f;
    buf[1] = f2;
    buf[2] = f3;
    return (float)fnv_32a_buf(buf, 3*sizeof(T), hash_init)/UINT_MAX;
}

template <class T>
inline float random(T f, T f2, T f3, T f4, unsigned int hash_init=FNV1_32_INIT) {
    T buf[4];
    buf[0] = f;
    buf[1] = f2;
    buf[2] = f3;
    buf[3] = f4;
    return (float)fnv_32a_buf(buf, 4*sizeof(T), hash_init)/UINT_MAX;
}

class WhiteNoise {
    private:
        unsigned int hash_init;
    public:
        WhiteNoise(int s=0) {
            seed(s);
        }

        void seed(int s) {
            hash_init = fnv_32a_buf(&s, sizeof(int), FNV1_32_INIT);
        }

        float operator()(void *buf, unsigned int size, unsigned int hash_init) {
            return random(buf, size, hash_init);
        }

        template <class T>
        float operator()(T f) {
            return random(f, hash_init);
        }

        template <class T>
        float operator()(T f, T f2) {
            return random(f, f2, hash_init);
        }

        template <class T>
        float operator()(T f, T f2, T f3) {
            return random(f, f2, f3, hash_init);
        }

        template <class T>
        float operator()(T f, T f2, T f3, T f4) {
            return random(f, f2, f3, f4, hash_init);
        }
};

#define HASH2(x,y)  (perm[(x)+perm[(y)]]%grad2_size)
#define HASH3(x,y,z)  (perm[(x)+perm[(y)+perm[(z)]]]%grad3_size)
#define FASTFLOOR(x) ( ((x)>0) ? (int)(x) : (int)(x)-1 )
#define DOT2(x1,y1,x2,y2) ( (x1)*(x2)+(y1)*(y2) )
#define DOT3(x1,y1,z1,x2,y2,z2) ( (x1)*(x2)+(y1)*(y2)+(z1)*(z2) )
#define DOT4(x1,y1,z1,w1,x2,y2,z2,w2) ( (x1)*(x2)+(y1)*(y2)+(z1)*(z2)+(w1)*(w2) )
#define LERP(a,b,t) ( (1-(t))*(a)+(t)*(b) )
#define FADE(t) ( (t)*(t)*(t)*((t)*((t)*6-15)+10) )

class PerlinNoise {
    private:
        WhiteNoise r;
        vec2 *grad2;
        int grad2_size;

        vec3 *grad3;
        int grad3_size;

        vec4 *grad4;
        int grad4_size;

        int *perm;
        int perm_size; // power of 2

    public:
        
        PerlinNoise(int seed=0) : r(seed) {
            grad2_size = 16;
            grad2 = new vec2[grad2_size];
            for(unsigned int i = 0; i < grad2_size; i++) {
                grad2[i] = vec2(cos(TWOPI*(float)i/16.f), sin(TWOPI*(float)i/16.f));
            }

            grad3_size = 12;
            grad3 = new vec3[grad3_size];
            grad3[0] = vec3(0,1,1);
            grad3[1] = vec3(0,1,-1);
            grad3[2] = vec3(0,-1,1);
            grad3[3] = vec3(0,-1,-1);
            grad3[4] = vec3(1,0,1);
            grad3[5] = vec3(1,0,-1);
            grad3[6] = vec3(-1,0,1);
            grad3[7] = vec3(-1,0,-1);
            grad3[8] = vec3(1,1,0);
            grad3[9] = vec3(1,-1,0);
            grad3[10] = vec3(-1,1,0);
            grad3[11] = vec3(-1,-1,0);

            grad4_size = 32;
            grad4 = new vec4[grad4_size];
            grad4[0] = vec4(0,1,1,1);
            grad4[1] = vec4(0,1,1,-1);
            grad4[2] = vec4(0,1,-1,1);
            grad4[3] = vec4(0,1,-1,-1);
            grad4[4] = vec4(0,-1,1,1);
            grad4[5] = vec4(0,-1,1,-1);
            grad4[6] = vec4(0,-1,-1,1);
            grad4[7] = vec4(0,-1,-1,-1);
            grad4[8] = vec4(1,0,1,1);
            grad4[9] = vec4(1,0,1,-1);
            grad4[10] = vec4(1,0,-1,1);
            grad4[11] = vec4(1,0,-1,-1);
            grad4[12] = vec4(-1,0,1,1);
            grad4[13] = vec4(-1,0,1,-1);
            grad4[14] = vec4(-1,0,-1,1);
            grad4[15] = vec4(-1,0,-1,-1);
            grad4[16] = vec4(1,1,0,1);
            grad4[17] = vec4(1,1,0,-1);
            grad4[18] = vec4(1,-1,0,1);
            grad4[19] = vec4(1,-1,0,-1);
            grad4[20] = vec4(-1,1,0,1);
            grad4[21] = vec4(-1,1,0,-1);
            grad4[22] = vec4(-1,-1,0,1);
            grad4[23] = vec4(-1,-1,0,-1);
            grad4[24] = vec4(1,1,1,0);
            grad4[25] = vec4(1,1,-1,0);
            grad4[26] = vec4(1,-1,1,0);
            grad4[27] = vec4(1,-1,-1,0);
            grad4[28] = vec4(-1,1,1,0);
            grad4[29] = vec4(-1,1,-1,0);
            grad4[30] = vec4(-1,-1,1,0);
            grad4[31] = vec4(-1,-1,-1,0);

            perm_size = 256;
            perm = new int[perm_size << 1];
            for(unsigned int i = 0; i < perm_size; i++) {
                perm[i] = perm[i+256] = (int)(perm_size*r(i*1.23));
            }

        }
    
        float operator()(float x, float y) const {
            int X = FASTFLOOR(x);
            int Y = FASTFLOOR(y);
            
            x -= X;
            y -= Y;
            
            X &= perm_size-1;
            Y &= perm_size-1;
            
            int gi00 = HASH2(X,Y);
            int gi01 = HASH2(X,Y+1);
            int gi10 = HASH2(X+1, Y);
            int gi11 = HASH2(X+1, Y+1);
            
            float n00 = grad2[gi00].dot(x,y);
            float n01 = grad2[gi01].dot(x,y-1);
            float n10 = grad2[gi10].dot(x-1,y);
            float n11 = grad2[gi11].dot(x-1,y-1);

            double u = FADE(x);
            double v = FADE(y);
            
            double nx0 = LERP(n00, n10, u);
            double nx1 = LERP(n01, n11, u);
            
            double nxy = LERP(nx0, nx1, v);
                    
            return 1.47*nxy;
        }

        float operator()(float x, float y, float z) const {
            int X = FASTFLOOR(x);
            int Y = FASTFLOOR(y);
            int Z = FASTFLOOR(z);

            x -= X;
            y -= Y;
            z -= Z;

            X &= perm_size-1;
            Y &= perm_size-1;
            Z &= perm_size-1;

            int gi000 = HASH3(X,Y,Z);
            int gi001 = HASH3(X,Y,Z+1);
            int gi010 = HASH3(X,Y+1,Z);
            int gi011 = HASH3(X,Y+1,Z+1);
            int gi100 = HASH3(X+1,Y,Z);
            int gi101 = HASH3(X+1,Y,Z+1);
            int gi110 = HASH3(X+1,Y+1,Z);
            int gi111 = HASH3(X+1,Y+1,Z+1);

            float n000 = grad3[gi000].dot(x,y,z);
            float n100 = grad3[gi100].dot(x-1,y,z);
            float n010 = grad3[gi010].dot(x,y-1,z);
            float n110 = grad3[gi110].dot(x-1,y-1,z);
            float n001 = grad3[gi001].dot(x,y,z-1);
            float n101 = grad3[gi101].dot(x-1,y,z-1);
            float n011 = grad3[gi011].dot(x,y-1,z-1);
            float n111 = grad3[gi111].dot(x-1,y-1,z-1);

            double u = FADE(x);
            double v = FADE(y);
            double w = FADE(z);

            double nx00 = LERP(n000, n100, u);
            double nx01 = LERP(n001, n101, u);
            double nx10 = LERP(n010, n110, u);
            double nx11 = LERP(n011, n111, u);

            double nxy0 = LERP(nx00, nx10, v);
            double nxy1 = LERP(nx01, nx11, v);

            double nxyz = LERP(nxy0, nxy1, w);

            return nxyz;
        }

        ~PerlinNoise() {
            delete [] grad2;
            delete [] grad3;
            delete [] grad4;
            delete [] perm;
        }

};
    
static const PerlinNoise pnoise;

/* SLOW ALGORITHMS 
        float value(float x, float y) {
            int X = FASTFLOOR(x);
            int Y = FASTFLOOR(y);

            x -= X;
            y -= Y;

            float u = FADE(x);
            float v = FADE(y);

            float n0 = 2*r(X,Y)-1;
            float n1 = 2*r(X+1,Y)-1;
            float n2 = 2*r(X,Y+1)-1;
            float n3 = 2*r(X+1,Y+1)-1;

            float x0 = LERP(n0, n1, u);
            float x1 = LERP(n2, n3, u);

            return LERP(x0, x1, v);
        }

        // very slow but never repeats 
        // (doesn't use a gradient or permutation table)
        float perlin(float x, float y) {
            int X = FASTFLOOR(x);
            int Y = FASTFLOOR(y);

            x -= X;
            y -= Y;

            float u = FADE(x);
            float v = FADE(y);

            float g0theta = 2*PI*r(1.23*X,1.23*Y);
            float g0x = cos(g0theta);
            float g0y = sin(g0theta);

            float g1theta = 2*PI*r(1.23*(X+1),1.23*Y);
            float g1x = cos(g1theta);
            float g1y = sin(g1theta);

            float g2theta = 2*PI*r(1.23*X,1.23*(Y+1));
            float g2x = cos(g2theta);
            float g2y = sin(g2theta);

            float g3theta = 2*PI*r(1.23*(X+1),1.23*(Y+1));
            float g3x = cos(g3theta);
            float g3y = sin(g3theta);

            float n0 = DOT2(g0x, g0y, x, y);
            float n1 = DOT2(g1x, g1y, x-1, y);
            float n2 = DOT2(g2x, g2y, x, y-1);
            float n3 = DOT2(g3x, g3y, x-1, y-1);

            float x0 = LERP(n0, n1, u);
            float x1 = LERP(n2, n3, u);

            return LERP(x0, x1, v);
        }
        
        // very slow but never repeats 
        // (doesn't use a gradient or permutation table)
        float perlin(float x, float y, float z) {
            int X = FASTFLOOR(x);
            int Y = FASTFLOOR(y);
            int Z = FASTFLOOR(z);

            x -= X;
            y -= Y;
            z -= Z;

            float u = FADE(x);
            float v = FADE(y);
            float w = FADE(z);

            float g0theta = 2*PI*r(1.23*X,1.23*Y,1.23*Z);
            float g0phi = 2*asin(sqrt(r(.456*X, .456*Y, .456*Z)));
            float g0x = sin(g0phi)*cos(g0theta);
            float g0y = sin(g0phi)*sin(g0theta);
            float g0z = cos(g0phi);

            float g1theta = 2*PI*r(1.23*(X+1),1.23*Y,1.23*Z);
            float g1phi = 2*asin(sqrt(r(.456*(X+1), .456*Y, .456*Z)));
            float g1x = sin(g1phi)*cos(g1theta);
            float g1y = sin(g1phi)*sin(g1theta);
            float g1z = cos(g1phi);

            float g2theta = 2*PI*r(1.23*(X+1),1.23*Y,1.23*(Z+1));
            float g2phi = 2*asin(sqrt(r(.456*(X+1), .456*Y, .456*(Z+1))));
            float g2x = sin(g2phi)*cos(g2theta);
            float g2y = sin(g2phi)*sin(g2theta);
            float g2z = cos(g2phi);

            float g3theta = 2*PI*r(1.23*(X),1.23*Y,1.23*(Z+1));
            float g3phi = 2*asin(sqrt(r(.456*(X), .456*Y, .456*(Z+1))));
            float g3x = sin(g3phi)*cos(g3theta);
            float g3y = sin(g3phi)*sin(g3theta);
            float g3z = cos(g3phi);

            float g4theta = 2*PI*r(1.23*X,1.23*(Y+1),1.23*Z);
            float g4phi = 2*asin(sqrt(r(.456*X, .456*(Y+1), .456*Z)));
            float g4x = sin(g4phi)*cos(g4theta);
            float g4y = sin(g4phi)*sin(g4theta);
            float g4z = cos(g4phi);

            float g5theta = 2*PI*r(1.23*(X+1),1.23*(Y+1),1.23*Z);
            float g5phi = 2*asin(sqrt(r(.456*(X+1), .456*(Y+1), .456*Z)));
            float g5x = sin(g5phi)*cos(g5theta);
            float g5y = sin(g5phi)*sin(g5theta);
            float g5z = cos(g5phi);

            float g6theta = 2*PI*r(1.23*(X+1),1.23*(Y+1),1.23*(Z+1));
            float g6phi = 2*asin(sqrt(r(.456*(X+1), .456*(Y+1), .456*(Z+1))));
            float g6x = sin(g6phi)*cos(g6theta);
            float g6y = sin(g6phi)*sin(g6theta);
            float g6z = cos(g6phi);

            float g7theta = 2*PI*r(1.23*(X),1.23*(Y+1),1.23*(Z+1));
            float g7phi = 2*asin(sqrt(r(.456*(X), .456*(Y+1), .456*(Z+1))));
            float g7x = sin(g7phi)*cos(g7theta);
            float g7y = sin(g7phi)*sin(g7theta);
            float g7z = cos(g7phi);

            float n0 = DOT3(g0x, g0y, g0z, x, y, z);
            float n1 = DOT3(g1x, g1y, g1z, x-1, y, z);
            float n2 = DOT3(g2x, g2y, g2z, x-1, y, z-1);
            float n3 = DOT3(g3x, g3y, g3z, x, y, z-1);
            float n4 = DOT3(g4x, g4y, g4z, x, y-1, z);
            float n5 = DOT3(g5x, g5y, g5z, x-1, y-1, z);
            float n6 = DOT3(g6x, g6y, g6z, x-1, y-1, z-1);
            float n7 = DOT3(g7x, g7y, g7z, x, y-1, z-1);

            float x0 = LERP(n0, n1, u);
            float x1 = LERP(n3, n2, u);
            float x2 = LERP(n4, n5, u);
            float x3 = LERP(n7, n6, u);

            float y0 = LERP(x0, x2, v);
            float y1 = LERP(x1, x3, v);

            return LERP(y0, y1, w);
        }
        */

}

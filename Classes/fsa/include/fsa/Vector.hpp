#pragma once
#include <cmath>
#import <CoreGraphics/CGBase.h>

namespace fsa {
    
typedef CGFloat fsaFloat;

const fsaFloat PI = 4 * std::atan(1.0f);
const fsaFloat TWOPI = 2 * PI;

class Vector2f 

    {
    public:
        fsaFloat x;
        fsaFloat y;

        Vector2f() : x(0), y(0) {}
        Vector2f(fsaFloat x, fsaFloat y) : x(x), y(y) {}
#if TARGET_OS_IPHONE
        Vector2f(const CGPoint& p) : x(p.x), y(p.y) {}
#endif

        fsaFloat dot(const Vector2f &v) const {
            return x*v.x+y*v.y;
        }
        fsaFloat dot(fsaFloat xx, fsaFloat yy) const {
            return x*xx+y*yy;
        }
        
        void rotate(fsaFloat a) {
            fsaFloat sin_a = sin(a);
            fsaFloat cos_a = cos(a);
            
            fsaFloat new_x = x*cos_a+y*sin_a;
            fsaFloat new_y = -x*sin_a+y*cos_a;
            x = new_x;
            y = new_y;
        }
        
        void rotate(fsaFloat cos_a, fsaFloat sin_a) {     
            fsaFloat new_x = x*cos_a+y*sin_a;
            fsaFloat new_y = -x*sin_a+y*cos_a;
            x = new_x;
            y = new_y;
        }

        Vector2f& operator*=(const Vector2f& v) {
            x *= v.x;
            y *= v.y;
            return *this;
        }

        Vector2f& operator+=(const Vector2f& v) {
            x += v.x;
            y += v.y;
            return *this;
        }
        Vector2f& operator-=(const Vector2f& v) {
            x -= v.x;
            y -= v.y;
            return *this;
        }
        Vector2f& operator/=(const Vector2f& v) {
            x /= v.x;
            y /= v.y;
            return *this;
        }
        Vector2f& operator/=(fsaFloat s) {
            fsaFloat tmp = 1.0f / s;
            x *= tmp;
            y *= tmp;
            return *this;
        }
        Vector2f& operator*=(fsaFloat s) {
            x *= s;
            y *= s;
            return *this;
        }
        Vector2f& operator+=(fsaFloat s) {
            x += s;
            y += s;
            return *this;
        }
        Vector2f& operator-=(fsaFloat s) {
            x -= s;
            y -= s;
            return *this;
        }
        
        void clamp(fsaFloat min, fsaFloat max) {
            if(x < min) {
                x = min;
            }
            if(x > max) {
                x = max;
            }
            if(y < min) {
                y = min;
            }
            if(y > max) {
                y = max;
            }
        }
        
        const Vector2f operator*(const Vector2f& v) {
            return Vector2f(x*v.x, y*v.y);
        }

        const Vector2f operator+(const Vector2f& v) {
            return Vector2f(x+v.x, y+v.y);
        }

        const Vector2f operator-(const Vector2f& v) {
            return Vector2f(x-v.x, y-v.y);
        }
        
        const bool operator==(const Vector2f& v) {
            return x == v.x && y == v.y;
        }
        
        friend const Vector2f operator+(const Vector2f& v1, const Vector2f& v2) {
            return Vector2f(v1.x+v2.x, v1.y+v2.y);
        }
        
        friend const Vector2f operator-(const Vector2f& v1, const Vector2f& v2) {
            return Vector2f(v1.x-v2.x, v1.y-v2.y);
        }

        const Vector2f operator-() {
            return Vector2f(-x, -y);
        }

        const Vector2f operator/(const Vector2f& v) {
            return Vector2f(x/v.x, y/v.y);
        }

        const Vector2f operator*(fsaFloat s) {
            return Vector2f(s*x, s*y);
        }
        
        friend const Vector2f operator*(fsaFloat s, const Vector2f& v) {
            return Vector2f(s*v.x, s*v.y);
        }
        friend const Vector2f operator*(const Vector2f& v, fsaFloat s) {
            return Vector2f(s*v.x, s*v.y);
        }

        const Vector2f operator/(fsaFloat s) {
            fsaFloat tmp = 1.0f / s;
            return Vector2f(x*tmp, y*tmp);
        }

        fsaFloat length() const {
            return sqrt(x*x+y*y);
        }

        void normalize() {
            fsaFloat s = 1.0f / length();
            x *= s;
            y *= s;
        }

        const Vector2f unit() const {
            fsaFloat s = 1.0f / length();
            return Vector2f(x*s, y*s);
        }

        const Vector2f lerp(const Vector2f& v, fsaFloat t) {
            fsaFloat one_minus_t = 1-t;
            return Vector2f(x*one_minus_t+v.x*t,
                            y*one_minus_t+v.y*t);
        }

        const fsaFloat* pointer() const {
            return &x;
        }

};

class Vector3f {
    public:
        fsaFloat x;
        fsaFloat y;
        fsaFloat z;

        Vector3f() {}
        Vector3f(fsaFloat x, fsaFloat y, fsaFloat z) : x(x), y(y), z(z) {}
        Vector3f(Vector2f v) : x(v.x), y(v.y), z(0) {}

        fsaFloat dot(const Vector3f& v) {
            return x*v.x+y*v.y+z*v.z;
        }
        fsaFloat dot(fsaFloat xx, fsaFloat yy, fsaFloat zz) {
            return x*xx+y*yy+z*zz;
        }

        const Vector3f cross(const Vector3f& v) {
            return Vector3f(y*v.z-z*v.y, z*v.x-x*v.z, x*v.y-y*v.x);
        }

        Vector3f& operator*=(const Vector3f& v) {
            x *= v.x;
            y *= v.y;
            z *= v.z;
            return *this;
        }

        Vector3f& operator+=(const Vector3f& v) {
            x += v.x;
            y += v.y;
            z += v.z;
            return *this;
        }
        Vector3f& operator-=(const Vector3f& v) {
            x -= v.x;
            y -= v.y;
            z -= v.z;
            return *this;
        }
        Vector3f& operator/=(const Vector3f& v) {
            x /= v.x;
            y /= v.y;
            z /= v.z;
            return *this;
        }
        Vector3f& operator/=(fsaFloat s) {
            fsaFloat tmp = 1.0f / s;
            x *= tmp;
            y *= tmp;
            z *= tmp;
            return *this;
        }
        Vector3f& operator*=(fsaFloat s) {
            x *= s;
            y *= s;
            z *= s;
            return *this;
        }
        Vector3f& operator+=(fsaFloat s) {
            x += s;
            y += s;
            z += s;
            return *this;
        }
        Vector3f& operator-=(fsaFloat s) {
            x -= s;
            y -= s;
            z -= s;
            return *this;
        }
        
        const Vector3f operator*(const Vector3f& v) {
            return Vector3f(x*v.x, y*v.y, z*v.z);
        }

        const Vector3f operator+(const Vector3f& v) {
            return Vector3f(x+v.x, y+v.y, z+v.z);
        }

        const Vector3f operator-(const Vector3f& v) {
            return Vector3f(x-v.x, y-v.y, z-v.z);
        }

        const Vector3f operator-() {
            return Vector3f(-x, -y, -z);
        }

        const Vector3f operator/(const Vector3f& v) {
            return Vector3f(x/v.x, y/v.y, z/v.z);
        }

        const Vector3f operator*(fsaFloat s) {
            return Vector3f(s*x, s*y, s*z);
        }

        const Vector3f operator/(fsaFloat s) {
            fsaFloat tmp = 1.0f / s;
            return Vector3f(x*tmp, y*tmp, z*tmp);
        }

        fsaFloat length() {
            return sqrt(x*x+y*y+z*z);
        }

        void normalize() {
            fsaFloat s = 1.0f / length();
            x *= s;
            y *= s;
            z *= s;
        }

        const Vector3f unit() {
            fsaFloat s = 1.0f / length();
            return Vector3f(x*s, y*s, z*s);
        }

        const Vector3f lerp(const Vector3f& v, fsaFloat t) {
            fsaFloat one_minus_t = 1-t;
            return Vector3f(x*one_minus_t+v.x*t,
                            y*one_minus_t+v.y*t,
                            z*one_minus_t+v.z*t);
        }

        const fsaFloat* pointer() const {
            return &x;
        }

        const Vector2f xy() {
            return Vector2f(x,y);
        }
};

class Vector4f {
    public:
        fsaFloat x;
        fsaFloat y;
        fsaFloat z;
        fsaFloat w;

        Vector4f() {}
        Vector4f(fsaFloat x, fsaFloat y, fsaFloat z, fsaFloat w) : x(x), y(y), z(z), w(w) {}
        Vector4f(const Vector3f &v) : x(v.x), y(v.y), z(v.z), w(1) {}

        fsaFloat dot(const Vector4f& v) {
            return x*v.x+y*v.y+z*v.z+w*v.w;
        }
        fsaFloat dot(fsaFloat xx, fsaFloat yy, fsaFloat zz, fsaFloat ww) {
            return x*xx+y*yy+z*zz+w*ww;
        }
    
        const Vector4f operator+(const Vector4f& v) {
            return Vector4f(x+v.x, y+v.y, z+v.z, w+v.w);
        }

        const Vector4f lerp(const Vector4f& v, fsaFloat t) {
            fsaFloat one_minus_t = 1-t;
            return Vector4f(x*one_minus_t+v.x*t,
                            y*one_minus_t+v.y*t,
                            z*one_minus_t+v.z*t,
                            w*one_minus_t+v.w*t);
        }
    
        friend const Vector4f operator+(const Vector4f& v1, const Vector4f& v2) {
            return Vector4f(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z, v1.w+v2.w);
        }
        
        friend const Vector4f operator-(const Vector4f& v1, const Vector4f& v2) {
            return Vector4f(v1.x-v2.x, v1.y-v2.y, v1.z-v2.z, v1.w-v2.w);
        }
    
        Vector4f& operator*=(fsaFloat s) {
            x *= s;
            y *= s;
            z *= s;
            w *= s;
            return *this;
        }
    
        friend const Vector4f operator*(fsaFloat s, const Vector4f& v) {
            return Vector4f(s*v.x, s*v.y, s*v.z, s*v.w);
        }
        friend const Vector4f operator*(const Vector4f& v, fsaFloat s) {
            return Vector4f(s*v.x, s*v.y, s*v.z, s*v.w);
        }
    
        const fsaFloat* pointer() const {
            return &x;
        }

        const Vector2f xy() {
            return Vector2f(x,y);
        }
        const Vector3f xyz() {
            return Vector3f(x,y,z);
        }
};

typedef Vector2f vec2;
typedef Vector3f vec3;
typedef Vector4f vec4;

}

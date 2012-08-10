#pragma once
#include <cmath>

namespace fsa {

const float PI = 4 * std::atan(1.0f);
const float TWOPI = 2 * PI;

class Vector2f 

    {
    public:
        float x;
        float y;

        Vector2f() : x(0), y(0) {}
        Vector2f(float x, float y) : x(x), y(y) {}
#if TARGET_OS_IPHONE
        Vector2f(const CGPoint& p) : x(p.x), y(p.y) {}
#endif

        float dot(const Vector2f &v) const {
            return x*v.x+y*v.y;
        }
        float dot(float xx, float yy) const {
            return x*xx+y*yy;
        }
        
        void rotate(float a) {
            float sin_a = sin(a);
            float cos_a = cos(a);
            
            float new_x = x*cos_a+y*sin_a;
            float new_y = -x*sin_a+y*cos_a;
            x = new_x;
            y = new_y;
        }
        
        void rotate(float cos_a, float sin_a) {     
            float new_x = x*cos_a+y*sin_a;
            float new_y = -x*sin_a+y*cos_a;
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
        Vector2f& operator/=(float s) {
            float tmp = 1.0f / s;
            x *= tmp;
            y *= tmp;
            return *this;
        }
        Vector2f& operator*=(float s) {
            x *= s;
            y *= s;
            return *this;
        }
        Vector2f& operator+=(float s) {
            x += s;
            y += s;
            return *this;
        }
        Vector2f& operator-=(float s) {
            x -= s;
            y -= s;
            return *this;
        }
        
        void clamp(float min, float max) {
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

        const Vector2f operator*(float s) {
            return Vector2f(s*x, s*y);
        }
        
        friend const Vector2f operator*(float s, const Vector2f& v) {
            return Vector2f(s*v.x, s*v.y);
        }
        friend const Vector2f operator*(const Vector2f& v, float s) {
            return Vector2f(s*v.x, s*v.y);
        }

        const Vector2f operator/(float s) {
            float tmp = 1.0f / s;
            return Vector2f(x*tmp, y*tmp);
        }

        float length() const {
            return sqrt(x*x+y*y);
        }

        void normalize() {
            float s = 1.0f / length();
            x *= s;
            y *= s;
        }

        const Vector2f unit() const {
            float s = 1.0f / length();
            return Vector2f(x*s, y*s);
        }

        const Vector2f lerp(const Vector2f& v, float t) {
            float one_minus_t = 1-t;
            return Vector2f(x*one_minus_t+v.x*t,
                            y*one_minus_t+v.y*t);
        }

        const float* pointer() const {
            return &x;
        }

};

class Vector3f {
    public:
        float x;
        float y;
        float z;

        Vector3f() {}
        Vector3f(float x, float y, float z) : x(x), y(y), z(z) {}
        Vector3f(Vector2f v) : x(v.x), y(v.y), z(0) {}

        float dot(const Vector3f& v) {
            return x*v.x+y*v.y+z*v.z;
        }
        float dot(float xx, float yy, float zz) {
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
        Vector3f& operator/=(float s) {
            float tmp = 1.0f / s;
            x *= tmp;
            y *= tmp;
            z *= tmp;
            return *this;
        }
        Vector3f& operator*=(float s) {
            x *= s;
            y *= s;
            z *= s;
            return *this;
        }
        Vector3f& operator+=(float s) {
            x += s;
            y += s;
            z += s;
            return *this;
        }
        Vector3f& operator-=(float s) {
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

        const Vector3f operator*(float s) {
            return Vector3f(s*x, s*y, s*z);
        }

        const Vector3f operator/(float s) {
            float tmp = 1.0f / s;
            return Vector3f(x*tmp, y*tmp, z*tmp);
        }

        float length() {
            return sqrt(x*x+y*y+z*z);
        }

        void normalize() {
            float s = 1.0f / length();
            x *= s;
            y *= s;
            z *= s;
        }

        const Vector3f unit() {
            float s = 1.0f / length();
            return Vector3f(x*s, y*s, z*s);
        }

        const Vector3f lerp(const Vector3f& v, float t) {
            float one_minus_t = 1-t;
            return Vector3f(x*one_minus_t+v.x*t,
                            y*one_minus_t+v.y*t,
                            z*one_minus_t+v.z*t);
        }

        const float* pointer() const {
            return &x;
        }

        const Vector2f xy() {
            return Vector2f(x,y);
        }
};

class Vector4f {
    public:
        float x;
        float y;
        float z;
        float w;

        Vector4f() {}
        Vector4f(float x, float y, float z, float w) : x(x), y(y), z(z), w(w) {}
        Vector4f(const Vector3f &v) : x(v.x), y(v.y), z(v.z), w(1) {}

        float dot(const Vector4f& v) {
            return x*v.x+y*v.y+z*v.z+w*v.w;
        }
        float dot(float xx, float yy, float zz, float ww) {
            return x*xx+y*yy+z*zz+w*ww;
        }
    
        const Vector4f operator+(const Vector4f& v) {
            return Vector4f(x+v.x, y+v.y, z+v.z, w+v.w);
        }

        const Vector4f lerp(const Vector4f& v, float t) {
            float one_minus_t = 1-t;
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
    
        Vector4f& operator*=(float s) {
            x *= s;
            y *= s;
            z *= s;
            w *= s;
            return *this;
        }
    
        friend const Vector4f operator*(float s, const Vector4f& v) {
            return Vector4f(s*v.x, s*v.y, s*v.z, s*v.w);
        }
        friend const Vector4f operator*(const Vector4f& v, float s) {
            return Vector4f(s*v.x, s*v.y, s*v.z, s*v.w);
        }
    
        const float* pointer() const {
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

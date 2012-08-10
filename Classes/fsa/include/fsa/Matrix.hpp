#pragma once

#include "oolong/Include/Mathematics.h"
#include "Vector.hpp"

class Matrix4f {
public:
    Matrix4f() {
    }
    Matrix4f(float c) {
        f[0] = c; f[4] = 0.0f; f[8] = 0.0f; f[12] = 0.0f;
        f[1] = 0.0f; f[5] = c; f[9] = 0.0f; f[13] = 0.0f;
        f[2] = 0.0f; f[6] = 0.0f; f[10] = c; f[14] = 0.0f;
        f[3] = 0.0f; f[7] = 0.0f; f[11] = 0.0f; f[15] = c;
    }
    Matrix4f(const float* m)
    {
        f[0] = m[0]; f[4] = m[4]; f[8] = m[8]; f[12] = m[12];
        f[1] = m[1]; f[5] = m[5]; f[9] = m[9]; f[13] = m[13];
        f[2] = m[2]; f[6] = m[6]; f[10] = m[10]; f[14] = m[14];
        f[3] = m[3]; f[7] = m[7]; f[11] = m[11]; f[15] = m[15];
    }

    void identity() {
        f[0] = 1.0f; f[4] = 0.0f; f[8] = 0.0f; f[12] = 0.0f;
        f[1] = 0.0f; f[5] = 1.0f; f[9] = 0.0f; f[13] = 0.0f;
        f[2] = 0.0f; f[6] = 0.0f; f[10] = 1.0f; f[14] = 0.0f;
        f[3] = 0.0f; f[7] = 0.0f; f[11] = 0.0f; f[15] = 1.0f;
    }
    
    Matrix4f operator * (const Matrix4f& b) const
    {
        Matrix4f m;
        MatrixMultiply((MATRIX&)m, (const MATRIX&)*this, (const MATRIX&)b);

        return m;
    }

    const float* pointer() const {
        return &f[0];
    }

    static Matrix4f Identity()
    {
        return Matrix4f(1.0f);
    }
    static Matrix4f Translate(float x, float y, float z)
    {
        Matrix4f m;
        m.f[0] = 1.0f; m.f[4] = 0.0f; m.f[8] = 0.0f; m.f[12] = x;
        m.f[1] = 0.0f; m.f[5] = 1.0f; m.f[9] = 0.0f; m.f[13] = y;
        m.f[2] = 0.0f; m.f[6] = 0.0f; m.f[10] = 1.0f; m.f[14] = z;
        m.f[3] = 0.0f; m.f[7] = 0.0f; m.f[11] = 0.0f; m.f[15] = 1.0f;
        return m;
    }
    static Matrix4f Scale(float x, float y, float z)
    {
        Matrix4f m;
        m.f[0] = x; m.f[4] = 0.0f; m.f[8] = 0.0f; m.f[12] = 0.0f;
        m.f[1] = 0.0f; m.f[5] = y; m.f[9] = 0.0f; m.f[13] = 0.0f;
        m.f[2] = 0.0f; m.f[6] = 0.0f; m.f[10] = z; m.f[14] = 0.0f;
        m.f[3] = 0.0f; m.f[7] = 0.0f; m.f[11] = 0.0f; m.f[15] = 1.0f;
        return m;
    }

    float f[16];
};
/*
const Vector4f operator* (const Matrix4f &m, const Vector4f &v) {
    Vector4f out;
    MatrixVec4Multiply((VECTOR4&)out, (const VECTOR4&)v, (const MATRIX&)m);

    return out;
}

const Vector4f operator *(const Vector4f &v, const Matrix4f &m) {
    Vector4f out;
    MatrixVec4Multiply((VECTOR4&)out, (const VECTOR4&)v, (const MATRIX&)m);

    return out;
}
 */

typedef Matrix4f mat4;

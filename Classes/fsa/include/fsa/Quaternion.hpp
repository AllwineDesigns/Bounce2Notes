#pragma once
#include "Matrix.hpp"

namespace fsa {

class Quaternionf {
    float x;
    float y;
    float z;
    float w;
    
    QuaternionT() {}
    QuaternionT(float x, float y, float z, float w) : x(x), y(y), z(z), w(z) {}
};

typedef Quaternionf quat;

}

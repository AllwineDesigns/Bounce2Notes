#pragma once
#include "Matrix.hpp"

namespace fsa {

class Quaternionf {
    fsaFloat x;
    fsaFloat y;
    fsaFloat z;
    fsaFloat w;
    
    QuaternionT() {}
    QuaternionT(fsaFloat x, fsaFloat y, fsaFloat z, fsaFloat w) : x(x), y(y), z(z), w(z) {}
};

typedef Quaternionf quat;

}

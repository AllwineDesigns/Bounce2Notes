#include "fsa/Noise.hpp"

namespace fsa {

unsigned int fnv_32a_buf(void *buf, unsigned int len, unsigned int hval)
{
    unsigned char *bp = (unsigned char *)buf;	/* start of buffer */
    unsigned char *be = bp + len;		/* beyond end of buffer */
    /*
     * FNV-1a hash each octet in the buffer
     */
    while (bp < be) {

	/* xor the bottom with the current octet */
	hval ^= (unsigned int)*bp++;

	/* multiply by the 32 bit FNV magic prime mod 2^32 */
	hval += (hval<<1) + (hval<<4) + (hval<<7) + (hval<<8) + (hval<<24);
    }

    /* return our new hash value */
    return hval;
}

}

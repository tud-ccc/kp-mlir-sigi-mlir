
#include <memory.h>
#include "closure.h"


/// todo implement that in LLVM IR.
void closure_dec_or_drop(closure_t* closure) {
    if (--closure->refcount == 0) {
        closure->drop(closure);
        free(closure);
    }
}

void closure_incr(closure_t* closure) {
    closure->refcount++;
}

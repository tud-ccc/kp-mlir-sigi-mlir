
#include <memory.h>
#include <stdio.h>
#include "closure.h"


/// todo implement that in LLVM IR.
void closure_decr(closure_t* closure) {
    closure->refcount--;
}

void closure_decr_then_drop(closure_t* closure) {
    closure_decr(closure);
    closure_check_drop(closure);
}

void closure_check_drop(closure_t* closure) {
    if (closure->refcount == 0) {
        closure->drop(closure);
        printf("free\n");
        free(closure);
    }
}

void closure_incr(closure_t* closure) {
    closure->refcount++;
}

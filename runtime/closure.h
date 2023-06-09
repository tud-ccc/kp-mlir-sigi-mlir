
#pragma once
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

// forward decl
typedef struct sigi_stack_impl* sigi_stack_t;

/// Closure type, unsized, can only be manipulated by reference.
typedef struct closure_t {
    /// Invoke the closure.
    sigi_stack_t (*invoke)(sigi_stack_t);
    /// Reference count.
    int32_t refcount;
    /// Drop this value recursively.
    void (*drop)(struct closure_t*);
    // Unsized field for the captured args.
    char capture_args[];
} closure_t;

/// Decrement the reference count. If refcount is zero, call the 
/// virtual drop function to recursively dec_or_drop fields, then
/// free the allocation.
void closure_decr_then_drop(closure_t* closure);
/// If refcount is zero, drop the closure and all its fields.
/// Does not change the refcount.
void closure_check_drop(closure_t* closure);
/// Increment the reference count.
void closure_incr(closure_t* closure);
void closure_decr(closure_t* closure);

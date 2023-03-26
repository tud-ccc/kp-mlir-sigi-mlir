//===- Passes.td - Closure dialect passes ---------------------*- tablegen -*-===//
//
// This is the definitions file for the Closure dialect conversion passes.
//
//===----------------------------------------------------------------------===//

#ifndef CLOSURE_CONVERSION_PASSES
#define CLOSURE_CONVERSION_PASSES

include "PassUtil.td"


def ConvertClosureToLLVM : ConvertToLlvm<"Closure", "closure">;



#endif // CLOSURE_CONVERSION_PASSES
/// Implements the Closure dialect types.

#include "sigi-mlir/Dialect/Closure/IR/ClosureTypes.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/OpImplementation.h"

#include "llvm/ADT/TypeSwitch.h"

#define DEBUG_TYPE "closure-types"

using namespace mlir;
using namespace mlir::closure;

//===- Generated implementation -------------------------------------------===//

#define GET_TYPEDEF_CLASSES
#include "sigi-mlir/Dialect/Closure/IR/ClosureTypes.cpp.inc"

//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// ClosureDialect
//===----------------------------------------------------------------------===//

void ClosureDialect::registerTypes()
{
    addTypes<
#define GET_TYPEDEF_LIST
#include "sigi-mlir/Dialect/Closure/IR/ClosureTypes.cpp.inc"
        >();
}

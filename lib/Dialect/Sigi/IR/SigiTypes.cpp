/// Implements the Sigi dialect types.
///
/// @file

#include "sigi-mlir/Dialect/Sigi/IR/SigiTypes.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/OpImplementation.h"

#include "llvm/ADT/TypeSwitch.h"

#define DEBUG_TYPE "sigi-types"

using namespace mlir;
using namespace mlir::sigi;

//===- Generated implementation -------------------------------------------===//

#define GET_TYPEDEF_CLASSES
#include "sigi-mlir/Dialect/Sigi/IR/SigiTypes.cpp.inc"

//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// SigiDialect
//===----------------------------------------------------------------------===//

void SigiDialect::registerTypes()
{
    addTypes<
#define GET_TYPEDEF_LIST
#include "sigi-mlir/Dialect/Sigi/IR/SigiTypes.cpp.inc"
        >();
}

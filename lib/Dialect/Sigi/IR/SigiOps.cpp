/// Implements the Sigi dialect ops.
///
/// @file

#include "sigi-mlir/Dialect/Sigi/IR/SigiOps.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Transforms/DialectConversion.h"

#include "llvm/ADT/APFloat.h"

#define DEBUG_TYPE "sigi-ops"

using namespace mlir;
using namespace mlir::sigi;

//===- Generated implementation -------------------------------------------===//

#define GET_OP_CLASSES
#include "sigi-mlir/Dialect/Sigi/IR/SigiOps.cpp.inc"

//===----------------------------------------------------------------------===//
// SigiDialect
//===----------------------------------------------------------------------===//

void SigiDialect::registerOps()
{
    addOperations<
#define GET_OP_LIST
#include "sigi-mlir/Dialect/Sigi/IR/SigiOps.cpp.inc"
        >();
}

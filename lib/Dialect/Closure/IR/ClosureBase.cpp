/// Implements the Closure dialect base.
///
/// @file

#include "sigi-mlir/Dialect/Closure/IR/ClosureBase.h"

#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"
#include "mlir/Transforms/InliningUtils.h"
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"

#define DEBUG_TYPE "closure-base"

using namespace mlir;
using namespace mlir::closure;

//===- Generated implementation -------------------------------------------===//

#include "sigi-mlir/Dialect/Closure/IR/ClosureBase.cpp.inc"

//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// ClosureDialect
//===----------------------------------------------------------------------===//
namespace {

} // namespace

void ClosureDialect::initialize()
{
    registerOps();
    registerTypes();
}

/// Implements the Sigi dialect base.
///
/// @file

#include "sigi-mlir/Dialect/Sigi/IR/SigiBase.h"

#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

#define DEBUG_TYPE "sigi-base"

using namespace mlir;
using namespace mlir::sigi;

//===- Generated implementation -------------------------------------------===//

#include "sigi-mlir/Conversion/SigiToLLVM/SigiToLLVM.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiBase.cpp.inc"
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// SigiDialect
//===----------------------------------------------------------------------===//


void SigiDialect::initialize()
{
    registerOps();
    registerTypes();
}

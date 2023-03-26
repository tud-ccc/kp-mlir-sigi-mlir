/// Declaration of the conversion passes for the Closure dialect.
///
/// @file

#pragma once

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "sigi-mlir/Conversion/ClosureToLLVM/ClosureToLLVM.h"

namespace mlir {

//===- Generated passes ---------------------------------------------------===//

#define GEN_PASS_REGISTRATION
#include "sigi-mlir/Conversion/ClosurePasses.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir
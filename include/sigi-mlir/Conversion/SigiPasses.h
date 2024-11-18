/// Declaration of the conversion pass within Sigi dialect.
///
/// @file

#pragma once

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "sigi-mlir/Conversion/SigiToLLVM/SigiToLLVM.h"

namespace mlir {

//===- Generated passes ---------------------------------------------------===//

#define GEN_PASS_REGISTRATION
#include "sigi-mlir/Conversion/SigiPasses.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir
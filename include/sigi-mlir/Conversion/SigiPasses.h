/// Declaration of the conversion pass within Sigi dialect.
///
/// @file

#pragma once

namespace mlir {

//===- Generated passes ---------------------------------------------------===//

#define GEN_PASS_REGISTRATION
#include "sigi-mlir/Conversion/SigiPasses.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir
/// Declaration of the passes
///
/// @file

#pragma once

#include "mlir/Pass/Pass.h"
#include "mlir/IR/BuiltinOps.h"

namespace mlir {

// Forward declaration from Dialect.h
template<typename ConcreteDialect>
void registerDialect(DialectRegistry &registry);


namespace LLVM {
class LLVMDialect;
} // namespace func

namespace func {
class FuncDialect;
} // namespace func

namespace linalg {
class LinalgDialect;
} // namespace linalg

namespace closure {
class ClosureDialect;
} // namespace closure


namespace sigi {
class SigiDialect;
} // namespace closure

//===- Generated passes ---------------------------------------------------===//

#define GEN_PASS_DEF_CONVERTCLOSURETOLLVM
#include "sigi-mlir/Conversion/ClosurePasses.h.inc"

#define GEN_PASS_DEF_CONVERTSIGITOLLVM
#include "sigi-mlir/Conversion/SigiPasses.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir

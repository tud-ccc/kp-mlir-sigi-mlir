/// Declaration of the passes
///
/// @file

#pragma once

#include "mlir/IR/BuiltinOps.h"
#include "mlir/Pass/Pass.h"

namespace mlir {

// Forward declaration from Dialect.h
template<typename ConcreteDialect>
void registerDialect(DialectRegistry &registry);

namespace LLVM {
class LLVMDialect;
} // namespace LLVM

namespace func {
class FuncDialect;
class FuncOp;
} // namespace func

namespace linalg {
class LinalgDialect;
} // namespace linalg

namespace closure {
class ClosureDialect;
class CallOp;
class BoxOp;
} // namespace closure

namespace arith {
class ArithDialect;
} // namespace arith
namespace scf {
class SCFDialect;
} // namespace scf

namespace sigi {
class SigiDialect;
} // namespace sigi

//===- Generated passes ---------------------------------------------------===//

#define GEN_PASS_DEF_CONVERTCLOSURETOLLVM
#include "sigi-mlir/Conversion/ClosurePasses.h.inc"
#define GEN_PASS_DEF_CONVERTSIGITOLLVM
#include "sigi-mlir/Conversion/SigiPasses.h.inc"

//===----------------------------------------------------------------------===//

} // namespace mlir
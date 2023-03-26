/// Declaration of the Closure passes.
///
/// @file

#pragma once

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir::closure {

std::unique_ptr<Pass> createClosureInlinePass();
std::unique_ptr<Pass> createClosureToFuncPass();
std::unique_ptr<Pass> createClosureDeleteCapturesPass();

} // namespace mlir::closure

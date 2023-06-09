/// Declaration of the Closure passes.
///
/// @file

#pragma once

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir::closure {

std::unique_ptr<Pass> createClosureInlinePass();

} // namespace mlir::closure

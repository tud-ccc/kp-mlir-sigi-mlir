
#pragma once

#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir::sigi {

std::unique_ptr<Pass> createInsertDropChecksPass();

} // namespace mlir::closure

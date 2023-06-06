/// Declaration of the Closure passes.
///
/// @file

#pragma once

#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir::sigi {

bool isSigiLlvmStackType(Type ty);

void populateSigiToLLVMConversionPatterns(
    LLVMTypeConverter &typeConverter,
    RewritePatternSet &patterns);

std::unique_ptr<Pass> createConvertSigiToLLVMPass();

} // namespace mlir::sigi

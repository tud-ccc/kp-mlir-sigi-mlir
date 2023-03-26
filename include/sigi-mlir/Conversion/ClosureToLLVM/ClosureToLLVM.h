/// Declaration of the Closure passes.
///
/// @file

#pragma once

#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

namespace mlir::closure {

void populateClosureToLLVMFinalTypeConversions(
    LLVMTypeConverter &typeConverter);

void populateClosureToLLVMConversionPatterns(
    LLVMTypeConverter &typeConverter,
    RewritePatternSet &patterns);

std::unique_ptr<Pass> createConvertClosureToLLVMPass();

} // namespace mlir::closure

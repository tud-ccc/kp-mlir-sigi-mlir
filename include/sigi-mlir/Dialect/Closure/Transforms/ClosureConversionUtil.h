
#pragma once
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"

namespace mlir {
class TypeConverter;
class LLVMTypeConverter;
} // namespace mlir

namespace mlir::closure {

void populateClosureGenericTypeConversions(TypeConverter &typeConverter);
} // namespace mlir::closure
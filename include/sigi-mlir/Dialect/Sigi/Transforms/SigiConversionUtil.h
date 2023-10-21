
#pragma once
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

namespace mlir {
class TypeConverter;
class LLVMTypeConverter;
} // namespace mlir

namespace mlir::sigi {

void populateSigiGenericTypeConversions(TypeConverter &typeConverter);
} // namespace mlir::sigi

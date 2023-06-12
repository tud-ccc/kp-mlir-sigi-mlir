
#pragma once
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"

namespace mlir {
class TypeConverter;
class LLVMTypeConverter;
class ModuleOp;
} // namespace mlir

namespace mlir::closure {

void populateClosureGenericTypeConversions(TypeConverter &typeConverter);
SmallString<20> getUniqueFunctionName(ModuleOp moduleOp, const char prefix[]);

} // namespace mlir::closure
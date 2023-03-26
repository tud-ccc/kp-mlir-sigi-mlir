
#include "sigi-mlir/Dialect/Closure/Transforms/ClosureConversionUtil.h"

#include "mlir/Transforms/DialectConversion.h"
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"

using namespace mlir;

namespace {

void convertTypeListOrIdentity(
    TypeConverter &converter,
    TypeRange range,
    SmallVectorImpl<Type> &result)
{

    for (auto parmTy : range)
        if (auto conv = converter.convertType(parmTy))
            result.emplace_back(std::move(conv));
        else
            result.emplace_back(std::move(parmTy));
}

} // namespace

void mlir::closure::populateClosureGenericTypeConversions(
    TypeConverter &typeConverter)
{
    // Convert BoxedClosure type to the underlying implementation type.
    typeConverter.addConversion(
        [&](closure::BoxedClosureType type) -> std::optional<Type> {
            auto funcTy = type.getFunctionType();
            SmallVector<Type, 4> convertedArgs;
            SmallVector<Type, 4> convertedResults;
            convertTypeListOrIdentity(
                typeConverter,
                funcTy.getInputs(),
                convertedArgs);
            convertTypeListOrIdentity(
                typeConverter,
                funcTy.getResults(),
                convertedResults);

            return closure::BoxedClosureType::get(
                type.getContext(),
                convertedArgs,
                convertedResults);
        });
}


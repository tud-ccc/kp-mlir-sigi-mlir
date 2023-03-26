#include "llvm/ADT/SmallString.h"
#include "sigi-mlir/Dialect/Closure/Transforms/ClosureConversionUtil.h"

#include "mlir/Transforms/DialectConversion.h"
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"
#include "llvm/ADT/SmallString.h"

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

SmallString<20>
mlir::closure::getUniqueFunctionName(ModuleOp moduleOp, const char prefix[])
{
    // Get a unique global name.
    unsigned stringNumber = 0;
    size_t prefixLen = strlen(prefix);
    assert(20 > 3 + prefixLen); // make sure this is bigger than the prefix
                                // (prefixes are literals)
    SmallString<20> name(prefix);
    do {
        name.truncate(prefixLen);
        name.append(std::to_string(stringNumber++));
    } while (moduleOp.lookupSymbol(name));
    return name;
}

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

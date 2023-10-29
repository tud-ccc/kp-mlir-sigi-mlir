/// Implements the SigiToLLVM pass.
///
/// @file
/// @author     Clément Fournier (clement.fournier@mailbox.tu-dresden.de)

#include "sigi-mlir/Conversion/SigiToLLVM/SigiToLLVM.h"

#include "../PassDetails.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Conversion/ReconcileUnrealizedCasts/ReconcileUnrealizedCasts.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/LLVMIR/FunctionCallUtils.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/ImplicitLocOpBuilder.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/SymbolTable.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

#include <iostream>

using namespace mlir;
using namespace mlir::sigi;

namespace {

//Typed pointer
static LLVM::LLVMPointerType ptrType(Type ty)
{
    return LLVM::LLVMPointerType::get(ty);
}

//Void pointer
static LLVM::LLVMPointerType untypedPtrType(MLIRContext* ctx)
{
    return LLVM::LLVMPointerType::get(ctx, 0);
}

struct ConvertSigiPopToLLVM
        : public ConvertOpToLLVMPattern<sigi::PopOp> {
    using ConvertOpToLLVMPattern<sigi::PopOp>::ConvertOpToLLVMPattern;

    LogicalResult matchAndRewrite(
        sigi::PopOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        std::cout << "Pop Pop" << std::endl;
        return LLVM::detail::oneToOneRewrite(
            op,
            LLVM::ReturnOp::getOperationName(),
            adaptor.getOperands(),
            op->getAttrs(),
            *getTypeConverter(),
            rewriter);
    }
};

struct ConvertSigiToLLVMPass
        : public impl::ConvertSigiToLLVMBase<ConvertSigiToLLVMPass> {
    void runOnOperation() final;
};

} // namespace

void mlir::sigi::populateSigiToLLVMFinalTypeConversions(
    LLVMTypeConverter &typeConverter)
{

    // Convert sigistack type to the underlying llvmPtr<struct<sigi_stack_t>>
    typeConverter.addConversion(
        [&](sigi::SigiStackType type) -> Type {
            // turns !sigi.stack
            // to !llvm.ptr<struct<"sigi_stack_t">>>

            /*
            TypeConverter::SignatureConversion conversion(
                type.getFunctionType().getInputs().size());
            auto funcTy = type.getFunctionType();
            auto llvmTy = typeConverter.convertFunctionSignature(
                funcTy,
                false,
                conversion);
*/
            //Right now just build the llvm type and emit that
            
            std::cout << "Sigi stack to llvm type..." << std::endl;
            //NOTE: I Hope this generates the llvm.ptr<struct<"sigi_stack_t">> type.
            auto llvmStackTy = LLVM::LLVMStructType::getIdentified(
                &typeConverter.getContext(), "sigi_stack_t");
            auto llvmStackPtrTy = LLVM::LLVMPointerType::get(llvmStackTy);
            return llvmStackPtrTy;
        });
        
}

void mlir::sigi::populateSigiToLLVMConversionPatterns(
    LLVMTypeConverter &typeConverter,
    RewritePatternSet &patterns)
{

    patterns.add<
        ConvertSigiPopToLLVM
        //ConvertSigiCallToLLVM,
        //ConvertSigiBoxToLLVM,
        //ConvertSigiReturnToLLVM
    >(typeConverter);
}

/***
 * Conversion Target
 ***/
void ConvertSigiToLLVMPass::runOnOperation()
{

    LLVMTypeConverter converter(&getContext());

    mlir::sigi::populateSigiToLLVMFinalTypeConversions(converter);
    //TODO: What is this?
    const auto addUnrealizedCast =
        [](OpBuilder &builder, Type type, ValueRange inputs, Location loc) {
            return builder.create<UnrealizedConversionCastOp>(loc, type, inputs)
                .getResult(0);
        };
    converter.addSourceMaterialization(addUnrealizedCast);
    converter.addTargetMaterialization(addUnrealizedCast);

    ConversionTarget target(getContext());
    RewritePatternSet patterns(&getContext());

    // Convert sigi dialect operations.
    populateSigiToLLVMConversionPatterns(converter, patterns);

    // Remove unrealized casts wherever possible.
    populateReconcileUnrealizedCastsPatterns(patterns);

    //target.addIllegalDialect<sigi::SigiDialect>();
    //TODO: What is this?
    target.markUnknownOpDynamicallyLegal([](Operation*) { return true; });

    if (failed(applyPartialConversion(
            getOperation(),
            target,
            std::move(patterns))))
        signalPassFailure();
        
}

std::unique_ptr<Pass> mlir::sigi::createConvertSigiToLLVMPass()
{
    return std::make_unique<ConvertSigiToLLVMPass>();
}

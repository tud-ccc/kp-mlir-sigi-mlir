/// Implements the SigiToLLVM pass.
///
/// @file
/// @author     Clément Fournier (clement.fournier@mailbox.tu-dresden.de)

#include "sigi-mlir/Conversion/SigiToLLVM/SigiToLLVM.h"

#include "../PassDetails.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Conversion/ReconcileUnrealizedCasts/ReconcileUnrealizedCasts.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/LLVMIR/FunctionCallUtils.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/ImplicitLocOpBuilder.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/SymbolTable.h"
#include "sigi-mlir/Conversion/ClosureToLLVM/ClosureToLLVM.h"
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"
#include "sigi-mlir/Dialect/Closure/Transforms/ClosureConversionUtil.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

#include <mlir/Dialect/LLVMIR/LLVMTypes.h>

/*

typedef struct sigi_stack_impl* sigi_stack_t;

void sigi_init_stack(sigi_stack_t* stack);
void sigi_free_stack(sigi_stack_t* stack);

void sigi_push_i32(sigi_stack_t* stack, int32_t value);
void sigi_push_bool(sigi_stack_t* stack, bool value);
void sigi_push_closure(sigi_stack_t* stack, void* value);

void* sigi_pop_closure(sigi_stack_t* stack);
int32_t sigi_pop_i32(sigi_stack_t* stack);
bool sigi_pop_bool(sigi_stack_t* stack);

// This is the implementation of the pp method.
void sigi_print_stack_top_ln(sigi_stack_t*);

*/

using namespace mlir;
using namespace mlir::sigi;

namespace {

static LLVM::LLVMPointerType ptrType(Type ty)
{
    return LLVM::LLVMPointerType::get(ty.getContext());
}

static Type llvmStackType(MLIRContext* ctx)
{
    auto stackT = LLVM::LLVMStructType::getOpaque("sigi_stack_t", ctx);
    return ptrType(stackT);
}

static bool isSigiClosureType(Type ty)
{

    auto stackTy = sigi::StackType::get(ty.getContext());
    if (auto boxTy = dyn_cast<closure::BoxedClosureType>(ty)) {
        auto funTy = boxTy.getFunctionType();
        return funTy.getInputs() == llvm::ArrayRef<Type>{stackTy}
               && funTy.getResults() == llvm::ArrayRef<Type>{stackTy};
    }
    return false;
}

LogicalResult getOrCreatePushFunc(
    ModuleOp moduleOp,
    Type paramSrcTy,
    Type paramLlvmTy,
    LLVM::LLVMFuncOp* resultFunc)
{
    /*
    void sigi_push_i32(sigi_stack_t* stack, int32_t value);
    void sigi_push_bool(sigi_stack_t* stack, bool value);
    void sigi_push_closure(sigi_stack_t* stack, void* value);
    */
    auto stackT = llvmStackType(paramSrcTy.getContext());
    auto lookup = [=](StringRef name) {
        *resultFunc = LLVM::lookupOrCreateFn(
            moduleOp,
            name,
            {stackT, paramLlvmTy},
            LLVM::LLVMVoidType::get(paramSrcTy.getContext()));
        return success();
    };
    if (paramSrcTy.isInteger(32)) return lookup("sigi_push_i32");
    if (paramSrcTy.isInteger(1)) return lookup("sigi_push_bool");
    if (mlir::isa<LLVM::LLVMPointerType>(paramSrcTy))
        return lookup("sigi_push_closure");
    if (isSigiClosureType(paramSrcTy)) return lookup("sigi_push_closure");
    return failure();
}

LogicalResult getOrCreatePopFunc(
    ModuleOp moduleOp,
    Type resultSrcTy,
    Type resultLlvmTy,
    LLVM::LLVMFuncOp* resultFunc)
{
    /*
    void* sigi_pop_closure(sigi_stack_t* stack);
    int32_t sigi_pop_i32(sigi_stack_t* stack);
    bool sigi_pop_bool(sigi_stack_t* stack);
    */
    auto stackT = llvmStackType(resultSrcTy.getContext());
    auto lookup = [=](StringRef name) {
        *resultFunc =
            LLVM::lookupOrCreateFn(moduleOp, name, {stackT}, resultLlvmTy);
        return success();
    };
    if (resultSrcTy.isInteger(32)) return lookup("sigi_pop_i32");
    if (resultSrcTy.isInteger(1)) return lookup("sigi_pop_bool");
    if (mlir::isa<LLVM::LLVMPointerType>(resultSrcTy))
        return lookup("sigi_push_closure");
    if (isSigiClosureType(resultSrcTy)) return lookup("sigi_pop_closure");

    return failure();
}

struct ConvertSigiPushToLLVM : public ConvertOpToLLVMPattern<sigi::PushOp> {
    using ConvertOpToLLVMPattern<sigi::PushOp>::ConvertOpToLLVMPattern;

    explicit ConvertSigiPushToLLVM(
        LLVMTypeConverter &typeConverter,
        PatternBenefit benefit = 1)
            : ConvertOpToLLVMPattern(typeConverter, benefit)
    {
        setHasBoundedRewriteRecursion();
    }

    LogicalResult matchAndRewrite(
        sigi::PushOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter0) const override
    {
        auto loc = op.getLoc();
        ImplicitLocOpBuilder rewriter(loc, rewriter0);

        auto moduleOp = op->getParentOfType<ModuleOp>();

        LLVM::LLVMFuncOp pushFunc;
        if (failed(getOrCreatePushFunc(
                moduleOp,
                op.getValueType(),
                getTypeConverter()->convertType(op.getValueType()),
                &pushFunc)))
            return rewriter0.notifyMatchFailure(loc, [&](Diagnostic &diag) {
                diag << "Unknown type for sigi.push: " << op.getValueType();
            });

        rewriter.create<LLVM::CallOp>(
            pushFunc,
            ValueRange{adaptor.getInStack(), adaptor.getValue()});
        rewriter0.replaceOp(op, {adaptor.getInStack()});

        return success();
    }
};

struct ConvertSigiPopToLLVM : public ConvertOpToLLVMPattern<sigi::PopOp> {

    explicit ConvertSigiPopToLLVM(
        LLVMTypeConverter &typeConverter,
        PatternBenefit benefit = 1)
            : ConvertOpToLLVMPattern(typeConverter, benefit)
    {
        setHasBoundedRewriteRecursion();
    }

    LogicalResult matchAndRewrite(
        sigi::PopOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter0) const override
    {
        auto loc = op.getLoc();
        ImplicitLocOpBuilder rewriter(loc, rewriter0);

        auto moduleOp = op->getParentOfType<ModuleOp>();

        LLVM::LLVMFuncOp popFunc;
        if (failed(getOrCreatePopFunc(
                moduleOp,
                op.getValueType(),
                getTypeConverter()->convertType(op.getValueType()),
                &popFunc)))
            return rewriter0.notifyMatchFailure(loc, [&](Diagnostic &diag) {
                diag << "Unknown type for sigi.pop: " << op.getValueType();
            });

        auto newOp =
            rewriter.create<LLVM::CallOp>(popFunc, adaptor.getInStack());
        rewriter0.replaceOp(op, {adaptor.getInStack(), newOp.getResult()});

        return success();
    }
};

struct ConvertSigiFrontendFwdDecl
        : public ConvertOpToLLVMPattern<LLVM::LLVMFuncOp> {

    explicit ConvertSigiFrontendFwdDecl(
        LLVMTypeConverter &typeConverter,
        PatternBenefit benefit = 1)
            : ConvertOpToLLVMPattern(typeConverter, benefit)
    {
        setHasBoundedRewriteRecursion();
    }

    LogicalResult matchAndRewrite(
        LLVM::LLVMFuncOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter0) const override
    {
        auto loc = op.getLoc();
        ImplicitLocOpBuilder rewriter(loc, rewriter0);
        if (op.isExternal() && op.getName() == "sigi::pp") {
            rewriter0.startOpModification(op);
            if (failed(op.replaceAllSymbolUses(
                    rewriter0.getStringAttr("sigi_builtin__pp"),
                    op->getParentOfType<ModuleOp>())))
                rewriter0.cancelOpModification(op);
            else {
                op.setName("sigi_builtin__pp");
                op->removeAttr("sigi.builtinfunc");
                rewriter0.finalizeOpModification(op);
                return success();
            }
        }
        return failure();
    }
};

/// Find the function annotated with sigi.main and generate
/// a wrapper function that initializes the runtime and calls
/// the main program.
struct ConvertSigiMainFuncToLLVM
        : public ConvertOpToLLVMPattern<LLVM::LLVMFuncOp> {

    explicit ConvertSigiMainFuncToLLVM(
        LLVMTypeConverter &typeConverter,
        PatternBenefit benefit = 1)
            : ConvertOpToLLVMPattern(typeConverter, benefit)
    {
        setHasBoundedRewriteRecursion();
    }

    LogicalResult matchAndRewrite(
        LLVM::LLVMFuncOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter0) const override
    {
        auto loc = op.getLoc();
        ImplicitLocOpBuilder rewriter(loc, rewriter0);
        if (!op->hasAttr("sigi.main"))
            return rewriter0.notifyMatchFailure(
                loc,
                "Only targets functions with sigi.main attr");

        auto moduleOp = op->getParentOfType<ModuleOp>();

        // clang-format off
/*
    llvm.func @malloc(%a: i64) -> !llvm.ptr<i8>
    llvm.func @free(%a: !llvm.ptr) -> !llvm.void
    llvm.func @sigi_init_stack(%a: !llvm.ptr<i8>) -> !llvm.void
    llvm.func @sigi_free_stack(%a: !llvm.ptr<i8>) -> !llvm.void
    
    llvm.func @main() -> () {
        %arg0 = arith.constant 128: i64 
        %stackAlloc = llvm.call @malloc(%arg0): (i64) -> !llvm.ptr<i8>
        llvm.call @sigi_init_stack(%stackAlloc): (!llvm.ptr) -> !llvm.void

        %llvmStack = llvm.bitcast %stackAlloc: !llvm.ptr<i8> to !llvm.ptr<struct<"sigi_stack_t", opaque>>
        %stack = func.call @__main__(%llvmStack): (!llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>>
        llvm.call @sigi_free_stack(%stackAlloc): (!llvm.ptr<i8>) -> !llvm.void
        llvm.call @free(%stackAlloc): (!llvm.ptr<i8>) -> !llvm.void
        llvm.return
    }
*/
        // clang-format on
        auto indexTy = rewriter.getI64Type();
        auto voidTy = LLVM::LLVMVoidType::get(getContext());
        auto mallocDef = LLVM::lookupOrCreateMallocFn(moduleOp, indexTy);
        auto freeDef = LLVM::lookupOrCreateFreeFn(moduleOp);
        auto sigiInitStackDef = LLVM::lookupOrCreateFn(
            moduleOp,
            "sigi_init_stack",
            mallocDef.getResultTypes(),
            voidTy);
        auto sigiDestroyStack = LLVM::lookupOrCreateFn(
            moduleOp,
            "sigi_free_stack",
            mallocDef.getResultTypes(),
            voidTy);

        rewriter.setInsertionPointToEnd(moduleOp.getBody());

        auto newMainFunc = rewriter.create<LLVM::LLVMFuncOp>(
            "main",
            LLVM::LLVMFunctionType::get(voidTy, {}));

        auto* block = newMainFunc.addEntryBlock(rewriter);
        rewriter.setInsertionPointToStart(block);
        // this is an alloc that should be at least as large as a pointer
        auto allocSize = rewriter.create<LLVM::ConstantOp>(indexTy, 128);
        auto mallocCall =
            rewriter.create<LLVM::CallOp>(mallocDef, allocSize.getResult());
        rewriter.create<LLVM::CallOp>(sigiInitStackDef, mallocCall.getResult());

        auto castToStrongLlvmTy = rewriter.create<LLVM::BitcastOp>(
            llvmStackType(getContext()),
            mallocCall.getResult());

        // this is the call to the user defined main func, result is ignored
        rewriter.create<LLVM::CallOp>(op, castToStrongLlvmTy.getResult());

        // finally free stack
        rewriter.create<LLVM::CallOp>(sigiDestroyStack, mallocCall.getResult());
        rewriter.create<LLVM::CallOp>(freeDef, mallocCall.getResult());

        rewriter.create<LLVM::ReturnOp>(ValueRange{});

        rewriter0.modifyOpInPlace(op, [&]() { op->removeAttr("sigi.main"); });
        return success();
    }
};

struct ConvertSigiToLLVMPass
        : public mlir::impl::ConvertSigiToLLVMBase<ConvertSigiToLLVMPass> {
    void runOnOperation() final;
};

} // namespace

void mlir::sigi::populateSigiToLLVMConversionPatterns(
    LLVMTypeConverter &typeConverter,
    RewritePatternSet &patterns)
{
    patterns.add<
        ConvertSigiPushToLLVM,
        ConvertSigiPopToLLVM,
        ConvertSigiMainFuncToLLVM,
        ConvertSigiFrontendFwdDecl>(typeConverter);
}
bool mlir::sigi::isSigiLlvmStackType(Type ty)
{
    return llvmStackType(ty.getContext()) == ty;
}

/***
 * Conversion Target
 ***/
void ConvertSigiToLLVMPass::runOnOperation()
{
    // note: this pass also executes closure -> LLVM pass, because otherwise we
    // need the llvm.call ops to use only LLVM compatible ops. Better
    // independence and interoperability between the dialects could be achieved
    // by using an intermediate dialect `sigic` which models the sigi runtime
    // 1:1, but doesn't restrict types to only LLVM types.

    LLVMTypeConverter converter(&getContext());

    // Convert BoxedSigi type to the underlying implementation type.
    converter.addConversion([](sigi::StackType type) -> Type {
        return llvmStackType(type.getContext());
    });

    mlir::closure::populateClosureGenericTypeConversions(converter);
    mlir::closure::populateClosureToLLVMFinalTypeConversions(converter);
    const auto addUnrealizedCast =
        [](OpBuilder &builder, Type type, ValueRange inputs, Location loc) {
            return builder.create<UnrealizedConversionCastOp>(loc, type, inputs)
                .getResult(0);
        };
    converter.addSourceMaterialization(addUnrealizedCast);
    converter.addTargetMaterialization(addUnrealizedCast);

    ConversionTarget target(getContext());
    RewritePatternSet patterns(&getContext());

    // Convert function signatures.

    populateFunctionOpInterfaceTypeConversionPattern<func::FuncOp>(
        patterns,
        converter);
    populateCallOpTypeConversionPattern(patterns, converter);
    populateReturnOpTypeConversionPattern(patterns, converter);

    // make sure our rewrite pattern is applied
    target.addDynamicallyLegalOp<LLVM::LLVMFuncOp>([&](LLVM::LLVMFuncOp op) {
        return !op->hasAttr("sigi.main") && !op->hasAttr("sigi.builtinfunc")
               && converter.isLegal(&op.getBody());
    });

    // Add patterns to convert everything to LLVM
    closure::populateClosureToLLVMConversionPatterns(converter, patterns);
    cf::populateControlFlowToLLVMConversionPatterns(converter, patterns);
    sigi::populateSigiToLLVMConversionPatterns(converter, patterns);
    populateFuncToLLVMConversionPatterns(converter, patterns);

    // Remove unrealized casts wherever possible.
    // populateReconcileUnrealizedCastsPatterns(patterns);

    target.addIllegalDialect<
        sigi::SigiDialect,
        closure::ClosureDialect,
        func::FuncDialect,
        cf::ControlFlowDialect>();
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

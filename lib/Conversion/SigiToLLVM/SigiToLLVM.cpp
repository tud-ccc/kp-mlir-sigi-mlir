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

using namespace mlir;
using namespace mlir::sigi;

namespace {
/*
static LLVM::LLVMPointerType ptrType(Type ty)
{
    return LLVM::LLVMPointerType::get(ty);
}

static LLVM::LLVMPointerType untypedPtrType(MLIRContext* ctx)
{
    return LLVM::LLVMPointerType::get(ctx, 0);
}

static LLVM::LLVMFunctionType
convertFunType(LLVMTypeConverter &converter, FunctionType funTy)
{
    TypeConverter::SignatureConversion conversion(funTy.getInputs().size());
    Type res = converter.convertFunctionSignature(funTy, false, conversion);
    return res.cast<LLVM::LLVMFunctionType>();
}

static LLVM::LLVMFunctionType
insertSigiParameter(LLVM::LLVMFunctionType funTy)
{
    SmallVector<Type> argTypes;
    argTypes.reserve(funTy.getParams().size() + 1);
    argTypes.push_back(untypedPtrType(funTy.getContext()));
    for (auto ty : funTy.getParams()) argTypes.push_back(ty);

    return LLVM::LLVMFunctionType::get(
        funTy.getContext(),
        funTy.getReturnType(),
        argTypes,
        funTy.isVarArg());
}

struct ConvertSigiBoxToLLVM : public ConvertOpToLLVMPattern<sigi::BoxOp> {

    explicit ConvertSigiBoxToLLVM(
        LLVMTypeConverter &typeConverter,
        PatternBenefit benefit = 1)
            : ConvertOpToLLVMPattern(typeConverter, benefit)
    {
        // sigis may be nested
        setHasBoundedRewriteRecursion();
    }

    static SmallString<20>
    getUniqueFunctionName(ModuleOp moduleOp, const char prefix[])
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

    static Value getSizeOfType(Type ty, ImplicitLocOpBuilder &rewriter)
    {
        //  https://stackoverflow.com/questions/14608250/how-can-i-find-the-size-of-a-type
        auto fakeArray = rewriter.create<LLVM::NullOp>(ptrType(ty));

        auto gep = rewriter.create<LLVM::GEPOp>(
            ptrType(ty),
            fakeArray.getResult(),
            ArrayRef<LLVM::GEPArg>{1});
        auto size =
            rewriter.create<LLVM::PtrToIntOp>(rewriter.getI64Type(), gep);
        return size.getResult();
    }

    LogicalResult matchAndRewrite(
        sigi::BoxOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter0) const override
    {

        auto loc = op.getLoc();
        ImplicitLocOpBuilder rewriter(loc, rewriter0);

        auto moduleOp = op->getParentOfType<ModuleOp>();
        auto funTy = convertFunType(*getTypeConverter(), op.getFunctionType());
        auto wrapperTy = insertSigiParameter(funTy);
        auto workerTy = convertFunType(
            *getTypeConverter(),
            FunctionType::get(
                getContext(),
                op.getRegion().front().getArgumentTypes(),
                wrapperTy.getReturnTypes()));

        LLVM::LLVMFuncOp workerFun;
        {
            // outline the body of the sigi into a worker function

            ConversionPatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPointToStart(moduleOp.getBody());
            workerFun = rewriter.create<LLVM::LLVMFuncOp>(
                getUniqueFunctionName(moduleOp, "sigi_worker_"),
                workerTy,
                LLVM::Linkage::Private);
            Block* entry = workerFun.addEntryBlock();

            rewriter0.cloneRegionBefore(op.getBody(), entry);
            workerFun.getFunctionBody()
                .getBlocks()
                .pop_back(); // remove that fake block

            auto conversionResult = rewriter0.convertRegionTypes(
                &workerFun.getFunctionBody(),
                *getTypeConverter());
            if (failed(conversionResult))
                return rewriter0.notifyMatchFailure(loc, [](auto &diag) {
                    diag << "cannot convert block signature";
                });
        }

        SmallVector<Type> captureArgTypes(adaptor.getCaptureArgs().getTypes());

        // type of the struct that holds the captured parameters
        auto captureParamStructTy =
            LLVM::LLVMStructType::getLiteral(getContext(), captureArgTypes);

        // type of the struct that holds the entire sigi (fptr + capture
        // args)
        auto fullSigiTy = LLVM::LLVMStructType::getLiteral(
            getContext(),
            {ptrType(wrapperTy), captureParamStructTy});

        // create a wrapper function, that has the type of the erased
        // function + 1 initial parameter for the sigi itself
        LLVM::LLVMFuncOp wrapperFun;
        {
            ConversionPatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPointAfter(workerFun.getOperation());
            wrapperFun = rewriter.create<LLVM::LLVMFuncOp>(
                getUniqueFunctionName(moduleOp, "sigi_wrapper_"),
                wrapperTy,
                LLVM::Linkage::Private);
            Block* entry = wrapperFun.addEntryBlock();
            rewriter.setInsertionPointToStart(entry);

            // clang-format off
            // %typedPtr = llvm.bitcast %sigi: !llvm.ptr to !llvm.ptr<fullSigiTy>
            // clang-format on
            auto typedPtr = rewriter.create<LLVM::BitcastOp>(
                ptrType(fullSigiTy),
                entry->getArgument(0));

            // clang-format off
            // %argsPtr = llvm.getelementptr %typedPtr[0, 1]: (!llvm.ptr<fullSigiTy>) -> !llvm.ptr<captureParamStructTy>
            // clang-format on
            auto argsPtr = rewriter.create<LLVM::GEPOp>(
                ptrType(captureParamStructTy),
                typedPtr,
                ArrayRef<LLVM::GEPArg>{0, 1});

            // clang-format off
            // %loadedArgs = llvm.load %argsPtr: !llvm.ptr<captureParamStructTy>
            // clang-format on
            auto loadedArgs = rewriter.create<LLVM::LoadOp>(loc, argsPtr);

            // unpack each struct field
            SmallVector<Value> workerArgs;
            workerArgs.reserve(workerFun.getArguments().size());

            int64_t i = 0, numCaptureArgs = adaptor.getCaptureArgs().size();
            for (; i < numCaptureArgs; i++) {
                auto field = rewriter.create<LLVM::ExtractValueOp>(
                    loadedArgs,
                    ArrayRef<int64_t>{i});
                workerArgs.emplace_back(field.getResult());
            }
            i = 0;
            for (auto funArg : entry->getArguments()) {
                if (i++ == 0) continue; // skip the ptr arg
                workerArgs.emplace_back(funArg);
            }

            // finally call the worker
            auto result = rewriter.create<LLVM::CallOp>(workerFun, workerArgs);
            // and return
            rewriter.create<LLVM::ReturnOp>(result.getResults());
        }

        // now for replacing the sigi.box

        // first we allocate memory for it
        Value sizeOfSigi = getSizeOfType(fullSigiTy, rewriter);
        auto mallocFun =
            LLVM::lookupOrCreateMallocFn(moduleOp, sizeOfSigi.getType());
        auto allocForSigi =
            rewriter.create<LLVM::CallOp>(mallocFun, sizeOfSigi);

        // then we create an instance and initialize it
        auto sigiInstance = rewriter.create<LLVM::UndefOp>(fullSigiTy);
        auto wrapperAddress = rewriter.create<LLVM::AddressOfOp>(wrapperFun);
        Value sigiBeingBuilt = rewriter.create<LLVM::InsertValueOp>(
            sigiInstance,
            wrapperAddress,
            ArrayRef<int64_t>{0});
        // initialize all captured fields
        int64_t i = 0;
        for (auto captArg : adaptor.getCaptureArgs()) {
            sigiBeingBuilt = rewriter.create<LLVM::InsertValueOp>(
                sigiBeingBuilt,
                captArg,
                ArrayRef<int64_t>{1, i});
            i++;
        }

        // that is the type needed to store
        auto castPtrToStrongType = rewriter.create<LLVM::BitcastOp>(
            ptrType(fullSigiTy),
            allocForSigi.getResults());

        // finally store it into the alloc
        rewriter.create<LLVM::StoreOp>(
            sigiBeingBuilt,
            castPtrToStrongType.getResult());

        // that is the LLVM type that the CallOp expects
        auto castPtrToErasedTy = rewriter.create<LLVM::BitcastOp>(
            getTypeConverter()->convertType(op.getSigiType()),
            allocForSigi.getResults());

        rewriter0.replaceOp(op, {castPtrToErasedTy.getResult()});

        return success();
    }
};

struct ConvertSigiReturnToLLVM
        : public ConvertOpToLLVMPattern<sigi::ReturnOp> {
    using ConvertOpToLLVMPattern<sigi::ReturnOp>::ConvertOpToLLVMPattern;

    LogicalResult matchAndRewrite(
        sigi::ReturnOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        return LLVM::detail::oneToOneRewrite(
            op,
            LLVM::ReturnOp::getOperationName(),
            adaptor.getOperands(),
            op->getAttrs(),
            *getTypeConverter(),
            rewriter);
    }
};

struct ConvertSigiCallToLLVM
        : public ConvertOpToLLVMPattern<sigi::CallOp> {
    using ConvertOpToLLVMPattern<sigi::CallOp>::ConvertOpToLLVMPattern;

    LogicalResult matchAndRewrite(
        sigi::CallOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter0) const override
    {
        auto loc = op.getLoc();
        ImplicitLocOpBuilder rewriter(loc, rewriter0);

        auto llvmFunPtrTy =
            getTypeConverter()->convertType(op.getSigiType());

        // Given a strongly typed ptr to the sigi type,
        auto callee = adaptor.getCallee();

        if (callee.getType() != llvmFunPtrTy)
            return rewriter0.notifyMatchFailure(
                callee.getLoc(),
                [&](Diagnostic &diag) {
                    diag << "Expected callee " << callee
                         << " to have pointer type " << llvmFunPtrTy
                         << " but got " << callee.getType() << ".";
                });

        // Load the actual wrapper function pointer.
        // clang-format off
        // %funPtr = llvm.load %castCallee: !llvm.ptr<llvmFuncTy>
        // clang-format on
        auto funPtr = rewriter.create<LLVM::LoadOp>(callee);

        // the worker expects an untyped !llvm.ptr that points to itself.
        auto erasedCalleePtr = rewriter.create<LLVM::BitcastOp>(
            untypedPtrType(getContext()),
            callee);

        // prepare call arguments
        SmallVector<Value> callArgs;
        callArgs.reserve(adaptor.getCalleeOperands().size() + 2);
        callArgs.push_back(funPtr.getResult()); // first the callee fun
        callArgs.push_back(erasedCalleePtr);    // this is the sigi ptr
        // then all other func args
        for (auto arg : adaptor.getCalleeOperands()) callArgs.push_back(arg);

        SmallVector<Type> llvmResultTypes;
        if (failed(getTypeConverter()->convertTypes(
                op.getResults().getTypes(),
                llvmResultTypes)))
            return failure();

        // clang-format off
        // %result = llvm.call %funPtr(%callee, %calleeArgs): (!llvm.ptr, argTypes...) -> resType
        // clang-format on
        rewriter0.replaceOpWithNewOp<LLVM::CallOp>(
            op.getOperation(),
            llvmResultTypes,
            ValueRange(callArgs));

        return success();
    }
};
*/
struct ConvertSigiToLLVMPass
        : public impl::ConvertSigiToLLVMBase<ConvertSigiToLLVMPass> {
    void runOnOperation() final;
};

} // namespace

void mlir::sigi::populateSigiToLLVMFinalTypeConversions(
    LLVMTypeConverter &typeConverter)
{
/*
    // Convert BoxedSigi type to the underlying implementation type.
    typeConverter.addConversion(
        [&](sigi::BoxedSigiType type) -> std::optional<Type> {
            // turns (a1, .., an) -> b
            // to !llvm.ptr<ptr<func<b (ptr, a1, ..., an)>>>
            TypeConverter::SignatureConversion conversion(
                type.getFunctionType().getInputs().size());
            auto funcTy = type.getFunctionType();
            auto llvmTy = typeConverter.convertFunctionSignature(
                funcTy,
                false,
                conversion);

            if (llvmTy)
                // means the function type is convertible to LLVM
                return ptrType(ptrType(insertSigiParameter(
                    llvmTy.cast<LLVM::LLVMFunctionType>())));

            return std::nullopt;
        });
        */
}

void mlir::sigi::populateSigiToLLVMConversionPatterns(
    LLVMTypeConverter &typeConverter,
    RewritePatternSet &patterns)
{
/*
    patterns.add<
        ConvertSigiCallToLLVM,
        ConvertSigiBoxToLLVM,
        ConvertSigiReturnToLLVM>(typeConverter);
        }
        */
}

/***
 * Conversion Target
 ***/
void ConvertSigiToLLVMPass::runOnOperation()
{
/*
    LLVMTypeConverter converter(&getContext());

    mlir::sigi::populateSigiToLLVMFinalTypeConversions(converter);
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

    target.addIllegalDialect<sigi::SigiDialect>();
    target.markUnknownOpDynamicallyLegal([](Operation*) { return true; });

    if (failed(applyPartialConversion(
            getOperation(),
            target,
            std::move(patterns))))
        signalPassFailure();
        */
}

std::unique_ptr<Pass> mlir::sigi::createConvertSigiToLLVMPass()
{
    return std::make_unique<ConvertSigiToLLVMPass>();
}

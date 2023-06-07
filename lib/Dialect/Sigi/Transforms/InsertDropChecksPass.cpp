
#include "sigi-mlir/Dialect/Closure/IR/ClosureOps.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Transforms/DialectConversion.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiOps.h"

using namespace mlir;
namespace {


struct SigiInsertDropChecksPass
        : public mlir::impl::ConvertSigiToLLVMBase<SigiInsertDropChecksPass> {
    void runOnOperation() final;
};


struct InsertDropChecksInSigiFunction
        : public OpConversionPattern<func::FuncOp> {

    using OpConversionPattern<func::FuncOp>::OpConversionPattern;

    LogicalResult matchAndRewrite(
        func::FuncOp op,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter0) const override
    {
        auto loc = op.getLoc();
        ImplicitLocOpBuilder rewriter(loc, rewriter0);

        auto funTy = op.getFunctionType();
        auto sigiStackTy = sigi::SigiStackType::get(getContext());
        if (funTy == FunctionType::get(getContext(), {sigiStackTy}, {sigiStackTy})) {
            // this looks like a sigi function
            auto body = op.getBody();



        }
        return failure();
    }
};


void populateInsertDropChecksPatterns(RewritePatternSet &patterns) {

    patterns.add<InsertDropChecksInSigiFunction>();
}

void SigiInsertDropChecksPass::runOnOperation()
{
    ConversionTarget target(getContext());
    RewritePatternSet patterns(&getContext());

    populateInsertDropChecksPatterns(patterns);

    target.markUnknownOpDynamicallyLegal([](Operation*) { return true; });

    if (failed(applyPartialConversion(
            getOperation(),
            target,
            std::move(patterns))))
        signalPassFailure();
}

} // namespace

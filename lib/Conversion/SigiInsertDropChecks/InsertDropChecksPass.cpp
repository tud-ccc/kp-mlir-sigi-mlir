
#include "../PassDetails.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/ImplicitLocOpBuilder.h"
#include "sigi-mlir/Conversion/SigiInsertDropChecks/SigiInsertDropChecks.h"
#include "sigi-mlir/Dialect/Closure/IR/ClosureOps.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiOps.h"

using namespace mlir;
namespace {

struct SigiInsertDropChecksPass : public mlir::impl::SigiInsertDropChecksBase<
                                      SigiInsertDropChecksPass> {
    void runOnOperation() final;
};

static bool closureNeedsDrop(Value closureVal)
{
    return !llvm::all_of(
        closureVal.getUses(),
        [](OpOperand &use) { return dyn_cast<sigi::PushOp>(use.getOwner()); });
}

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
        auto sigiStackTy = sigi::StackType::get(getContext());
        auto sigiFunTy =
            FunctionType::get(getContext(), {sigiStackTy}, {sigiStackTy});
        if (funTy == sigiFunTy) {
            // this looks like a sigi function

            // The following is not control-flow resilient...
            // It assumes the frontend emits straight-line code.
            Region &body = op.getBody();

            // accumulate the closures in the body that need a drop at the end
            // of the body
            SmallVector<Value> closuresInBody;
            SmallVector<func::ReturnOp> funcTerminators;
            body.walk([&closuresInBody, &funcTerminators](Operation* op) {
                Value checkVal;
                if (auto box = dyn_cast<closure::BoxOp>(op)) {
                    checkVal = box.getResult();
                } else if (auto pop = dyn_cast<sigi::PopOp>(op)) {
                    if (pop.getValueType().isa<closure::BoxedClosureType>())
                        checkVal = pop.getValue();
                }
                if (checkVal && closureNeedsDrop(checkVal))
                    closuresInBody.emplace_back(checkVal);

                if (auto ret = dyn_cast<func::ReturnOp>(op))
                    funcTerminators.emplace_back(ret);
            });

            if (!closuresInBody.empty()) {
                rewriter0.startRootUpdate(op);

                for (auto ret : funcTerminators) {
                    ConversionPatternRewriter::InsertionGuard guard(rewriter);
                    rewriter.setInsertionPoint(ret);
                    for (auto closure : closuresInBody)
                        rewriter.create<closure::DropOp>(closure);
                }
                rewriter0.finalizeRootUpdate(op);
                return success();
            }
        }
        return failure();
    }
};

void populateInsertDropChecksPatterns(RewritePatternSet &patterns)
{

    patterns.add<InsertDropChecksInSigiFunction>(patterns.getContext());
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

std::unique_ptr<Pass> mlir::sigi::createInsertDropChecksPass()
{
    return std::make_unique<SigiInsertDropChecksPass>();
}
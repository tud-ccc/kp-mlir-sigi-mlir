
#include "../PassDetails.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/ImplicitLocOpBuilder.h"
#include "mlir/IR/Visitors.h"
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
    bool anyUse = false;
    for (OpOperand &use : closureVal.getUses()) {
        anyUse = true;
        if (dyn_cast<closure::DropOp>(use.getOwner()))
            return false; // already dropped.
        if (!dyn_cast<sigi::PushOp>(use.getOwner()))
            return true; // some usage is disallowed
    }
    return !anyUse; // only check if there are no usages.
}

void SigiInsertDropChecksPass::runOnOperation()
{
    // todo make that generic over any functionopinterface
    func::FuncOp op = getOperation();
    ConversionPatternRewriter rewriter0(&getContext());
    auto loc = op.getLoc();
    ImplicitLocOpBuilder rewriter(loc, rewriter0);

    auto funTy = op.getFunctionType();
    auto sigiStackTy = sigi::StackType::get(&getContext());
    auto sigiFunTy =
        FunctionType::get(&getContext(), {sigiStackTy}, {sigiStackTy});
    if (funTy == sigiFunTy) {
        // this looks like a sigi function

        // The following is not control-flow resilient...
        // It assumes the frontend emits straight-line code.
        Region &body = op.getBody();

        // accumulate the closures in the body that need a drop at the end
        // of the body
        SmallVector<Value> closuresInBody;
        SmallVector<func::ReturnOp> funcTerminators;
        for (Block &block : body.getBlocks()) {
            for (Operation &op : block.getOperations()) {
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
            }
        }

        if (!closuresInBody.empty()) {
            rewriter0.startRootUpdate(op);

            for (auto ret : funcTerminators) {
                ConversionPatternRewriter::InsertionGuard guard(rewriter);
                rewriter.setInsertionPoint(ret);
                for (auto closure : closuresInBody)
                    rewriter.create<closure::DropOp>(closure);
            }
            rewriter0.finalizeRootUpdate(op);
        }
    }
}

} // namespace

std::unique_ptr<Pass> mlir::sigi::createInsertDropChecksPass()
{
    return std::make_unique<SigiInsertDropChecksPass>();
}
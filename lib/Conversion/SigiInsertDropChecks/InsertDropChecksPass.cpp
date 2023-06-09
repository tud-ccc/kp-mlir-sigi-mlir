
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

template<typename TerminatorOp>
static void exploreRegion(Region &region, ConversionPatternRewriter &rewriter0)
{
    // accumulate the closures in the region that need a drop at the end
    // of the region.
    SmallVector<Value> closuresInBody;
    SmallVector<Operation*> funcTerminators;
    SmallVector<closure::BoxOp> closuresToExplore;
    for (Block &block : region.getBlocks()) {
        for (Operation &op : block.getOperations()) {
            Value checkVal;
            if (auto box = dyn_cast<closure::BoxOp>(op)) {
                checkVal = box.getResult();
                // recursive call
                exploreRegion<closure::ReturnOp>(box.getRegion(), rewriter0);
            } else if (auto pop = dyn_cast<sigi::PopOp>(op)) {
                if (pop.getValueType().isa<closure::BoxedClosureType>())
                    checkVal = pop.getValue();
            }
            if (checkVal && closureNeedsDrop(checkVal))
                closuresInBody.emplace_back(checkVal);

            if (auto ret = dyn_cast<TerminatorOp>(op))
                funcTerminators.push_back(ret);
        }
    }

    if (!closuresInBody.empty()) {
        for (auto ret : funcTerminators) {
            ConversionPatternRewriter::InsertionGuard guard(rewriter0);
            rewriter0.setInsertionPoint(ret);
            for (auto closure : closuresInBody)
                rewriter0.create<closure::DropOp>(ret->getLoc(), closure);
        }
    }
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
        exploreRegion<func::ReturnOp>(op.getBody(), rewriter0);
    }
}

} // namespace

std::unique_ptr<Pass> mlir::sigi::createInsertDropChecksPass()
{
    return std::make_unique<SigiInsertDropChecksPass>();
}
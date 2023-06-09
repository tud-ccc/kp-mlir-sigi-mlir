/// Implements the ClosureToLLVM pass.
///
/// @file
/// @author     Clément Fournier (clement.fournier@mailbox.tu-dresden.de)

#include "../PassDetails.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Conversion/ReconcileUnrealizedCasts/ReconcileUnrealizedCasts.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/LLVMIR/FunctionCallUtils.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/ImplicitLocOpBuilder.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/SymbolTable.h"
#include "sigi-mlir/Conversion/ClosureInline/ClosureInline.h"
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"

using namespace mlir;
using namespace mlir::closure;

namespace {

/// @brief Duplicate a closure.call whose callee is an scf.if into each branch
/// of the if
struct DupClosureCall : public OpRewritePattern<closure::CallOp> {
    using OpRewritePattern::OpRewritePattern;

    static void cloneCallIntoIfBranch(
        Block &ifBranch,
        CallOp &call,
        PatternRewriter &rewriter)
    {
        PatternRewriter::InsertionGuard guard(rewriter);

        auto yield = cast<scf::YieldOp>(ifBranch.getTerminator());
        rewriter.setInsertionPoint(yield);
        IRMapping map;
        map.map(call.getCallee(), yield.getResults()[0]);
        auto newCall = cast<CallOp>(
            rewriter.clone(*call, map)); // clone the call into the block

        rewriter.replaceOpWithNewOp<scf::YieldOp>(yield, newCall.getResults());
    }

    LogicalResult
    matchAndRewrite(CallOp call, PatternRewriter &rewriter) const override
    {
        if (auto ifOp = call.getCallee().getDefiningOp<scf::IfOp>()) {
            Region &thenRegion = ifOp.getThenRegion();
            cloneCallIntoIfBranch(*thenRegion.begin(), call, rewriter);
            Region &elseRegion = ifOp.getElseRegion();
            cloneCallIntoIfBranch(*elseRegion.begin(), call, rewriter);
            rewriter.replaceOp(call, ifOp.getResults());
            return success();
        } else if (
            auto selectOp = call.getCallee().getDefiningOp<arith::SelectOp>()) {
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPoint(selectOp);
            auto ifOp = rewriter.create<scf::IfOp>(
                selectOp.getLoc(),
                call.getResultTypes(),
                selectOp.getCondition(),
                true);

            IRMapping map;

            // create the true block
            map.map(call.getCallee(), selectOp.getTrueValue());
            auto builder = ifOp.getThenBodyBuilder();
            auto newCall = builder.clone(*call, map);
            builder.create<scf::YieldOp>(
                selectOp.getLoc(),
                newCall->getResults());

            // create the false block
            map.map(call.getCallee(), selectOp.getFalseValue());
            builder = ifOp.getElseBodyBuilder();
            newCall = builder.clone(*call, map);
            builder.create<scf::YieldOp>(
                selectOp.getLoc(),
                newCall->getResults());

            rewriter.replaceOp(call, ifOp.getResults());
            rewriter.eraseOp(selectOp);
            return success();
        }
        return failure();
    }
};

struct ClosureInlinePass
        : public mlir::impl::ClosureInlineBase<ClosureInlinePass> {
    void runOnOperation() final
    {
        RewritePatternSet patterns(&getContext());

        patterns.add<DupClosureCall>(&getContext());

        ConversionTarget target(getContext());
        target.addDynamicallyLegalOp<closure::CallOp>([](CallOp call) {
            return !call.getCallee().getDefiningOp<scf::IfOp>()
                   && !call.getCallee().getDefiningOp<arith::SelectOp>();
        });
        target.markUnknownOpDynamicallyLegal([](auto) { return true; });

        if (failed(applyPartialConversion(
                getOperation(),
                target,
                std::move(patterns))))
            signalPassFailure();
    }
};
} // namespace

std::unique_ptr<Pass> mlir::closure::createClosureInlinePass()
{
    return std::make_unique<ClosureInlinePass>();
}

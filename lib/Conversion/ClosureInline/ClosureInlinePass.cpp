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
#include "sigi-mlir/Dialect/Closure/Transforms/ClosureConversionUtil.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

using namespace mlir;
using namespace mlir::closure;

namespace {

/// Turn a closure into closure with no args, if the call site is known.
struct DeleteCaptureArgs : public OpRewritePattern<closure::BoxOp> {
    DeleteCaptureArgs(MLIRContext* ctx) : OpRewritePattern(ctx)
    {
        setHasBoundedRewriteRecursion(true);
    }

    LogicalResult
    matchAndRewrite(BoxOp box, PatternRewriter &rewriter) const override
    {
        if (box.getCaptureArgs().empty()) return failure();

        auto baseType = box.getFunctionType();
        auto newFunType = FunctionType::get(
            getContext(),
            box.getRegion().getArgumentTypes(),
            baseType.getResults());
        rewriter.setInsertionPointAfter(box);
        auto newBox = rewriter.create<BoxOp>(
            box.getLoc(),
            ValueRange{},
            ArrayRef{rewriter.getNamedAttr(
                "function_type",
                TypeAttr::get(newFunType))});

        IRMapping map;
        box.getBody().cloneInto(&newBox.getBody(), map);

        SmallVector<Value> newCallArgs(box.getCaptureArgs());
        for (auto &use : box.getResult().getUses()) {
            if (auto call = dyn_cast<CallOp>(use.getOwner())) {
                newCallArgs.truncate(box.getCaptureArgs().size());

                SmallVector<Value> tmp(call.getCalleeOperands());
                newCallArgs.append(std::move(tmp));

                call.setOperand(0, newBox.getResult());
                call.getCalleeOperandsMutable().assign(newCallArgs);
            }
            // otherwise they just aren't changed
        }
        return success();
    }
};

struct ConvertClosureBoxIntoFunc : public OpRewritePattern<closure::BoxOp> {
    ConvertClosureBoxIntoFunc(MLIRContext* ctx) : OpRewritePattern(ctx)
    {
        setHasBoundedRewriteRecursion(true);
    }

    LogicalResult
    matchAndRewrite(BoxOp box, PatternRewriter &rewriter) const override
    {
        if (!box.getCaptureArgs().empty()) return failure();

        SmallVector<closure::CallOp> calls;
        for (auto &use : box.getResult().getUses())
            if (auto call = dyn_cast<closure::CallOp>(use.getOwner()))
                calls.emplace_back(std::move(call));

        if (calls.empty()) return failure();
        auto mod = box->getParentOfType<ModuleOp>();

        rewriter.setInsertionPointToStart(mod.getBody());
        auto fun = rewriter.create<func::FuncOp>(
            box.getLoc(),
            getUniqueFunctionName(mod, "closure"),
            box.getFunctionType());
        fun.setVisibility(SymbolTable::Visibility::Private);
        IRMapping map;
        box.getBody().cloneInto(&fun.getBody(), map);
        for (auto &block : fun.getBody().getBlocks()) {
            if (auto term =
                    dyn_cast<closure::ReturnOp>(block.getTerminator())) {
                rewriter.setInsertionPointAfter(term);
                rewriter.create<func::ReturnOp>(
                    term.getLoc(),
                    term.getOperands());
                rewriter.eraseOp(term);
            }
        }

        for (auto call : calls) {
            rewriter.setInsertionPoint(call);
            rewriter.replaceOpWithNewOp<func::CallOp>(
                call,
                fun,
                ValueRange(call.getArgOperands()));
        }
        return success();
    }
};

/// @brief Duplicate a closure.call whose callee is an scf.if into each branch
/// of the if. This may make an inlining opportunity visible.
struct DupClosureCall : public OpConversionPattern<closure::CallOp> {
    DupClosureCall(MLIRContext* ctx) : OpConversionPattern(ctx)
    {
        setHasBoundedRewriteRecursion(true);
    }

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

    LogicalResult matchAndRewrite(
        CallOp call,
        OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        if (auto ifOp = adaptor.getCallee().getDefiningOp<scf::IfOp>()) {
            Region &thenRegion = ifOp.getThenRegion();
            cloneCallIntoIfBranch(*thenRegion.begin(), call, rewriter);
            Region &elseRegion = ifOp.getElseRegion();
            cloneCallIntoIfBranch(*elseRegion.begin(), call, rewriter);
            rewriter.replaceOp(call, ifOp.getResults());
            return success();
        } else if (
            auto selectOp =
                adaptor.getCallee().getDefiningOp<arith::SelectOp>()) {
            PatternRewriter::InsertionGuard guard(rewriter);
            rewriter.setInsertionPoint(selectOp);
            auto ifOp = rewriter.create<scf::IfOp>(
                selectOp.getLoc(),
                call.getResultTypes(),
                selectOp.getCondition(),
                true);

            IRMapping map;

            // create the true block
            map.map(adaptor.getCallee(), selectOp.getTrueValue());
            auto builder = ifOp.getThenBodyBuilder();
            auto newCall = builder.clone(*call, map);
            builder.create<scf::YieldOp>(
                selectOp.getLoc(),
                newCall->getResults());

            // create the false block
            map.map(adaptor.getCallee(), selectOp.getFalseValue());
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
        // call the canonicalizer
        target.addDynamicallyLegalOp<sigi::PopOp>([](sigi::PopOp pop) {
            return !pop.getInStack().getDefiningOp<sigi::PushOp>();
        });
        target.markUnknownOpDynamicallyLegal([](auto) { return true; });

        // First expand if/else constructs to expose static callees
        if (failed(applyFullConversion(
                getOperation(),
                target,
                std::move(patterns))))
            signalPassFailure();

        ConversionPatternRewriter rewriter(&getContext());

        // Then delete capture args
        // The post-order walk is important here, to avoid cloning
        // closure bodies that themselves contain closures before they are
        // processed.
        DeleteCaptureArgs delArgs(&getContext());
        getOperation().walk(
            [&](BoxOp box) { (void)delArgs.matchAndRewrite(box, rewriter); });

        // Then turn the pattern (call (box with no args)) into func.func and
        // func.call
        ConvertClosureBoxIntoFunc toFunc(&getContext());
        getOperation().walk(
            [&](BoxOp box) { (void)toFunc.matchAndRewrite(box, rewriter); });
    }
};
} // namespace

std::unique_ptr<Pass> mlir::closure::createClosureInlinePass()
{
    return std::make_unique<ClosureInlinePass>();
}

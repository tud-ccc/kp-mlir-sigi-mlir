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
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

using namespace mlir;
using namespace mlir::closure;

namespace {

/// Turn a closure with a known call site into closure with no args.
struct DeleteCaptureArgs : public OpRewritePattern<closure::CallOp> {
    DeleteCaptureArgs(MLIRContext* ctx) : OpRewritePattern(ctx)
    {
        setHasBoundedRewriteRecursion(true);
    }

    LogicalResult
    matchAndRewrite(CallOp call, PatternRewriter &rewriter) const override
    {
        // The principle here is to transform the closure into a non-capturing
        // one so that the regular inlining pass can do its thing.
        if (auto box = call.getCallee().getDefiningOp<BoxOp>()) {
            if (box.getCaptureArgs().empty()) return failure();

            auto baseType = box.getFunctionType();
            auto newFunType = FunctionType::get(
                getContext(),
                box.getRegion().getArgumentTypes(),
                baseType.getResults());
            auto newBox = rewriter.create<BoxOp>(
                box.getLoc(),
                ValueRange{},
                ArrayRef{rewriter.getNamedAttr(
                    "function_type",
                    TypeAttr::get(newFunType))});

            IRMapping map;
            box.getBody().cloneInto(&newBox.getBody(), map);

            call.setOperand(0, newBox.getResult());

            SmallVector<Value> newCallArgs(box.getCaptureArgs());
            SmallVector<Value> tmp(call.getCalleeOperands());
            newCallArgs.append(std::move(tmp));
            call.getCalleeOperandsMutable().assign(newCallArgs);

            return success();
        }
        return failure();
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

        if (failed(applyFullConversion(
                getOperation(),
                target,
                std::move(patterns))))
            signalPassFailure();

        ConversionPatternRewriter rewriter(&getContext());

        getOperation().walk([&](BoxOp box) {
            DeleteCaptureArgs delArgs(&getContext());
            if (box.getCaptureArgs().empty()) return;
            for (auto& use : box.getResult().getUses())
                if (!dyn_cast<CallOp>(use.getOwner())) return;

            auto baseType = box.getFunctionType();
            auto newFunType = FunctionType::get(
                &getContext(),
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
            for (auto& use : box.getResult().getUses()) {
                auto call = cast<CallOp>(use.getOwner());
                newCallArgs.truncate(box.getCaptureArgs().size());

                SmallVector<Value> tmp(call.getCalleeOperands());
                newCallArgs.append(std::move(tmp));

                call.setOperand(0, newBox.getResult());
                call.getCalleeOperandsMutable().assign(newCallArgs);
            }
            rewriter.eraseOp(box);
        });
    }
};
} // namespace

std::unique_ptr<Pass> mlir::closure::createClosureInlinePass()
{
    return std::make_unique<ClosureInlinePass>();
}

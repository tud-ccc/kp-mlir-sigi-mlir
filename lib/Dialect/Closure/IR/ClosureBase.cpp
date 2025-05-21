/// Implements the Closure dialect base.
///
/// @file

#include "sigi-mlir/Dialect/Closure/IR/ClosureBase.h"

#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"
#include "mlir/Transforms/InliningUtils.h"
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"

#define DEBUG_TYPE "closure-base"

using namespace mlir;
using namespace mlir::closure;

//===- Generated implementation -------------------------------------------===//

#include "sigi-mlir/Dialect/Closure/IR/ClosureBase.cpp.inc"

//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// ClosureDialect
//===----------------------------------------------------------------------===//
namespace {

struct ClosureInlinerInterface : public DialectInlinerInterface {
    using DialectInlinerInterface::DialectInlinerInterface;

    //===--------------------------------------------------------------------===//
    // Analysis Hooks
    //===--------------------------------------------------------------------===//

    /// All call operations can be inlined.
    bool isLegalToInline(Operation*, Operation*, bool) const final
    {
        return true;
    }

    /// All operations can be inlined.
    bool isLegalToInline(Operation*, Region*, bool, IRMapping &) const final
    {
        return true;
    }

    /// All functions can be inlined.
    bool isLegalToInline(Region*, Region*, bool, IRMapping &) const final
    {
        return true;
    }

    //===--------------------------------------------------------------------===//
    // Transformation Hooks
    //===--------------------------------------------------------------------===//

    /// Handle the given inlined terminator by replacing it with a new operation
    /// as necessary.
    void handleTerminator(Operation* op, Block* newDest) const final
    {
        // Only return needs to be handled here.
        auto returnOp = dyn_cast<ReturnOp>(op);
        if (!returnOp) return;

        // Replace the return with a branch to the dest.
        OpBuilder builder(op);
        builder.create<cf::BranchOp>(
            op->getLoc(),
            newDest,
            returnOp.getOperands());
        op->erase();
    }

    /// Handle the given inlined terminator by replacing it with a new operation
    /// as necessary.
    void
    handleTerminator(Operation* op, ValueRange valuesToRepl) const final
    {
        // Only return needs to be handled here.
        auto returnOp = cast<ReturnOp>(op);

        // Replace the values directly with the return operands.
        assert(returnOp.getNumOperands() == valuesToRepl.size());
        for (const auto &it : llvm::enumerate(returnOp.getOperands()))
            valuesToRepl[it.index()].replaceAllUsesWith(it.value());
    }
};

} // namespace

void ClosureDialect::initialize()
{
    registerOps();
    registerTypes();
    addInterface<ClosureInlinerInterface>();
}

/// Implements the Sigi dialect base.
///
/// @file

#include "sigi-mlir/Dialect/Sigi/IR/SigiBase.h"

#include "mlir/Dialect/ControlFlow/IR/ControlFlowOps.h"
#include "mlir/Transforms/InliningUtils.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

#define DEBUG_TYPE "sigi-base"

using namespace mlir;
using namespace mlir::sigi;

//===- Generated implementation -------------------------------------------===//

#include "sigi-mlir/Conversion/SigiToLLVM/SigiToLLVM.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiBase.cpp.inc"

//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// SigiDialect
//===----------------------------------------------------------------------===//

namespace {
struct SigiInlinerInterface : public DialectInlinerInterface {
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
    void handleTerminator(Operation*, Block*) const final {}

    /// Handle the given inlined terminator by replacing it with a new operation
    /// as necessary.
    void handleTerminator(Operation*, ValueRange) const final {}
};

} // namespace
void SigiDialect::initialize()
{
    registerOps();
    registerTypes();
    addInterface<SigiInlinerInterface>();
}

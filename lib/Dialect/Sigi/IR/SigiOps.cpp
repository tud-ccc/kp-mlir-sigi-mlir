/// Implements the Sigi dialect ops.
///
/// @file

#include "sigi-mlir/Dialect/Sigi/IR/SigiOps.h"

#include "mlir/IR/Builders.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Transforms/DialectConversion.h"

#include "llvm/ADT/APFloat.h"

#define DEBUG_TYPE "sigi-ops"

using namespace mlir;
using namespace mlir::sigi;

//===- Generated implementation -------------------------------------------===//

#define GET_OP_CLASSES
#include "sigi-mlir/Dialect/Sigi/IR/SigiOps.cpp.inc"

//===----------------------------------------------------------------------===//
// SigiDialect
//===----------------------------------------------------------------------===//

void SigiDialect::registerOps()
{
    addOperations<
#define GET_OP_LIST
#include "sigi-mlir/Dialect/Sigi/IR/SigiOps.cpp.inc"
        >();
}

// parsers/printers

ParseResult PushOp::parse(OpAsmParser &parser, OperationState &result)
{
    OpAsmParser::UnresolvedOperand stackOperand;
    OpAsmParser::UnresolvedOperand valueOperand;
    Type valueType;

    if (parser.parseOperand(stackOperand) || parser.parseComma()
        || parser.parseOperand(valueOperand)
        || parser.parseColonType(valueType))
        return failure();

    SmallVector<Value, 1> stackOpResolved;
    SmallVector<Value, 1> valueOpResolved;
    if (parser.resolveOperand(
            stackOperand,
            sigi::StackType::get(parser.getContext()),
            stackOpResolved)
        || parser.resolveOperand(valueOperand, valueType, valueOpResolved))
        return failure();

    result.addAttribute(
        getValueTypeAttrName(result.name),
        TypeAttr::get(valueType));
    result.addOperands(stackOpResolved);
    result.addOperands(valueOpResolved);
    result.addTypes({sigi::StackType::get(parser.getContext())});
    return success();
}

ParseResult PopOp::parse(OpAsmParser &parser, OperationState &result)
{
    OpAsmParser::UnresolvedOperand stackOperand;
    Type valueType;

    if (parser.parseOperand(stackOperand) || parser.parseColonType(valueType))
        return failure();

    SmallVector<Value, 1> stackOpResolved;
    if (parser.resolveOperand(
            stackOperand,
            sigi::StackType::get(parser.getContext()),
            stackOpResolved))
        return failure();

    result.addAttribute(
        getValueTypeAttrName(result.name),
        TypeAttr::get(valueType));

    result.addOperands(stackOpResolved);
    result.addTypes({sigi::StackType::get(parser.getContext()), valueType});
    return success();
}

void PushOp::print(OpAsmPrinter &printer)
{
    printer << " " << getInStack() << ", " << getValue() << " : " << getValueType();
}

void PopOp::print(OpAsmPrinter &printer)
{
    printer << " " << getInStack() << " : " << getValueType();
}

namespace {
/// @brief Fold a push followed by a pop into nothing.
class SigiPushPopFolder : public OpRewritePattern<sigi::PopOp> {
    using OpRewritePattern::OpRewritePattern;

    LogicalResult
    matchAndRewrite(sigi::PopOp pop, PatternRewriter &rewriter0) const override
    {

        if (auto push = pop.getInStack().getDefiningOp<sigi::PushOp>()) {
            rewriter0.replaceOp(pop, {push.getInStack(), push.getValue()});
            return success();
        }
        return failure();
    }
};

} // namespace

void PopOp::getCanonicalizationPatterns(
    RewritePatternSet &patterns,
    MLIRContext* context)
{
    patterns.add<SigiPushPopFolder>(context);
}

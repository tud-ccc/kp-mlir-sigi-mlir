/// Implements the Closure dialect ops.
///
/// @file
/// @author     Jihaong Bi (jiahong.bi@mailbox.tu-dresden.de)

#include "sigi-mlir/Dialect/Closure/IR/ClosureOps.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/OpImplementation.h"
#include "mlir/Interfaces/FunctionImplementation.h"
#include "mlir/Interfaces/FunctionInterfaces.h"
#include "mlir/Transforms/DialectConversion.h"

#include "llvm/ADT/APFloat.h"

#include <mlir/IR/BuiltinAttributes.h>

#define DEBUG_TYPE "closure-ops"

using namespace mlir;
using namespace mlir::closure;

//===- Generated implementation -------------------------------------------===//

#define GET_OP_CLASSES
#include "sigi-mlir/Dialect/Closure/IR/ClosureOps.cpp.inc"

//===----------------------------------------------------------------------===//
// ClosureDialect
//===----------------------------------------------------------------------===//

void ClosureDialect::registerOps()
{
    addOperations<
#define GET_OP_LIST
#include "sigi-mlir/Dialect/Closure/IR/ClosureOps.cpp.inc"
        >();
}

// parsers/printers

ParseResult parseCaptureArgs(
    OpAsmParser &parser,
    SmallVectorImpl<OpAsmParser::Argument> &lhs,
    SmallVectorImpl<OpAsmParser::UnresolvedOperand> &rhs,
    SmallVectorImpl<Type> &types)
{
    auto parseElt = [&]() -> ParseResult {
        if (parser.parseArgument(lhs.emplace_back()) || parser.parseEqual()
            || parser.parseOperand(rhs.emplace_back())
            || parser.parseColonType<Type>(types.emplace_back()))
            return failure();
        return success();
    };
    return parser.parseCommaSeparatedList(
        AsmParser::Delimiter::Square,
        parseElt);
}

ParseResult parseBoxOp(
    OpAsmParser &parser,
    OperationState &result,
    StringAttr typeAttrName,
    StringAttr argAttrsName,
    StringAttr resAttrsName)
{
    using namespace function_interface_impl;

    SmallVector<DictionaryAttr> resultAttrs;
    SmallVector<Type> resultTypes;
    auto &builder = parser.getBuilder();

    SmallVector<OpAsmParser::Argument, 4> capturedParams;
    SmallVector<OpAsmParser::UnresolvedOperand, 4> capturedArgs;
    SmallVector<Type, 4> capturedArgsTypes;

    if (parseCaptureArgs(
            parser,
            capturedParams,
            capturedArgs,
            capturedArgsTypes))
        return failure();

    SmallVector<Value, 4> resolvedCaptArgs;
    if (parser.resolveOperands(
            std::move(capturedArgs),
            capturedArgsTypes,
            parser.getCurrentLocation(),
            resolvedCaptArgs))
        return failure();

    result.addOperands(std::move(resolvedCaptArgs));

    SmallVector<OpAsmParser::Argument> funTyArgs;
    // Parse the function signature.
    SMLoc signatureLocation = parser.getCurrentLocation();
    bool isVariadic = false;
    if (parseFunctionSignature(
            parser,
            false, // allowVariadic,
            funTyArgs,
            isVariadic,
            resultTypes,
            resultAttrs))
        return failure();

    std::string errorMessage;
    // types for the arguments of the function type
    // region types additionally include the captured arg types
    SmallVector<OpAsmParser::Argument> regionParams;
    regionParams.reserve(funTyArgs.size() + capturedParams.size());
    // captured type args come first
    for (auto [arg, argT] : llvm::zip(capturedParams, capturedArgsTypes)) {
        arg.type = argT;
        regionParams.push_back(arg);
    }
    // function type args come last
    for (auto &arg : funTyArgs) regionParams.push_back(arg);

    {
        SmallVector<Type> funTyArgTypes;
        funTyArgTypes.reserve(funTyArgs.size());
        for (auto &arg : funTyArgs) funTyArgTypes.push_back(arg.type);
        Type type = builder.getFunctionType(funTyArgTypes, resultTypes);
        if (!type) {
            return parser.emitError(signatureLocation)
                   << "failed to construct function type"
                   << (errorMessage.empty() ? "" : ": ") << errorMessage;
        }

        result.addAttribute(typeAttrName, TypeAttr::get(type));
        result.addTypes(BoxedClosureType::get(
            result.getContext(),
            mlir::cast<FunctionType>(type)));
    }

    // If function attributes are present, parse them.
    NamedAttrList parsedAttributes;
    SMLoc attributeDictLocation = parser.getCurrentLocation();
    if (parser.parseOptionalAttrDictWithKeyword(parsedAttributes))
        return failure();

    // Disallow attributes that are inferred from elsewhere in the attribute
    // dictionary.
    for (StringRef disallowed : {typeAttrName.getValue()})
        if (parsedAttributes.get(disallowed))
            return parser.emitError(attributeDictLocation, "'")
                   << disallowed
                   << "' is an inferred attribute and should not be specified "
                      "in the "
                      "explicit attribute dictionary";
    result.attributes.append(parsedAttributes);

    // Add the attributes to the function arguments.
    assert(resultAttrs.size() == resultTypes.size());
    addArgAndResultAttrs(
        builder,
        result,
        funTyArgs,
        resultAttrs,
        argAttrsName,
        resAttrsName);

    // Parse the optional function body. The printer will not print the body if
    // its empty, so disallow parsing of empty body in the parser.
    auto* body = result.addRegion();
    SMLoc loc = parser.getCurrentLocation();
    OptionalParseResult parseResult = parser.parseRegion(
        *body,
        regionParams,
        /*enableNameShadowing=*/false);
    if (parseResult.has_value()) {
        if (failed(*parseResult)) return failure();
        // Function body was parsed, make sure its not empty.
        if (body->empty())
            return parser.emitError(loc, "expected non-empty function body");
    }
    assert(result.attributes.get(typeAttrName) && "Need a function type attr");
    return success();
}

ParseResult BoxOp::parse(OpAsmParser &parser, OperationState &result)
{
    return parseBoxOp(
        parser,
        result,
        getFunctionTypeAttrName(result.name),
        getArgAttrsAttrName(result.name),
        getResAttrsAttrName(result.name));
}

/// Print a function result list. The provided `attrs` must either be null, or
/// contain a set of DictionaryAttrs of the same arity as `types`.
static void
printFunctionResultList(OpAsmPrinter &p, ArrayRef<Type> types, ArrayAttr attrs)
{
    assert(!types.empty() && "Should not be called for empty result list.");
    assert(
        (!attrs || attrs.size() == types.size())
        && "Invalid number of attributes.");

    auto &os = p.getStream();
    bool needsParens =
        types.size() > 1 || mlir::isa<FunctionType>(types[0])
        || (attrs && !mlir::cast<DictionaryAttr>(attrs[0]).empty());
    if (needsParens) os << '(';
    llvm::interleaveComma(
        llvm::seq<size_t>(0, types.size()),
        os,
        [&](size_t i) {
            p.printType(types[i]);
            if (attrs)
                p.printOptionalAttrDict(
                    mlir::cast<DictionaryAttr>(attrs[i]).getValue());
        });
    if (needsParens) os << ')';
}

void printFunctionSignature(
    OpAsmPrinter &p,
    BoxOp* op,
    ArrayRef<Type> argTypes,
    bool isVariadic,
    ArrayRef<Type> resultTypes)
{
    Region &body = op->getBody();
    ValueRange captured = op->getOperands();
    unsigned int argCount = body.getArguments().size();

    unsigned numCapt = captured.size();
    p << '[';
    for (unsigned i = 0; i < numCapt; ++i) {
        if (i > 0) p << ", ";

        p.printRegionArgument(body.getArgument(i), {}, /*omitType=*/true);
        p << " = ";
        p.printOperand(captured[i]);
        p << " : ";
        p.printType(captured[i].getType());
    }
    p << ']';

    p << '(';
    ArrayAttr argAttrs = op->getArgAttrsAttr();
    for (unsigned i = 0, e = argTypes.size(); i < e; ++i) {
        if (i > 0) p << ", ";

        ArrayRef<NamedAttribute> attrs;
        if (argAttrs)
            attrs = mlir::cast<DictionaryAttr>(argAttrs[i]).getValue();
        if (numCapt + i < argCount)
            p.printRegionArgument(body.getArgument(numCapt + i), attrs);
        else
            p << "<<UNKNOWN_SSA_VALUE>>";
    }

    if (isVariadic) {
        if (!argTypes.empty()) p << ", ";
        p << "...";
    }

    p << ')';

    if (!resultTypes.empty()) {
        p.getStream() << " -> ";
        auto resultAttrs = op->getResAttrsAttr();
        printFunctionResultList(p, resultTypes, resultAttrs);
    }
}

void printFunctionAttributes(
    OpAsmPrinter &p,
    BoxOp op,
    ArrayRef<StringRef> elided)
{
    // Print out function attributes, if present.
    SmallVector<StringRef, 8> ignoredAttrs = {op.getFunctionTypeAttrName()};
    ignoredAttrs.append(elided.begin(), elided.end());

    p.printOptionalAttrDictWithKeyword(op->getAttrs(), ignoredAttrs);
}

void BoxOp::print(OpAsmPrinter &p)
{
    // Print the operation and the function name.
    p << ' ';

    ArrayRef<Type> argTypes = getFunctionType().getInputs();
    ArrayRef<Type> resultTypes = getFunctionType().getResults();
    printFunctionSignature(p, this, argTypes, false, resultTypes);
    printFunctionAttributes(
        p,
        *this,
        {getFunctionTypeAttrName(),
         getArgAttrsAttrName(),
         getResAttrsAttrName()});
    // Print the body if this is not an external function.
    Region &body = getBody();
    p << ' ';
    p.printRegion(
        body,
        /*printEntryBlockArgs=*/false,
        /*printBlockTerminators=*/true);
}

// verifiers

LogicalResult ReturnOp::verify()
{
    auto function = cast<BoxOp>((*this)->getParentOp());

    // The operand number and types must match the function signature.
    const auto &results = function.getFunctionType().getResults();
    if (getNumOperands() != results.size())
        return emitOpError("has ")
               << getNumOperands()
               << " operands, but enclosing closure returns " << results.size();

    for (unsigned i = 0, e = results.size(); i != e; ++i)
        if (getOperand(i).getType() != results[i])
            return emitError() << "type of return operand " << i << " ("
                               << getOperand(i).getType()
                               << ") doesn't match function result type ("
                               << results[i] << ")"
                               << " in enclosing closure";

    return success();
}

ParseResult ReturnOp::parse(OpAsmParser &parser, OperationState &result)
{
    // This is weird but I was getting a puzzling segfault with the default
    // generated parser.
    return ::mlir::func::ReturnOp::parse(parser, result);
}

void ReturnOp::print(OpAsmPrinter &printer)
{
    ::llvm::SmallVector<::llvm::StringRef, 2> elidedAttrs;
    printer.printOptionalAttrDict((*this)->getAttrs(), elidedAttrs);
    if (!getOperands().empty()) {
        printer << ' ';
        printer << getOperands();
        printer << ' ' << ":";
        printer << ' ';
        printer << getOperands().getTypes();
    }
}

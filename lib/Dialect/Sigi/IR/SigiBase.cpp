/// Implements the Sigi dialect base.
///
/// @file

#include "sigi-mlir/Dialect/Sigi/IR/SigiBase.h"

#include "mlir/IR/DialectImplementation.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

#define DEBUG_TYPE "sigi-base"

using namespace mlir;
using namespace mlir::sigi;

//===- Generated implementation -------------------------------------------===//

#include "sigi-mlir/Dialect/Sigi/IR/SigiBase.cpp.inc"

//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// SigiDialect
//===----------------------------------------------------------------------===//

void SigiDialect::initialize()
{
    registerOps();
    registerTypes();
}
/*
/// Parse a type registered to this dialect.
mlir::Type SigiDialect::parseType(mlir::DialectAsmParser &parser) const
{
    return Type();
}

/// Print a type registered to this dialect.
void SigiDialect::printType(mlir::Type type, mlir::DialectAsmPrinter &os) const
{
    os << "SigiType";
}
*/
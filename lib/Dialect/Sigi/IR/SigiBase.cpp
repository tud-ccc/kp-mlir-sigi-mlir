/// Implements the Sigi dialect base.
///
/// @file

#include "sigi-mlir/Dialect/Sigi/IR/SigiBase.h"

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

struct SigiOpAsmInterface : public OpAsmDialectInterface {
    using OpAsmDialectInterface::OpAsmDialectInterface;
    SigiOpAsmInterface(Dialect* dialect) : OpAsmDialectInterface(dialect) {}

    AliasResult getAlias(Type type, raw_ostream &os) const override
    {
        if (isSigiLlvmStackType(type)) {
            os << "sigi_stackptr";
            return AliasResult::FinalAlias;
        }
        return AliasResult::NoAlias;
    }
};
} // namespace

void SigiDialect::initialize()
{
    registerOps();
    registerTypes();
    addInterface<SigiOpAsmInterface>();
}

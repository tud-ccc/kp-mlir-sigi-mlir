/// Main entry point for the sigi-mlir optimizer driver.
///
/// @file
/// @author      Karl F. A. Friebel (karl.friebel@tu-dresden.de)

#include "mlir/Dialect/LLVMIR/LLVMDialect.h"

#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

#include "mlir/IR/AsmState.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/InitAllDialects.h"
#include "mlir/InitAllExtensions.h"
#include "mlir/InitAllPasses.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Support/FileUtilities.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"

#include "llvm/Support/CommandLine.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/ToolOutputFile.h"

#include "sigi-mlir/Conversion/ClosurePasses.h"
#include "sigi-mlir/Conversion/SigiPasses.h"

using namespace mlir;

int main(int argc, char* argv[])
{
    DialectRegistry registry;
    registerAllDialects(registry);
    registerAllExtensions(registry);

    registry.insert<closure::ClosureDialect, sigi::SigiDialect>();

    registerAllPasses();
    registerClosureConversionPasses();
    registerSigiConversionPasses();

    return asMainReturnCode(
        MlirOptMain(argc, argv, "sigi-mlir optimizer driver\n", registry));
}

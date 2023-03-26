/// Main entry point for the sigi-mlir MLIR language server.

#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

#include "mlir/IR/Dialect.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/InitAllDialects.h"
#include "mlir/Tools/mlir-lsp-server/MlirLspServerMain.h"

using namespace mlir;

static int asMainReturnCode(LogicalResult r)
{
    return r.succeeded() ? EXIT_SUCCESS : EXIT_FAILURE;
}

int main(int argc, char* argv[])
{
    DialectRegistry registry;
    registerAllDialects(registry);

    registry.insert<closure::ClosureDialect, sigi::SigiDialect>();

    return asMainReturnCode(MlirLspServerMain(argc, argv, registry));
}

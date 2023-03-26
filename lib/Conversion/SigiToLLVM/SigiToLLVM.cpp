/// Implements the SigiToLLVM pass.
///
/// @file
/// @author     Clément Fournier (clement.fournier@mailbox.tu-dresden.de)

#include "sigi-mlir/Conversion/SigiToLLVM/SigiToLLVM.h"

#include "../PassDetails.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/LLVMCommon/Pattern.h"
#include "mlir/Conversion/ReconcileUnrealizedCasts/ReconcileUnrealizedCasts.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Func/Transforms/FuncConversions.h"
#include "mlir/Dialect/LLVMIR/FunctionCallUtils.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/IRMapping.h"
#include "mlir/IR/ImplicitLocOpBuilder.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/SymbolTable.h"
#include "sigi-mlir/Conversion/ClosureToLLVM/ClosureToLLVM.h"
#include "sigi-mlir/Dialect/Closure/IR/ClosureDialect.h"
#include "sigi-mlir/Dialect/Closure/Transforms/ClosureConversionUtil.h"
#include "sigi-mlir/Dialect/Sigi/IR/SigiDialect.h"

/*

typedef struct sigi_stack_impl* sigi_stack_t;

void sigi_init_stack(sigi_stack_t* stack);
void sigi_free_stack(sigi_stack_t* stack);

void sigi_push_i32(sigi_stack_t* stack, int32_t value);
void sigi_push_bool(sigi_stack_t* stack, bool value);
void sigi_push_closure(sigi_stack_t* stack, void* value);

void* sigi_pop_closure(sigi_stack_t* stack);
int32_t sigi_pop_i32(sigi_stack_t* stack);
bool sigi_pop_bool(sigi_stack_t* stack);

// This is the implementation of the pp method.
void sigi_print_stack_top_ln(sigi_stack_t*);

*/

using namespace mlir;
using namespace mlir::sigi;



namespace {

struct ConvertSigiToLLVMPass
        : public mlir::impl::ConvertSigiToLLVMBase<ConvertSigiToLLVMPass> {
    void runOnOperation() final;
};

} // namespace



void ConvertSigiToLLVMPass::runOnOperation()
{
    // todo
}

std::unique_ptr<Pass> mlir::sigi::createConvertSigiToLLVMPass()
{
    return std::make_unique<ConvertSigiToLLVMPass>();
}

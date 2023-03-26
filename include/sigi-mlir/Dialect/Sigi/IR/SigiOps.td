//===- Ops.td - Sigi dialect ops ----------------------*- tablegen -*-===//
//
// This is the definitions file for the Sigi dialect ops.
//
//===----------------------------------------------------------------------===//

#ifndef SIGI_OPS
#define SIGI_OPS


include "sigi-mlir/Dialect/Sigi/IR/SigiBase.td"
include "sigi-mlir/Dialect/Sigi/IR/SigiTypes.td"

include "mlir/IR/EnumAttr.td"
include "mlir/IR/OpAsmInterface.td"
include "mlir/IR/SymbolInterfaces.td"
include "mlir/Interfaces/FunctionInterfaces.td"
include "mlir/Bytecode/BytecodeOpInterface.td"
include "mlir/Interfaces/ControlFlowInterfaces.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"


// These ops are pure because they consume a stack and return a new one.
// The implementation is not pure though.


#endif

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


def PushOp : Sigi_Op<"push", [Pure]> {
  let summary = "push operation";
  let description = [{
  }];

  let arguments = (ins Sigi_StackType:$inStack,
                       AnyType:$value,
                       TypeAttrOf<AnyType>:$value_type);
  let results = (outs Sigi_StackType:$outStack);

  let extraClassDeclaration = [{

  }];

  let hasCustomAssemblyFormat = 1;
}


def PopOp : Sigi_Op<"pop", [Pure]> {
  let summary = "pop operation";
  let description = [{
  }];

  let arguments = (ins Sigi_StackType:$inStack, TypeAttrOf<AnyType>:$value_type);
  let results = (outs Sigi_StackType:$outStack, AnyType:$value);

  let extraClassDeclaration = [{

  }];

  let hasCustomAssemblyFormat = 1;
}

#endif

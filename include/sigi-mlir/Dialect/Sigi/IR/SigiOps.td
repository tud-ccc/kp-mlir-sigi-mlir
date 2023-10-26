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
include "mlir/Interfaces/CallInterfaces.td"
include "mlir/Interfaces/ControlFlowInterfaces.td"
include "mlir/IR/FunctionInterfaces.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"


def PopOp : Sigi_Op<"pop"> {
  let summary = "stack pop operation";
  let description = [{
  }];

  let arguments = (ins Sigi_StackType:$callee);
  let results = (outs Sigi_StackType:$newstack, Variadic<AnyType>:$result);
/*
  let extraClassDeclaration = [{
    FunctionType getCalleeType() {
      return getCallee().getType().cast<SigiStackType>().getFunctionType();
    }

    SigiStackType getOpType() {
      return SigiType::get(getContext(), getCalleeType());
    }

    /// Get the argument operands to the called function.
    operand_range getArgOperands() {
      return {arg_operand_begin(), arg_operand_end()};
    }

    operand_iterator arg_operand_begin() { return operand_begin(); }
    operand_iterator arg_operand_end() { return operand_end(); }

    /// Return the callee of this operation.
    CallInterfaceCallable getCallableForCallee() {
      return (*this)->getAttrOfType<SymbolRefAttr>("callee");
    }
  }];
*/

  let assemblyFormat = [{
    $callee attr-dict `:` type($result)
  }];
  
}


def PushOp : Sigi_Op<"push">{
  let summary = "stack pop operation";
  let description = [{}];

  let arguments = (ins Sigi_StackType:$instack, Variadic<AnyType>:$element);
  let results = (outs Sigi_StackType:$outstack);

  let assemblyFormat = [{
    $instack `,` $element attr-dict `:` type($element)
  }];
}

#endif

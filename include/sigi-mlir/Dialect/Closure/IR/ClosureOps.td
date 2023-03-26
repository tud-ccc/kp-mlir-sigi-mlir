//===- Ops.td - Closure dialect ops ----------------------*- tablegen -*-===//
//
// This is the definitions file for the Closure dialect ops.
//
//===----------------------------------------------------------------------===//

#ifndef CLOSURE_OPS
#define CLOSURE_OPS


include "sigi-mlir/Dialect/Closure/IR/ClosureBase.td"
include "sigi-mlir/Dialect/Closure/IR/ClosureTypes.td"

include "mlir/IR/EnumAttr.td"
include "mlir/IR/OpAsmInterface.td"
include "mlir/IR/SymbolInterfaces.td"
include "mlir/Interfaces/CallInterfaces.td"
include "mlir/Interfaces/ControlFlowInterfaces.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Bytecode/BytecodeOpInterface.td"


def CallOp : Closure_Op<"call",
    [CallOpInterface,   
     TypesMatchWith<"callee input types match argument types",
                     "callee", "callee_operands",
                     "$_self.cast<BoxedClosureType>().getFunctionType().getInputs()">,
     TypesMatchWith<"callee result types match result types",
                     "callee", "results",
                     "$_self.cast<BoxedClosureType>().getFunctionType().getResults()">,
    
    ]> {
  let summary = "call operation";
  let description = [{
  }];

  let arguments = (ins Closure_BoxType:$callee,
                       Variadic<AnyType>:$callee_operands);
  let results = (outs Variadic<AnyType>:$results);

  let extraClassDeclaration = [{
    FunctionType getCalleeType() {
      return getCallee().getType().cast<BoxedClosureType>().getFunctionType();
    }

    BoxedClosureType getClosureType() {
      return BoxedClosureType::get(getContext(), getCalleeType());
    }

    /// Get the argument operands to the called function.
    operand_range getArgOperands() {
      return {arg_operand_begin(), arg_operand_end()};
    }

    MutableOperandRange getArgOperandsMutable() {
      return MutableOperandRange(*this, 1, getCalleeOperands().size());
    }

    operand_iterator arg_operand_begin() { return ++operand_begin(); }
    operand_iterator arg_operand_end() { return operand_end(); }

    /// Return the callee of this operation.
    CallInterfaceCallable getCallableForCallee() {
      return this->getCallee();
    }
    void setCalleeFromCallable(CallInterfaceCallable callable) {
      // todo
    }
  }];

  let assemblyFormat = [{
    $callee `(` $callee_operands `)` attr-dict `:` type($callee)
  }];
}


def BoxOp : Closure_Op<"box", [
  AffineScope, AutomaticAllocationScope, CallableOpInterface, 
  IsolatedFromAbove, Pure
]> {
  let summary = "Create a boxed closure with the given functional signature.";
  let description = [{
    Operations within the function can capture values, provided the captures are
    declared explicitly (in square brackets).

    %0 = arith.constant 1 : i32
    // this closure has type () -> i32
    %1 = closure.box [%a = %0 : i32] () -> i32 {
      closure.return %a : i32
    }

    // this closure has type (i32) -> i32
    %1 = closure.box [%a = %0 : i32] (%b: i32) -> i32 {
      %x = arith.addi %a, %b : i32
      closure.return %x : i32
    }
  }];

  let arguments = (ins TypeAttrOf<FunctionType>:$function_type,
                       Variadic<CapturableType>:$capture_args,
                       OptionalAttr<DictArrayAttr>:$arg_attrs,
                       OptionalAttr<DictArrayAttr>:$res_attrs);
  let results = (outs Closure_BoxType:$result);
  let regions = (region AnyRegion:$body);


  let extraClassDeclaration = [{

    BoxedClosureType getClosureType() {
      return BoxedClosureType::get(getContext(), getFunctionType());
    }

    ArrayRef<Type> getArgumentTypes() {
      return getFunctionType().getInputs();
    }

    ArrayRef<Type> getResultTypes() {
      return getFunctionType().getResults();
    }


    //===------------------------------------------------------------------===//
    // CallableOpInterface
    //===------------------------------------------------------------------===//

    /// Returns the region on the current operation that is callable.
    ::mlir::Region *getCallableRegion() { return &getBody(); }

    /// Returns the results types that the callable region produces when
    /// executed.
    ArrayRef<Type> getCallableResults() { return getFunctionType().getResults(); }
    ArrayAttr getCallableArgAttrs() { return {}; }
    ArrayAttr getCallableResAttrs() { return {}; }

  }];
  let hasCustomAssemblyFormat = 1;
}


//===----------------------------------------------------------------------===//
// ReturnOp
//===----------------------------------------------------------------------===//

def ReturnOp : Closure_Op<"return", [Pure, HasParent<"BoxOp">,
                                     ReturnLike, Terminator]> {
  let summary = "Function return operation";
  let description = [{
    The `closure.return` operation represents a return operation within a closure function.
    The operation takes variable number of operands and produces no results.
    The operand number and types must match the signature of the closure
    that contains the operation.

    Example:

    ```mlir
    closure.box() -> (i32, f8) {
      ...
      closure.return %0, %1 : i32, f8
    }
    ```
  }];

  let arguments = (ins Variadic<AnyType>:$operands);

  // let assemblyFormat = "attr-dict ($operands^ `:` type($operands))?";
  let hasVerifier = 1;
  let hasCustomAssemblyFormat = 1;

}

def DropOp : Closure_Op<"check_drop", []> {
  let summary = "If the closure reference count is zero, drop the closure recursively. This does not mutate the reference count.";
  let description = [{
  }];

  let arguments = (ins Closure_BoxType:$callee);
  let results = (outs);

  let extraClassDeclaration = [{
    FunctionType getCalleeType() {
      return getCallee().getType().cast<BoxedClosureType>().getFunctionType();
    }

    BoxedClosureType getClosureType() {
      return BoxedClosureType::get(getContext(), getCalleeType());
    }

  }];

  let assemblyFormat = [{
    $callee  attr-dict `:` type($callee)
  }];
}


#endif

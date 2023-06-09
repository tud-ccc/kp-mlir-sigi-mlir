//===- Passes.td - Closure dialect passes ---------------------*- tablegen -*-===//
//
// This is the definitions file for the Closure dialect conversion passes.
//
//===----------------------------------------------------------------------===//

#ifndef CLOSURE_CONVERSION_PASSES
#define CLOSURE_CONVERSION_PASSES

include "PassUtil.td"


def ConvertClosureToLLVM : ConvertToLlvm<"Closure", "closure">;


def ClosureInline : Pass<"closure-inline", "func::FuncOp"> {
  let summary = "Inline more complex closure call patterns";

  let constructor = "mlir::closure::createClosureInlinePass()";

  let dependentDialects = [
    "::mlir::func::FuncDialect",
    "::mlir::scf::SCFDialect",
    "::mlir::arith::ArithDialect",
  ];
}

#endif // CLOSURE_CONVERSION_PASSES
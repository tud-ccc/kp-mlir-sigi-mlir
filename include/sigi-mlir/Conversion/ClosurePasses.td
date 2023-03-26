//===- Passes.td - Closure dialect passes ---------------------*- tablegen -*-===//
//
// This is the definitions file for the Closure dialect conversion passes.
//
//===----------------------------------------------------------------------===//

#ifndef CLOSURE_CONVERSION_PASSES
#define CLOSURE_CONVERSION_PASSES

include "PassUtil.td"


def ConvertClosureToLLVM : ConvertToLlvm<"Closure", "closure">;


def ClosureToFunc : Pass<"closure-to-func", "func::FuncOp"> {
  let summary = "Remove closure boxing where possible.";

  let constructor = "mlir::closure::createClosureToFuncPass()";

  let dependentDialects = [
    "::mlir::func::FuncDialect",
  ];
}

def ClosureDeleteCaptures : Pass<"closure-delete-captures", "func::FuncOp"> {
  let summary = "Delete capture arguments of closures if possible.";

  let constructor = "mlir::closure::createClosureDeleteCapturesPass()";

  let dependentDialects = [
    "::mlir::func::FuncDialect",
    "::mlir::scf::SCFDialect",
    "::mlir::arith::ArithDialect",
  ];
}
def ClosureInline : Pass<"closure-inline", "func::FuncOp"> {
  let summary = "Pipeline for closure inlining.";

  let constructor = "mlir::closure::createClosureInlinePass()";

  let dependentDialects = [
    "::mlir::func::FuncDialect",
    "::mlir::scf::SCFDialect",
    "::mlir::arith::ArithDialect",
  ];
}

#endif // CLOSURE_CONVERSION_PASSES
//===- Passes.td - Closure dialect passes ---------------------*- tablegen -*-===//
//
// This is the definitions file for the Closure dialect conversion passes.
//
//===----------------------------------------------------------------------===//

#ifndef SIGI_PASS_UTIL
#define SIGI_PASS_UTIL

include "mlir/Pass/PassBase.td"

// easily declare a to-llvm conversion pass by writing
// def ConvertSigiToLlvm: ConvertToLlvm<"Sigi", "sigi">
class ConvertToLlvm<string dialectName, string dialectNs> : Pass<"convert-" # dialectNs # "-to-llvm"> {
  let summary = "Convert " # dialectNs # " dialect to LLVM IR";

  let constructor = "mlir::" # dialectNs # "::createConvert" # dialectName # "ToLLVMPass()";

  let dependentDialects = [
    "LLVM::LLVMDialect",
  ];
}

#endif // SIGI_PASS_UTIL
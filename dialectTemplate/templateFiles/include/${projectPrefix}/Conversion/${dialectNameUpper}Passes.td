//===- Passes.td - ${dialectNameUpper} dialect passes ---------------------*- tablegen -*-===//
//
// This is the definitions file for the ${dialectNameUpper} dialect conversion passes.
//
//===----------------------------------------------------------------------===//

#ifndef ${dialectNameAllCaps}_CONVERSION_PASSES
#define ${dialectNameAllCaps}_CONVERSION_PASSES

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

#endif // ${dialectNameAllCaps}_CONVERSION_PASSES
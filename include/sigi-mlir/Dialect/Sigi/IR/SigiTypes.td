//===- Types.td - Sigi dialect types ------------------*- tablegen -*-===//
//
// This is the definitions file for the Sigi dialect types.
//
//===----------------------------------------------------------------------===//

#ifndef SIGI_TYPES
#define SIGI_TYPES

include "mlir/IR/BuiltinTypeInterfaces.td"
include "SigiBase.td"


def Sigi_StackType : Sigi_Type<"Stack"> {
  let mnemonic = "stack";
  let summary = "Type for the runtime stack of a Sigi program.";
}

def Sigi_GenericType : Sigi_Type<"Generic"> {
  let mnemonic = "generic";
  let summary = "Type for an erased runtime value.";
}

#endif

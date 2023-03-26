//===- Types.td - Closure dialect types ------------------*- tablegen -*-===//
//
// This is the definitions file for the Closure dialect types.
//
//===----------------------------------------------------------------------===//

#ifndef CLOSURE_TYPES
#define CLOSURE_TYPES

include "mlir/IR/BuiltinTypeInterfaces.td"



def Closure_BoxType : Closure_Type<"BoxedClosure"> {
  let mnemonic = "box";
  let summary = "Opaque type for a boxed closure.";

  let parameters = (ins "FunctionType":$functionType);
  let assemblyFormat = "`<` $functionType `>`";

  let builders = [
    TypeBuilder<(ins "TypeRange":$inputs, "TypeRange":$results), [{
        return get(context, FunctionType::get(context, inputs, results));
    }]>
  ];
}

def CapturableType: AnyTypeOf<[
  AnyInteger,
  Closure_BoxType
]>;

#endif

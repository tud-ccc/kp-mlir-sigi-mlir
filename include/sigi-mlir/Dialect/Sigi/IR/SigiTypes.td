//===- Types.td - Sigi dialect types ------------------*- tablegen -*-===//
//
// This is the definitions file for the Sigi dialect types.
//
//===----------------------------------------------------------------------===//

#ifndef SIGI_TYPES
#define SIGI_TYPES

include "mlir/IR/BuiltinTypeInterfaces.td"

def Sigi_StackType : Sigi_Type<"stack"> {
  let mnemonic = "stack";
  let summary = "Type that represents sigi's stack.";

  //let parameters = (ins "FunctionType":$functionType);
  //let assemblyFormat = "`<` $functionType `>`";

  //let builders = [
  //  TypeBuilder<(ins "TypeRange":$inputs, "TypeRange":$results), [{
  //      return get(context, FunctionType::get(context, inputs, results));
  //  }]>
  //];
}



#endif

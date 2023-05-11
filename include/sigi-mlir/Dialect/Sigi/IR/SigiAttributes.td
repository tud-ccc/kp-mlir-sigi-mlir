//===- Attributes.td - Sigi dialect attributes --------*- tablegen -*-===//
//
// This is the definitions file for the Sigi dialect attributes.
//
//===----------------------------------------------------------------------===//

#ifndef SIGI_ATTRIBUTES
#define SIGI_ATTRIBUTES

include "sigi-mlir/Dialect/Sigi/IR/SigiBase.td"

class Sigi_UnitAttr<string name> : Sigi_Attr<name> {
    let storageType = "::mlir::UnitAttr";
    let constBuilderCall = "(($0) ? $_builder.getUnitAttr() : nullptr)";
    let returnType = "bool";
    let convertFromStorage = "$_self != nullptr";
    let defaultValue = false;
    let valueType = NoneType;
    let isOptional = 1;
}


def Sigi_MainAttr : Sigi_UnitAttr<"main">; 
def Sigi_BuiltinAttr : Sigi_UnitAttr<"builtinfunc">; 

#endif

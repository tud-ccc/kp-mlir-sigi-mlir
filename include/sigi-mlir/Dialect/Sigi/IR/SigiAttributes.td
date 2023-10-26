//===- Attributes.td - Sigi dialect attributes --------*- tablegen -*-===//
//
// This is the definitions file for the Sigi dialect attributes.
//
//===----------------------------------------------------------------------===//

#ifndef SIGI_ATTRIBUTES
#define SIGI_ATTRIBUTES

include "sigi-mlir/Dialect/Sigi/IR/SigiBase.td"

def Sigi_MainAttr : Sigi_Attr<"main">{
    let summary = "Tags a function as the main function";
    let description = [{}];

    let assemblyFormat = "`main`";
}



def Sigi_BuildinAttr : Sigi_Attr<"buildinfunc">{
    let summary = "Tags a function as being a build-in function";
    let description = [{}];

    let assemblyFormat = "`buildinfunc`";
}

#endif

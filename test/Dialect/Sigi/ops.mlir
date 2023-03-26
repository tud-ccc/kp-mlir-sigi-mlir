// RUN: sigi-opt %s | sigi-opt | FileCheck %s
// RUN: sigi-opt %s --mlir-print-op-generic | sigi-opt | FileCheck %s


// CHECK-LABEL: simpleSigi
func.func @simpleSigi(%s0: !sigi.stack) -> !sigi.stack {
    %v1 = arith.constant 1: i1
    %s1 = sigi.push %s0, %v1: i1
    %v2 = arith.constant 0: i1
    %s2 = sigi.push %s1, %v2: i1
    // =
    %s3, %v3 = sigi.pop %s2: i1
    %s4, %v4 = sigi.pop %s3: i1
    %v5 = arith.cmpi "eq", %v3, %v4: i1
    %s5 = sigi.push %s4, %v5: i1
    return %s5: !sigi.stack
}


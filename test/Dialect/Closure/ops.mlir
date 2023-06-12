// RUN: sigi-opt %s | sigi-opt | FileCheck %s
// RUN: sigi-opt %s --mlir-print-op-generic | sigi-opt | FileCheck %s


// CHECK-LABEL: return_closure
func.func @return_closure(%arg0: i32) -> !closure.box<(i32) -> i32> {
    %6 = closure.box [] (%2 : i32) -> i32 {
        %10 = arith.constant 32: i32
        %9 = arith.addi %2, %10: i32
        closure.return %9: i32
    }
    return %6: !closure.box<(i32) -> i32>
}

// CHECK-LABEL: call_closure
func.func @call_closure(%arg0: i32) -> i32 {
    %6 = closure.box [%1 = %arg0: i32] (%2 : i32) -> i32 {
        %9 = arith.addi %2, %1: i32
        closure.return %9: i32
    }

    %10 = arith.constant 32: i32
    %11 = closure.call %6 (%10): !closure.box<(i32) -> i32>
    return %11: i32
}
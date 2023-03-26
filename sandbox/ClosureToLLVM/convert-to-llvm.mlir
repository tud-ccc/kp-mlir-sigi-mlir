// RUN: sigi-opt %s -convert-closure-to-llvm | FileCheck %s

llvm.func @printf(!llvm.ptr, ...) -> i32

llvm.mlir.global private constant @intFmt("%d\n\00")

llvm.func @main() {

    

    %cst1 = arith.constant 1 : i32
    %cst = arith.constant 24 : i32

    %6 = closure.box [%1 = %cst: i32] (%2 : i32) -> i32 {
        %9 = arith.addi %2, %1: i32
        closure.return %9: i32
    }

    %res = closure.call %6(%cst1): !closure.box<(i32) -> i32>

    %fmt = llvm.mlir.addressof @intFmt: !llvm.ptr
    llvm.call @printf(%fmt, %res): (!llvm.ptr, i32) -> i32

    llvm.return
}


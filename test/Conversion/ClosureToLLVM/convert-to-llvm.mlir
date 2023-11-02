// RUN: sigi-opt %s -convert-closure-to-llvm | FileCheck %s

// CHECK-LABEL: check_1captureArg
module @check_1captureArg {
    // CHECK-DAG: llvm.func private @[[CLOSURE_WORKER:.+]](%{{.+}}: i32, %{{.+}}: i32) -> i32
    // CHECK-DAG: llvm.func private @[[CLOSURE_WRAPPER:.+]](%{{.+}}: !llvm.ptr, %{{.+}}: i32) -> i32
    func.func @main() {


        // CHECK-DAG: %[[CST1:.+]] = arith.constant 1 : i32
        %cst1 = arith.constant 1 : i32
        // CHECK-DAG: %[[CST24:.+]] = arith.constant 24 : i32
        %cst = arith.constant 24 : i32

        // CHECK-DAG: %[[ALLOC:.+]] = llvm.call @malloc(%{{.+}}) : (i64) -> !llvm.ptr
        // CHECK-DAG: %[[UD:.+]] = llvm.mlir.undef : !llvm.struct<([[FPTR:ptr<func<i32 \(ptr, i32\)>>]], struct<(i32)>)>
        // CHECK-DAG: %[[WADDRESS:.+]] = llvm.mlir.addressof @[[CLOSURE_WRAPPER]] : !llvm.[[FPTR]]
        // CHECK-DAG: %[[STRUCT0:.+]] = llvm.insertvalue %[[WADDRESS]], %[[UD]][0] : !llvm.struct<([[FPTR]], struct<(i32)>)> 
        // CHECK-DAG: %[[STRUCT1:.+]] = llvm.insertvalue %[[CST24]], %[[STRUCT0]][1, 0] : !llvm.struct<([[FPTR]], struct<(i32)>)> 
        // CHECK-DAG: %[[STOREPTR:.+]] = llvm.bitcast %[[ALLOC]] : !llvm.ptr to !llvm.ptr<struct<([[FPTR]], struct<(i32)>)>>
        // CHECK-DAG: llvm.store %[[STRUCT1]], %[[STOREPTR]] : !llvm.ptr<struct<([[FPTR]], struct<(i32)>)>>
        // CHECK-DAG: %[[CAST_CLOSURE:.+]] = llvm.bitcast %[[ALLOC]] : !llvm.ptr to !llvm.ptr<[[FPTR]]>
        %6 = closure.box [%1 = %cst: i32] (%2 : i32) -> i32 {
            %9 = arith.addi %2, %1: i32
            closure.return %9: i32
        }

        // CHECK-DAG: %[[LOADEDPTR:.+]] = llvm.load %[[CAST_CLOSURE]] : !llvm.ptr<[[FPTR]]>
        // CHECK-DAG: %[[ERASEDPTR:.+]] = llvm.bitcast %[[CAST_CLOSURE]] : !llvm.ptr<[[FPTR]]> to !llvm.ptr
        // CHECK-DAG: %[[RESULT:.+]] = llvm.call %[[LOADEDPTR]](%[[ERASEDPTR]], %[[CST1]]) : !llvm.[[FPTR]], (!llvm.ptr, i32) -> i32
        %res = closure.call %6(%cst1): !closure.box<(i32) -> i32>

        func.return
    }

}

// CHECK-LABEL: check_2captureArgs
module @check_2captureArgs {
    // CHECK-DAG: llvm.func private @[[CLOSURE_WORKER:.+]](%{{.+}}: i8, %{{.+}}: i32, %{{.+}}: i32) -> i32
    // CHECK-DAG: llvm.func private @[[CLOSURE_WRAPPER:.+]](%{{.+}}: !llvm.ptr, %{{.+}}: i32) -> i32
    func.func @main() {


        // CHECK-DAG: %[[CST0:.+]] = arith.constant 7 : i8
        %cst0 = arith.constant 7 : i8
        // CHECK-DAG: %[[CST1:.+]] = arith.constant 1 : i32
        %cst1 = arith.constant 1 : i32
        // CHECK-DAG: %[[CST24:.+]] = arith.constant 24 : i32
        %cst = arith.constant 24 : i32

        // CHECK-DAG: %[[ALLOC:.+]] = llvm.call @malloc(%{{.+}}) : (i64) -> !llvm.ptr
        // CHECK-DAG: %[[UD:.+]] = llvm.mlir.undef : !llvm.struct<([[FPTR:ptr<func<i32 \(ptr, i32\)>>]], struct<(i8, i32)>)>
        // CHECK-DAG: %[[WADDRESS:.+]] = llvm.mlir.addressof @[[CLOSURE_WRAPPER]] : !llvm.[[FPTR]]
        // CHECK-DAG: %[[STRUCT0:.+]] = llvm.insertvalue %[[WADDRESS]], %[[UD]][0] : !llvm.struct<([[FPTR]], struct<(i8, i32)>)> 
        // CHECK-DAG: %[[STRUCT1:.+]] = llvm.insertvalue %[[CST0]], %[[STRUCT0]][1, 0] : !llvm.struct<([[FPTR]], struct<(i8, i32)>)> 
        // CHECK-DAG: %[[STRUCT2:.+]] = llvm.insertvalue %[[CST24]], %[[STRUCT1]][1, 1] : !llvm.struct<([[FPTR]], struct<(i8, i32)>)> 
        // CHECK-DAG: %[[STOREPTR:.+]] = llvm.bitcast %[[ALLOC]] : !llvm.ptr to !llvm.ptr<struct<([[FPTR]], struct<(i8, i32)>)>>
        // CHECK-DAG: llvm.store %[[STRUCT2]], %[[STOREPTR]] : !llvm.ptr<struct<([[FPTR]], struct<(i8, i32)>)>>
        // CHECK-DAG: %[[CAST_CLOSURE:.+]] = llvm.bitcast %[[ALLOC]] : !llvm.ptr to !llvm.ptr<[[FPTR]]>
        %6 = closure.box [%x = %cst0: i8, %1 = %cst: i32] (%2 : i32) -> i32 {
            %9 = arith.addi %2, %1: i32
            closure.return %9: i32
        }

        func.return
    }

}


// CHECK-LABEL: check_0captureArg

module @check_0captureArg {
    // CHECK-DAG: llvm.func private @[[CLOSURE_WORKER:.+]](%{{.+}}: i32) -> i32
    // CHECK-DAG: llvm.func private @[[CLOSURE_WRAPPER:.+]](%{{.+}}: !llvm.ptr, %{{.+}}: i32) -> i32
    func.func @main() {


        // CHECK-DAG: %[[CST1:.+]] = arith.constant 1 : i32
        %cst1 = arith.constant 1 : i32

        // CHECK-DAG: %[[ALLOC:.+]] = llvm.call @malloc(%{{.+}}) : (i64) -> !llvm.ptr
        // CHECK-DAG: %[[UD:.+]] = llvm.mlir.undef : !llvm.struct<([[FPTR:ptr<func<i32 \(ptr, i32\)>>]], struct<()>)>
        // CHECK-DAG: %[[WADDRESS:.+]] = llvm.mlir.addressof @[[CLOSURE_WRAPPER]] : !llvm.[[FPTR]]
        // CHECK-DAG: %[[STRUCT0:.+]] = llvm.insertvalue %[[WADDRESS]], %[[UD]][0] : !llvm.struct<([[FPTR]], struct<()>)> 
        // CHECK-DAG: %[[STOREPTR:.+]] = llvm.bitcast %[[ALLOC]] : !llvm.ptr to !llvm.ptr<struct<([[FPTR]], struct<()>)>>
        // CHECK-DAG: llvm.store %[[STRUCT0]], %[[STOREPTR]] : !llvm.ptr<struct<([[FPTR]], struct<()>)>>
        // CHECK-DAG: %[[CAST_CLOSURE:.+]] = llvm.bitcast %[[ALLOC]] : !llvm.ptr to !llvm.ptr<[[FPTR]]>
        %6 = closure.box [] (%2 : i32) -> i32 {
            %9 = arith.addi %2, %2: i32
            closure.return %9: i32
        }

        // CHECK-DAG: %[[LOADEDPTR:.+]] = llvm.load %[[CAST_CLOSURE]] : !llvm.ptr<[[FPTR]]>
        // CHECK-DAG: %[[ERASEDPTR:.+]] = llvm.bitcast %[[CAST_CLOSURE]] : !llvm.ptr<[[FPTR]]> to !llvm.ptr
        // CHECK-DAG: %[[RESULT:.+]] = llvm.call %[[LOADEDPTR]](%[[ERASEDPTR]], %[[CST1]]) : !llvm.[[FPTR]], (!llvm.ptr, i32) -> i32
        %res = closure.call %6(%cst1): !closure.box<(i32) -> i32>

        func.return
    }

}
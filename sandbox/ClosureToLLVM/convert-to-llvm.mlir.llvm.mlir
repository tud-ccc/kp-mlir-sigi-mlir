module {
  llvm.func @malloc(i64) -> !llvm.ptr<i8>
  llvm.func private @closure_worker_0(%arg0: i32, %arg1: i32) -> i32 {
    %0 = llvm.add %arg0, %arg1  : i32
    llvm.return %0 : i32
  }
  llvm.func private @closure_wrapper_0(%arg0: !llvm.ptr, %arg1: i32) -> i32 {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>>
    %1 = llvm.getelementptr %0[0, 1] : (!llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>>) -> !llvm.ptr<struct<(i32)>>
    %2 = llvm.load %1 : !llvm.ptr<struct<(i32)>>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<(i32)> 
    %4 = llvm.call @closure_worker_0(%3, %arg1) : (i32, i32) -> i32
    llvm.return %4 : i32
  }
  llvm.func private @closure_drop_0(%arg0: !llvm.ptr) {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, i32, ptr<func<void(ptr)>>, struct<(i32)>)>>
    %1 = llvm.getelementptr %0[0, 1] : (!llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, i32, ptr<func<void(ptr)>>, struct<(i32)>)>>) -> !llvm.ptr<struct<(i32)>>
    // for each closure field: 
    %2 = llvm.load %1 : !llvm.ptr<struct<(i32)>>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<(i32)> 
    llvm.return %4 : i32
  }
  llvm.func @printf(!llvm.ptr, ...) -> i32
  llvm.mlir.global private constant @intFmt("%d\0A\00") {addr_space = 0 : i32}
  llvm.func @main() {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(24 : i32) : i32
    %2 = llvm.mlir.null : !llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>>
    %3 = llvm.getelementptr %2[1] : (!llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>>) -> !llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>>
    %4 = llvm.ptrtoint %3 : !llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>> to i64
    %5 = llvm.call @malloc(%4) : (i64) -> !llvm.ptr<i8>
    %6 = llvm.mlir.undef : !llvm.struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>
    %7 = llvm.mlir.addressof @closure_wrapper_0 : !llvm.ptr<func<i32 (ptr, i32)>>
    %8 = llvm.insertvalue %7, %6[0] : !llvm.struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)> 
    %9 = llvm.insertvalue %1, %8[1, 0] : !llvm.struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)> 
    %10 = llvm.bitcast %5 : !llvm.ptr<i8> to !llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>>
    llvm.store %9, %10 : !llvm.ptr<struct<(ptr<func<i32 (ptr, i32)>>, struct<(i32)>)>>
    %11 = llvm.bitcast %5 : !llvm.ptr<i8> to !llvm.ptr<ptr<func<i32 (ptr, i32)>>>
    %12 = llvm.load %11 : !llvm.ptr<ptr<func<i32 (ptr, i32)>>>
    %13 = llvm.bitcast %11 : !llvm.ptr<ptr<func<i32 (ptr, i32)>>> to !llvm.ptr
    %14 = llvm.call %12(%13, %0) : (!llvm.ptr, i32) -> i32
    %15 = llvm.mlir.addressof @intFmt : !llvm.ptr
    %16 = llvm.call @printf(%15, %14) : (!llvm.ptr, i32) -> i32
    llvm.return
  }
}


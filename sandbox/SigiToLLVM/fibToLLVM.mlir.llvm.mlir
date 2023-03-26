!sigistackptr = !llvm.ptr<struct<"sigi_stack_t", opaque>>
module {
  llvm.func @sigi_free_stack(!llvm.ptr<i8>)
  llvm.func @sigi_init_stack(!llvm.ptr<i8>)
  llvm.func @free(!llvm.ptr<i8>)
  llvm.func @sigi_pop_bool(!sigistackptr) -> i1
  llvm.func private @closure_worker_1(%arg0: i32, %arg1: i32, %arg2: !sigistackptr) -> !sigistackptr {
    llvm.call @sigi_push_i32(%arg2, %arg1) : (!sigistackptr, i32) -> ()
    %0 = llvm.call @show(%arg2) : (!sigistackptr) -> !sigistackptr
    llvm.call @sigi_push_i32(%0, %arg0) : (!sigistackptr, i32) -> ()
    %1 = llvm.mlir.constant(1 : i32) : i32
    llvm.call @sigi_push_i32(%0, %1) : (!sigistackptr, i32) -> ()
    %2 = llvm.call @sigi_pop_i32(%0) : (!sigistackptr) -> i32
    %3 = llvm.call @sigi_pop_i32(%0) : (!sigistackptr) -> i32
    %4 = llvm.sub %2, %3  : i32
    llvm.call @sigi_push_i32(%0, %4) : (!sigistackptr, i32) -> ()
    llvm.call @sigi_push_i32(%0, %arg1) : (!sigistackptr, i32) -> ()
    %5 = llvm.mlir.constant(10 : i32) : i32
    llvm.call @sigi_push_i32(%0, %5) : (!sigistackptr, i32) -> ()
    %6 = llvm.call @sigi_pop_i32(%0) : (!sigistackptr) -> i32
    %7 = llvm.call @sigi_pop_i32(%0) : (!sigistackptr) -> i32
    %8 = llvm.mul %6, %7  : i32
    llvm.call @sigi_push_i32(%0, %8) : (!sigistackptr, i32) -> ()
    %9 = llvm.call @fibloop(%0) : (!sigistackptr) -> !sigistackptr
    llvm.return %9 : !sigistackptr
  }
  llvm.func private @closure_wrapper_1(%arg0: !llvm.ptr, %arg1: !sigistackptr) -> !sigistackptr {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>>
    %1 = llvm.getelementptr %0[1] : (!llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>>) -> !llvm.ptr<struct<(i32, i32)>>
    %2 = llvm.load %1 : !llvm.ptr<struct<(i32, i32)>>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<(i32, i32)> 
    %4 = llvm.extractvalue %2[1] : !llvm.struct<(i32, i32)> 
    %5 = llvm.call @closure_worker_1(%3, %4, %arg1) : (i32, i32, !sigistackptr) -> !sigistackptr
    llvm.return %5 : !sigistackptr
  }
  llvm.func @sigi_push_closure(!sigistackptr, !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>)
  llvm.func @malloc(i64) -> !llvm.ptr<i8>
  llvm.func private @closure_worker_0(%arg0: !sigistackptr) -> !sigistackptr {
    llvm.return %arg0 : !sigistackptr
  }
  llvm.func private @closure_wrapper_0(%arg0: !llvm.ptr, %arg1: !sigistackptr) -> !sigistackptr {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>>
    %1 = llvm.getelementptr %0[1] : (!llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>>) -> !llvm.ptr<struct<()>>
    %2 = llvm.call @closure_worker_0(%arg1) : (!sigistackptr) -> !sigistackptr
    llvm.return %2 : !sigistackptr
  }
  llvm.func @sigi_push_bool(!sigistackptr, i1)
  llvm.func @sigi_push_i32(!sigistackptr, i32)
  llvm.func @sigi_pop_i32(!sigistackptr) -> i32
  llvm.func @sigi_pop_closure(!sigistackptr) -> !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>
  llvm.func @sigi_builtin__pp(!sigistackptr) -> !sigistackptr attributes {sym_visibility = "private"}
  llvm.func @apply(%arg0: !sigistackptr) -> !sigistackptr attributes {sym_visibility = "private"} {
    %0 = llvm.call @sigi_pop_closure(%arg0) : (!sigistackptr) -> !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>
    %1 = llvm.load %0 : !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>
    %2 = llvm.bitcast %0 : !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>> to !llvm.ptr
    %3 = llvm.call %1(%2, %arg0) : (!llvm.ptr, !sigistackptr) -> !sigistackptr
    llvm.return %3 : !sigistackptr
  }
  llvm.func @show(%arg0: !sigistackptr) -> !sigistackptr attributes {sym_visibility = "private"} {
    %0 = llvm.call @sigi_builtin__pp(%arg0) : (!sigistackptr) -> !sigistackptr
    %1 = llvm.call @sigi_pop_i32(%0) : (!sigistackptr) -> i32
    llvm.return %0 : !sigistackptr
  }
  llvm.func @fibloop(%arg0: !sigistackptr) -> !sigistackptr attributes {sym_visibility = "private"} {
    %0 = llvm.call @sigi_pop_i32(%arg0) : (!sigistackptr) -> i32
    %1 = llvm.call @sigi_pop_i32(%arg0) : (!sigistackptr) -> i32
    llvm.call @sigi_push_i32(%arg0, %0) : (!sigistackptr, i32) -> ()
    %2 = llvm.mlir.constant(0 : i32) : i32
    llvm.call @sigi_push_i32(%arg0, %2) : (!sigistackptr, i32) -> ()
    %3 = llvm.call @sigi_pop_i32(%arg0) : (!sigistackptr) -> i32
    %4 = llvm.call @sigi_pop_i32(%arg0) : (!sigistackptr) -> i32
    %5 = llvm.icmp "eq" %3, %4 : i32
    llvm.call @sigi_push_bool(%arg0, %5) : (!sigistackptr, i1) -> ()
    %6 = llvm.mlir.null : !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>>
    %7 = llvm.getelementptr %6[1] : (!llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>>) -> !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>>
    %8 = llvm.ptrtoint %7 : !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>> to i64
    %9 = llvm.call @malloc(%8) : (i64) -> !llvm.ptr<i8>
    %10 = llvm.mlir.undef : !llvm.struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>
    %11 = llvm.mlir.addressof @closure_wrapper_0 : !llvm.ptr<func<!sigistackptr (ptr, !sigistackptr)>>
    %12 = llvm.insertvalue %11, %10[0] : !llvm.struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)> 
    %13 = llvm.bitcast %9 : !llvm.ptr<i8> to !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>>
    llvm.store %12, %13 : !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<()>)>>
    %14 = llvm.bitcast %9 : !llvm.ptr<i8> to !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>
    llvm.call @sigi_push_closure(%arg0, %14) : (!sigistackptr, !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>) -> ()
    %15 = llvm.mlir.null : !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>>
    %16 = llvm.getelementptr %15[1] : (!llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>>) -> !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>>
    %17 = llvm.ptrtoint %16 : !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>> to i64
    %18 = llvm.call @malloc(%17) : (i64) -> !llvm.ptr<i8>
    %19 = llvm.mlir.undef : !llvm.struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>
    %20 = llvm.mlir.addressof @closure_wrapper_1 : !llvm.ptr<func<!sigistackptr (ptr, !sigistackptr)>>
    %21 = llvm.insertvalue %20, %19[0] : !llvm.struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)> 
    %22 = llvm.insertvalue %0, %21[1, 0] : !llvm.struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)> 
    %23 = llvm.insertvalue %1, %22[1, 1] : !llvm.struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)> 
    %24 = llvm.bitcast %18 : !llvm.ptr<i8> to !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>>
    llvm.store %23, %24 : !llvm.ptr<struct<(ptr<func<!sigistackptr (ptr, !sigistackptr)>>, struct<(i32, i32)>)>>
    %25 = llvm.bitcast %18 : !llvm.ptr<i8> to !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>
    llvm.call @sigi_push_closure(%arg0, %25) : (!sigistackptr, !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>) -> ()
    %26 = llvm.call @sigi_pop_closure(%arg0) : (!sigistackptr) -> !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>
    %27 = llvm.call @sigi_pop_closure(%arg0) : (!sigistackptr) -> !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>
    %28 = llvm.call @sigi_pop_bool(%arg0) : (!sigistackptr) -> i1
    llvm.cond_br %28, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    llvm.br ^bb3(%27 : !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>)
  ^bb2:  // pred: ^bb0
    llvm.br ^bb3(%26 : !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>)
  ^bb3(%29: !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>):  // 2 preds: ^bb1, ^bb2
    llvm.br ^bb4
  ^bb4:  // pred: ^bb3
    llvm.call @sigi_push_closure(%arg0, %29) : (!sigistackptr, !llvm.ptr<ptr<func<!sigistackptr (ptr, !sigistackptr)>>>) -> ()
    %30 = llvm.call @apply(%arg0) : (!sigistackptr) -> !sigistackptr
    llvm.return %30 : !sigistackptr
  }
  llvm.func @__main__(%arg0: !sigistackptr) -> !sigistackptr {
    %0 = llvm.mlir.constant(10 : i32) : i32
    llvm.call @sigi_push_i32(%arg0, %0) : (!sigistackptr, i32) -> ()
    %1 = llvm.mlir.constant(1 : i32) : i32
    llvm.call @sigi_push_i32(%arg0, %1) : (!sigistackptr, i32) -> ()
    %2 = llvm.call @fibloop(%arg0) : (!sigistackptr) -> !sigistackptr
    llvm.return %2 : !sigistackptr
  }
  llvm.func @main() {
    %0 = llvm.mlir.constant(128 : i64) : i64
    %1 = llvm.call @malloc(%0) : (i64) -> !llvm.ptr<i8>
    llvm.call @sigi_init_stack(%1) : (!llvm.ptr<i8>) -> ()
    %2 = llvm.bitcast %1 : !llvm.ptr<i8> to !sigistackptr
    %3 = llvm.call @__main__(%2) : (!sigistackptr) -> !sigistackptr
    llvm.call @sigi_free_stack(%1) : (!llvm.ptr<i8>) -> ()
    llvm.call @free(%1) : (!llvm.ptr<i8>) -> ()
    llvm.return
  }
}

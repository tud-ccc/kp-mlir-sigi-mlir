module {
  llvm.func private @closure_worker_1(%arg0: !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>, %arg1: !stackPtr) -> !stackPtr {
    llvm.call @sigi_push_closure(%arg1, %arg0) : (!stackPtr, !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>) -> ()
    llvm.call @sigi_push_closure(%arg1, %arg0) : (!stackPtr, !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>) -> ()
    llvm.return %arg1 : !stackPtr
  }
  llvm.func private @closure_wrapper_1(%arg0: !llvm.ptr, %arg1: !stackPtr) -> !stackPtr {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>>
    %1 = llvm.getelementptr %0[0, 1] : (!llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>>) -> !llvm.ptr<struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>>
    %2 = llvm.load %1 : !llvm.ptr<struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>
    %4 = llvm.call @closure_worker_1(%3, %arg1) : (!llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>, !stackPtr) -> !stackPtr
    llvm.return %4 : !stackPtr
  }
  llvm.func @sigi_pop_closure(!stackPtr) -> !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>
  llvm.func @sigi_push_closure(!stackPtr, !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)
  llvm.func @sigi_push_i32(!stackPtr, i32)
  llvm.func @closure_drop_nothing(%arg0: !llvm.ptr) {
    llvm.return
  }
  llvm.func private @closure_worker_0(%arg0: !stackPtr) -> !stackPtr {
    %c1_i32 = arith.constant 1 : i32
    llvm.call @sigi_push_i32(%arg0, %c1_i32) : (!stackPtr, i32) -> ()
    llvm.return %arg0 : !stackPtr
  }
  llvm.func private @closure_wrapper_0(%arg0: !llvm.ptr, %arg1: !stackPtr) -> !stackPtr {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    %1 = llvm.getelementptr %0[0, 1] : (!llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>) -> !llvm.ptr<struct<()>>
    %2 = llvm.load %1 : !llvm.ptr<struct<()>>
    %3 = llvm.call @closure_worker_0(%arg1) : (!stackPtr) -> !stackPtr
    llvm.return %3 : !stackPtr
  }
  llvm.func @closure_dec_or_drop(!llvm.ptr)
  llvm.func @sigi_free_stack(!llvm.ptr<i8>)
  llvm.func @sigi_init_stack(!llvm.ptr<i8>)
  llvm.func @free(!llvm.ptr<i8>)
  llvm.func @malloc(i64) -> !llvm.ptr<i8>
  llvm.func @__main__(%arg0: !stackPtr) -> !stackPtr {
    %0 = llvm.mlir.null : !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    %1 = llvm.getelementptr %0[1] : (!llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>) -> !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    %2 = llvm.ptrtoint %1 : !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>> to i64
    %3 = llvm.call @malloc(%2) : (i64) -> !llvm.ptr<i8>
    %4 = llvm.mlir.undef : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>
    %5 = llvm.mlir.addressof @closure_wrapper_0 : !llvm.ptr<func<!stackPtr (ptr, !stackPtr)>>
    %6 = llvm.mlir.addressof @closure_drop_nothing : !llvm.ptr<func<void (ptr)>>
    %7 = llvm.mlir.constant(1 : i32) : i32
    %8 = llvm.insertvalue %5, %4[0] : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>
    %9 = llvm.insertvalue %7, %8[1] : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>
    %10 = llvm.insertvalue %6, %9[2] : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>
    %11 = llvm.bitcast %3 : !llvm.ptr<i8> to !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    llvm.store %10, %11 : !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    %12 = llvm.bitcast %3 : !llvm.ptr<i8> to !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>
    llvm.call @sigi_push_closure(%arg0, %12) : (!stackPtr, !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>) -> ()
    %13 = llvm.call @sigi_pop_closure(%arg0) : (!stackPtr) -> !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>
    %14 = llvm.mlir.null : !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>>
    %15 = llvm.getelementptr %14[1] : (!llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>>) -> !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>>
    %16 = llvm.ptrtoint %15 : !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>> to i64
    %17 = llvm.call @malloc(%16) : (i64) -> !llvm.ptr<i8>
    %18 = llvm.mlir.undef : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>
    %19 = llvm.mlir.addressof @closure_wrapper_1 : !llvm.ptr<func<!stackPtr (ptr, !stackPtr)>>
    %20 = llvm.mlir.addressof @closure_drop_nothing : !llvm.ptr<func<void (ptr)>>
    %21 = llvm.mlir.constant(1 : i32) : i32
    %22 = llvm.insertvalue %19, %18[0] : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>
    %23 = llvm.insertvalue %21, %22[1] : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>
    %24 = llvm.insertvalue %20, %23[2] : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>
    %25 = llvm.insertvalue %13, %24[3, 0] : !llvm.struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>
    %26 = llvm.bitcast %17 : !llvm.ptr<i8> to !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>>
    llvm.store %25, %26 : !llvm.ptr<struct<(ptr<func<!stackPtr (ptr, !stackPtr)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>)>)>>
    %27 = llvm.bitcast %17 : !llvm.ptr<i8> to !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>
    llvm.call @sigi_push_closure(%arg0, %27) : (!stackPtr, !llvm.ptr<ptr<func<!stackPtr (ptr, !stackPtr)>>>) -> ()
    llvm.return %arg0 : !stackPtr
  }
  llvm.func @main() {
    %0 = llvm.mlir.constant(128 : i64) : i64
    %1 = llvm.call @malloc(%0) : (i64) -> !llvm.ptr<i8>
    llvm.call @sigi_init_stack(%1) : (!llvm.ptr<i8>) -> ()
    %2 = llvm.bitcast %1 : !llvm.ptr<i8> to !stackPtr
    %3 = llvm.call @__main__(%2) : (!stackPtr) -> !stackPtr
    llvm.call @sigi_free_stack(%1) : (!llvm.ptr<i8>) -> ()
    llvm.call @free(%1) : (!llvm.ptr<i8>) -> ()
    llvm.return
  }
}

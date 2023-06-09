module {
  llvm.func @closure_incr(!llvm.ptr)
  llvm.func private @closure_worker_1(%arg0: !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>, %arg1: !llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>> {
    llvm.call @sigi_push_closure(%arg1, %arg0) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>, !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>) -> ()
    llvm.call @sigi_push_closure(%arg1, %arg0) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>, !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>) -> ()
    llvm.return %arg1 : !llvm.ptr<struct<"sigi_stack_t", opaque>>
  }
  llvm.func private @closure_drop_0(%arg0: !llvm.ptr) {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>
    %1 = llvm.getelementptr %0[0, 3] : (!llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>) -> !llvm.ptr<struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>>
    %2 = llvm.load %1 : !llvm.ptr<struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)> 
    %4 = llvm.bitcast %3 : !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>> to !llvm.ptr
    llvm.call @closure_decr_then_drop(%4) : (!llvm.ptr) -> ()
    llvm.return
  }
  llvm.func private @closure_wrapper_1(%arg0: !llvm.ptr, %arg1: !llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>> {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>
    %1 = llvm.getelementptr %0[0, 3] : (!llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>) -> !llvm.ptr<struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>>
    %2 = llvm.load %1 : !llvm.ptr<struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>>
    %3 = llvm.extractvalue %2[0] : !llvm.struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)> 
    %4 = llvm.call @closure_worker_1(%3, %arg1) : (!llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>, !llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>>
    llvm.return %4 : !llvm.ptr<struct<"sigi_stack_t", opaque>>
  }
  llvm.func @sigi_push_closure(!llvm.ptr<struct<"sigi_stack_t", opaque>>, !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)
  llvm.func @sigi_push_i32(!llvm.ptr<struct<"sigi_stack_t", opaque>>, i32)
  llvm.func private @closure_drop_nothing(%arg0: !llvm.ptr) {
    llvm.return
  }
  llvm.func private @closure_worker_0(%arg0: !llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>> {
    %0 = llvm.mlir.constant(1 : i32) : i32
    llvm.call @sigi_push_i32(%arg0, %0) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>, i32) -> ()
    llvm.return %arg0 : !llvm.ptr<struct<"sigi_stack_t", opaque>>
  }
  llvm.func private @closure_wrapper_0(%arg0: !llvm.ptr, %arg1: !llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>> {
    %0 = llvm.bitcast %arg0 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    %1 = llvm.getelementptr %0[0, 3] : (!llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>) -> !llvm.ptr<struct<()>>
    %2 = llvm.call @closure_worker_0(%arg1) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>>
    llvm.return %2 : !llvm.ptr<struct<"sigi_stack_t", opaque>>
  }
  llvm.func @closure_decr_then_drop(!llvm.ptr)
  llvm.func @sigi_free_stack(!llvm.ptr)
  llvm.func @sigi_init_stack(!llvm.ptr)
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @closure_check_drop(!llvm.ptr)
  llvm.func @sigi_pop_closure(!llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>
  llvm.func @apply(%arg0: !llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>> attributes {sym_visibility = "private"} {
    %0 = llvm.call @sigi_pop_closure(%arg0) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>
    %1 = llvm.load %0 : !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>
    %2 = llvm.bitcast %0 : !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>> to !llvm.ptr
    %3 = llvm.call %1(%2, %arg0) : !llvm.ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, (!llvm.ptr, !llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>>
    llvm.call @closure_check_drop(%2) : (!llvm.ptr) -> ()
    llvm.return %3 : !llvm.ptr<struct<"sigi_stack_t", opaque>>
  }
  llvm.func @__main__(%arg0: !llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>> {
    %0 = llvm.mlir.null : !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    %1 = llvm.getelementptr %0[1] : (!llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>) -> !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    %2 = llvm.ptrtoint %1 : !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>> to i64
    %3 = llvm.call @malloc(%2) : (i64) -> !llvm.ptr
    %4 = llvm.mlir.undef : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>
    %5 = llvm.mlir.addressof @closure_wrapper_0 : !llvm.ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>
    %6 = llvm.mlir.addressof @closure_drop_nothing : !llvm.ptr<func<void (ptr)>>
    %7 = llvm.mlir.constant(0 : i32) : i32
    %8 = llvm.insertvalue %5, %4[0] : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)> 
    %9 = llvm.insertvalue %7, %8[1] : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)> 
    %10 = llvm.insertvalue %6, %9[2] : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)> 
    %11 = llvm.bitcast %3 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    llvm.store %10, %11 : !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<()>)>>
    %12 = llvm.bitcast %3 : !llvm.ptr to !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>
    llvm.call @sigi_push_closure(%arg0, %12) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>, !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>) -> ()
    %13 = llvm.call @sigi_pop_closure(%arg0) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>
    %14 = llvm.mlir.null : !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>
    %15 = llvm.getelementptr %14[1] : (!llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>) -> !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>
    %16 = llvm.ptrtoint %15 : !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>> to i64
    %17 = llvm.call @malloc(%16) : (i64) -> !llvm.ptr
    %18 = llvm.mlir.undef : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>
    %19 = llvm.mlir.addressof @closure_wrapper_1 : !llvm.ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>
    %20 = llvm.mlir.addressof @closure_drop_0 : !llvm.ptr<func<void (ptr)>>
    %21 = llvm.insertvalue %19, %18[0] : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)> 
    %22 = llvm.insertvalue %7, %21[1] : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)> 
    %23 = llvm.insertvalue %20, %22[2] : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)> 
    %24 = llvm.bitcast %13 : !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>> to !llvm.ptr
    llvm.call @closure_incr(%24) : (!llvm.ptr) -> ()
    %25 = llvm.insertvalue %13, %23[3, 0] : !llvm.struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)> 
    %26 = llvm.bitcast %17 : !llvm.ptr to !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>
    llvm.store %25, %26 : !llvm.ptr<struct<(ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>, i32, ptr<func<void (ptr)>>, struct<(ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>)>)>>
    %27 = llvm.bitcast %17 : !llvm.ptr to !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>
    llvm.call @sigi_push_closure(%arg0, %27) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>, !llvm.ptr<ptr<func<ptr<struct<"sigi_stack_t", opaque>> (ptr, ptr<struct<"sigi_stack_t", opaque>>)>>>) -> ()
    %28 = llvm.call @apply(%arg0) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>>
    llvm.call @closure_check_drop(%24) : (!llvm.ptr) -> ()
    llvm.return %28 : !llvm.ptr<struct<"sigi_stack_t", opaque>>
  }
  llvm.func @main() {
    %0 = llvm.mlir.constant(128 : i64) : i64
    %1 = llvm.call @malloc(%0) : (i64) -> !llvm.ptr
    llvm.call @sigi_init_stack(%1) : (!llvm.ptr) -> ()
    %2 = llvm.bitcast %1 : !llvm.ptr to !llvm.ptr<struct<"sigi_stack_t", opaque>>
    %3 = llvm.call @__main__(%2) : (!llvm.ptr<struct<"sigi_stack_t", opaque>>) -> !llvm.ptr<struct<"sigi_stack_t", opaque>>
    llvm.call @sigi_free_stack(%1) : (!llvm.ptr) -> ()
    llvm.call @free(%1) : (!llvm.ptr) -> ()
    llvm.return
  }
}


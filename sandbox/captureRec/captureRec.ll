; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare ptr @malloc(i64)

declare void @free(ptr)

declare void @closure_incr(ptr)

define private ptr @closure_worker_1(ptr %0, ptr %1) {
  call void @sigi_push_closure(ptr %1, ptr %0)
  call void @sigi_push_closure(ptr %1, ptr %0)
  ret ptr %1
}

define private void @closure_drop_0(ptr %0) {
  %2 = getelementptr { ptr, i32, ptr, { ptr } }, ptr %0, i32 0, i32 3
  %3 = load { ptr }, ptr %2, align 8
  %4 = extractvalue { ptr } %3, 0
  call void @closure_decr_then_drop(ptr %4)
  ret void
}

define private ptr @closure_wrapper_1(ptr %0, ptr %1) {
  %3 = getelementptr { ptr, i32, ptr, { ptr } }, ptr %0, i32 0, i32 3
  %4 = load { ptr }, ptr %3, align 8
  %5 = extractvalue { ptr } %4, 0
  %6 = call ptr @closure_worker_1(ptr %5, ptr %1)
  ret ptr %6
}

declare void @sigi_push_closure(ptr, ptr)

declare void @sigi_push_i32(ptr, i32)

define private void @closure_drop_nothing(ptr %0) {
  ret void
}

define private ptr @closure_worker_0(ptr %0) {
  call void @sigi_push_i32(ptr %0, i32 1)
  ret ptr %0
}

define private ptr @closure_wrapper_0(ptr %0, ptr %1) {
  %3 = getelementptr { ptr, i32, ptr, {} }, ptr %0, i32 0, i32 3
  %4 = call ptr @closure_worker_0(ptr %1)
  ret ptr %4
}

declare void @closure_decr_then_drop(ptr)

declare void @sigi_free_stack(ptr)

declare void @sigi_init_stack(ptr)

declare void @closure_check_drop(ptr)

declare ptr @sigi_pop_closure(ptr)

define ptr @apply(ptr %0) {
  %2 = call ptr @sigi_pop_closure(ptr %0)
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr %3(ptr %2, ptr %0)
  call void @closure_check_drop(ptr %2)
  ret ptr %4
}

define ptr @__main__(ptr %0) {
  %2 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, i32, ptr, {} }, ptr null, i32 1) to i64))
  store { ptr, i32, ptr, {} } { ptr @closure_wrapper_0, i32 0, ptr @closure_drop_nothing, {} undef }, ptr %2, align 8
  call void @sigi_push_closure(ptr %0, ptr %2)
  %3 = call ptr @sigi_pop_closure(ptr %0)
  %4 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, i32, ptr, { ptr } }, ptr null, i32 1) to i64))
  call void @closure_incr(ptr %3)
  %5 = insertvalue { ptr, i32, ptr, { ptr } } { ptr @closure_wrapper_1, i32 0, ptr @closure_drop_0, { ptr } undef }, ptr %3, 3, 0
  store { ptr, i32, ptr, { ptr } } %5, ptr %4, align 8
  call void @sigi_push_closure(ptr %0, ptr %4)
  %6 = call ptr @apply(ptr %0)
  call void @closure_check_drop(ptr %3)
  ret ptr %6
}

define void @main() {
  %1 = call ptr @malloc(i64 128)
  call void @sigi_init_stack(ptr %1)
  %2 = call ptr @__main__(ptr %1)
  call void @sigi_free_stack(ptr %1)
  call void @free(ptr %1)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}

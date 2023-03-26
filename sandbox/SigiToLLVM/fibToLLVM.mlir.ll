; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare ptr @malloc(i64)

declare void @free(ptr)

declare void @sigi_free_stack(ptr)

declare void @sigi_init_stack(ptr)

define private ptr @closure_worker_5(i32 %0, i32 %1, i32 %2, ptr %3) {
  call void @sigi_push_i32(ptr %3, i32 %0)
  call void @sigi_push_i32(ptr %3, i32 1)
  %5 = call i32 @sigi_pop_i32(ptr %3)
  %6 = call i32 @sigi_pop_i32(ptr %3)
  %7 = sub i32 %5, %6
  call void @sigi_push_i32(ptr %3, i32 %7)
  call void @sigi_push_i32(ptr %3, i32 %2)
  call void @sigi_push_i32(ptr %3, i32 %1)
  call void @sigi_push_i32(ptr %3, i32 %2)
  %8 = call i32 @sigi_pop_i32(ptr %3)
  %9 = call i32 @sigi_pop_i32(ptr %3)
  %10 = add i32 %8, %9
  call void @sigi_push_i32(ptr %3, i32 %10)
  %11 = call ptr @fib_tailrec_helper(ptr %3)
  ret ptr %11
}

define private ptr @closure_wrapper_5(ptr %0, ptr %1) {
  %3 = getelementptr { ptr, { i32, i32, i32 } }, ptr %0, i32 0, i32 1
  %4 = load { i32, i32, i32 }, ptr %3, align 4
  %5 = extractvalue { i32, i32, i32 } %4, 0
  %6 = extractvalue { i32, i32, i32 } %4, 1
  %7 = extractvalue { i32, i32, i32 } %4, 2
  %8 = call ptr @closure_worker_5(i32 %5, i32 %6, i32 %7, ptr %1)
  ret ptr %8
}

define private ptr @closure_worker_4(i32 %0, ptr %1) {
  call void @sigi_push_i32(ptr %1, i32 %0)
  ret ptr %1
}

define private ptr @closure_wrapper_4(ptr %0, ptr %1) {
  %3 = getelementptr { ptr, { i32 } }, ptr %0, i32 0, i32 1
  %4 = load { i32 }, ptr %3, align 4
  %5 = extractvalue { i32 } %4, 0
  %6 = call ptr @closure_worker_4(i32 %5, ptr %1)
  ret ptr %6
}

define private ptr @closure_worker_3(i32 %0, i32 %1, i32 %2, ptr %3) {
  call void @sigi_push_i32(ptr %3, i32 %0)
  call void @sigi_push_i32(ptr %3, i32 1)
  %5 = call i32 @sigi_pop_i32(ptr %3)
  %6 = call i32 @sigi_pop_i32(ptr %3)
  %7 = icmp eq i32 %5, %6
  call void @sigi_push_bool(ptr %3, i1 %7)
  %8 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, { i32 } }, ptr null, i32 1) to i64))
  %9 = insertvalue { ptr, { i32 } } { ptr @closure_wrapper_4, { i32 } undef }, i32 %2, 1, 0
  store { ptr, { i32 } } %9, ptr %8, align 8
  call void @sigi_push_closure(ptr %3, ptr %8)
  %10 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, { i32, i32, i32 } }, ptr null, i32 1) to i64))
  %11 = insertvalue { ptr, { i32, i32, i32 } } { ptr @closure_wrapper_5, { i32, i32, i32 } undef }, i32 %0, 1, 0
  %12 = insertvalue { ptr, { i32, i32, i32 } } %11, i32 %1, 1, 0
  %13 = insertvalue { ptr, { i32, i32, i32 } } %12, i32 %2, 1, 0
  store { ptr, { i32, i32, i32 } } %13, ptr %10, align 8
  call void @sigi_push_closure(ptr %3, ptr %10)
  %14 = call ptr @sigi_pop_closure(ptr %3)
  %15 = call ptr @sigi_pop_closure(ptr %3)
  %16 = call i1 @sigi_pop_bool(ptr %3)
  br i1 %16, label %17, label %18

17:                                               ; preds = %4
  br label %19

18:                                               ; preds = %4
  br label %19

19:                                               ; preds = %17, %18
  %20 = phi ptr [ %14, %18 ], [ %15, %17 ]
  br label %21

21:                                               ; preds = %19
  call void @sigi_push_closure(ptr %3, ptr %20)
  %22 = call ptr @apply(ptr %3)
  ret ptr %22
}

define private ptr @closure_wrapper_3(ptr %0, ptr %1) {
  %3 = getelementptr { ptr, { i32, i32, i32 } }, ptr %0, i32 0, i32 1
  %4 = load { i32, i32, i32 }, ptr %3, align 4
  %5 = extractvalue { i32, i32, i32 } %4, 0
  %6 = extractvalue { i32, i32, i32 } %4, 1
  %7 = extractvalue { i32, i32, i32 } %4, 2
  %8 = call ptr @closure_worker_3(i32 %5, i32 %6, i32 %7, ptr %1)
  ret ptr %8
}

define private ptr @closure_worker_2(i32 %0, ptr %1) {
  call void @sigi_push_i32(ptr %1, i32 %0)
  ret ptr %1
}

define private ptr @closure_wrapper_2(ptr %0, ptr %1) {
  %3 = getelementptr { ptr, { i32 } }, ptr %0, i32 0, i32 1
  %4 = load { i32 }, ptr %3, align 4
  %5 = extractvalue { i32 } %4, 0
  %6 = call ptr @closure_worker_2(i32 %5, ptr %1)
  ret ptr %6
}

define private ptr @closure_worker_1(i32 %0, ptr %1) {
  call void @sigi_push_i32(ptr %1, i32 %0)
  call void @sigi_push_i32(ptr %1, i32 2)
  %3 = call i32 @sigi_pop_i32(ptr %1)
  %4 = call i32 @sigi_pop_i32(ptr %1)
  %5 = sub i32 %3, %4
  call void @sigi_push_i32(ptr %1, i32 %5)
  %6 = call ptr @fib_naive(ptr %1)
  call void @sigi_push_i32(ptr %6, i32 %0)
  call void @sigi_push_i32(ptr %6, i32 1)
  %7 = call i32 @sigi_pop_i32(ptr %6)
  %8 = call i32 @sigi_pop_i32(ptr %6)
  %9 = sub i32 %7, %8
  call void @sigi_push_i32(ptr %6, i32 %9)
  %10 = call ptr @fib_naive(ptr %6)
  %11 = call i32 @sigi_pop_i32(ptr %10)
  %12 = call i32 @sigi_pop_i32(ptr %10)
  %13 = add i32 %11, %12
  call void @sigi_push_i32(ptr %10, i32 %13)
  ret ptr %10
}

define private ptr @closure_wrapper_1(ptr %0, ptr %1) {
  %3 = getelementptr { ptr, { i32 } }, ptr %0, i32 0, i32 1
  %4 = load { i32 }, ptr %3, align 4
  %5 = extractvalue { i32 } %4, 0
  %6 = call ptr @closure_worker_1(i32 %5, ptr %1)
  ret ptr %6
}

declare void @sigi_push_closure(ptr, ptr)

define private ptr @closure_worker_0(ptr %0) {
  call void @sigi_push_i32(ptr %0, i32 1)
  ret ptr %0
}

define private ptr @closure_wrapper_0(ptr %0, ptr %1) {
  %3 = getelementptr { ptr, {} }, ptr %0, i32 0, i32 1
  %4 = call ptr @closure_worker_0(ptr %1)
  ret ptr %4
}

declare void @sigi_push_bool(ptr, i1)

declare void @sigi_push_i32(ptr, i32)

declare i32 @sigi_pop_i32(ptr)

declare i1 @sigi_pop_bool(ptr)

declare ptr @sigi_pop_closure(ptr)

declare ptr @sigi_builtin__pp(ptr)

define ptr @apply(ptr %0) {
  %2 = call ptr @sigi_pop_closure(ptr %0)
  %3 = load ptr, ptr %2, align 8
  %4 = call ptr %3(ptr %2, ptr %0)
  ret ptr %4
}

define ptr @show(ptr %0) {
  %2 = call ptr @sigi_builtin__pp(ptr %0)
  %3 = call i1 @sigi_pop_bool(ptr %2)
  ret ptr %2
}

define ptr @fib_naive(ptr %0) {
  %2 = call i32 @sigi_pop_i32(ptr %0)
  call void @sigi_push_i32(ptr %0, i32 %2)
  call void @sigi_push_i32(ptr %0, i32 1)
  %3 = call i32 @sigi_pop_i32(ptr %0)
  %4 = call i32 @sigi_pop_i32(ptr %0)
  %5 = icmp sle i32 %3, %4
  call void @sigi_push_bool(ptr %0, i1 %5)
  %6 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, {} }, ptr null, i32 1) to i64))
  store { ptr, {} } { ptr @closure_wrapper_0, {} undef }, ptr %6, align 8
  call void @sigi_push_closure(ptr %0, ptr %6)
  %7 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, { i32 } }, ptr null, i32 1) to i64))
  %8 = insertvalue { ptr, { i32 } } { ptr @closure_wrapper_1, { i32 } undef }, i32 %2, 1, 0
  store { ptr, { i32 } } %8, ptr %7, align 8
  call void @sigi_push_closure(ptr %0, ptr %7)
  %9 = call ptr @sigi_pop_closure(ptr %0)
  %10 = call ptr @sigi_pop_closure(ptr %0)
  %11 = call i1 @sigi_pop_bool(ptr %0)
  br i1 %11, label %12, label %13

12:                                               ; preds = %1
  br label %14

13:                                               ; preds = %1
  br label %14

14:                                               ; preds = %12, %13
  %15 = phi ptr [ %9, %13 ], [ %10, %12 ]
  br label %16

16:                                               ; preds = %14
  call void @sigi_push_closure(ptr %0, ptr %15)
  %17 = call ptr @apply(ptr %0)
  ret ptr %17
}

define ptr @fib_tailrec(ptr %0) {
  call void @sigi_push_i32(ptr %0, i32 1)
  call void @sigi_push_i32(ptr %0, i32 1)
  %2 = call ptr @fib_tailrec_helper(ptr %0)
  ret ptr %2
}

define ptr @fib_tailrec_helper(ptr %0) {
  %2 = call i32 @sigi_pop_i32(ptr %0)
  %3 = call i32 @sigi_pop_i32(ptr %0)
  %4 = call i32 @sigi_pop_i32(ptr %0)
  call void @sigi_push_i32(ptr %0, i32 %2)
  call void @sigi_push_i32(ptr %0, i32 0)
  %5 = call i32 @sigi_pop_i32(ptr %0)
  %6 = call i32 @sigi_pop_i32(ptr %0)
  %7 = icmp eq i32 %5, %6
  call void @sigi_push_bool(ptr %0, i1 %7)
  %8 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, { i32 } }, ptr null, i32 1) to i64))
  %9 = insertvalue { ptr, { i32 } } { ptr @closure_wrapper_2, { i32 } undef }, i32 %3, 1, 0
  store { ptr, { i32 } } %9, ptr %8, align 8
  call void @sigi_push_closure(ptr %0, ptr %8)
  %10 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, { i32, i32, i32 } }, ptr null, i32 1) to i64))
  %11 = insertvalue { ptr, { i32, i32, i32 } } { ptr @closure_wrapper_3, { i32, i32, i32 } undef }, i32 %2, 1, 0
  %12 = insertvalue { ptr, { i32, i32, i32 } } %11, i32 %3, 1, 0
  %13 = insertvalue { ptr, { i32, i32, i32 } } %12, i32 %4, 1, 0
  store { ptr, { i32, i32, i32 } } %13, ptr %10, align 8
  call void @sigi_push_closure(ptr %0, ptr %10)
  %14 = call ptr @sigi_pop_closure(ptr %0)
  %15 = call ptr @sigi_pop_closure(ptr %0)
  %16 = call i1 @sigi_pop_bool(ptr %0)
  br i1 %16, label %17, label %18

17:                                               ; preds = %1
  br label %19

18:                                               ; preds = %1
  br label %19

19:                                               ; preds = %17, %18
  %20 = phi ptr [ %14, %18 ], [ %15, %17 ]
  br label %21

21:                                               ; preds = %19
  call void @sigi_push_closure(ptr %0, ptr %20)
  %22 = call ptr @apply(ptr %0)
  ret ptr %22
}

define ptr @__main__(ptr %0) {
  call void @sigi_push_i32(ptr %0, i32 20)
  %2 = call ptr @fib_tailrec(ptr %0)
  call void @sigi_push_i32(ptr %2, i32 20)
  %3 = call ptr @fib_naive(ptr %2)
  %4 = call i32 @sigi_pop_i32(ptr %3)
  %5 = call i32 @sigi_pop_i32(ptr %3)
  %6 = icmp eq i32 %4, %5
  call void @sigi_push_bool(ptr %3, i1 %6)
  %7 = call ptr @show(ptr %3)
  ret ptr %7
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

; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

@intFmt = private constant [4 x i8] c"%d\0A\00"

declare ptr @malloc(i64)

declare void @free(ptr)

define private i32 @closure_worker_0(i32 %0, i32 %1) {
  %3 = add i32 %0, %1
  ret i32 %3
}

define private i32 @closure_wrapper_0(ptr %0, i32 %1) {
  %3 = getelementptr { ptr, { i32 } }, ptr %0, i32 0, i32 1
  %4 = load { i32 }, ptr %3, align 4
  %5 = extractvalue { i32 } %4, 0
  %6 = call i32 @closure_worker_0(i32 %5, i32 %1)
  ret i32 %6
}

declare i32 @printf(ptr, ...)

define void @main() {
  %1 = call ptr @malloc(i64 ptrtoint (ptr getelementptr ({ ptr, { i32 } }, ptr null, i32 1) to i64))
  store { ptr, { i32 } } { ptr @closure_wrapper_0, { i32 } { i32 24 } }, ptr %1, align 8
  %2 = load ptr, ptr %1, align 8
  %3 = call i32 %2(ptr %1, i32 1)
  %4 = call i32 (ptr, ...) @printf(ptr @intFmt, i32 %3)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}

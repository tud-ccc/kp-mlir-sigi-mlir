; ModuleID = 'sandbox/ClosureToLLVM/convert-to-llvm.mlir.ll'
source_filename = "LLVMDialectModule"

@intFmt = private constant [4 x i8] c"%d\0A\00"

; Function Attrs: mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite)
declare noalias noundef ptr @malloc(i64 noundef) local_unnamed_addr #0

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define private i32 @closure_wrapper_0(ptr nocapture readonly %0, i32 %1) #1 {
  %3 = getelementptr { ptr, { i32 } }, ptr %0, i64 0, i32 1
  %.unpack = load i32, ptr %3, align 4
  %4 = add i32 %.unpack, %1
  ret i32 %4
}

; Function Attrs: nofree nounwind
declare noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #2

; Function Attrs: nofree nounwind
define void @main() local_unnamed_addr #2 {
  %1 = tail call dereferenceable_or_null(16) ptr @malloc(i64 16)
  store { ptr, { i32 } } { ptr @closure_wrapper_0, { i32 } { i32 24 } }, ptr %1, align 8
  %2 = getelementptr { ptr, { i32 } }, ptr %1, i64 0, i32 1
  %.unpack.i = load i32, ptr %2, align 4
  %3 = add i32 %.unpack.i, 1
  %4 = tail call i32 (ptr, ...) @printf(ptr nonnull dereferenceable(1) @intFmt, i32 %3)
  ret void
}

attributes #0 = { mustprogress nofree nounwind willreturn allockind("alloc,uninitialized") allocsize(0) memory(inaccessiblemem: readwrite) "alloc-family"="malloc" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) }
attributes #2 = { nofree nounwind }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}

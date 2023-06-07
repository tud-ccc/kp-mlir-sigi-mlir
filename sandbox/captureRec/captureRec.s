	.text
	.file	"LLVMDialectModule"
	.p2align	4, 0x90                         # -- Begin function closure_worker_1
	.type	.Lclosure_worker_1,@function
.Lclosure_worker_1:                     # @closure_worker_1
	.cfi_startproc
# %bb.0:
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rsi, (%rsp)                    # 8-byte Spill
	movq	%rdi, %rsi
	movq	(%rsp), %rdi                    # 8-byte Reload
	movq	%rsi, 8(%rsp)                   # 8-byte Spill
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	callq	sigi_push_closure@PLT
	movq	8(%rsp), %rsi                   # 8-byte Reload
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_push_closure@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	.Lclosure_worker_1, .Lfunc_end0-.Lclosure_worker_1
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_drop_0
	.type	.Lclosure_drop_0,@function
.Lclosure_drop_0:                       # @closure_drop_0
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	24(%rdi), %rdi
	callq	closure_decr_then_drop@PLT
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	.Lclosure_drop_0, .Lfunc_end1-.Lclosure_drop_0
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_1
	.type	.Lclosure_wrapper_1,@function
.Lclosure_wrapper_1:                    # @closure_wrapper_1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	24(%rdi), %rdi
	callq	.Lclosure_worker_1
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	.Lclosure_wrapper_1, .Lfunc_end2-.Lclosure_wrapper_1
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_drop_nothing
	.type	.Lclosure_drop_nothing,@function
.Lclosure_drop_nothing:                 # @closure_drop_nothing
	.cfi_startproc
# %bb.0:
	retq
.Lfunc_end3:
	.size	.Lclosure_drop_nothing, .Lfunc_end3-.Lclosure_drop_nothing
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_worker_0
	.type	.Lclosure_worker_0,@function
.Lclosure_worker_0:                     # @closure_worker_0
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rdi, (%rsp)                    # 8-byte Spill
	movl	$1, %esi
	callq	sigi_push_i32@PLT
	movq	(%rsp), %rax                    # 8-byte Reload
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	.Lclosure_worker_0, .Lfunc_end4-.Lclosure_worker_0
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_0
	.type	.Lclosure_wrapper_0,@function
.Lclosure_wrapper_0:                    # @closure_wrapper_0
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsi, (%rsp)                    # 8-byte Spill
	movq	%rdi, %rax
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	.Lclosure_worker_0
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end5:
	.size	.Lclosure_wrapper_0, .Lfunc_end5-.Lclosure_wrapper_0
	.cfi_endproc
                                        # -- End function
	.globl	apply                           # -- Begin function apply
	.p2align	4, 0x90
	.type	apply,@function
apply:                                  # @apply
	.cfi_startproc
# %bb.0:
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rdi, (%rsp)                    # 8-byte Spill
	callq	sigi_pop_closure@PLT
	movq	(%rsp), %rsi                    # 8-byte Reload
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movq	%rax, %rdi
	callq	*(%rax)
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	callq	closure_check_drop@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end6:
	.size	apply, .Lfunc_end6-apply
	.cfi_endproc
                                        # -- End function
	.globl	__main__                        # -- Begin function __main__
	.p2align	4, 0x90
	.type	__main__,@function
__main__:                               # @__main__
	.cfi_startproc
# %bb.0:
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	movq	%rdi, 32(%rsp)                  # 8-byte Spill
	movl	$24, %edi
	callq	malloc@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rsi
	movq	$.Lclosure_drop_nothing, 16(%rsi)
	movl	$0, 8(%rsi)
	movq	$.Lclosure_wrapper_0, (%rsi)
	callq	sigi_push_closure@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_closure@PLT
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	movq	%rax, 40(%rsp)                  # 8-byte Spill
	movl	$32, %edi
	callq	malloc@PLT
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	movq	%rax, 24(%rsp)                  # 8-byte Spill
	callq	closure_incr@PLT
	movq	8(%rsp), %rcx                   # 8-byte Reload
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	24(%rsp), %rsi                  # 8-byte Reload
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movq	%rcx, 24(%rax)
	movq	$.Lclosure_drop_0, 16(%rax)
	movl	$0, 8(%rax)
	movq	$.Lclosure_wrapper_1, (%rax)
	callq	sigi_push_closure@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	apply@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	callq	closure_check_drop@PLT
	movq	48(%rsp), %rax                  # 8-byte Reload
	addq	$56, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end7:
	.size	__main__, .Lfunc_end7-__main__
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$128, %edi
	callq	malloc@PLT
	movq	%rax, %rdi
	movq	%rdi, (%rsp)                    # 8-byte Spill
	callq	sigi_init_stack@PLT
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	__main__@PLT
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	sigi_free_stack@PLT
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	free@PLT
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end8:
	.size	main, .Lfunc_end8-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits

	.text
	.file	"LLVMDialectModule"
	.p2align	4, 0x90                         # -- Begin function closure_worker_0
	.type	.Lclosure_worker_0,@function
.Lclosure_worker_0:                     # @closure_worker_0
	.cfi_startproc
# %bb.0:
	movl	%edi, %eax
	addl	%esi, %eax
	retq
.Lfunc_end0:
	.size	.Lclosure_worker_0, .Lfunc_end0-.Lclosure_worker_0
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_0
	.type	.Lclosure_wrapper_0,@function
.Lclosure_wrapper_0:                    # @closure_wrapper_0
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	8(%rdi), %edi
	callq	.Lclosure_worker_0
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	.Lclosure_wrapper_0, .Lfunc_end1-.Lclosure_wrapper_0
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
	movl	$16, %edi
	callq	malloc@PLT
	movq	%rax, %rcx
	movq	%rcx, %rax
	movl	$24, 8(%rcx)
	movq	$.Lclosure_wrapper_0, (%rcx)
	movl	$1, %esi
	movq	%rax, %rdi
	callq	*(%rax)
	movl	%eax, %esi
	movabsq	$.LintFmt, %rdi
	movb	$0, %al
	callq	printf@PLT
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	main, .Lfunc_end2-main
	.cfi_endproc
                                        # -- End function
	.type	.LintFmt,@object                # @intFmt
	.section	.rodata,"a",@progbits
.LintFmt:
	.asciz	"%d\n"
	.size	.LintFmt, 4

	.section	".note.GNU-stack","",@progbits

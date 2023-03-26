	.text
	.file	"LLVMDialectModule"
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_0
	.type	.Lclosure_wrapper_0,@function
.Lclosure_wrapper_0:                    # @closure_wrapper_0
# %bb.0:
	movl	%esi, %eax
	addl	8(%rdi), %eax
	retq
.Lfunc_end0:
	.size	.Lclosure_wrapper_0, .Lfunc_end0-.Lclosure_wrapper_0
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
# %bb.0:
	pushq	%rax
	movl	$16, %edi
	callq	malloc@PLT
	movl	$24, 8(%rax)
	movq	$.Lclosure_wrapper_0, (%rax)
	movl	8(%rax), %esi
	incl	%esi
	movl	$.LintFmt, %edi
	xorl	%eax, %eax
                                        # kill: def $al killed $al killed $eax
	popq	%rcx
	jmp	printf@PLT                      # TAILCALL
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
                                        # -- End function
	.type	.LintFmt,@object                # @intFmt
	.section	.rodata,"a",@progbits
.LintFmt:
	.asciz	"%d\n"
	.size	.LintFmt, 4

	.section	".note.GNU-stack","",@progbits

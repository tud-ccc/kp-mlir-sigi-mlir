	.text
	.file	"LLVMDialectModule"
	.p2align	4, 0x90                         # -- Begin function closure_worker_5
	.type	.Lclosure_worker_5,@function
.Lclosure_worker_5:                     # @closure_worker_5
	.cfi_startproc
# %bb.0:
	subq	$40, %rsp
	.cfi_def_cfa_offset 48
	movq	%rcx, 8(%rsp)                   # 8-byte Spill
	movl	%esi, %eax
	movl	%edi, %esi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movl	%eax, 20(%rsp)                  # 4-byte Spill
	movl	%edx, 24(%rsp)                  # 4-byte Spill
	movq	%rdi, 32(%rsp)                  # 8-byte Spill
	callq	sigi_push_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movl	$1, %esi
	callq	sigi_push_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 16(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movl	16(%rsp), %esi                  # 4-byte Reload
	movq	32(%rsp), %rdi                  # 8-byte Reload
	subl	%eax, %esi
	callq	sigi_push_i32@PLT
	movl	24(%rsp), %esi                  # 4-byte Reload
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_push_i32@PLT
	movl	20(%rsp), %esi                  # 4-byte Reload
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_push_i32@PLT
	movl	24(%rsp), %esi                  # 4-byte Reload
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_push_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 28(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movl	28(%rsp), %esi                  # 4-byte Reload
	movq	32(%rsp), %rdi                  # 8-byte Reload
	addl	%eax, %esi
	callq	sigi_push_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	fib_tailrec_helper@PLT
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	.Lclosure_worker_5, .Lfunc_end0-.Lclosure_worker_5
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_5
	.type	.Lclosure_wrapper_5,@function
.Lclosure_wrapper_5:                    # @closure_wrapper_5
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsi, %rcx
	movq	%rdi, %rax
	movl	16(%rax), %edx
	movl	8(%rax), %edi
	movl	12(%rax), %esi
	callq	.Lclosure_worker_5
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	.Lclosure_wrapper_5, .Lfunc_end1-.Lclosure_wrapper_5
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_worker_4
	.type	.Lclosure_worker_4,@function
.Lclosure_worker_4:                     # @closure_worker_4
	.cfi_startproc
# %bb.0:
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rsi, 8(%rsp)                   # 8-byte Spill
	movl	%edi, %esi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	callq	sigi_push_i32@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	.Lclosure_worker_4, .Lfunc_end2-.Lclosure_worker_4
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_4
	.type	.Lclosure_wrapper_4,@function
.Lclosure_wrapper_4:                    # @closure_wrapper_4
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	8(%rdi), %edi
	callq	.Lclosure_worker_4
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end3:
	.size	.Lclosure_wrapper_4, .Lfunc_end3-.Lclosure_wrapper_4
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_worker_3
	.type	.Lclosure_worker_3,@function
.Lclosure_worker_3:                     # @closure_worker_3
	.cfi_startproc
# %bb.0:
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	movq	%rcx, 16(%rsp)                  # 8-byte Spill
	movl	%esi, %eax
	movl	%edi, %esi
	movq	16(%rsp), %rdi                  # 8-byte Reload
	movl	%edx, 28(%rsp)                  # 4-byte Spill
	movq	%rdi, 40(%rsp)                  # 8-byte Spill
	callq	sigi_push_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	$1, %esi
	callq	sigi_push_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 24(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, %ecx
	movl	24(%rsp), %eax                  # 4-byte Reload
	subl	%ecx, %eax
	sete	%al
	movzbl	%al, %esi
	callq	sigi_push_bool@PLT
	movl	$16, %edi
	callq	malloc@PLT
	movl	28(%rsp), %edx                  # 4-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rsi
	movl	%edx, 8(%rsi)
	movq	$.Lclosure_wrapper_4, (%rsi)
	callq	sigi_push_closure@PLT
	movl	$24, %edi
	callq	malloc@PLT
	movl	28(%rsp), %edx                  # 4-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rsi
	movl	%edx, 8(%rax)
	movq	$.Lclosure_wrapper_5, (%rax)
	callq	sigi_push_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	callq	sigi_pop_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	callq	sigi_pop_bool@PLT
	testb	$1, %al
	jne	.LBB4_1
	jmp	.LBB4_2
.LBB4_1:
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB4_3
.LBB4_2:
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB4_3
.LBB4_3:
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, (%rsp)                    # 8-byte Spill
# %bb.4:
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	(%rsp), %rsi                    # 8-byte Reload
	callq	sigi_push_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	apply@PLT
	addq	$56, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	.Lclosure_worker_3, .Lfunc_end4-.Lclosure_worker_3
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_3
	.type	.Lclosure_wrapper_3,@function
.Lclosure_wrapper_3:                    # @closure_wrapper_3
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsi, %rcx
	movq	%rdi, %rax
	movl	16(%rax), %edx
	movl	8(%rax), %edi
	movl	12(%rax), %esi
	callq	.Lclosure_worker_3
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end5:
	.size	.Lclosure_wrapper_3, .Lfunc_end5-.Lclosure_wrapper_3
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_worker_2
	.type	.Lclosure_worker_2,@function
.Lclosure_worker_2:                     # @closure_worker_2
	.cfi_startproc
# %bb.0:
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%rsi, 8(%rsp)                   # 8-byte Spill
	movl	%edi, %esi
	movq	8(%rsp), %rdi                   # 8-byte Reload
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	callq	sigi_push_i32@PLT
	movq	16(%rsp), %rax                  # 8-byte Reload
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end6:
	.size	.Lclosure_worker_2, .Lfunc_end6-.Lclosure_worker_2
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_2
	.type	.Lclosure_wrapper_2,@function
.Lclosure_wrapper_2:                    # @closure_wrapper_2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	8(%rdi), %edi
	callq	.Lclosure_worker_2
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end7:
	.size	.Lclosure_wrapper_2, .Lfunc_end7-.Lclosure_wrapper_2
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_worker_1
	.type	.Lclosure_worker_1,@function
.Lclosure_worker_1:                     # @closure_worker_1
	.cfi_startproc
# %bb.0:
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	movq	%rsi, (%rsp)                    # 8-byte Spill
	movl	%edi, %esi
	movq	(%rsp), %rdi                    # 8-byte Reload
	movl	%esi, 24(%rsp)                  # 4-byte Spill
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	callq	sigi_push_i32@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	movl	$2, %esi
	callq	sigi_push_i32@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_i32@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 12(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movl	12(%rsp), %esi                  # 4-byte Reload
	movq	16(%rsp), %rdi                  # 8-byte Reload
	subl	%eax, %esi
	callq	sigi_push_i32@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	fib_naive@PLT
	movl	24(%rsp), %esi                  # 4-byte Reload
	movq	%rax, %rdi
	movq	%rdi, 32(%rsp)                  # 8-byte Spill
	callq	sigi_push_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movl	$1, %esi
	callq	sigi_push_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 28(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movl	28(%rsp), %esi                  # 4-byte Reload
	movq	32(%rsp), %rdi                  # 8-byte Reload
	subl	%eax, %esi
	callq	sigi_push_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	fib_naive@PLT
	movq	%rax, %rdi
	movq	%rdi, 48(%rsp)                  # 8-byte Spill
	callq	sigi_pop_i32@PLT
	movq	48(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 44(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movl	44(%rsp), %esi                  # 4-byte Reload
	movq	48(%rsp), %rdi                  # 8-byte Reload
	addl	%eax, %esi
	callq	sigi_push_i32@PLT
	movq	48(%rsp), %rax                  # 8-byte Reload
	addq	$56, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end8:
	.size	.Lclosure_worker_1, .Lfunc_end8-.Lclosure_worker_1
	.cfi_endproc
                                        # -- End function
	.p2align	4, 0x90                         # -- Begin function closure_wrapper_1
	.type	.Lclosure_wrapper_1,@function
.Lclosure_wrapper_1:                    # @closure_wrapper_1
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	8(%rdi), %edi
	callq	.Lclosure_worker_1
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end9:
	.size	.Lclosure_wrapper_1, .Lfunc_end9-.Lclosure_wrapper_1
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
.Lfunc_end10:
	.size	.Lclosure_worker_0, .Lfunc_end10-.Lclosure_worker_0
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
.Lfunc_end11:
	.size	.Lclosure_wrapper_0, .Lfunc_end11-.Lclosure_wrapper_0
	.cfi_endproc
                                        # -- End function
	.globl	apply                           # -- Begin function apply
	.p2align	4, 0x90
	.type	apply,@function
apply:                                  # @apply
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rdi, (%rsp)                    # 8-byte Spill
	callq	sigi_pop_closure@PLT
	movq	(%rsp), %rsi                    # 8-byte Reload
	movq	%rax, %rdi
	callq	*(%rax)
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end12:
	.size	apply, .Lfunc_end12-apply
	.cfi_endproc
                                        # -- End function
	.globl	show                            # -- Begin function show
	.p2align	4, 0x90
	.type	show,@function
show:                                   # @show
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	callq	sigi_builtin__pp@PLT
	movq	%rax, %rdi
	movq	%rdi, (%rsp)                    # 8-byte Spill
	callq	sigi_pop_bool@PLT
                                        # kill: def $cl killed $al
	movq	(%rsp), %rax                    # 8-byte Reload
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end13:
	.size	show, .Lfunc_end13-show
	.cfi_endproc
                                        # -- End function
	.globl	fib_naive                       # -- Begin function fib_naive
	.p2align	4, 0x90
	.type	fib_naive,@function
fib_naive:                              # @fib_naive
	.cfi_startproc
# %bb.0:
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	movq	%rdi, 40(%rsp)                  # 8-byte Spill
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, %esi
	movl	%esi, 28(%rsp)                  # 4-byte Spill
	callq	sigi_push_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	$1, %esi
	callq	sigi_push_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 24(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, %ecx
	movl	24(%rsp), %eax                  # 4-byte Reload
	subl	%ecx, %eax
	setle	%al
	movzbl	%al, %esi
	callq	sigi_push_bool@PLT
	movl	$8, %edi
	callq	malloc@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rsi
	movq	$.Lclosure_wrapper_0, (%rsi)
	callq	sigi_push_closure@PLT
	movl	$16, %edi
	callq	malloc@PLT
	movl	28(%rsp), %ecx                  # 4-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rsi
	movl	%ecx, 8(%rax)
	movq	$.Lclosure_wrapper_1, (%rax)
	callq	sigi_push_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	callq	sigi_pop_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	callq	sigi_pop_bool@PLT
	testb	$1, %al
	jne	.LBB14_1
	jmp	.LBB14_2
.LBB14_1:
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	jmp	.LBB14_3
.LBB14_2:
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 16(%rsp)                  # 8-byte Spill
	jmp	.LBB14_3
.LBB14_3:
	movq	16(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 8(%rsp)                   # 8-byte Spill
# %bb.4:
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	8(%rsp), %rsi                   # 8-byte Reload
	callq	sigi_push_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	apply@PLT
	addq	$56, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end14:
	.size	fib_naive, .Lfunc_end14-fib_naive
	.cfi_endproc
                                        # -- End function
	.globl	fib_tailrec                     # -- Begin function fib_tailrec
	.p2align	4, 0x90
	.type	fib_tailrec,@function
fib_tailrec:                            # @fib_tailrec
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rdi, (%rsp)                    # 8-byte Spill
	movl	$1, %esi
	callq	sigi_push_i32@PLT
	movq	(%rsp), %rdi                    # 8-byte Reload
	movl	$1, %esi
	callq	sigi_push_i32@PLT
	movq	(%rsp), %rdi                    # 8-byte Reload
	callq	fib_tailrec_helper@PLT
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end15:
	.size	fib_tailrec, .Lfunc_end15-fib_tailrec
	.cfi_endproc
                                        # -- End function
	.globl	fib_tailrec_helper              # -- Begin function fib_tailrec_helper
	.p2align	4, 0x90
	.type	fib_tailrec_helper,@function
fib_tailrec_helper:                     # @fib_tailrec_helper
	.cfi_startproc
# %bb.0:
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	movq	%rdi, 40(%rsp)                  # 8-byte Spill
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 16(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 24(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movl	16(%rsp), %esi                  # 4-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 28(%rsp)                  # 4-byte Spill
	callq	sigi_push_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	xorl	%esi, %esi
	callq	sigi_push_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 20(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, %ecx
	movl	20(%rsp), %eax                  # 4-byte Reload
	subl	%ecx, %eax
	sete	%al
	movzbl	%al, %esi
	callq	sigi_push_bool@PLT
	movl	$16, %edi
	callq	malloc@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rsi
	movl	24(%rsp), %eax                  # 4-byte Reload
	movl	%eax, 8(%rsi)
	movq	$.Lclosure_wrapper_2, (%rsi)
	callq	sigi_push_closure@PLT
	movl	$24, %edi
	callq	malloc@PLT
	movl	28(%rsp), %ecx                  # 4-byte Reload
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, %rsi
	movl	%ecx, 8(%rax)
	movq	$.Lclosure_wrapper_3, (%rax)
	callq	sigi_push_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	sigi_pop_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, 32(%rsp)                  # 8-byte Spill
	callq	sigi_pop_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	%rax, 48(%rsp)                  # 8-byte Spill
	callq	sigi_pop_bool@PLT
	testb	$1, %al
	jne	.LBB16_1
	jmp	.LBB16_2
.LBB16_1:
	movq	48(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB16_3
.LBB16_2:
	movq	32(%rsp), %rax                  # 8-byte Reload
	movq	%rax, 8(%rsp)                   # 8-byte Spill
	jmp	.LBB16_3
.LBB16_3:
	movq	8(%rsp), %rax                   # 8-byte Reload
	movq	%rax, (%rsp)                    # 8-byte Spill
# %bb.4:
	movq	40(%rsp), %rdi                  # 8-byte Reload
	movq	(%rsp), %rsi                    # 8-byte Reload
	callq	sigi_push_closure@PLT
	movq	40(%rsp), %rdi                  # 8-byte Reload
	callq	apply@PLT
	addq	$56, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end16:
	.size	fib_tailrec_helper, .Lfunc_end16-fib_tailrec_helper
	.cfi_endproc
                                        # -- End function
	.globl	__main__                        # -- Begin function __main__
	.p2align	4, 0x90
	.type	__main__,@function
__main__:                               # @__main__
	.cfi_startproc
# %bb.0:
	subq	$40, %rsp
	.cfi_def_cfa_offset 48
	movq	%rdi, 8(%rsp)                   # 8-byte Spill
	movl	$20, %esi
	callq	sigi_push_i32@PLT
	movq	8(%rsp), %rdi                   # 8-byte Reload
	callq	fib_tailrec@PLT
	movq	%rax, %rdi
	movq	%rdi, 16(%rsp)                  # 8-byte Spill
	movl	$20, %esi
	callq	sigi_push_i32@PLT
	movq	16(%rsp), %rdi                  # 8-byte Reload
	callq	fib_naive@PLT
	movq	%rax, %rdi
	movq	%rdi, 32(%rsp)                  # 8-byte Spill
	callq	sigi_pop_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, 28(%rsp)                  # 4-byte Spill
	callq	sigi_pop_i32@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	movl	%eax, %ecx
	movl	28(%rsp), %eax                  # 4-byte Reload
	cmpl	%ecx, %eax
	sete	%al
	movzbl	%al, %esi
	callq	sigi_push_bool@PLT
	movq	32(%rsp), %rdi                  # 8-byte Reload
	callq	show@PLT
	addq	$40, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end17:
	.size	__main__, .Lfunc_end17-__main__
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
.Lfunc_end18:
	.size	main, .Lfunc_end18-main
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits

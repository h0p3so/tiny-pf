.section .rodata
	._xvargs_fatal_busy_address_msg: .string "xvargs: cannot invoke two instances of xvargs at the same time\n"
	._xvargs_fatal_busy_address_len: .quad   63

	._xvargs_fatal_unexpected_limit_msg: .string "xvargs: safe-limit is not an invalid limit (limit < 1)\n"
	._xvargs_fatal_unexpected_limit_len: .quad   55

.section .bss
	._xvargs_callers_rbp:  .zero 8
	._xvargs_stack_offset: .zero 8
#ifdef XVARG_SAFE
	._xvargs_safe_limit:   .zero 8
	._xvargs_safe_default: .zero 8
#endif

.section .text

.macro _xvargs_fatal msg, len
	movq	$1, %rax
	movq	$2, %rdi
	leaq	\msg, %rsi
	movq	\len, %rdx
	syscall
	movq	$60, %rax
	movq	$1, %rdi
	syscall
.endm

._xvargs_fatal_busy_address:
	_xvargs_fatal ._xvargs_fatal_busy_address_msg(%rip), ._xvargs_fatal_busy_address_len(%rip)
._xvargs_fatal_unexpected_limit:
	_xvargs_fatal ._xvargs_fatal_unexpected_limit_msg(%rip), ._xvargs_fatal_unexpected_limit_len(%rip)

.globl xvargs_init
.globl xvargs_next
.globl xvargs_fini

xvargs_init:	
	pushq	%rbp
	movq	%rsp, %rbp
	movq	._xvargs_callers_rbp(%rip), %rax
	testq	%rax, %rax
	jnz		._xvargs_fatal_busy_address
	leaq	._xvargs_callers_rbp(%rip), %rax
	movq	%rdi, (%rax)
#ifdef XVARG_SAFE
	cmpq	$0, %rsi
	jle		._xvargs_fatal_unexpected_limit
	leaq	._xvargs_safe_limit(%rip), %rax
	movq	%rsi, (%rax)
	leaq	._xvargs_safe_default(%rip), %rax
	movq	%rdx, (%rax)
#endif
	leave
	ret

xvargs_next:
	pushq	%rbp
	movq	%rsp, %rbp
#ifdef XVARG_SAFE
	movq	._xvargs_safe_limit(%rip), %rax
	movq	._xvargs_stack_offset(%rip), %rcx
	cmpq	%rax, %rcx
	jae		._xvargs_next_return_default
#endif
	movq	._xvargs_callers_rbp(%rip), %rbx
	movq	._xvargs_stack_offset(%rip), %rax
	#       | rbp				 0(offset from rbp)
	#       | return address	 8(offset from rbp)
	# stack | arg1				16(offset from rbp) ._xvargs_stack_offset = 0
	#       | arg2                       .          ._xvargs_stack_offset = 1
	#       | arg3                       .          ._xvargs_stack_offset = 2
	#       v                            .
	shlq	$3, %rax
	movq	16(%rbx, %rax, 1), %rax
	incq	._xvargs_stack_offset(%rip)
	leave
	ret
#ifdef XVARG_SAFE
._xvargs_next_return_default:	
	movq	._xvargs_safe_default(%rip), %rax
	leave
	ret
#endif

xvargs_fini:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	$0, ._xvargs_callers_rbp(%rip)
	movq	$0, ._xvargs_stack_offset(%rip)
#ifdef XVARG_SAFE
	movq	$0, ._xvargs_safe_limit(%rip)
	movq	$0, ._xvargs_safe_default(%rip)
#endif
	leave
	ret

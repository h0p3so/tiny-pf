.section .rodata
#ifndef TINY_PF_LONG_BOOL_FMT
	._tiny_pf_bool_true_fmt_msg:  .string "true"
	._tiny_pf_bool_true_fmt_len:  .quad    4
	._tiny_pf_bool_false_fmt_msg: .string "false"
	._tiny_pf_bool_false_fmt_len: .quad    5
#else
	._tiny_pf_bool_true_fmt_msg:  .string "T"
	._tiny_pf_bool_true_fmt_len:  .quad    1
	._tiny_pf_bool_false_fmt_msg: .string "F"
	._tiny_pf_bool_false_fmt_len: .quad    1
#endif
	._tiny_pf_buffer_capacity: .quad 4096

.section .bss
	._tiny_pf_buffer:      .zero 4096
	# indicates the number of times tiny_pf had to flush since the
	# buffer reached its max capacity
	._tiny_pf_mid_flushes: .zero 8

.section .text

.macro _tiny_pf_flush buffer, size, fd
	movq	$1, %rax
	movl	\fd, %edi
	leaq	\buffer, %rsi
	movq	\size, %rdx
	syscall
.endm

.macro _tiny_pf_put_in_buffer c
	leaq	._tiny_pf_buffer(%rip), %rax
	movq	-20(%rbp), %rcx
	movb	\c, (%rax, %rcx)
.endm

.globl tiny_pf

tiny_pf:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rsp, %rdx
	subq	$32, %rsp
	# stack variables --------------
	#  -4(%rbp): fd
	# -12(%rbp): fmt string (ptr)
	# -20(%rbp): bytes written into buffer so far
	# -24(%rbp): alignment type (< or >)
	#
	#
	movl	%edi, -4(%rbp)
	movq	%rsi, -12(%rbp)
	movq	$0, -20(%rbp)
	#
	# xvargs initialization
	#
	movq	%rdx, %rdi
	call	xvargs_init
._tiny_pf_loop:
	movq	-20(%rbp), %rax
	cmpq	._tiny_pf_buffer_capacity(%rip), %rax
	jae	._tiny_pf_perform_mid_flush
._tiny_pf_loop_eat:
	movq	-12(%rbp), %rax
	movzbl	(%rax), %edi
	#
	cmpb	$0, %dil
	je	._tiny_pf_fini
	cmpb	$37, %dil
	je	._tiny_pf_loop_parse
	#
	_tiny_pf_put_in_buffer %dil
	jmp	._tiny_pf_loop_advance
._tiny_pf_loop_parse:
	incq	%rax
	movzbl	(%rax), %edi
	# finding format ------
	cmpb	$37, %dil
	je	._tiny_pf_loop_parse_per
	cmpb	$60, %dil
	je	._tiny_pf_loop_parse_alignment
	cmpb	$62, %dil
	je	._tiny_pf_loop_parse_alignment
._tiny_pf_loop_parse_pick_specifier:
	cmpb	$99, %dil
	je	._tiny_pf_loop_parse_chr
	# ------ finding format

._tiny_pf_loop_parse_alignment:
	movl	%edi, -24(%rbp)
	jmp	._tiny_pf_loop_parse_pick_specifier
._tiny_pf_loop_parse_per:
	_tiny_pf_put_in_buffer $37
	incq	-12(%rbp)
	jmp	._tiny_pf_loop_advance
._tiny_pf_loop_parse_chr:
	call	xvargs_next
	movl	%eax, %edi
	_tiny_pf_put_in_buffer %dil
	incq	-12(%rbp)
	jmp	._tiny_pf_loop_advance

._tiny_pf_loop_advance:
	incq	-12(%rbp)
	incq	-20(%rbp)
	jmp	._tiny_pf_loop
._tiny_pf_perform_mid_flush:
	_tiny_pf_flush ._tiny_pf_buffer(%rip), ._tiny_pf_buffer_capacity(%rip), -4(%rbp)
	incq	._tiny_pf_mid_flushes(%rip)
	movq	$0, -20(%rbp)
	jmp	._tiny_pf_loop_eat
._tiny_pf_fini:
	call	xvargs_fini
	_tiny_pf_flush ._tiny_pf_buffer(%rip), -20(%rbp), -4(%rbp)
	# TODO: get _tiny_pf_mid_flushes * 4096 + current bytes written
	movq	$0, ._tiny_pf_mid_flushes(%rip)
	movq	-20(%rbp), %rax
	leave
	ret


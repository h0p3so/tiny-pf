.section .rodata
	.fmt_simple:       .string " 1) Hello, World!\n"
	.fmt_int:          .string " 2) int: %d\n"
	.fmt_char:         .string " 3) char: %c\n"
	.fmt_str:          .string " 4) str: %s\n"
	.fmt_bool:         .string " 5) true: %b  false: %b\n"
	.fmt_align_l:      .string " 6) |%<10s|\n"
	.fmt_align_r:      .string " 7) |%>10s|\n"
	.fmt_multi:        .string " 8) %s is %d years old and likes '%c'\n"
	.fmt_rt_l:         .string " 9) |%<#s|\n"
	.fmt_rt_r:         .string "10) |%>#s|\n"
	.fmt_align_int_l:  .string "11) |%<5d|\n"
	.fmt_align_int_r:  .string "12) |%>5d|\n"
	.fmt_pct:          .string "13) 100%%\n"
	.fmt_negative:     .string "14) negative: %d\n"
	
	.str_hello:        .string "hello"
	.str_world:        .string "world"
	.str_alice:        .string "Alice"
	.str_right:        .string "right"

.section .text
.globl _start
_start:
	# 1) plain string (no variadic args)
	movl	$1, %edi
	leaq	.fmt_simple(%rip), %rsi
	call	tiny_pf

	# 2) integer
	pushq	$0
	movl	$1, %edi
	leaq	.fmt_int(%rip), %rsi
	call	tiny_pf
	addq	$8, %rsp

	# 3) character
	pushq	$'Z'
	movl	$1, %edi
	leaq	.fmt_char(%rip), %rsi
	call	tiny_pf
	addq	$8, %rsp

	# 4) string
	leaq	.str_world(%rip), %rax
	pushq	%rax
	movl	$1, %edi
	leaq	.fmt_str(%rip), %rsi
	call	tiny_pf
	addq	$8, %rsp


	# 5) booleans
	pushq	$0
	pushq	$1
	movl	$1, %edi
	leaq	.fmt_bool(%rip), %rsi
	call	tiny_pf
	addq	$16, %rsp

	# 6) left-aligned string, literal size 10
	leaq	.str_hello(%rip), %rax
	pushq	%rax
	movl	$1, %edi
	leaq	.fmt_align_l(%rip), %rsi
	call	tiny_pf
	addq	$8, %rsp

	# 7) right-aligned string, literal size 10
	leaq	.str_hello(%rip), %rax
	pushq	%rax
	movl	$1, %edi
	leaq	.fmt_align_r(%rip), %rsi
	call	tiny_pf
	addq	$8, %rsp

	# 8) mixed formats: %s %d %c
	pushq	$'!'
	pushq	$25
	leaq	.str_alice(%rip), %rax
	pushq	%rax
	movl	$1, %edi
	leaq	.fmt_multi(%rip), %rsi
	call	tiny_pf
	addq	$24, %rsp

	# 9) runtime left-align (#)
	leaq	.str_hello(%rip), %rax
	pushq	%rax
	pushq	$10
	movl	$1, %edi
	leaq	.fmt_rt_l(%rip), %rsi
	call	tiny_pf
	addq	$16, %rsp

	# 10) runtime right-align (#)
	leaq	.str_right(%rip), %rax
	pushq	%rax
	pushq	$10
	movl	$1, %edi
	leaq	.fmt_rt_r(%rip), %rsi
	call	tiny_pf
	addq	$16, %rsp

	# 11) left-aligned integer
	pushq	$42
	movl	$1, %edi
	leaq	.fmt_align_int_l(%rip), %rsi
	call	tiny_pf
	addq	$8, %rsp

	# 12) right-aligned integer
	pushq	$42
	movl	$1, %edi
	leaq	.fmt_align_int_r(%rip), %rsi
	call	tiny_pf
	addq	$8, %rsp

	# 13) literal percent
	movl	$1, %edi
	leaq	.fmt_pct(%rip), %rsi
	call	tiny_pf

	# 14) negative integer
	pushq	$-128
	movl	$1, %edi
	leaq	.fmt_negative(%rip), %rsi
	call	tiny_pf
	addq	$8, %rsp

	# exit(0)
	movq	$60, %rax
	xorq	%rdi, %rdi
	syscall

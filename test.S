
.section .rodata
	.fmt: .string "|%b|\n"

	.test0: .string "hello"
	.test1: .string "world!"

.section .text
.globl _start

_start:
	pushq	$10

	movl	$1, %edi
	leaq	.fmt(%rip), %rsi
	call	tiny_pf

	movq	%rax, %rdi
	movq	$60, %rax
	syscall


.section .rodata
	.fmt: .string "|%<5s%>10s|\n"
	.test0: .string "hello"
	.test1: .string "world!"

.section .text
.globl _start

_start:
	leaq	.test1(%rip), %rax
	pushq	%rax

	leaq	.test0(%rip), %rax
	pushq	%rax

	movl	$1, %edi
	leaq	.fmt(%rip), %rsi
	call	tiny_pf

	movq	%rax, %rdi
	movq	$60, %rax
	syscall

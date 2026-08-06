
.section .rodata
	.fmt: .string "%s\n"
	.test: .string "hello world!"

.section .text
.globl _start

_start:
	leaq	.test(%rip), %rax
	pushq	%rax

	movl	$1, %edi
	leaq	.fmt(%rip), %rsi
	call	tiny_pf

	movq	%rax, %rdi
	movq	$60, %rax
	syscall

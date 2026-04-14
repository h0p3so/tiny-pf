.section .rodata
	.fmt: .string "success for %c is 99.9%%\n"

.section .text
.globl _start

_start:
	pushq	$'A'

	movl	$1, %edi
	leaq	.fmt(%rip), %rsi
	call	tiny_pf

	movq	%rax, %rdi
	movq	$60, %rax
	syscall

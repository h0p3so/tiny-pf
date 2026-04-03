.section .rodata
	.fmt: .string "hello world from tiny-pf\n\0"

.section .text
.globl _start

_start:
	movl	$1, %edi
	leaq	.fmt(%rip), %rsi
	call	tiny_pf
	movq	%rax, %rdi
	movq	$60, %rax
	syscall

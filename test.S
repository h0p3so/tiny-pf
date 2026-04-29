.section .rodata
	.fmt: .string "success for %c is 99.9%%\n"
	.test: .string "69"

.section .text
.globl _start

_start:
	pushq	$'A'

	# movl	$1, %edi
	# leaq	.fmt(%rip), %rsi
	# call	tiny_pf

	leaq	.test(%rip), %rdi
	movl	$10, %esi
	call	_tiny_pf_function_parse_number

	movq	%rax, %rdi
	movq	$60, %rax
	syscall

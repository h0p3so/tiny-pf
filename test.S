.section .rodata
	.fmt: .string "%<10abcde\n"
	.test: .string "123a"

.section .text
.globl _start

_start:
	pushq	$'A'

	movl	$1, %edi
	leaq	.fmt(%rip), %rsi
	call	tiny_pf

	# pushq	%rbp
	# movq	%rsp, %rbp
	# subq	$8, %rsp
	# leaq	.test(%rip), %rdi
	# movq	%rdi, -8(%rbp)
	# leaq	-8(%rbp), %rdi
	# movl	$10, %esi
	# call	_tiny_pf_function_parse_number
	# movq	$1, %rax
	# movq	$1, %rdi
	# movq	-8(%rbp), %rsi
	# movq	$1, %rdx
	# syscall


	movq	%rax, %rdi
	movq	$60, %rax
	syscall

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

	._tiny_pf_fatal_unk_fmt_msg: .string "tiny-pf: unknown format!\n"
	._tiny_pf_fatal_unk_fmt_len: .quad   25

.section .bss
	._tiny_pf_buffer:      .zero 4096
	# indicates the number of times tiny_pf had to flush since the
	# buffer reached its max capacity
	._tiny_pf_mid_flushes: .zero 8

	._tiny_pf_padding: .zero 8

.section .text

.macro _tiny_pf_flush buffer, size, fd
	movq	$1, %rax
	movl	\fd, %edi
	leaq	\buffer, %rsi
	movq	\size, %rdx
	syscall
.endm

.macro _tiny_pf_fatal buffer, size
	_tiny_pf_flush \buffer, \size, $2
	movq	$60, %rax
	movq	$39, %rdi
	syscall
.endm

.macro _tiny_pf_eat_and_load
	incq	-12(%rbp)
	movq	-12(%rbp), %rax
	movzbl	(%rax), %edi
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
	# -32(%rbp): alignment size (padding)
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
	# right now we have
	# fmtstring: "some text %x"
	#                       |\
	#   -12(%rbp) is here  / |
	#                       /
	# after these 3 loc (above) we'll
	# be here, so we can know what to
	# parse
	_tiny_pf_eat_and_load
	# finding format -------------------------#
	cmpb	$37, %dil                         #
	je	._tiny_pf_loop_parse_per          #
	cmpb	$60, %dil                         #
	je	._tiny_pf_loop_parse_alignment    #
	cmpb	$62, %dil                         #
	je	._tiny_pf_loop_parse_alignment    #
._tiny_pf_loop_parse_pick_specifier:              #
	cmpb	$99, %dil                         #
	je	._tiny_pf_loop_parse_chr          #
	# finding format -------------------------#
	_tiny_pf_fatal ._tiny_pf_fatal_unk_fmt_msg(%rip), ._tiny_pf_fatal_unk_fmt_len(%rip)
._tiny_pf_loop_parse_alignment:
	movl	%edi, -24(%rbp)
	# right now we have
	# fmtstring: "some text %*xs"
	#                        |` need what's in here
	#                 -12(%rbp)
	_tiny_pf_eat_and_load
	cmpb	$35, %dil
	jne	._tiny_pf_loop_parse_alignment_parse
	call	xvargs_next
	movq	%rax, -32(%rbp)
	jmp	._tiny_pf_loop_parse_pick_specifier

._tiny_pf_loop_parse_alignment_parse:
	leaq	-12(%rbp), %rdi
	movl	$10, %esi
	call	_tiny_pf_function_parse_number
	movq	%rax, -32(%rbp)
	jmp	._tiny_pf_loop_parse_pick_specifier


._tiny_pf_loop_parse_per:
	_tiny_pf_put_in_buffer $37
	jmp	._tiny_pf_loop_advance
._tiny_pf_loop_parse_chr:
	call	xvargs_next
	movl	%eax, %edi
	_tiny_pf_put_in_buffer %dil
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

#  ____________________
# < external functions >
#  --------------------
#         \   ^__^
#          \  (oo)\_______
#             (__)\       )\/\
#                 ||----w |
#                 ||     ||

# basically atoi: (char**, u32) -> u64
# rdi: mutable pointer to source char**
# esi: base
#
# _if no number is found, zero is returned
_tiny_pf_function_parse_number:
	pushq	%rbp
	movq	%rsp, %rbp
	# stack variables --------------
	#  -8(%rbp): address of source
	# -12(%rbp): base
	# -20(%rbp): answer
	subq	$32, %rsp
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	movq	$0, -20(%rbp)
.__tiny_pf_function_parse_number_parse:
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	movzbl	(%rax), %edi
	call	_tiny_pf_function_isdigit
	cmpq	$0, %rax
	je	.__tiny_pf_function_parse_number_fini
	#  result * base + (*s - '0')
	subb	$48, %dil
	movq	-20(%rbp), %rax
	movl	-12(%rbp), %esi
	mulq	%rsi
	addq	%rdi, %rax
	movq	%rax, -20(%rbp)
	#
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	leaq	1(%rax), %rdx
	movq	-8(%rbp), %rax
	movq	%rdx, (%rax)
	#
	jmp	.__tiny_pf_function_parse_number_parse
.__tiny_pf_function_parse_number_fini:
	movq	-20(%rbp), %rax
	leave
	ret

# basically isdigit: (u8) -> u64
# dil: current character
#
# _if it is, one (1) is returned, zero (0) otherwise
_tiny_pf_function_isdigit:
	cmpb	$48, %dil
	jb	.__tiny_pf_function_isdigit_no
	cmpb	$57, %dil
	ja	.__tiny_pf_function_isdigit_no
	movq	$1, %rax
	jmp	.__tiny_pf_function_isdigit_fini
.__tiny_pf_function_isdigit_no:
	movq	$0, %rax
.__tiny_pf_function_isdigit_fini:
	ret


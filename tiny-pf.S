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
	# Errors -----
	._tiny_pf_fatal_unk_fmt_msg:  .string "tiny-pf: unknown format!\n"
	._tiny_pf_fatal_unk_fmt_len:  .quad   25

	._tiny_pf_fatal_inv_alig_msg: .string "tiny-pf: invalid alignment specifier!\n"
	._tiny_pf_fatal_inv_alig_len: .quad   38
	# ----- Errors

	._tiny_pf_buffer_capacity:    .quad 4096

.section .bss
	._tiny_pf_buffer: .zero 4096

.section .text

#
# Flushes the current content of the buffer
#
.macro _tiny_pf_flush buffer, size, fd
	movq	$1, %rax
	movl	\fd, %edi
	leaq	\buffer, %rsi
	movq	\size, %rdx
	syscall
.endm

#
# Displays error message and exits
#
.macro _tiny_pf_fatal buffer, size
	_tiny_pf_flush \buffer, \size, $2
	movq	$60, %rax
	movq	$1, %rdi
	syscall
.endm

#
# Advances by one input buffer and sets the character
# into rdi
#
.macro _tiny_pf_eat_and_load
	incq	-12(%rbp)
	movq	-12(%rbp), %rax
	movzbl	(%rax), %edi
.endm

#
# Sets `c` character into output buffer
#
.macro _tiny_pf_put_in_buffer c
	leaq	._tiny_pf_buffer(%rip), %rax
	movq	-20(%rbp), %rcx
	movb	\c, (%rax, %rcx)
	incq	-20(%rbp)
.endm

#
# Writes `size` bytes from the buffer and jumps to `jmp2` address
#
.macro _tiny_pf_perform_mid_flush size, jmp2
	_tiny_pf_flush ._tiny_pf_buffer(%rip), \size, -4(%rbp)
	movq	\size, %r8
	addq	%r8, -40(%rbp)
	movq	$0, -20(%rbp)
	jmp	\jmp2
.endm

.globl tiny_pf

tiny_pf:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rsp, %rdx
	subq	$80, %rsp
	# stack variables --------------
	#  -4(%rbp): fd
	# -12(%rbp): fmt string (ptr)
	# -20(%rbp): bytes written into buffer so far
	# -24(%rbp): current alignment type
	# -32(%rbp): current alignment size
	# -40(%rbp): bytes written due to mid flushes
	# -48(%rbp): argument's length
	# -56(%rbp): number of ' 's while aligning
	# -64(%rbp): last value poped via xvargs
	# -72(%rbp): is -64(%rbp) a pointer?
	movl	%edi,  -4(%rbp)
	movq	%rsi, -12(%rbp)
	movq	  $0, -20(%rbp)
	movq	  $0, -24(%rbp)
	movq	  $0, -32(%rbp)
	movq	  $0, -40(%rbp)
	movq	  $0, -48(%rbp)
	movq	  $0, -56(%rbp)
	movq	  $0, -64(%rbp)
	movq	  $0, -72(%rbp)
	#
	# xvargs initialization
	#
	movq	%rdx, %rdi
	call	xvargs_init
._tiny_pf_loop:
	movq	-20(%rbp), %rax
	cmpq	._tiny_pf_buffer_capacity(%rip), %rax
	jb	._tiny_pf_loop_eat
	_tiny_pf_perform_mid_flush ._tiny_pf_buffer_capacity(%rip), ._tiny_pf_loop_eat
._tiny_pf_loop_eat:
	movq	-12(%rbp), %rax
	movzbl	(%rax), %edi
	# special characters -----
	cmpb	$0, %dil
	je	._tiny_pf_fini
	cmpb	$37, %dil
	je	._tiny_pf_loop_parse
	# ----- special characters
	_tiny_pf_put_in_buffer %dil
._tiny_pf_loop_advance:
	incq	-12(%rbp)
	jmp	._tiny_pf_loop
._tiny_pf_loop_parse:
	# right now we have
	# fmtstring: "some text %x"
	#                       |` format (*)
	#   -12(%rbp) is here </
	#
	# (*): whatever is x, will define what needs to be parsed
	_tiny_pf_eat_and_load
	# finding format -------------------------#
	cmpb	$37, %dil                         #
	je	._tiny_pf_loop_parse_per          #
	cmpb	$60, %dil                         #
	je	._tiny_pf_loop_parse_alignment    #
	cmpb	$62, %dil                         #
	je	._tiny_pf_loop_parse_alignment    #
._tiny_pf_loop_parse_get_format:                  #
	cmpb	$99, %dil                         #
	je	._tiny_pf_loop_parse_chr          #
	# finding format -------------------------#
	#
	# [[no return]]
	_tiny_pf_fatal ._tiny_pf_fatal_unk_fmt_msg(%rip), ._tiny_pf_fatal_unk_fmt_len(%rip)
	# [[no return]]
	#
._tiny_pf_loop_parse_alignment:
	movl	%edi, -24(%rbp)
	# right now we have
	# fmtstring: "some text %*xs"
	#
	# *: current position of -12(%rbp), it is either `<` or `>` (rdi's value)
	# x: this character either be a serie of digits [0-9] or `#`
	# s: actual alignment specifier
	#
	_tiny_pf_eat_and_load
	cmpb	$35, %dil
	jne	._tiny_pf_loop_parse_alignment_parse
	call	xvargs_next
	movq	%rax, -32(%rbp)
	jmp	._tiny_pf_loop_parse_alignment_specifier_is_ok
._tiny_pf_loop_parse_alignment_parse:
	leaq	-12(%rbp), %rdi
	movl	$10, %esi
	call	_tiny_pf_function_parse_number
	movq	%rax, -32(%rbp)
	cmpq	$0, %rax
	jne	._tiny_pf_loop_parse_alignment_specifier_is_ok
	#
	# [[no return]]
	_tiny_pf_fatal ._tiny_pf_fatal_inv_alig_msg(%rip), ._tiny_pf_fatal_inv_alig_len(%rip)
	# [[no return]]
	#
._tiny_pf_loop_parse_alignment_specifier_is_ok:
	# right now we have
	# fmtstring: "some text %<*x"
	#
	# <: alignment type
	# *: alignment size
	# s: actual format
	#
	jmp	._tiny_pf_loop_parse_get_format
._tiny_pf_loop_parse_per:
	_tiny_pf_put_in_buffer $37
	jmp	._tiny_pf_loop_advance
._tiny_pf_loop_parse_chr:
	call	xvargs_next
	movq	%rax, -64(%rbp)
	movq	$1, -48(%rbp)
	movq	$0, -72(%rbp)
	jmp	._tiny_pf_loop_parse_write_out
#
# Once the alignment type, alignment size and format type are correctly defined,
# tiny-pf needs to write the argument given the parameters found
#
._tiny_pf_loop_parse_write_out:
	#
	# is there not alignment or is it left-aligned?
	#
	movl	-24(%rbp), %eax
	cmpl	$0, %eax
	je	._tiny_pf_loop_parse_write_out_write_validate
	cmpl	$60, %eax
	je	._tiny_pf_loop_parse_write_out_write_validate
	#
	# _if arglen >= alignsize: ignore alignment
	#
	movq	-48(%rbp), %rax
	cmpq	-32(%rbp), %rax
	jae	._tiny_pf_loop_parse_write_out_write_validate
	#
	# given arglen < alignsize -> nofill = alignsize - arglen
	#
	movq	-32(%rbp), %rax				# |
	subq	-48(%rbp), %rax				# |
	movq	%rax, -56(%rbp)				# XXX: turn this into a macro
	#
	leaq	._tiny_pf_buffer(%rip), %rdi
	addq	-20(%rbp), %rdi
	movq	-56(%rbp), %rsi
	movq	$' ', %rdx
	call	_tiny_pf_function_fill
	addq	%rax, -20(%rbp)
	#
	jmp	._tiny_pf_loop_parse_write_out_write_validate
#
# Since tiny-pf already knows the length in bytes of the argument, it will
# see if it fits in the current buffer's capacity
#
._tiny_pf_loop_parse_write_out_write_validate:
	movq	-20(%rbp), %rax
	addq	-48(%rbp), %rax
	cmpq	._tiny_pf_buffer_capacity(%rip), %rax
	jb	._tiny_pf_loop_parse_write_out_write
	_tiny_pf_perform_mid_flush -20(%rbp), ._tiny_pf_loop_parse_write_out_write
._tiny_pf_loop_parse_write_out_write:
	xorq	%r8, %r8
._tiny_pf_loop_parse_write_out_write_loop:
	cmpq	-48(%rbp), %r8
	jae	._tiny_pf_loop_parse_write_out_finished
	movq	-64(%rbp), %rax
	cmpq	$0, -72(%rbp)
	jne	._tiny_pf_loop_parse_write_out_write_loop_extract
	jmp	._tiny_pf_loop_parse_write_out_write_loop_put
._tiny_pf_loop_parse_write_out_write_loop_extract:
	movq	-64(%rbp), %rax
	movzbl	(%rax), %eax
	jmp	._tiny_pf_loop_parse_write_out_write_loop_put
._tiny_pf_loop_parse_write_out_write_loop_put:
	movl	%eax, %edi
	_tiny_pf_put_in_buffer %dil
	incq	%r8
	jmp	._tiny_pf_loop_parse_write_out_write_loop
._tiny_pf_loop_parse_write_out_finished:
	movl	$0, -24(%rbp)
	movq	$0, -32(%rbp)
	movq	$0, -48(%rbp)
	movq	$0, -56(%rbp)
	movq	$0, -72(%rbp)
	jmp	._tiny_pf_loop_advance

._tiny_pf_fini:
	_tiny_pf_flush ._tiny_pf_buffer(%rip), -20(%rbp), -4(%rbp)
	# returns the current number of bytes plus the number of bytes
	# written during mid flushes
	movq	-20(%rbp), %rax
	addq	-40(%rbp), %rax
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

# basically memset: (char**, u64, u64) -> u64
# rdi: pointer to source
# rsi: number of bytes to fill
# rdx: value to fill with (ascii char)
#
# number of bytes written
_tiny_pf_function_fill:	
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	# stack variables --------------
	#  -8(%rbp): address of source
	# -16(%rbp): number of bytes to fill
	# -24(%rbp): value to fill with (ascii char)
	# -32(%rbp): number of bytes filled so far
	movq	%rdi,  -8(%rbp)
	movq	%rsi, -16(%rbp)
	movq	%rdx, -24(%rbp)
	movq	$0,   -32(%rbp)
.__tiny_pf_function_fill_loop:
	movq	-32(%rbp), %rcx
	cmpq	-16(%rbp), %rcx
	jae	.__tiny_pf_function_fill_fini
	movq	-8(%rbp), %rax
	movq	-24(%rbp), %rbx
	movb	%bl, (%rax, %rcx)
	incq	-32(%rbp)
	jmp	.__tiny_pf_function_fill_loop
.__tiny_pf_function_fill_fini:
	movq	-32(%rbp), %rax
	leave
	ret


#   __   __                           ___
#  |  |_|__.-----.--.--.______.-----.'  _|
#  |   _|  |     |  |  |______|  _  |   _|
#  |____|__|__|__|___  |      |   __|__|
#                |_____|      |__|
# 
# tiny-pf is an implementation of `dprintf` function form libc
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 

#define _TINY_PF_BUFFER_CAPACITY        4096
#define _TINY_PF_NUM_BUFFER_CAPACITY    32

#define _TINY_PF_OFFSET_FD              -4
#define _TINY_PF_OFFSET_FMT_STR         -12
#define _TINY_PF_OFFSET_COUNT           -20
#define _TINY_PF_OFFSET_ALIGN_TYPE      -24
#define _TINY_PF_OFFSET_ALIGN_SIZE      -32
#define _TINY_PF_OFFSET_NO_MID_FLUSHES  -40
#define _TINY_PF_OFFSET_ARG_LENGTH      -48
#define _TINY_PF_OFFSET_PADDING_SIZE    -56
#define _TINY_PF_OFFSET_LAST_ARG_XVARGS -64
#define _TINY_PF_OFFSET_IS_ARG_PTR      -68

#
# _TINY_PF_ASCII_NULL_BYTE        '\0'
# _TINY_PF_ASCII_FORMATTER        '%'
# _TINY_PF_ASCII_LEFT_ALIGN       '<'
# _TINY_PF_ASCII_RIGHT_ALIGN      '>'
# _TINY_PF_ASCII_CHAR_FMT         'c'
# _TINY_PF_ASCII_STR_FMT          's'
# _TINY_PF_ASCII_INT_FMT          'd'
# _TINY_PF_ASCII_NON_CTE_ALIGN    '#'
# _TINT_PF_ASCII_PADDING          ' '
# ~~~
#
#define _TINY_PF_ASCII_NULL_BYTE        0
#define _TINY_PF_ASCII_FORMATTER        37
#define _TINY_PF_ASCII_LEFT_ALIGN       60
#define _TINY_PF_ASCII_RIGHT_ALIGN      62
#define _TINY_PF_ASCII_CHAR_FMT         99
#define _TINY_PF_ASCII_STR_FMT          115
#define _TINY_PF_ASCII_INT_FMT          100
#define _TINY_PF_ASCII_NON_CTE_ALIGN    35
#define _TINY_PF_ASCII_PADDING          32

#define _TINY_PF_BASE_10                10
#define _TINY_PF_BASE_16                16
#define _TINY_PF_BASE_8                  8
#define _TINY_PF_BASE_2                  2

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
	incq	_TINY_PF_OFFSET_FMT_STR(%rbp)
	movq	_TINY_PF_OFFSET_FMT_STR(%rbp), %rax
	movzbl	(%rax), %edi
.endm

#
# Sets `c` character into output buffer
#
.macro _tiny_pf_put_in_buffer c
	leaq	._tiny_pf_buffer(%rip), %rax
	movq	_TINY_PF_OFFSET_COUNT(%rbp), %rcx
	movb	\c, (%rax, %rcx)
	incq	_TINY_PF_OFFSET_COUNT(%rbp)
.endm

#
# Writes `size` bytes from the buffer and jumps to `jmp2` address
#
.macro _tiny_pf_perform_mid_flush size, jmp2
	_tiny_pf_flush ._tiny_pf_buffer(%rip), \size, _TINY_PF_OFFSET_FD(%rbp)
	movq	\size, %r8
	addq	%r8, _TINY_PF_OFFSET_NO_MID_FLUSHES(%rbp)
	movq	$0, _TINY_PF_OFFSET_COUNT(%rbp)
	jmp	\jmp2
.endm

#
# _if the argument's size is larger than the alignment size, jump to `jmp2_if_so`
#
.macro _tiny_pf_should_skip_alignment jmp2_if_so
	movq	_TINY_PF_OFFSET_ARG_LENGTH(%rbp), %rax
	cmpq	_TINY_PF_OFFSET_ALIGN_SIZE(%rbp), %rax
	jae	\jmp2_if_so
.endm

.macro _tiny_pf_get_padding_size
	movq	_TINY_PF_OFFSET_ALIGN_SIZE(%rbp), %rax
	subq	_TINY_PF_OFFSET_ARG_LENGTH(%rbp), %rax
	movq	%rax, _TINY_PF_OFFSET_PADDING_SIZE(%rbp)
.endm

.globl tiny_pf

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

.section .bss
	._tiny_pf_buffer:     .zero _TINY_PF_BUFFER_CAPACITY
	._tiny_pf_num_buffer: .zero _TINY_PF_NUM_BUFFER_CAPACITY

.section .text

tiny_pf:
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rsp, %rdx
	subq	$80, %rsp
	# Stack 
	# _TINY_PF_OFFSET_FD              -4(%rbp):  fd
	# _TINY_PF_OFFSET_FMT_STR         -12(%rbp): fmt string (ptr)
	# _TINY_PF_OFFSET_COUNT           -20(%rbp): bytes written into buffer so far
	# _TINY_PF_OFFSET_ALIGN_TYPE      -24(%rbp): current alignment type
	# _TINY_PF_OFFSET_ALIGN_SIZE      -32(%rbp): current alignment size
	# _TINY_PF_OFFSET_NO_MID_FLUSHES  -40(%rbp): bytes written due to mid flushes
	# _TINY_PF_OFFSET_ARG_LENGTH      -48(%rbp): argument's length
	# _TINY_PF_OFFSET_PADDING_SIZE    -56(%rbp): number of ' 's while aligning
	# _TINY_PF_OFFSET_LAST_ARG_XVARGS -64(%rbp): last value poped via xvargs
	# _TINY_PF_OFFSET_IS_ARG_PTR      -68(%rbp): is -64(%rbp) a pointer?
	movl	%edi, _TINY_PF_OFFSET_FD(%rbp)
	movq	%rsi, _TINY_PF_OFFSET_FMT_STR(%rbp)
	movq	  $0, _TINY_PF_OFFSET_COUNT(%rbp)
	movq	  $0, _TINY_PF_OFFSET_ALIGN_TYPE(%rbp)
	movq	  $0, _TINY_PF_OFFSET_ALIGN_SIZE(%rbp)
	movq	  $0, _TINY_PF_OFFSET_NO_MID_FLUSHES(%rbp)
	movq	  $0, _TINY_PF_OFFSET_ARG_LENGTH(%rbp)
	movq	  $0, _TINY_PF_OFFSET_PADDING_SIZE(%rbp)
	movq	  $0, _TINY_PF_OFFSET_LAST_ARG_XVARGS(%rbp)
	movl	  $0, _TINY_PF_OFFSET_IS_ARG_PTR(%rbp)
	#
	# xvargs initialization
	#
	movq	%rdx, %rdi
	call	xvargs_init
._tiny_pf_loop:
	movq	_TINY_PF_OFFSET_COUNT(%rbp), %rax
	cmpq	$_TINY_PF_BUFFER_CAPACITY, %rax
	jb	._tiny_pf_loop_eat
	_tiny_pf_perform_mid_flush $_TINY_PF_BUFFER_CAPACITY, ._tiny_pf_loop_eat
._tiny_pf_loop_eat:
	movq	_TINY_PF_OFFSET_FMT_STR(%rbp), %rax
	movzbl	(%rax), %edi
	# special characters -----
	cmpb	$_TINY_PF_ASCII_NULL_BYTE, %dil
	je	._tiny_pf_fini
	cmpb	$_TINY_PF_ASCII_FORMATTER, %dil
	je	._tiny_pf_loop_parse
	# ----- special characters
	_tiny_pf_put_in_buffer %dil
._tiny_pf_loop_advance:
	incq	_TINY_PF_OFFSET_FMT_STR(%rbp)
	jmp	._tiny_pf_loop
._tiny_pf_loop_parse:
	# right now we have
	# fmtstring: "some text %x"
	#                       |` format (*)
	#   _TINY_PF_OFFSET_FMT_STR(%rbp) is here </
	#
	# (*): whatever is x, will define what needs to be parsed
	_tiny_pf_eat_and_load
	# finding format -------------------------#
	cmpb	$_TINY_PF_ASCII_FORMATTER, %dil   #
	je	._tiny_pf_loop_parse_per          #
	cmpb	$_TINY_PF_ASCII_LEFT_ALIGN, %dil  #
	je	._tiny_pf_loop_parse_alignment    #
	cmpb	$_TINY_PF_ASCII_RIGHT_ALIGN, %dil #
	je	._tiny_pf_loop_parse_alignment    #
._tiny_pf_loop_parse_get_format:                  #
	cmpb	$_TINY_PF_ASCII_CHAR_FMT, %dil    #
	je	._tiny_pf_loop_parse_chr          #
	cmpb	$_TINY_PF_ASCII_STR_FMT, %dil     #
	je	._tiny_pf_loop_parse_str          #
	cmpb	$_TINY_PF_ASCII_INT_FMT, %dil     #
	je	._tiny_pf_loop_parse_int          #
	# finding format -------------------------#
	#
	# [[no return]]
	_tiny_pf_fatal ._tiny_pf_fatal_unk_fmt_msg(%rip), ._tiny_pf_fatal_unk_fmt_len(%rip)
	# [[no return]]
	#
._tiny_pf_loop_parse_alignment:
	movl	%edi, _TINY_PF_OFFSET_ALIGN_TYPE(%rbp)
	# right now we have
	# fmtstring: "some text %*xs"
	#
	# *: current position of _TINY_PF_OFFSET_FMT_STR(%rbp), it is either `<` or `>` (rdi's value)
	# x: this character either be a serie of digits [0-9] or `#`
	# s: actual alignment specifier
	#
	_tiny_pf_eat_and_load
	cmpb	$_TINY_PF_ASCII_NON_CTE_ALIGN, %dil
	jne	._tiny_pf_loop_parse_alignment_parse
	call	xvargs_next
	movq	%rax, _TINY_PF_OFFSET_ALIGN_SIZE(%rbp)
	_tiny_pf_eat_and_load
	jmp	._tiny_pf_loop_parse_alignment_specifier_is_ok
._tiny_pf_loop_parse_alignment_parse:
	leaq	_TINY_PF_OFFSET_FMT_STR(%rbp), %rdi
	movl	$_TINY_PF_BASE_10, %esi
	call	_tiny_pf_function_parse_number
	movq	%rax, _TINY_PF_OFFSET_ALIGN_SIZE(%rbp)
	cmpq	$0, %rax
	jne	._tiny_pf_loop_parse_alignment_specifier_is_ok
	#
	# [[no return]]
	_tiny_pf_fatal ._tiny_pf_fatal_inv_alig_msg(%rip), ._tiny_pf_fatal_inv_alig_len(%rip)
	# [[no return]]
	#
._tiny_pf_loop_parse_alignment_specifier_is_ok:
	# right now we have
	# fmtstring: "some text %$*x"
	#
	# $: alignment type
	# *: alignment size
	# x: actual format
	#
	jmp	._tiny_pf_loop_parse_get_format
._tiny_pf_loop_parse_per:
	#
	# just append '%' into buffer
	#
	_tiny_pf_put_in_buffer $_TINY_PF_ASCII_FORMATTER
	jmp	._tiny_pf_loop_advance
._tiny_pf_loop_parse_chr:
	call	xvargs_next
	movq	%rax, _TINY_PF_OFFSET_LAST_ARG_XVARGS(%rbp)
	movq	$1, _TINY_PF_OFFSET_ARG_LENGTH(%rbp)
	movl	$0, _TINY_PF_OFFSET_IS_ARG_PTR(%rbp)
	jmp	._tiny_pf_loop_parse_write_out
._tiny_pf_loop_parse_str:
	call	xvargs_next
	movq	%rax, _TINY_PF_OFFSET_LAST_ARG_XVARGS(%rbp)
	movq	%rax, %rdi
	call	_tiny_pf_function_strlen
	movq	%rax, _TINY_PF_OFFSET_ARG_LENGTH(%rbp)
	movl	$1, _TINY_PF_OFFSET_IS_ARG_PTR(%rbp)
	jmp	._tiny_pf_loop_parse_write_out
._tiny_pf_loop_parse_int:
	call	xvargs_next
	movq	%rax, %rdi
	movq	$_TINY_PF_BASE_10, %rsi
	leaq	-48(%rbp), %rdx
	call	_tiny_pf_function_numstr
	movq	%rax, _TINY_PF_OFFSET_LAST_ARG_XVARGS(%rbp)
	movq	-48(%rbp), %rax
	movq	%rax, _TINY_PF_OFFSET_ARG_LENGTH(%rbp)
	movl	$1, _TINY_PF_OFFSET_IS_ARG_PTR(%rbp)
	jmp	._tiny_pf_loop_parse_write_out




#
# Once the alignment type, alignment size and format type are correctly defined,
# tiny-pf needs to write the argument given the parameters found
#
._tiny_pf_loop_parse_write_out:	
	#
	# is there not alignment or is it left-aligned?
	#
	movl	_TINY_PF_OFFSET_ALIGN_TYPE(%rbp), %eax
	cmpl	$0, %eax
	je	._tiny_pf_loop_parse_write_out_write_validate
	cmpl	$_TINY_PF_ASCII_LEFT_ALIGN, %eax
	je	._tiny_pf_loop_parse_write_out_write_validate
	#
	# _if arglen >= alignsize: ignore alignment
	#
	_tiny_pf_should_skip_alignment ._tiny_pf_loop_parse_write_out_write_validate
	_tiny_pf_get_padding_size
	#
	leaq	._tiny_pf_buffer(%rip), %rdi
	addq	_TINY_PF_OFFSET_COUNT(%rbp), %rdi
	movq	_TINY_PF_OFFSET_PADDING_SIZE(%rbp), %rsi
	movq	$_TINY_PF_ASCII_PADDING, %rdx
	call	_tiny_pf_function_fill
	addq	%rax, _TINY_PF_OFFSET_COUNT(%rbp)
	#
	jmp	._tiny_pf_loop_parse_write_out_write_validate
#
# Since tiny-pf already knows the length in bytes of the argument, it will
# see if it fits in the current buffer's capacity
#
._tiny_pf_loop_parse_write_out_write_validate:
	movq	_TINY_PF_OFFSET_COUNT(%rbp), %rax
	addq	_TINY_PF_OFFSET_ARG_LENGTH(%rbp), %rax
	cmpq	$_TINY_PF_BUFFER_CAPACITY, %rax
	jb	._tiny_pf_loop_parse_write_out_write
	_tiny_pf_perform_mid_flush _TINY_PF_OFFSET_COUNT(%rbp), ._tiny_pf_loop_parse_write_out_write
._tiny_pf_loop_parse_write_out_write:
	xorq	%r8, %r8
._tiny_pf_loop_parse_write_out_write_loop:
	movq	_TINY_PF_OFFSET_COUNT(%rbp), %rax
	cmpq	$_TINY_PF_BUFFER_CAPACITY, %rax
	jb	._tiny_pf_loop_parse_write_out_write_loop_body
	_tiny_pf_perform_mid_flush _TINY_PF_OFFSET_COUNT(%rbp), ._tiny_pf_loop_parse_write_out_write_loop_body
._tiny_pf_loop_parse_write_out_write_loop_body:
	cmpq	_TINY_PF_OFFSET_ARG_LENGTH(%rbp), %r8
	jae	._tiny_pf_loop_parse_write_out_finished
	movq	_TINY_PF_OFFSET_LAST_ARG_XVARGS(%rbp), %rax
	cmpl	$0, _TINY_PF_OFFSET_IS_ARG_PTR(%rbp)
	jne	._tiny_pf_loop_parse_write_out_write_loop_extract
	jmp	._tiny_pf_loop_parse_write_out_write_loop_put
._tiny_pf_loop_parse_write_out_write_loop_extract:
	movq	_TINY_PF_OFFSET_LAST_ARG_XVARGS(%rbp), %rax
	movzbl	(%rax, %r8), %eax
	jmp	._tiny_pf_loop_parse_write_out_write_loop_put
._tiny_pf_loop_parse_write_out_write_loop_put:
	movl	%eax, %edi
	_tiny_pf_put_in_buffer %dil
	incq	%r8
	jmp	._tiny_pf_loop_parse_write_out_write_loop
._tiny_pf_loop_parse_write_out_finished:
	#
	# validating if there's right alignment
	#
	movl	_TINY_PF_OFFSET_ALIGN_TYPE(%rbp), %eax
	cmpl	$0, %eax
	je	._tiny_pf_loop_parse_write_out_finished_clean
	cmpl	$_TINY_PF_ASCII_RIGHT_ALIGN, %eax
	je	._tiny_pf_loop_parse_write_out_finished_clean
	#
	# _if arglen >= alignsize: ignore alignment
	#
	_tiny_pf_should_skip_alignment	._tiny_pf_loop_parse_write_out_finished_clean
	_tiny_pf_get_padding_size
	#
	# checking if there's space enough for padding
	#
	movq	_TINY_PF_OFFSET_COUNT(%rbp), %rax
	addq	_TINY_PF_OFFSET_ARG_LENGTH(%rbp), %rax
	cmpq	$_TINY_PF_BUFFER_CAPACITY, %rax
	jb	._tiny_pf_loop_parse_write_out_finished_do_right_alignment
	_tiny_pf_perform_mid_flush _TINY_PF_OFFSET_COUNT(%rbp), ._tiny_pf_loop_parse_write_out_finished_do_right_alignment
._tiny_pf_loop_parse_write_out_finished_do_right_alignment:
	leaq	._tiny_pf_buffer(%rip), %rdi
	addq	_TINY_PF_OFFSET_COUNT(%rbp), %rdi
	movq	_TINY_PF_OFFSET_PADDING_SIZE(%rbp), %rsi
	movq	$_TINY_PF_ASCII_PADDING, %rdx
	call	_tiny_pf_function_fill
	addq	%rax, _TINY_PF_OFFSET_COUNT(%rbp)
	jmp	._tiny_pf_loop_parse_write_out_finished_clean
._tiny_pf_loop_parse_write_out_finished_clean:
	movl	$0, _TINY_PF_OFFSET_ALIGN_TYPE(%rbp)
	movq	$0, _TINY_PF_OFFSET_ALIGN_SIZE(%rbp)
	movq	$0, _TINY_PF_OFFSET_ARG_LENGTH(%rbp)
	movq	$0, _TINY_PF_OFFSET_PADDING_SIZE(%rbp)
	movl	$0, _TINY_PF_OFFSET_IS_ARG_PTR(%rbp)
	jmp	._tiny_pf_loop_advance
._tiny_pf_fini:
	_tiny_pf_flush ._tiny_pf_buffer(%rip), _TINY_PF_OFFSET_COUNT(%rbp), _TINY_PF_OFFSET_FD(%rbp)
	# returns the current number of bytes plus the number of bytes
	# written during mid flushes
	movq	_TINY_PF_OFFSET_COUNT(%rbp), %rax
	addq	_TINY_PF_OFFSET_NO_MID_FLUSHES(%rbp), %rax
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

# basically strlen: (char*) -> u64
# rdi: pointer to source
#
# number of bytes
_tiny_pf_function_strlen:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	$0, -16(%rbp)
	jmp	.__tiny_pf_function_strlen_condition
.__tiny_pf_function_strlen_loop:
	addq	$1, -8(%rbp)
	addq	$1, -16(%rbp)
.__tiny_pf_function_strlen_condition:
	movq	-8(%rbp), %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	.__tiny_pf_function_strlen_loop
	movq	-16(%rbp), %rax
	leave
	ret

# rdi: number
# rsi: base
# rdx: argument's length pointer
_tiny_pf_function_numstr:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	# stack variables --------------
	#  -8: number
	# -12: base 
	# -20: pointer to argument's length
	# -28: pointer to buffer
	# -30: is number negative?
	movq	%rdi, -8(%rbp)
	movl	%esi, -12(%rbp)
	movq	%rdx, -20(%rbp)
	movw	$0, -30(%rbp)
	#
	leaq	._tiny_pf_num_buffer(%rip), %rax
	addq	$_TINY_PF_NUM_BUFFER_CAPACITY, %rax
	decq	%rax
	movq	%rax, -28(%rbp)
	#
	movq	-20(%rbp), %rax
	movq	$0, (%rax)
.__tiny_pf_function_numstr_init:
	movq	-8(%rbp), %rax
	cmpq	$0, %rax
	je	.__tiny_pf_function_numstr_init_trivial
	jg	.__tiny_pf_function_numstr_loop
	movq	-8(%rbp), %rax
	movq	$-1, %rbx
	imulq	%rbx
	movq	%rax, -8(%rbp)
	movw	$1, -30(%rbp)
	jmp	.__tiny_pf_function_numstr_loop
.__tiny_pf_function_numstr_init_trivial:
	movq	-28(%rbp), %rax
	movb	$'0', (%rax)
	movq	-20(%rbp), %rax
	movq	$1, (%rax)
	jmp	.__tiny_pf_function_numstr_fini
.__tiny_pf_function_numstr_loop:
	movq	-8(%rbp), %rax
	movl	-12(%rbp), %ebx
	xorq	%rdx, %rdx
	divq	%rbx
	movq	%rax, -8(%rbp)
	addq	$48, %rdx
	movq	-28(%rbp), %rax
	movb	%dl, (%rax)
	decq	%rax
	movq	%rax, -28(%rbp)
	movq	-20(%rbp), %rax
	incq	(%rax)
	cmpq	$0, -8(%rbp)
	je	.__tiny_pf_function_numstr_fini
	jmp	.__tiny_pf_function_numstr_loop
.__tiny_pf_function_numstr_fini:
	cmpw	$1, -30(%rbp)
	jne	.__tiny_pf_function_numstr_fini_ret
	movq	-28(%rbp), %rax
	movb	$'-', (%rax)
	decq	%rax
	movq	%rax, -28(%rbp)
	movq	-20(%rbp), %rax
	incq	(%rax)
.__tiny_pf_function_numstr_fini_ret:
	movq	-28(%rbp), %rax
	incq	%rax
	leave
	ret



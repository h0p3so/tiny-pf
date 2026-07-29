.macro _tiny_pf_is_there_align type, jmp2_if_no_alignment, jmp2_if_alignment
	movl	_TINY_PF_OFFSET_ALIGN_TYPE(%rip), %eax
	cmpl	$0, %eax
	je	\jmp2_if_no_alignment
	cmpl	\type, %eax
	je	\jmp2_if_alignment
.endm

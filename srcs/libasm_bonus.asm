; -------------------------------------------------------------------------------
;			Libasm subject - Bonus part  |  ade-sarr  |  26-jan-2026
; -------------------------------------------------------------------------------
;
; int ft_atoi_base(char *str, char *base)
;
;   • Write a function that converts the initial portion of the string pointed to
;	  by str into an integer representation.
;	• str is in a specific base, given as a second parameter.
;	• Except for the base rule, the function should behave exactly like ft_atoi.
;	• If an invalid argument is provided, the function should return 0.
;	  Examples of invalid arguments:
;		◦ The base is empty or has only one character.
;		◦ The base contains duplicate characters.
;		◦ The base contains +, -, or whitespace characters.
;
; -------------------------------------------------------------
;	The linked list functions will use the following structure:
;	typedef struct	s_list
;	{
;		void 			*data;
;		struct s_list	*next;
;	}				t_list;
; -------------------------------------------------------------
;
; void ft_list_push_front(t_list **begin_list, void *data)
;
;	• Create the function ft_list_push_front, which adds a new element of type
;	  t_list to the beginning of the list.
;	• It should assign data to the given argument.
;	• If necessary, it will update the pointer at the beginning of the list.
;
; int ft_list_size(t_list *begin_list)
;
;	• Create the function ft_list_size, which returns the number of elements
;	  in the list.
;
; void ft_list_sort(t_list **begin_list, int (*cmp)(void *d1, void *d2))
;
;	• Create the function ft_list_sort which sorts the list’s elements in ascending
;	  order by comparing two elements and their data using a comparison function.
;	• The function pointed to by cmp will be used as:
;	  (*cmp)(list_ptr->data, list_other_ptr->data);
;
; void ft_list_remove_if(t_list **begin_list, void *data_ref,
;						 int (*cmp)(void *d1, void *data_ref), void (*free_fct)(void *d1))
;
;	• Create the function ft_list_remove_if which removes from the list all elements
;	  whose data, when compared to data_ref using cmp, causes cmp to return 0.
;	• The data from an element to be erased should be freed using free_fct.
;	• The functions pointed to by cmp and free_fct will be used as:
;	  (*cmp)(list_ptr->data, data_ref);
;	  (*free_fct)(list_ptr->data);
;
; -------------------------------------------------------------------------------
; System V ABI (x86-64 calling convention)
;	This is a 64-bit platform. The stack grows downwards. Parameters to functions
;	are passed in the registers rdi, rsi, rdx, rcx, r8, r9, and further values are
;	passed on the stack in reverse order. Parameters passed on the stack may be
;	modified by the called function. Functions are called using the call instruction
;	that pushes the address of the next instruction to the stack and jumps to the
;	operand. Functions return to the caller using the ret instruction that pops a
;	value from the stack and jump to it. The stack is 16-byte aligned just before
;	the call instruction is called.
;
;	Functions preserve the registers rbx, rsp, rbp, r12, r13, r14, and r15;
;	while rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11 are scratch registers.
;	The return value is stored in the rax register, or if it is a 128-bit value,
;	then the higher 64-bits go in rdx.
; -------------------------------------------------------------------------------

	default rel
	
	global ft_atoi_base, ft_list_push_front, ft_list_size, ft_list_remove_if, ft_list_sort, get_valid_base
	global ft_strchr, ft_skip_chars

	extern malloc, free, qsort, ft_strlen

	section .note.GNU-stack
	
	section .rdata
base_validchar:	db "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
				db "$&~^%*#\|/@={}()[]_<>?!.",0
blank_chars:	db ` \t\n\r\f\v`,0
	
	section .bss
ft_list_sort_cmpfct dq ?
	
	section .text

struc clist
	cl_data:	resq 1
	cl_next:	resq 1
endstruc

; ======= I. ft_atoi_base() & helpers =================================================

; char *ft_strchr(const char *str, int c)
; preserves registers (except flags and rax)
ft_strchr:
	push	rdi
	push	rcx
	xor		rax, rax	; rax = null
	test	rdi, rdi
	jz		.return		; return null
.loop:
	mov		cl, [rdi]	; cl = current char
	cmp		cl, sil		; compare with c
	je		.founded
	test	cl, cl		; end of str ?
	jz		.return		; if yes return null
	inc		rdi			; set rdi to next char
	jmp		.loop
.founded:
	mov		rax, rdi	; return addr of first occurence of c in str
.return:
	pop		rcx
	pop		rdi
	ret

; char *ft_skip_chars(char *str, char *chr2skip)
; returns the first position witch is not a char belonging to chr2skip 
; preserves registers (except flags and rax)
ft_skip_chars:
	push	rdi
	push	rsi
	push	rcx
	xor		rax, rax	; rax = null
	test	rdi, rdi
	jz		.return		; return null
	mov		rcx, rdi	; rcx = str
	mov		rdi, rsi	; rdi = chr2skip
	xor		rsi, rsi	; sil will be used to store current char of str
.loop:
	mov		sil, [rcx]	; sil = current char
	call	ft_strchr
	test	rax, rax
	jz		.retcurpos
	test	sil, sil	; end of str ?
	jz		.retcurpos
	inc		rcx			; set rcx to next char
	jmp		.loop
.retcurpos:
	mov		rax, rcx	; return addr of current char
.return:
	pop		rcx
	pop		rsi
	pop		rdi
	ret

; int get_valid_base(char *base)
; returns the numeric base: the length of base string if base is valid;
; if base is not valid, returns 0
get_valid_base:
	call	ft_strlen		; (ft_strlen preserves regs)
	cmp		rax, 2			; base must have at least 2 digit
	jb		.retinvalid
	mov		rdx, rax		; rdx = the numeric base
	mov		rcx, rdi		; rcx = ptr to current digit
	xor		rsi, rsi
.loop:
	lea		rdi, [base_validchar]
	mov		sil, [rcx]
	call	ft_strchr		; test if digit is a valid char ; (ft_strchr preserves regs)
	test	rax, rax
	jz		.retinvalid
	inc		rcx				; set rcx to next digit
	mov		rdi, rcx
	call	ft_strchr		; test if we have no duplicate
	test	rax, rax
	jnz		.retinvalid
	cmp		byte [rcx], 0	; fin de base ?
	jnz		.loop
.return:
	mov		rax, rdx		; return the numeric base
	ret
.retinvalid:
	xor		rax, rax
	ret

; int ft_atoi_getsign(char *str)
; get sign and skip blanks: return sign in rax & adjused str addr in rdi
ft_atoi_getsign:
	lea		rsi, [blank_chars]
	call	ft_skip_chars
	mov		rdi, rax
	cmp		byte [rax], '+'
	je		.plus
	cmp		byte [rax], '-'
	je		.minus
	mov		rax, 1
	ret
.plus:
	inc		rdi
	mov		rax, 1
	ret
.minus:
	inc		rdi
	mov		rax, -1
	ret

; int ft_atoi_base(char *str, char *base)
ft_atoi_base:
	push	rbx
	push	rsi
	push	rdi
	mov		rdi, rsi
	call	get_valid_base
	test	rax, rax
	jz		.return			; return 0
	mov		rdi, [rsp]		; rdi = str
	push	rax				; save num base
	call	ft_atoi_getsign	; get sign and skip blanks: return sign in rax & adjused str in rdi
	mov		r8, rax			; r8 = sign (1 or -1)
	mov		rcx, rdi		; rcx = str adjusted addr
	pop		rbx				; rbx = the numeric base
	mov		rdi, [rsp+8]	; rdi = base
	xor		rsi, rsi		; sil will be used to store current digit char
	xor		rdx, rdx		; init result number to 0
	jmp		.loop_entry
.loop:
	call	ft_strchr		; find the digit char into base
	test	rax, rax
	jz		.retnumber
	imul	rdx, rbx		; result *= numbase
	sub		rax, rdi		; rax = digit value (distance to first digit in base)
	add		rdx, rax		; result += digitvalue
.loop_entry:	
	mov		sil, [rcx]		;| sil = *rcx++
	inc		rcx				;|
	test	sil, sil
	jnz		.loop
.retnumber:
	mov		rax, rdx
	imul	rax, r8			; mul by sign (1 or -1)
.return:
	pop		rdi
	pop		rsi
	pop		rbx
	ret

; ======= II. Chained list fonctions ==================================================

; void ft_list_push_front(t_list **begin_list, void *data)
ft_list_push_front:
	sub		rsp, 8				; align stack on 16-byte boundary
	push	rsi
	push	rdi
	mov		rdi, clist_size		; sizeof(t_list) ; (two 64-bit pointers = 16 bytes)
	call	malloc wrt ..plt	; alloc mem for the new elem
	pop		rdi
	pop		rsi
	test	rax, rax			; test malloc ret val: rax = ptr on new elem
	jz		.return
	mov		r8, [rdi]			; r8 = *begin_list
	mov		[rax + cl_data], rsi	; newelem->data = data
	mov		[rax + cl_next], r8		; newelem->next = *begin_list
	mov		[rdi], rax			; begin_list = addr of new elem
.return:
	add		rsp, 8				; retore stack
	ret

; int ft_list_size(t_list *begin_list)
ft_list_size:
	xor		rax, rax		; (compteur et valeur de retour) rax = 0
	jmp		.test
.loop:
	inc		rax
	mov		rdi, [rdi + cl_next]
.test:
	test	rdi, rdi
	jnz		.loop
	ret

; input:  rdi = t_list *list
; output: rax = array addr, rdx = array size
create_array_from_list:
	test	rdi, rdi
	jnz		.notnull
	xor		rax, rax
	ret
.notnull:
	push	rdi					; save list and align stack on 16 bytes boundary
	call	ft_list_size
	shl		rax, 3				; size of array in bytes: list_size * 8
	mov		rdi, rax
	call	malloc wrt ..plt
	test	rax, rax
	jz		.return
	mov		rdi, rax			; rdi = array
	mov		rsi, [rsp]			; rsi = list
.loop:
	mov		rdx, [rsi + cl_data]	;| copy data ptr from list to array
	mov		[rdi], rdx				;| 
	add		rdi, 8					; | iterate through array and list
	mov		rsi, [rsi + cl_next]	; | 
	test	rsi, rsi			; test end of list
	jnz		.loop
	mov		rdx, rdi
	sub		rdx, rax
	shr		rdx, 3				; div by 8
.return:
	add		rsp, 8
	ret

; input: rdi = t_list *list, rsi = array addr
sort_list_from_array:
	mov		rdx, [rsi]				;| copy data ptr from array to list
	mov		[rdi + cl_data], rdx	;|
	mov		rdi, [rdi + cl_next]	; | iterate through array and list
	add		rsi, 8					; | 
	test	rdi, rdi
	jnz		sort_list_from_array
	ret

; Wrapper for the comparison function of ft_list_sort (cmp)
; suitable for qsort() as comparison function.
; /!\ global ft_list_sort_cmpfct must be set before use.
compare_data:
	sub		rsp, 8
	mov		rdi, [rdi]
	mov		rsi, [rsi]
	call	[ft_list_sort_cmpfct]
	add		rsp, 8
	ret

; void qsort(void base[.size * .nmemb], size_t nmemb, size_t size,
;			 int (*compar)(const void [.size], const void [.size]));

; void ft_list_sort(t_list **begin_list, int (*cmp)(void *d1, void *d2))
ft_list_sort:
	sub		rsp, 24			; space for 3 local vars to store begin_list, cmp and array addr
	mov		rdi, [rdi]		; rdi = 1er element de la liste
	mov		[rsp], rdi		; [rsp+0] = t_list *begin_list 
	mov		[rsp+8], rsi	; [rsp+8] = cmp function
	call	create_array_from_list ; return array addr in rax and size in rdx
	test	rax, rax		; create array fail ?
	jz		.return
	mov		[rsp+16], rax	; [rsp+16] = array addr
	mov		rdi, rax		; qsort arg 1: base = array addr
	mov		rsi, rdx		; qsort arg 2: nmemb = array size
	mov		rdx, 8			; qsort arg 3: size = sizeof(void *)
	mov		rcx, [rsp+8]	; qsort arg 4: rcx = cmp function
	mov		[ft_list_sort_cmpfct], rcx
	lea		rcx, [compare_data]
	call	qsort wrt ..plt
	mov		rdi, [rsp]
	mov		rsi, [rsp+16]
	call	sort_list_from_array
	mov		rdi, [rsp+16]
	call	free wrt ..plt
.return:
	add		rsp, 24
	ret


; void ft_list_remove_if(t_list **begin_list, void *data_ref,
;			int (*cmp)(void *d, void *data_ref), void (*free_data)(void *d))
ft_list_remove_if:
	sub		rsp, 8
	push	rbx
	push	rbp
	push	r12
	push	r13
	push	r14
	push	r15
	mov		r12, rdi			; r12 = begin_list
	mov		r13, rsi			; r13 = data_ref
	mov		r14, rdx			; r14 = cmp function
	mov		r15, rcx			; r15 = free_data
	mov		rbp, 0				; rbp = previous element
	mov		rbx, [r12]			; rbx = current element
.loop:
	test	rbx, rbx
	jz		.return
	mov		rdi, [rbx+cl_data]
	mov		rsi, r13
	call	r14					; cmp()
	test	rax, rax			; if current elem data match data_ref
	jz		.remove				;   ->remove element
	mov		rbp, rbx			; set previous = current
	mov		rbx, [rbx+cl_next]	; set current = next
	jmp		.loop
.remove:
	mov		rdi, [rbx+cl_data]
	call	r15					; free_data()
	mov		rax, [rbx+cl_next]	; rax = next element
	test	rbp, rbp
	jz		.firstelem
	mov		[rbp+cl_next], rax	; prev->next = curr->next
	jmp		.free
.firstelem:
	mov		[r12], rax			; *begin_list = curr->next
.free:
	mov		rdi, rbx
	mov		rbx, rax			; set current = next (and prev. unchanged)
	call	free wrt ..plt
	jmp		.loop
.return:	
	pop		r15
	pop		r14
	pop		r13
	pop		r12
	pop		rbp
	pop		rbx
	add		rsp, 8
	ret

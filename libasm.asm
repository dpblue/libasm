; ---------------------------------------------------------------------------------
;			Libasm subject - Mandatory part  |  ade-sarr  |  26-jan-2026
; ---------------------------------------------------------------------------------
;
; • The library must be called libasm.a.
; • You must submit a main function that will test your functions and compile with
;   your library to demonstrate that it is functional.
; • You must rewrite the following functions in assembly:
;	 ◦ ft_strlen (man 3 strlen)
;	 ◦ ft_strcpy (man 3 strcpy)
;	 ◦ ft_strcmp (man 3 strcmp)
;	 ◦ ft_write (man 2 write)
;	 ◦ ft_read (man 2 read)
;	 ◦ ft_strdup (man 3 strdup, you can call to malloc)
; • You must check for errors during syscalls and handle them properly when needed.
; • Your code must set the variable errno properly.
; • For that, you are allowed to call the extern ___error or errno_location.
; ---------------------------------------------------------------------------------
;
; void *malloc(size_t size)
;
; syscall 0: ssize_t read (int fd, const void *buf, size_t count)
; syscall 1: ssize_t write(int fd, const void *buf, size_t count)
;
; Convention d'appel de fonction:
; 	les 6 premiers arguments sont passés par registres: rdi, rsi, rdx, rcx, r8, r9
;	et les arguments suivants sont passés par la pile (empilés en ordre inverse).
;	rbx, rsp, rbp, r12, r13, r14, et r15 doivent etre preservés
;	rax, rdi, rsi, rdx, rcx, r8, r9, r10 et r11 peuvent etre modifiés
;	le retour se fait dans rax (ou si valeur 128-bit, retour dans rdx:rax)
;
; syscall args order: rdi, rsi, rdx, r10, r8, r9 (rcx is used to store the return addr)
;
; IMPORTANT: avant un call le registre de pile (rsp) doit etre alignée sur 16 octets.
; En entrée de fonction rsp n'est plus aligné car la valeur de retour (64-bit ; 8 bytes)
; a été empilée par le call ! Il faut donc penser à réaligner la pile si l'on fait
; un autre call dans la fonction.
;
; ---------------------------------------------------------------------------------
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
; ---------------------------------------------------------------------------------


	global ft_read, ft_write, ft_strlen, ft_strcpy, ft_strcmp, ft_strdup

	extern __errno_location, malloc

	section .note.GNU-stack
	
	section .text

; ssize_t	ft_read (int fd, const void *buf, size_t count)
ft_read:
	sub		rsp, 8
	mov		rax, 0			; call read
	syscall					; invoke the syscall
	test	rax, rax		; test if the read returns an error (negative value) ?
	jl		.error			; jump to error if lower than zero
	add		rsp, 8
	ret
.error:
	mov		rbx, rax		; rbx = negative value returned by the read syscall
	neg		rbx				; rbx = the errno value (positive)
	call	__errno_location wrt ..plt ; get errno address
	mov		[rax], rbx		; set errno
	mov		rax, -1			; set return value to -1
	add		rsp, 8
	ret	

; ssize_t	ft_write(int fd, const void *buf, size_t count)
ft_write:
	sub		rsp, 8
	mov		rax, 1			; call write
	syscall					; invoke the syscall
	test	rax, rax		; test if write returns error (negative value) ?
	jl		.error			; jump to error if lower than zero
	add		rsp, 8
	ret
.error:
	mov		rbx, rax		; rbx = negative value returned by the write syscall
	neg		rbx				; rbx = the errno value (positive)
	call	__errno_location wrt ..plt ; get errno address
	mov		[rax], rbx		; set errno
	mov		rax, -1			; set return value to -1
	add		rsp, 8
	ret	

; size_t	ft_strlen(const char *str)
; NB: preserves registers (except flags and rax)
ft_strlen:
	test	rdi, rdi
	jnz		.begin
	xor		rax, rax
	ret
.begin:	
	push	rsi
	mov		rsi, rdi		; use rsi to iterate and rdi remains on str first char
	dec		rsi
.loop:
	inc		rsi
	cmp		byte [rsi], 0	; end of str ?
	jnz		.loop			; no -> loop to the next char
	mov		rax, rsi
	sub		rax, rdi		; length (rax) = rsi - rdi
	pop		rsi
	ret

; char *	ft_strcpy(char *restrict dst, const char *restrict src)
ft_strcpy:
	mov		rax, rdi		; set return val = dst
.loop:
	mov		cl, [rsi]
	mov		[rdi], cl		; copy char from src to dst
	inc		rsi				; next char addr for src
	inc		rdi				; next char addr for dst
	test	cl, cl			; test end of src (char == 0) ?
	jnz		.loop
	ret

; int		ft_strcmp(const char *s1, const char *s2)
ft_strcmp:
	test	rdi, rdi		; test s1
	jnz		.s1ok
	test	rsi, rsi		; test s2
	jnz		.s2sup
	xor		rax, rax		; s1 & s2 both null: return 0
	ret
.s2sup:
	mov		rax, -1			; s1 null & s2 ok: return -1
	ret
.s1ok:
	test	rsi, rsi		; test s2
	jnz		.begin
	mov		rax, 1			; s1 ok & s2 null: return 1
	ret

.begin:						; s1 & s2 not null
	xor		rcx, rcx		; rcx = 0
	xor		rdx, rdx		; rdx = 0
.loop:
	mov		dl, [rdi]		; dl = current char of s1
	mov		cl, [rsi]		; cl = current char of s2
	cmp		dl, cl			; dl == cl ?
	jne		.end			; no -> goto end
	test	dl, dl			; dl == 0 ?
	jz		.end			; yes -> goto end
	test	cl, cl			; cl == 0 ?
	jz		.end			; yes -> goto end
	inc		rdi				; next char addr for s1
	inc		rsi				; next char addr for s2
	jmp		.loop
.end:
	mov		rax, rdx
	sub		rax, rcx		; return value (rax) = dl - cl
	ret

; char *	ft_strdup(const char *str)
ft_strdup:
	push	rdi				; save str and align stack on 16 bytes boundary
	call	ft_strlen
	mov		rdi, rax
	inc		rdi				; malloc arg = strlen + 1
	call	malloc wrt ..plt
	test	rax, rax		; rax == NULL ?
	jz		.return			; if malloc fails do nothing (and return rax witch is 0)
	mov		rdi, rax		; 1st arg for ft_strcpy: malloc return addr
	mov		rsi, [rsp]		; 2nd arg for ft_strcpy: str (get from stack)
	call	ft_strcpy
.return:
	add		rsp, 8
	ret

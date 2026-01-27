; Les fonctions print attendent les memes arguments qu'un printf
; ce qui est logique puisque qu'elles se contentent d'appeler printf() !
;
; IMPORTANT: avant un call la pile doit etre alignée sur 16 octets.
; En entrée de fonction la pile n'est plus alignée car la valeur de retour
; de 8 octets (64-bit) a été empilée par le call ! Il faut donc penser à réaligner
; la pile si l'on fait un autre call dans la fonction.
;
; author: ade-sarr
; date: janvier 2026

default rel
global print, print_7, print_8, print_1_6
extern printf

section .note.GNU-stack

section .rdata

section .text
print:							; Simple saut vers printf; marche dans tous les cas quelque soit le
	jmp		printf wrt ..plt	; nombre d'arguments car la pile est conservée (avec les varargs > 6)
								; et deumeure désalignée de 8 bytes comme en entrée du print.
	;ret						; ici pas de return: le printf retournera directement à l'appelant du print.
								; par ailleurs aucun registre n'est modifié donc les arguments 1 à 6 preservés.

print_7:						; printf avec 7 arguments
	push	qword [rsp + 8]		; argument 7 (et pile aligné sur 16 octets)
	call	printf wrt ..plt
	add		rsp, 8
	ret

print_8:						; printf avec 8 arguments
	push	rbp					; sauvegarde bp (et pile aligné sur 16 octets)
	mov		rbp, rsp			;
	push	qword [rbp + 24]	; argument 8
	push	qword [rbp + 16]	; argument 7 (et pile aligné sur 16 octets)
	call	printf wrt ..plt
	mov		rsp, rbp			; retauration de sp
	pop		rbp					; restauration de bp
	ret

print_1_6:						; les 6 premiers arguments sont transmis par les registres: rdi, rsi, rdx, rcx, r8, r9
	sub		rsp, 8				; nécessaire pour aligner la pile
	call	printf wrt ..plt
	add		rsp, 8
	ret

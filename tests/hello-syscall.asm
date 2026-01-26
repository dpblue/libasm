; Appels système via SYSCALL (default in 64-bit, recommended)
; write(2) syscall: ssize_t write(int fd, const void *buf, size_t count)

    global _start

    section .rdata

message: db "Hello, world!", 0xA
length: equ $ - message

    section .text

_start:
    mov rax, 1          ; call write
    mov rdi, 1          ; file descriptor 1 (stdout)
    lea rsi, message    ; the string to write
    mov rdx, length     ; the length of the string
    syscall             ; invoke the syscall

    mov eax, 60         ; call exit
    xor rdi, rdi        ; error code 0
    syscall             ; invoke the syscall

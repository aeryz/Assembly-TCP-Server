%include "defines.s"

extern socket_listen
extern socket_accept
extern h_memset

global _main

section .bss
buffer:
resb 1024

section .text

echo:
    push rbp
    mov rbp, rsp
    sub rsp, 0xF
    push rbx

    ; Save the socket descriptor.
    mov rbx, rdi

    ; Clean the buffer.
    mov rdi, buffer
    mov rsi, 0
    mov rdx, 1024
    call h_memset

    ; read(rdi: socketfd, rsi: buffer, rdx: len(buffer))
    ;    Read max. 1024 characters to buffer. 
    mov rax, SYSCALL(READ)
    mov rdi, rbx
    mov rsi, buffer
    mov rdx, 1024
    syscall

    ; write(rdi: socketfd, rsi: buffer, rdx: len(buffer))
    ;    Write 
    mov rdx, rax
    mov rax, SYSCALL(WRITE)
    mov rsi, buffer
    syscall

    cmp rax, 0
    jmp .ret

.ret:
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

close_connection:
    mov rax, SYSCALL(CLOSE)
    syscall

    ret

accept_loop:
    push rbp
    mov rbp, rsp
    sub rsp, 0x8 ; for stack alignment
.accept_loop:
    push rdi
    call socket_accept
    cmp rax, 0
    jl .ret
    mov rdi, rax
    call echo
    call close_connection
    pop rdi
    jmp .accept_loop

.ret:
    mov rsp, rbp
    pop rbp
    ret

extern h_strlen


_main:
    and rsp, 0xFFFFFFFFFFFFFF00
    call socket_listen

    mov rdi, rax
    call accept_loop

.ret:
    mov rax, SYSCALL(EXIT)
    mov rdi, 0
    syscall

READ_FAILED:
db "read() failed", 0x10, 0x0

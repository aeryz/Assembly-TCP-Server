%include "defines.s"

extern socket_listen
extern socket_accept

global _main

section .bss
buffer:
resb 1024

section .text

echo:
    mov rax, SYSCALL(READ)
    mov rsi, buffer
    mov rdx, 1024
    syscall

    mov rax, SYSCALL(WRITE)
    mov rsi, buffer
    mov rdx, 1024
    syscall

    ret

close_connection:
    mov rax, SYSCALL(CLOSE)
    syscall

    ret

accept_loop:
    push rbp
    mov rbp, rsp

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


_main:
    and rsp, 0xFFFFFFFFFFFFFF00
    call socket_listen

    mov rdi, rax

    call accept_loop
    
    mov rax, SYSCALL_BASE + 1
    mov rdi, 0
    syscall

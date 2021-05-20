%include "defines.s"

extern socket_listen
extern socket_accept

global _main

section .bss
buffer:
resb 1024

section .text

echo:
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

    cmp rax, 0
    jle .read_failed

    ; write(rdi: socketfd, rsi: buffer, rdx: len(buffer))
    ;    Write 
    mov rax, SYSCALL(WRITE)
    mov rsi, buffer
    mov rdx, rax
    syscall

    jmp .ret

.read_failed:
    mov rbx, rax

    mov rdi, READ_FAILED
    call h_strlen

    
.ret:
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

extern h_strlen


_main:
    mov rdi, HELO
    call h_strlen
    jmp .ret

    and rsp, 0xFFFFFFFFFFFFFF00
    call socket_listen

    mov rdi, rax

    call accept_loop

.ret:
    mov rax, SYSCALL(EXIT)
    mov rdi, 0
    syscall

HELO:
db "hello world", 0x10, 0x0

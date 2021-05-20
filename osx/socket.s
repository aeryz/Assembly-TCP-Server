%include "defines.s"

%define AF_INET 2
%define SOCK_STREAM 1
%define INADDR_ANY 0

global socket_listen
global socket_accept

extern _htons

section .text

htons:
    mov dx, di
    mov ax, dx
    shl ax, 8
    shr dx, 8
    mov al, dl

    ret
    

; listen(ip_address, port)
;
; Opens a TCP socket and listens on the given ip/port
socket_listen:
    push rbp
    mov rbp, rsp 
    sub rsp, 0x10

    mov rax, SYSCALL(SOCKET)
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, 0
    syscall

    cmp rax, 0
    jl .socket_failed

    mov rbx, rax

    mov di, 4444
    call htons

    ; TODO memset
    mov byte [rsp], 0
    mov byte [rsp+0x1], AF_INET
    mov word [rsp+0x2], ax
    mov dword[rsp+0x4], INADDR_ANY
    mov qword[rsp+0x8], 0

    mov rax, SYSCALL(BIND)
    mov rdi, rbx
    lea rsi, [rsp]
    mov rdx, 16
    syscall

    cmp rax, 0
    jl .bind_failed

    mov rax, SYSCALL(LISTEN)
    mov rdi, rbx
    mov rsi, 0
    syscall 

    cmp rax, 0
    jl .listen_failed

    mov rax, rbx
    jmp .ret

.socket_failed:
    mov rsi, SOCKET_FAILED
    jmp .err_msg
.bind_failed:
    mov rsi, BIND_FAILED
    jmp .err_msg
.listen_failed:
    mov rsi, LISTEN_FAILED
    jmp .err_msg
.err_msg:
    mov rax, SYSCALL(READ)
    mov rdi, 1
    mov rdx, 15 ; TODO: strlen
    syscall

    mov rax, -1
.ret:
    mov rsp, rbp
    pop rbp
    ret

; rdi: socket
socket_accept:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10 

    mov rax, SYSCALL(ACCEPT)
    lea rsi, [rsp + 0x4]
    lea rdx, [rsp]
    syscall

    cmp rax, 0
    jge .ret

    mov rax, SYSCALL(READ)
    mov rsi, ACCEPT_FAILED
    mov rdi, STDOUT
    mov rdx, 15 ; TODO: strlen
    syscall

    mov rax, -1
    jmp .ret
.ret:
    mov rsp, rbp
    pop rbp
    ret


SOCKET_FAILED:
    db "socket() failed", 10, 0
BIND_FAILED:
    db "bind() failed", 10, 0
LISTEN_FAILED:
    db "listen() failed", 10, 0
ACCEPT_FAILED:
    db "accept() failed", 10, 0




%include "defines.s"

%define AF_INET 2
%define SOCK_STREAM 1
%define INADDR_ANY 0

global socket_listen
global socket_accept

extern h_strlen

section .text

; htons(port)
;    Convert 'port' to network byte-order.
htons:
    ; Swap the first and the second byte of 'port'.
    mov dx, di
    mov ax, dx
    shl ax, 8
    shr dx, 8
    mov al, dl

    ret
    

socket_listen:
    ; Save the stack's base pointer.
    push rbp
    mov rbp, rsp 
    ; 16-byte aligned stack:
    ;    0x8: 'call' instruction pushes the return address,
    ;    0x8: saved 'rbp',
    ;    0x10: reserved for local variable,
    ;    Total of 32 bytes.
    sub rsp, 0x10

    ; socket(rdi: AF_INET, rsi: SOCK_STREAM, rdx: 0)
    mov rax, SYSCALL(SOCKET)
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, 0
    syscall

    ; Socket returns <0 on failure.
    cmp rax, 0
    jl .socket_failed

    ; Save the returned socket descriptor.
    mov rbx, rax

    ; htons(rdi: port)
    ;    Convert port to network byte-order.
    mov di, 4444
    call htons

    ; memset(rdi: struct sockaddr*, rsi: x, rdx: sizeof(struct sockaddr))
    ;    Initialize 'struct sockaddr' variable with 'x'.
    lea rdi, [rsp]
    mov rsi, 0
    mov rdx, 0x10
    call memset

    ; struct sockaddr_in addr;
    ; memset(&addr, 0, sizeof(addr));
    ; addr.sin_family = AF_INET;
    ; addr.sin_addr.s_addr = INADDR_ANY;
    ; addr.sin_port = htons(PORT);
    mov byte [rsp+0x1], AF_INET
    mov word [rsp+0x2], ax
    mov dword[rsp+0x4], INADDR_ANY

    ; bind(rdi: socket, rsi: addr, rdx: sizeof(addr))
    mov rax, SYSCALL(BIND)
    mov rdi, rbx
    lea rsi, [rsp]
    mov rdx, 0x10
    syscall

    cmp rax, 0
    jl .bind_failed

    ; listen(rdi: socket, rsi: backlog(5))
    mov rax, SYSCALL(LISTEN)
    mov rdi, rbx
    mov rsi, 5
    syscall 

    cmp rax, 0
    jl .listen_failed

    ; Restore the socket to return.
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
    ; strlen(rdi: str)
    mov rdi, rsi
    call h_strlen
    ; write(rdi: fd, rsi: buffer, rdx: count of bytes to write);
    mov rbx, rax
    mov rax, SYSCALL(WRITE)
    mov rdi, 1
    mov rdx, rbx 
    syscall

    mov rax, -1
.ret:
    ; Properly return from the function.
    mov rsp, rbp
    pop rbp
    ret

socket_accept:
    push rbp
    mov rbp, rsp
    sub rsp, 0x10 

    ; accept(rdi: socket, rsi: output addr, rdx: addr len);
    ;    This blocks until a new connection is establishes and returns
    ;    a new socket descriptor for the connection.
    mov rax, SYSCALL(ACCEPT)
    lea rsi, [rsp + 0x4]
    lea rdx, [rsp]
    syscall

    cmp rax, 0
    jge .ret

    mov rdi, ACCEPT_FAILED
    call h_strlen
    mov rbx, rax

    mov rax, SYSCALL(WRITE)
    mov rsi, ACCEPT_FAILED
    mov rdi, STDOUT
    mov rdx, rbx
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




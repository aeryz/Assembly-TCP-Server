
global h_strlen
global h_memset

section .text
; strlen(str)
;    loop until '\0' is seen and return length of 'str'
h_strlen:
    push rdi
    push rbx
    mov rbx, rdi
    xor rax, rax
    xor rcx, rcx
    dec rcx
    repne scasb
    sub rax, 2
    sub rax, rcx
    pop rbx
    pop rdi
    ret
    
; memset(dst, x, n)
;   starting from [dst], write 'x', to next 'n' bytes
h_memset:
    mov rax, rsi
    mov rcx, rdx
    rep stosb
    ret

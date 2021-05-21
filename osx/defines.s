
%ifdef PLATFORM_OSX
    %define SYSCALL_BASE 0x2000000
    %define EXIT 1
    %define READ 3
    %define WRITE 4
    %define CLOSE 6
    %define ACCEPT 30
    %define SOCKET 97
    %define BIND 104
    %define SETSOCKOPT 105
    %define LISTEN 106
%endif

%define STDOUT 1

%define SYSCALL(NUM) (SYSCALL_BASE + NUM)

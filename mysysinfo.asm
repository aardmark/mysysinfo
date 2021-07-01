LF equ 10
NULL equ 0
TAB equ 9
EXIT_SUCCESS equ 0 ; success code
SYS_sysinfo equ 99; get system information
SYS_exit equ 60 ; terminate

struc s_sysinfo
    .uptime:        resq 1
    .load1:         resq 1
    .load2:         resq 1
    .load3:         resq 1
    .totalram:      resq 1
    .freeram:       resq 1
    .sharedram:     resq 1
    .bufferram:     resq 1
    .totalswap:     resq 1
    .freeswap:      resq 1
    .procs:         resw 1
    .pad1           resb 6 ; pad to 64 bits
    .totalhigh:     resq 1
    .freehigh:      resq 1
    .mem_unit:      resd 1
    .pad2           resb 4 ; pad to 64 bits
endstruc

;--------------------------------------------------------------;
section .data

totalMemory db 'Total memory:', TAB, NULL
freeMemory db 'Free memory:', TAB, NULL
sharedMemory db 'Shared memory:', TAB, NULL
bufferMemory db 'Buffer memory:', TAB, NULL
totalSwap db 'Total swap:', TAB, NULL
freeSwap db 'Free swap:', TAB, NULL
processes db 'Processes:', TAB, NULL
newLine db LF, NULL
kb db ' kB', LF, NULL
errorText db 'An error occurred retrieving system information',LF,NULL

;--------------------------------------------------------------;
section .bss
sysinfo: resb s_sysinfo_size

;--------------------------------------------------------------;
extern printString, printError, malloc, free, printNum
;--------------------------------------------------------------;

section .text
global _start
_start:

    mov rdi, sysinfo
    mov rax, SYS_sysinfo
    syscall
    test rax, rax ; check for error
    js error

    mov rdi, totalMemory
    mov rsi, [sysinfo + s_sysinfo.totalram]
    call printMemoryInKb

    mov rdi, freeMemory
    mov rsi, [sysinfo + s_sysinfo.freeram]
    call printMemoryInKb

    mov rdi, sharedMemory
    mov rsi, [sysinfo + s_sysinfo.sharedram]
    call printMemoryInKb

    mov rdi, bufferMemory
    mov rsi, [sysinfo + s_sysinfo.bufferram]
    call printMemoryInKb

    mov rdi, totalSwap
    mov rsi, [sysinfo + s_sysinfo.totalswap]
    call printMemoryInKb

    mov rdi, freeSwap
    mov rsi, [sysinfo + s_sysinfo.freeswap]
    call printMemoryInKb

    mov rdi, processes
    mov rsi, 0
    mov si, [sysinfo + s_sysinfo.procs]
    call printValue

    jmp done

printMemoryInKb:
    push rbx
    push rsi
    call printString
    pop rax
    mov rdx, 0
    mov rbx, 1024
    div rbx
    mov rdi, rax
    mov rsi, 10
    call printNum
    mov rdi, kb
    call printString
    pop rbx
    ret

; print a value with a label
; params: rdi - pointer to label
;         rsi - value
printValue:
    push rsi
    call printString
    pop rdi
    mov rsi, 10
    call printNum
    mov rdi, newLine
    call printString

error:
    mov rdi, errorText
    call printError

done:
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall

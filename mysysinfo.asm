LF equ 10
NULL equ 0
EXIT_SUCCESS equ 0 ; success code
SYS_exit equ 60 ; terminate

;--------------------------------------------------------------;
section .data

newLine db LF, NULL

;--------------------------------------------------------------;
section .bss

;--------------------------------------------------------------;
extern printString, printError, malloc, free, printNum
;--------------------------------------------------------------;

section .text
global _start
_start:

done:
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall

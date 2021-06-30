NULL equ 0 ; end of string
STDIN equ 0 ; standard input
STDOUT equ 1 ; standard output
STDERR equ 2 ; standard error
SYS_write equ 1 ; write
ZERO_BIT equ 0x1
PROT_READ equ 0x1 ;		Page can be read.
PROT_WRITE equ 0x2 ;		Page can be written.
MAP_SHARED equ	0x01 ;		Share changes.
MAP_PRIVATE equ	0x02 ;		Changes are private.
MAP_ANONYMOUS equ	0x20
SYS_mmap equ 9 ; mmap
SYS_munmap equ 11; munmap
BINARY_PREFIX equ 0x6230
OCTAL_PREFIX equ 0x6f30
HEX_PREFIX equ 0x7830
section .data

section .bss

buffer:         resb    128

section .text

global printString, printError, malloc, free, printNum

; printNum
; prints a number in a specified radix
; args: rdi - number to print
;       rsi - radix
; returns: nothing
printNum:
    push rbx ; save preserved register

    mov rax, rdi
    mov rbx, rsi
    mov rcx, 0    ; counter of digits pushed on to stack

; first store the characters we want to print on the stack
.divloop:
    mov rdx, 0
    div rbx       ; remainder of div goes into rdx
    cmp rdx, 9    ; if the digit is greater than nine, we want alpha representation
    jg .alpha
    add rdx, 0x30 ; convert digit to ascii
    jmp .pushit
.alpha:
    add rdx, 0x57 ; convert alpha digit to ascii
.pushit:
    push rdx      ; push ascii character on stack
    inc rcx       ; and increment counter
    cmp rax, 0
    jnz .divloop

; now store digits in memory as zero terminated string
    mov rbx, buffer
    mov rdi, 0

; apply known prefixes
    cmp rsi, 2
    jne .notbase2
    mov word [rbx+rdi], BINARY_PREFIX
    add rdi, 2
    jmp .popit
.notbase2:
    cmp rsi, 8
    jne .notbase8
    mov word [rbx+rdi], OCTAL_PREFIX
    add rdi, 2
    jmp .popit
.notbase8:
    cmp rsi, 16
    jne .popit
    mov word [rbx+rdi], HEX_PREFIX
    add rdi, 2
    
.popit:
    pop rax ; get next character off the stack and store in memory
    mov byte [rbx+rdi], al
    inc rdi
    loop .popit

    mov byte [rbx+rdi], 0 ; null terminate string
    mov rdi, buffer
    call printString      ; and print it

    pop rbx ; restore preserved register
    ret

; printString
; prints a null terminated string to stdout
; args:    rdi - address of string
; returns: nothing
;
printString:
    mov rsi, rdi ; address of string
    mov rdi, STDOUT
    call printf
    ret

; printError
; prints a null terminated string to stderr
; args:    rdi - address of string
; returns: nothing
;
printError:
    mov rsi, rdi ; address of string
    mov rdi, STDERR
    call printf
    ret


; printf
; prints a null terminated string to a file
; args:    rdi - fd
;          rsi - pointer to string
; returns: nothing
;
printf:
    push rdi ; save args
    push rsi
    mov rdi, rsi
    call strLen
    pop rsi ; restore args
    pop rdi
    test rax, rax ; is length of string 0?
    jz printfDone ; nothing to print
    mov rdx, rax ; length of string
    mov rax, SYS_write ; system code for write()
    syscall
printfDone:
    ret

; strLen
; gets the length of a null terminated string
; args:      rdi - address of string
; returns:   rax - length
strLen:
    push rbx

    mov rbx, rdi
    mov rdx, 0

strLenLoop:
    cmp byte [rbx], NULL
    je strLenEndLoop
    inc rdx
    inc rbx
    jmp strLenLoop

strLenEndLoop:
    mov rax, rdx

    pop rbx
    ret

; malloc
; gets some memory
; args:      rdi - amount of memory
; returns:   rax - address of memory
malloc:
    mov rsi, rdi ; length
    mov rdi, NULL ; address
    mov rdx, PROT_READ | PROT_WRITE ; memory protection
    mov r10, MAP_ANONYMOUS | MAP_PRIVATE ; flags
    mov r8, -1 ; fd
    mov r9, 0 ; offset
    mov rax, SYS_mmap
    syscall

    ret

; free
; free some memory
; args:      rdi - address
;            rsi - amount of memory
; returns:   rax - 0 for success, - for error
free:
    mov rax, SYS_munmap
    syscall

    ret

%include "asm_io.inc"
segment .data
    prompt1 db "Enter a number: ",0
    prompt2 db "Enter an other number: ",0
    outmsg1 db "You entered ",0
    outmsg2 db " and ",0
    outmsg3 db "The sum is ",0
segment .bss
    number1 resd 1
    number2 resd 1
segment .text
    global asm_main
asm_main:
    enter 0,0
    pusha

    mov eax,prompt1
    call print_string

    call read_int
    mov [number1],eax

    mov eax,prompt2
    call print_string

    call read_int
    mov [number2],eax

    mov eax,outmsg1
    call print_string

    mov eax,[number1]
    call print_int

    mov eax,outmsg2
    call print_string

    mov eax,[number2]
    call print_int
    call print_nl

    mov eax,outmsg3
    call print_string
    mov eax,[number1]
    add eax,[number2]
    call print_int
    call print_nl

    popa
    mov eax,0
    leave
    ret

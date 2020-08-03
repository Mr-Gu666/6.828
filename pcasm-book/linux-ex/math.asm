%include "asm_io.inc"
segment .data
    prompt db "Enter a number: ",0
    prompt2 db "Enter another number: ",0
    outmsg db "The larger one is: ",0
segment .bss
    input1 resd 1
segment .text
    global asm_main
asm_main:
    enter 0,0
    pusha

    mov eax,prompt
    call print_string
    call read_int
    mov [input1],eax
    mov eax,prompt2
    call print_string
    call read_int

    xor ebx,ebx
    cmp eax,[input1]
    setg bl
    neg ebx
    mov ecx,ebx
    and ecx,eax
    not ebx
    and ebx,[input1]
    or ecx,ebx

    mov eax,outmsg
    call print_string
    mov eax,ecx
    call print_int
    call print_nl

    popa
    mov eax,0
    leave
    ret

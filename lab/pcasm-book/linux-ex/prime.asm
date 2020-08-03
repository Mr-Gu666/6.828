%include "asm_io.inc"
segment .data
    prompt db "Find prime number up to: ",0
segment .bss
    prime resd 1
    now resd 1
segment .text
    global asm_main
asm_main:
    enter 0,0
    pusha

    mov eax,prompt
    call print_string
    call read_int
    mov [prime],eax

    mov dword [now],1

loop_start:
    mov eax,[now]
    inc eax
    mov [now],eax
    mov ecx,[prime]
    cmp ecx,eax
    jz end
    mov ebx,2
    jmp judge

judge:
    mov eax,[now]
    cmp eax,ebx
    jz cout
    ;mov eax,[now]
    cdq
    idiv ebx
    cmp edx,0
    jz loop_start
    inc ebx
    jmp judge

cout:
    ;mov eax,[now]
    call print_int
    call print_nl
    jmp loop_start

end:
    mov eax,0
    popa
    leave
    ret

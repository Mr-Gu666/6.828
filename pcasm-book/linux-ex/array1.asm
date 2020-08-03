%define ARRAY_SIZE 100
%define NEW_LINE 10

segment .data
    first_msg db "First 10 elements of array: ",0
    prompt db "Enter an index of array to display element: ",0
    second_msg db "Element%d is %d",NEW_LINE,0
    third_msg db "Elements 20 to 29 of array is: ",0
    input_format db "%d",0

segment .bss
    array resd ARRAY_SIZE

segment .text
    extern puts,printf,scanf,dump_line
    global asm_main

asm_main:
    ;都不明白啥意思
    ;enter 4,0 预留一个双字的位置
    ;push ebp
    ;mov ebp,esp
    ;sub esp,4 sub是减法
    enter 4,0
    ;ebx要求不变
    push ebx
    push esi

    ;初始化数组为100，99，98...
    mov ecx,ARRAY_SIZE
    mov ebx,array
init_loop:
    mov [ebx],ecx
    add ebx,4
    loop init_loop
    
    push dword first_msg
    call puts
    pop ecx

    push dword 10
    push dword array
    call print_array
    add esp,8

prompt_loop:
    push dword prompt
    call printf
    pop ecx

    lea eax,[ebp-4]
    push eax
    push dword input_format
    call scanf
    ;已有eax作为返回值
    add esp,8
    cmp eax,1
    je input_ok

    call dump_line
    jmp prompt_loop

input_ok:
    mov esi,[ebp-4]
    push dword [array+4*esi]
    push esi
    push dword second_msg
    call printf
    add esp,12

    push dword third_msg
    call puts
    pop ecx

    push dword 10
    push dword array+20*4
    call print_array
    add esp,8

    pop esi
    pop ebx
    mov eax,0
    leave
    ret

segment .data
    output_format db "%-5d %5d",NEW_LINE,0

segment .text
    global print_array
print_array:
    enter 0,0
    push ebx
    push esi

    ;esi = 0
    xor esi,esi
    ;ecx = n
    mov ecx,[ebp+12]
    ;ebx = address
    mov ebx,[ebp+8]
print_loop:
    ;因为printf会改变ecx
    push ecx
    
    push dword [ebx+esi*4]
    push esi
    push dword output_format
    call printf
    ;留了ecx
    add esp,12
    
    inc esi
    pop ecx
    loop print_loop

    pop esi
    pop ebx
    leave
    ret

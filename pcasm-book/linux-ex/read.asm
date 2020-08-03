segment .data
    format db "%lf",0

segment .text
    global read_doubles
    extern fscanf

%define SIZEOF_DOUBLE 8
%define FP dword [ebp+8]
%define ARRAYP dword [ebp+12]
%define ARRAY_SIZE dword [ebp+16]
%define TEMP_DOUBLE [ebp-8]

read_doubles:
    enter SIZEOF_DOUBLE,0

    push esi
    mov esi,ARRAYP
    xor edx,edx

while_loop:
    cmp edx,ARRAY_SIZE
    jnl quit

    push edx
    lea eax,TEMP_DOUBLE
    ;&temp_double 入栈
    push eax
    push dword format
    push FP
    call fscanf

    add esp,12
    pop edx
    cmp eax,1
    jne quit

    mov eax,[ebp-8]
    ;先复制低4字节
    mov [esi+8*edx],eax
    ;再复制高4字节
    mov eax,[ebp-4]
    mov [esi+8*edx+4],eax

    inc edx
    jmp while_loop

quit:
    pop esi
    mov eax,edx
    leave
    ret

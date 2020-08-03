global asm_copy, asm_find, asm_strlen, asm_strcpy

segment .text

;asm_copy 复制内存块，有三个参数，目的指针，源指针，需要复制的字节数
%define dest [ebp+8]
%define src [ebp+12]
%define sz [ebp+16]

asm_copy:
    enter 0,0
    push esi
    push edi

    mov esi,src
    mov edi,dest
    mov ecx,sz

    cld
    rep movsb

    pop edi
    pop esi
    leave
    ret

;根据给定字节值查找内存 源指针，查找的字节值，在缓冲区的总字节数
%define src [ebp+8]
%define target [ebp+12]
%define sz [ebp+16]
asm_find:
   enter 0,0
   push edi

   mov eax,target
   mov edi,src
   mov ecx,sz

   cld
   repne scasb

   je found_it
   mov eax,0
   jmp quit
found_it:
    mov eax,edi
    ;奇怪的要求，找到后，一定要减一个数值才会是正确的地址
    dec eax
quit:
    pop edi
    leave
    ret

%define src [ebp+8]
;返回字符串大小 字符串指针
asm_strlen:
    enter 0,0
    push edi

    mov edi,src
    ;ecx max
    mov ecx,0FFFFFFFFh
    ;al=0
    xor al,al
    cld
    ;compare with al
    repnz scasb

    ;repnz 会多行一步，所以ecx=FFFFFFFE
    mov eax,0FFFFFFFEh
    sub eax,ecx
    
    pop edi
    leave 
    ret

%define dest [ebp+8]
%define src [ebp+12]
;复制字符串 目的指针，源指针
asm_strcpy:
    enter 0,0
    push esi
    push edi

    mov esi,src
    mov edi,dest
    cld
cpy_loop:
    lodsb
    stosb
    or al,al
    jnz cpy_loop

    pop edi
    pop esi
    leave
    ret

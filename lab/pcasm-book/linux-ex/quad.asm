%define a qword [ebp+8]
%define b qword [ebp+16]
%define c qword [ebp+24]
;指针的大小与什么类型的指针无关
%define root1 dword [ebp+32]
%define root2 dword [ebp+36]
%define disc qword [ebp-8]
%define one_over_2a qword [ebp-16]

segment .data
    min_four dw -4

segment .text
    global quadratic

quadratic:
    enter 16,0
    push ebx

    ;st0 = -4f
    fild word [min_four]
    ;stack: a -4
    fld a
    ;stack: c a -4
    fld c
    ;stack: ac -4
    fmulp st1
    ;stack: -4ac
    fmulp st1
    ;stack: b -4ac
    fld b
    ;b b -4ac
    fld b
    ;b^2 -4ac
    fmulp st1
    ;b^2-4ac
    faddp st1
    ;st0 compare with 0
    ftst
    ;将协处理器状态转到ax中
    fstsw ax
    ;ah->flags
    sahf
    ;<0 无解
    jb no_real_solutions
    fsqrt
    fstp disc
    fld1
    ;a 1
    fld a
    ;st0 = st0*(2^st1) 2a 1
    fscale
    ;1/2a
    fdivp st1
    fst one_over_2a
    ;b 1/2a
    fld b
    ;dis b 1/2a
    fld disc
    ;dest = st0-dest & pop
    ;disc-b 1/2a
    fsubrp st1
    ;(-b+disx)/2a
    fmulp st1
    mov ebx,root1
    ;ebx = root1 = disc-b
    fstp qword [ebx]
    ;b
    fld b
    ;disc b
    fld disc
    ;-disc b
    fchs
    ;-disc-b
    fsubrp st1
    ;(-disc-b)/2a
    fmul one_over_2a
    mov ebx,root2
    fstp qword [ebx]
    mov eax,1
    jmp quit

no_real_solutions:
    mov eax,0

quit:
    pop ebx
    leave
    ret

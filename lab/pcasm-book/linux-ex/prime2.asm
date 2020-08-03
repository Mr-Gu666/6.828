segment .text
    global find_primes

;以下全部存储的是地址
%define array ebp+8
%define n_find ebp+12
;目前为止找到的素数个数
%define n ebp-4
;猜想的下一个素数开平方后得到的整数
%define isqrt ebp-8
;原始控制字 word=2byte
%define orig_cntl_wd ebp-10
%define new_cntl_wd ebp-12

find_primes:
    enter 12,0
    push ebx
    push esi
    
    ;get current control word
    fstcw word [orig_cntl_wd]
    mov ax,[orig_cntl_wd]
    ;设定RC=11 舍入方式是截取
    or ax,0C00h
    ;get new control word
    mov [new_cntl_wd],ax
    ;设置控制字
    fldcw word [new_cntl_wd]

    mov esi,[array]
    mov dword [esi],2
    mov dword [esi+4],3
    ;evx=guess=5
    mov ebx,5
    ;finded
    mov dword [n],2

while_limit:
    mov eax,[n]
    cmp eax,[n_find]
    jnb short quit_limit

    ;数组下标
    ;why not 2?
    mov ecx,1
    ;guess pushed
    push ebx
    ;esp = guess
    ;st0 = guess
    fild dword [esp]
    pop ebx
    fsqrt
    ;isqrt = floor(sqrt(guess))
    fistp dword [isqrt]

while_factor:
    mov eax,dword [esi+4*ecx]
    cmp eax,[isqrt]
    ;while eax>isqrt
    jnbe short quit_factor_prime
    mov eax,ebx
    ;init edx
    xor edx,edx
    div dword [esi+4*ecx]
    or edx,edx
    jz short quit_factor_not_prime
    inc ecx
    jmp short while_factor

quit_factor_prime:
    mov eax,[n]
    ;guess added
    mov dword [esi+4*eax],ebx
    inc eax
    mov [n],eax

quit_factor_not_prime:
    add ebx,2
    jmp short while_limit

quit_limit:
    fldcw word [orig_cntl_wd]
    pop esi
    pop ebx
    leave
    ret

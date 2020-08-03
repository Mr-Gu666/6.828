segment .text
    global calc_sum
calc_sum:
    ;push ebp
    ;mov ebp,esp
    ;sub esp,4
    enter 4,0
    ;要求ebx不变
    push ebx
    ;sum = 0
    mov dword [ebp-4],0
    ;ecx = i = 1
    mov ecx,1
for_loop:
    ;cmp i n
    cmp ecx,[ebp+8]
    jnle end_for
    add [ebp-4],ecx
    inc ecx
    jmp for_loop
end_for:
    ;ebx = sump
    mov ebx,[ebp+12]
    ;eax = sum
    mov eax,[ebp-4]
    mov [ebx],eax
    pop ebx
    leave
    ret

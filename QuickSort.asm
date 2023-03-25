%include "asm_io.inc"

section .data
array: dd 0., 4., 5., 2., 1., 7., -2.1, 8.4, 25., 12., 15., -3., 28.55, 82., 73.5, 4.2, -40., 26., 100., 266., -110.
main: dd "ARRAY >> ", 0
sorted: dd "SORTED >> ", 0

section .bss
i: resd 1       ; int i;
j: resd 1       ; int j;
left: resd 1    ; int left
right: resd 1   ; int right
pivot: resd 1   ; float pivot

section .text
    extern print_array, print_float_array
    global asm_main
asm_main:
    enter 0, 0
    pusha

        ; System.out.println("ARRAY >> ")
    mov eax, main
    call print_string
        ; print array             
    push 21
    push array
    call print_float_array        
    call print_nl
    call print_nl

        ; calling quick_sort function
    push 0
    push 20
    call quick_sort               

        ; System.out.println("SORTED >> ")
    mov eax, sorted
    call print_string
        ; print array(after sorting)             
    push 21
    push array
    call print_float_array        
    call print_nl

    popa
    leave
    ret
        ; starting function
quick_sort:                       
    mov eax, [esp+8]
    mov [left], eax
    mov eax, [esp+4]
    mov [right], eax
    cmp eax, [left]
    jle end_func
    mov eax, [left]
    mov [i], eax
    mov eax, [right]
    inc eax
    mov [j], eax
    mov eax, [i]
    imul eax, 4
    mov eax, [array+eax]
    mov [pivot], eax

        ; starting a loop
while_1:
    add dword [i], 1
    mov eax, [i]
    cmp eax, [right]
    jg break_1
    mov eax, [i]
    fld dword [pivot]
    fld dword [array+4*eax]
        ;while (arr[i] < pivot)
    fcomip	st0, st1
    fstp	st0
    jb while_1

        ; starting another loop
    while_2:
    sub dword [j], 1
    mov eax, [j]
    cmp eax, [left]
    jl break_2
    mov eax, [j]
    fld dword [pivot]
    fld dword [array+4*eax]
        ; while (arr[j] > pivot)
    fcomip	st0, st1
    fstp	st0
    ja while_2
    jmp break_3

break_1:
        ; i--
    dec dword [i]
    jmp while_2
        
break_2:
        ; j++
    inc dword [j]

break_3:

    mov eax, [i]
    cmp eax, [j]
    jge jump
    
        ; calling swap function
    push dword [i]
    push dword [j]
    call swap
jump:
        ; while (i < j)
    mov eax, [i]
    cmp eax, [j]
    jl while_1

        ; calling swap function
    push dword [left]
    push dword [j]
    call swap

        ; calling recursion function
        ; push inputs of function
        ; and pop after calling
    push dword [j]
    push dword [left]
    push dword [right]
    push dword [left]
    sub dword [j], 1
    push  dword [j]
    call quick_sort
    pop dword [right]
    pop dword [left]
    pop dword [j]

        ; calling recursion function
        ; push inputs of function
        ; and pop after calling
    push dword [j]
    push dword [right]
    push dword [left]
    add dword [j], 1
    push dword [j]
    push dword [right]
    call quick_sort
    pop dword [left]
    pop dword [right]
    pop dword [j]


end_func:
    ret 8

    ; swap function
    ; changing a[i], a[j]
swap:
    mov ebx, [esp+4]
    mov edx, [esp+8]
    imul ebx, 4
    imul edx, 4
    mov eax, [array+ebx]
    mov ecx, [array+edx]
    mov [array+ebx], ecx
    mov [array+edx], eax
    ret 8
[ORG 0x1000]
[BITS 16]

kernel_start:
    mov  si, kernel_msg
    call print

    hlt
    jmp  $

print:
    mov  ah, 0x0e

.print_loop:
    lodsb
    or   al, al
    jz   .done_print
    int  0x10

    jmp  .print_loop

.done_print:
    ret

kernel_msg  db "Welcome to ardonium/OS v0.01", 0x0d, 10, 0


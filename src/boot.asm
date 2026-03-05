%define KERNELADDR         0x1000
%define READSECTOR         0x02

[ORG  0x7C00]
[BITS 16]

main:
    xor  ax, ax                                     ; mov  ax, 0  ->  reset segments
    mov  ds, ax
    mov  es, ax
    mov  ss, ax

    mov  sp, 0x7c00                                 ; create stack

    mov  si, boot_msg                               ; print boot message
    call print

    mov  bx, KERNELADDR
    mov  ah, READSECTOR
    mov  al, 1                                      ; read 1 sector (512 bytes)
    mov  ch, 0                                      ; cylinder -> 0
    mov  dh, 0                                      ; head -> 0
    mov  cl, 2                                      ; sector -> 2 (#1 bootloader, #2 kernel)
;   mov  dl, ...                                    * driver number -- automatically set by BIOS *

    int  0x13                                       ; read the disk
    jc   disk_error                                 ; jump to disk_error if CF=1
    jmp  KERNELADDR

disk_error:
    mov  si, err_msg
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

boot_msg:                   db "Loading ardonium/OS...", 0x0d, 10, 0
err_msg:                    db "Disk read failed!", 0x0d, 10, 0

times 510 - ($ - $$)        db 0                    ; boot signature
dw 0x0aa55


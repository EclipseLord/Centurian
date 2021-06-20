global kernel_long_jump
extern k_main

section .text
bits 64
kernel_long_jump:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call k_main
    hlt
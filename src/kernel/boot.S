global _start

extern kernel_long_jump

section .text
bits 32
_start:
    mov esp, stack_top

    call init_page_tables
    call enable_page_tables

    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:kernel_long_jump

    cli

    hlt

init_page_tables:
    mov eax, page_2
    or eax, 0b11
    mov [page_3], eax

    mov eax, page_1
    or eax, 0b11
    mov [page_2], eax
    
    mov ecx, 0

.loop:
    mov eax, 0x200000
    mul ecx
    or eax, 0b10000011
    mov [page_2 + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .loop

    ret

enable_page_tables:
    mov eax, page_3
    mov cr3, eax

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

section .bss
    page_3:
        resb 4096
    page_2:
        resb 4096
    page_1:
        resb 4096

    stack_bottom:
        resb 4096 * 4
    stack_top:


section .rodata
    gdt64:
        dq 0
    .code_segment: equ $ - gdt64
        dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
    .pointer:
        dw $ - gdt64
        dq gdt64
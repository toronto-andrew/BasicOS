; 一个简单的引导扇区程序，打印 "Hello, world!" 然后停机

[BITS 16]           ; 设置 CPU 工作在 16 位模式（BIOS 使用实模式）
[ORG 0x7C00]        ; BIOS 会将引导扇区加载到内存地址 0x7C00

start:
    mov si, msg      ; 将字符串地址加载到 SI 寄存器
    call print_string

hang:
    hlt              ; 停机，等待中断
    jmp hang         ; 无限循环

print_string:
    mov ah, 0x0E     ; BIOS 功能号，用于在屏幕上显示字符
.next_char:
    lodsb            ; 加载字符串中的下一个字符到 AL 寄存器
    cmp al, 0        ; 判断是否是字符串结束符
    je .done
    int 0x10         ; 调用 BIOS 中断，打印字符
    jmp .next_char
.done:
    ret

msg db "Hello, world!", 0

times 510 - ($ - $$) db 0 ; 填充到 510 字节
dw 0xAA55                 ; 设置引导扇区标志



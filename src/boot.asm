[BITS 16]           ; 16位实模式
[ORG 0x7C00]        ; BIOS加载引导所在的内存地址是0x7C00

start:
    mov si, msg      ; 将字符串地址加载到 SI 寄存器
    call print_string ; 调用打印字符串的子程序

    call check_memory ; 调用内存检查子程序

hang:
    hlt              ; 停机，等待中断
    jmp hang         ; 死循环，保持程序运行状态

; 打印字符串的子程序
; SI: 指向要打印的字符串
print_string:
    mov ah, 0x0E     ; BIOS 功能号：在屏幕上显示字符
.next_char:
    lodsb            ; 从内存中取出当前字符（由 SI 指向）并加载到 AL 寄存器
    cmp al, 0        ; 判断当前字符是否为字符串结束符
    je .done         ; 如果 AL=0（字符串结束符），跳转到完成
    int 0x10         ; 调用 BIOS 中断打印字符
    jmp .next_char   ; 打印下一个字符
.done:
    ret              ; 返回主程序

; 内存检查子程序
check_memory:
    mov ah, 0x0E     ; BIOS 功能号：在屏幕上显示字符
    mov si, mem_msg  ; 加载内存信息提示字符串
    call print_string ; 打印提示字符串

    int 0x12         ; 调用 BIOS 中断，获取低 640KB 内存大小
    mov bx, ax       ; 将内存大小保存到 BX 寄存器中（单位是 KB）

    ; 将 BX 的值转换为 ASCII 并显示
    call print_number ; 打印数值

    ret

; 打印数值子程序
print_number:
    xor cx, cx       ; 清空 CX 寄存器，用于计数
.next_digit:
    xor dx, dx       ; 清空 DX，防止之前的值干扰
    div word [div_10] ; AX = AX / 10，余数在 DX 中，商在 AX 中
    push dx          ; 将余数压栈
    inc cx           ; 计数加 1
    test ax, ax      ; 判断 AX 是否为 0
    jnz .next_digit  ; 如果不是 0，则继续

.print_loop:
    pop dx           ; 弹出余数
    add dl, '0'      ; 转换为 ASCII
    mov al, dl       ; 加载字符到 AL
    int 0x10         ; 调用 BIOS 中断打印字符
    loop .print_loop ; 循环打印

    ret

msg db "Hello, Bootloader!", 0            ; 引导提示信息
mem_msg db "Available memory: ", 0        ; 内存提示信息
div_10 dw 10                              ; 除数，用于数值转换

times 510 - ($ - $$) db 0 ; 填充至510字节
dw 0xAA55                 ; 引导所在标志
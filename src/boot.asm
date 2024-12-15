[BITS 16]           ; 16位实模式
[ORG 0x7C00]        ; BIOS加载引导所在的内存地址是0x7C00

start:
    mov si, welcome_msg ; 加载欢迎信息
    call print_string   ; 打印字符串

    call display_menu   ; 显示菜单

wait_input:
    call get_input      ; 获取用户输入
    call handle_command ; 处理命令
    jmp wait_input      ; 等待下一次输入

hang:
    hlt                ; 停机，等待中断
    jmp hang           ; 死循环，保持程序运行状态

; 打印字符串的子程序
; SI: 指向要打印的字符串
print_string:
    mov ah, 0x0E       ; BIOS 功能号：在屏幕上显示字符
.next_char:
    lodsb              ; 从内存中取出当前字符（由 SI 指向）并加载到 AL 寄存器
    cmp al, 0          ; 判断当前字符是否为字符串结束符
    je .done           ; 如果 AL=0（字符串结束符），跳转到完成
    int 0x10           ; 调用 BIOS 中断打印字符
    jmp .next_char     ; 打印下一个字符
.done:
    ret                ; 返回主程序

; 显示菜单
; 在屏幕上显示可用选项
display_menu:
    mov si, menu_msg   ; 显示选项提示信息
    call print_string

    mov si, option1_msg ; 显示选项1
    call print_string

    mov si, option2_msg ; 显示选项2
    call print_string

    mov si, option3_msg ; 显示选项3
    call print_string
    ret

; 获取用户输入字符
get_input:
    mov ah, 0x00      ; BIOS 功能：获取按键
    int 0x16          ; 调用 BIOS 按键输入
    mov ah, 0x0E      ; 打印用户输入的字符
    int 0x10
    ret

; 处理命令
handle_command:
    cmp al, '1'       ; 检查是否选择1
    je load_program_a
    cmp al, '2'       ; 检查是否选择2
    je load_program_b
    cmp al, '3'       ; 检查是否选择3
    je exit_program
    ret               ; 如果是其他值，返回菜单

; 加载程序 A
load_program_a:
    mov si, program_a_msg ; 显示作者信息
    call print_string
    ret

; 加载程序 B
load_program_b:
    mov si, program_b_msg ; 显示时间信息
    call print_string
    call display_time     ; 显示当前时间
    ret

; 显示时间子程序
display_time:
    ; 获取 RTC 时间
    mov ah, 0x02      ; BIOS INT 0x1A 功能号：读 RTC 当前时间
    int 0x1A          ; 调用 BIOS RTC 功能

    ; 显示时间：将 CH (时)，CL (分)，DH (秒) 转换为 ASCII 并打印
    mov si, time_msg
    call print_string

    mov al, ch        ; 获取当前时
    call print_number ; 打印小时
    mov si, colon_msg
    call print_string ; 打印冒号

    mov al, cl        ; 获取当前分
    call print_number ; 打印分钟
    mov si, colon_msg
    call print_string ; 打印冒号

    mov al, dh        ; 获取当前秒
    call print_number ; 打印秒
    ret

; 打印数值的子程序
print_number:
    ; 将数值转换为 ASCII
    aam               ; 分解数值，AH = 十位，AL = 个位
    add ah, '0'       ; 转换十位为 ASCII
    int 0x10          ; 打印十位
    add al, '0'       ; 转换个位为 ASCII
    int 0x10          ; 打印个位
    ret

; Exit program
exit_program:
    mov si, exit_msg      ; Display exit message
    call print_string
    jmp hang              ; Jump to hang (halt the system)

menu_msg db "Select an option:\n", 0
option1_msg db "1. Load Program A\n", 0
option2_msg db "2. Load Program B\n", 0
option3_msg db "3. Exit\n", 0
welcome_msg db "Welcome to the bootloader!\n", 0
program_a_msg db "Author: John Doe\n", 0
program_b_msg db "Current Date and Time:\n", 0
time_msg db "Time: ", 0
colon_msg db ":", 0
exit_msg db "Exiting program...\n", 0

times 510 - ($ - $$) db 0 ; 填充至510字节
dw 0xAA55                 ; 引导扇区标志
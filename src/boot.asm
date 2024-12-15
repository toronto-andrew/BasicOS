[BITS 16]           ; 16位实模式
[ORG 0x7C00]        ; BIOS加载引导所在的内存地址是0x7C00

; Define your messages
welcome_msg db 'Welcome to the OS!', 0x0D, 0x0A, 0
menu_msg db 'Please select an option:', 0x0D, 0x0A, 0
option1_msg db '1. Option 1', 0x0D, 0x0A, 0
option2_msg db '2. Option 2', 0x0D, 0x0A, 0
option3_msg db '3. Option 3', 0x0D, 0x0A, 0

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
    int 0x10           ; 调用 BIOS 中断显示字符
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
    je list_files
    cmp al, '2'       ; 检查是否选择2
    je read_file
    cmp al, '3'       ; 检查是否选择3
    je exit_program
    ret               ; 如果是其他值，返回菜单

; 列出文件
dir_entry_size equ 32   ; 每个目录条目大小
read_sector:
    mov ah, 0x02      ; BIOS 功能号：读扇区
    mov al, 1         ; 读取一个扇区
    int 0x13          ; 调用 BIOS 中断读扇区
    ret

; 显示文件系统所有内容
list_files:
    ; 文件
dump_dir_start:         ;读取位置
    root_dir_sector      ;文件起始点下次逻辑会读取

; Define your functions
read_file:
    ; Add your file reading code here
    ret

exit_program:
    ; Add your exit code here
    ret

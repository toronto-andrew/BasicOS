[BITS 16]
[ORG 0x7C00]

    ; Initial boot entry
    jmp short start
    nop

; BIOS Parameter Block (BPB)
OEMLabel        db "MYOS    "   ; 8 bytes
BytesPerSector  dw 512
SectorsPerCluster db 1
ReservedSectors dw 1
NumberOfFATs    db 2
RootDirEntries  dw 224
TotalSectors    dw 2880         ; 1.44 MB
MediaDescriptor db 0xF0         ; 3.5" floppy
SectorsPerFAT   dw 9
SectorsPerTrack dw 18
NumberOfHeads   dw 2
HiddenSectors   dd 0
LargeSectors    dd 0
DriveNumber     db 0            ; 0 = floppy
Reserved        db 0
ExtendedBootSig db 0x29
SerialNumber    dd 0xDEADBEEF
VolumeLabel     db "MYOS BOOT  " ; 11 bytes
FileSystem      db "FAT12   "    ; 8 bytes

start:
    ; Set up segments
    cli                     ; Disable interrupts
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti                     ; Enable interrupts

    ; Save boot drive
    mov [bootDrive], dl

    ; Reset disk system
    mov ah, 0
    mov dl, [bootDrive]
    int 0x13
    jc disk_error

    ; Print welcome message
    mov si, welcome_msg
    call print_string

main_loop:
    call display_menu
    call get_input
    call handle_command
    jmp main_loop

; Display menu function
display_menu:
    mov si, menu_msg
    call print_string
    ret

; Get input function
get_input:
    mov ah, 0
    int 0x16        ; BIOS keyboard input
    ret

; Handle command function
handle_command:
    cmp al, '1'
    je .cmd_list_files
    cmp al, '2'
    je .cmd_read_file
    cmp al, '3'
    je .cmd_exit
    ret

.cmd_list_files:
    call list_files
    ret

.cmd_read_file:
    mov si, msg_not_implemented
    call print_string
    ret

.cmd_exit:
    mov si, exit_msg
    call print_string
    jmp $           ; Infinite loop

; List files function (simplified)
list_files:
    pusha
    mov si, dir_msg
    call print_string
    
    ; Read root directory (simplified)
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [bootDrive]
    mov bx, buffer
    int 0x13
    jc disk_error
    
    ; Display first entry (simplified)
    mov cx, 11
    mov si, buffer
.print_loop:
    lodsb
    mov ah, 0x0E
    int 0x10
    loop .print_loop
    
    mov si, newline
    call print_string
    popa
    ret

; Print string function
print_string:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

; Error handler
disk_error:
    mov si, msg_disk_error
    call print_string
    jmp $

; Data
bootDrive        db 0
welcome_msg      db 'Welcome to MYOS!', 13, 10, 0
menu_msg         db '1.List 2.Read 3.Exit', 13, 10, 0
exit_msg         db 'Exiting...', 13, 10, 0
dir_msg          db 'Files:', 13, 10, 0
msg_disk_error   db 'Disk error!', 13, 10, 0
msg_not_implemented db 'Not implemented', 13, 10, 0
newline          db 13, 10, 0

; Buffer (smaller to fit in boot sector)
buffer times 64 db 0

; Boot sector padding
times 510-($-$$) db 0   ; Pad with zeros
dw 0xAA55               ; Boot signature
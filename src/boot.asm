[bits 16]             ; Instruct the assembler that we are working in 16-bit mode

jmp $                 ; '$' represents the current address; jumping to the current address creates an infinite loop

times 510-($-$$) db 0 ; '$' represents the current address, and '$$' represents the start of the current segment
                      ; '510-($-$$)' calculates the distance from the current position to 510 bytes, and fills all those bytes with 0

dw 0xaa55             ; The last two bytes are set to the value 0xaa55


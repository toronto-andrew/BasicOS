#!/bin/bash

# Remove old files
rm -f boot.bin floppy.img

# Assemble boot sector
nasm -f bin src/boot.asm -o boot.bin

# Check if boot.bin is exactly 512 bytes
if [ $(stat -f %z boot.bin 2>/dev/null || stat -c %s boot.bin) -ne 512 ]; then
    echo "Error: boot.bin is not exactly 512 bytes!"
    exit 1
fi

# Create a new floppy image (1.44MB)
dd if=/dev/zero of=floppy.img bs=1474560 count=1

# Format the floppy image with FAT12
mkfs.fat -F 12 -n "MYOS" floppy.img

# Write boot sector to the image
dd if=boot.bin of=floppy.img conv=notrunc bs=512 count=1

# Create a test file (optional)
mkdir -p temp_mount
sudo mount floppy.img temp_mount
echo "Hello from MYOS!" > temp_mount/TEST.TXT
sudo umount temp_mount
rmdir temp_mount

# Run QEMU
qemu-system-i386 -fda floppy.img

#!/bin/bash

# Remove old files
rm -f boot.bin floppy.img
rm -rf temp_mount

# Assemble boot sector
nasm -f bin src/boot.asm -o boot.bin

# Create a new floppy image (1.44MB)
dd if=/dev/zero of=floppy.img bs=1474560 count=1

# Format the floppy image with FAT12
mkfs.fat -F 12 -n "MYOS" floppy.img

# Write boot sector to the image
dd if=boot.bin of=floppy.img conv=notrunc bs=512 count=1

# Create a test file (optional)
mkdir -p temp_mount
sudo mount -o uid=$(id -u),gid=$(id -g) floppy.img temp_mount
echo "Hello from MYOS!" > temp_mount/TEST.TXT
sudo umount temp_mount
rm -rf temp_mount

# Run QEMU
qemu-system-i386 -fda floppy.img

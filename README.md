# BasicOS - A Minimal Operating System

## Overview
This is a basic, educational operating system designed to demonstrate fundamental OS development concepts.

## Prerequisites
- i686-elf cross-compiler
- NASM assembler
- GRUB2
- QEMU (for testing)


## Environment
- Ubuntu 24.04
- qemu
- nasm
- gcc
- make

- sudo apt-get update
- sudo apt-get install nasm qemu gcc gcc-multilib

debug tools
- sudo apt-get install xxd gdb

## Building the OS
```bash
# Compile the OS
make

# Create bootable ISO
make iso

# Run in QEMU
qemu-system-i386 -cdrom basicos.iso
```

## Components
- `boot.asm`: Multiboot-compliant bootloader
- `kernel.c`: Minimal kernel with basic screen output
- `linker.ld`: Linker script to organize kernel memory layout

## Learning Objectives
- Understand x86 boot process
- Learn low-level system programming
- Explore kernel development basics

## Limitations
This is a minimal, non-functional OS meant for educational purposes.

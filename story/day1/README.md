# BasicOS - A Minimal Operating System

## Overview
心血来潮，准备写一个操作系统，记录一下学习过程。主要参考著名的《恐龙书》。从bootloader开始，逐步实现一个最小的操作系统。
既然是操作系统，那么就避免不了汇编语言。之后会使用C语言来实现。最后如果有余力的话，会使用Rust来实现。

## 环境
- Ubuntu 24.04
- qemu
- nasm
- gcc
- make  

## 安装环境
```bash
sudo apt-get update
sudo apt-get install nasm qemu gcc gcc-multilib
```

## 安装环境 
```bash
sudo apt-get install xxd gdb
```
```bash 
sudo apt-get install qemu-system-i386
```

## 编译
```bash
nasm -f bin boot.asm -o boot.bin
```

## 运行
```bash
qemu-system-x86_64 boot.bin
```

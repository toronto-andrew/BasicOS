**FAT12 文件系统支持**

---

### **1. 什么是 FAT12 文件系统？**

FAT12（File Allocation Table 12-bit）是 MS-DOS 使用的早期文件系统：
- **扇区大小**：通常为 512 字节。
- **簇（Cluster）**：最小存储单元，由一个或多个扇区组成。
- **文件分配表（FAT）**：记录文件存储位置的链表，每个簇使用 12 位表示。
- **根目录区（Root Directory）**：固定大小，存储文件和目录的元信息。

---

### **2. 实现 FAT12 支持的模块**

#### (1) **文件系统初始化**
- **功能**：
  - 读取 FAT12 的基本信息（如 BPB 数据）。
  - 确认加载的卷是 FAT12 格式。
- **实现**：
  - 读取主引导记录（MBR 或 BPB）。
  - 提取以下信息：
    - 每扇区字节数
    - 每簇扇区数
    - FAT 表起始位置
    - 根目录条目数
    - 数据区起始位置

#### 示例代码：
```asm
; 读取 BPB（BIOS Parameter Block）
read_bpb:
    mov ah, 0x02      ; BIOS 功能号：读扇区
    mov al, 0x01      ; 读取一个扇区
    mov ch, 0x00      ; 磁道号
    mov cl, 0x01      ; 扇区号（MBR 或 BPB 通常位于第一个扇区）
    mov dh, 0x00      ; 磁头号
    mov dl, 0x00      ; 驱动器号（A盘）
    mov bx, buffer    ; 缓冲区地址
    int 0x13          ; 调用 BIOS 磁盘中断
    jc error          ; 如果出错，跳转到错误处理
    ret

buffer times 512 db 0 ; 512 字节缓冲区
```

---

#### (2) **读取根目录**
- **功能**：
  - 读取 FAT12 根目录区，获取文件和目录的元数据。
- **实现**：
  - 根目录区位置 = 数据区域起始地址 - 根目录大小。
  - 每个目录条目长度为 32 字节，包含以下字段：
    - **文件名（8 字节）**：文件名。
    - **扩展名（3 字节）**：文件扩展名。
    - **文件属性（1 字节）**：如只读、隐藏等。
    - **起始簇号（2 字节）**：文件数据的起始簇。
    - **文件大小（4 字节）**：文件大小。

#### 示例代码：
```asm
; 读取根目录
read_root_dir:
    mov ax, root_dir_sector ; 根目录起始扇区
    mov ch, byte [ax]       ; 磁道号
    mov cl, byte [ax + 1]   ; 扇区号
    mov dh, 0x00            ; 磁头号
    mov dl, 0x00            ; 驱动器号
    mov ah, 0x02            ; BIOS 功能号：读扇区
    mov al, sectors_per_root ; 读取根目录的全部扇区
    mov bx, buffer          ; 缓冲区地址
    int 0x13                ; 调用 BIOS 磁盘中断
    jc error                ; 如果出错，跳转到错误处理
    ret
```

---

#### (3) **读取文件数据**
- **功能**：
  - 根据根目录中的起始簇号，从 FAT 表中找到文件的所有簇并读取。
- **实现**：
  - 从 FAT 表中解析每个簇号。
  - 读取对应簇的数据并加载到内存。

#### 示例代码：
```asm
; 读取文件数据
read_file:
    mov ax, start_cluster   ; 起始簇号
.next_cluster:
    ; 计算 FAT 表中簇号位置
    mov bx, ax
    shl bx, 1               ; 每个簇号占 1.5 字节
    add bx, fat_start       ; 加入 FAT 表起始位置
    mov dx, word [bx]       ; 从 FAT 表中读取簇号

    ; 检查是否结束
    cmp dx, 0xFFF           ; 0xFFF 表示文件结束
    je .done

    ; 计算簇的实际地址
    sub dx, 2               ; 减去偏移值
    mul sectors_per_cluster ; 计算簇的起始扇区
    add dx, data_area_start ; 加上数据区起始位置

    ; 读取簇数据
    mov ax, dx
    mov bx, buffer          ; 缓冲区地址
    call read_sector        ; 调用读扇区函数
    jmp .next_cluster       ; 处理下一个簇
.done:
    ret
```

---

### **3. 文件系统功能的实现**

#### **支持的基本功能**
1. **列出文件和目录**：
   - 遍历根目录并显示文件名和属性。
   - 示例：
     ```
     DIR
     FILE1   TXT
     FILE2   BIN
     ```

2. **打开和读取文件**：
   - 根据文件名查找目录条目。
   - 读取文件数据并显示或加载到内存。

3. **执行文件**：
   - 如果文件是可执行格式（如 `.COM` 文件），直接加载到内存并跳转执行。

---

### **4. 模块间的交互**
1. **引导加载器**：加载并初始化文件系统模块。
2. **文件系统模块**：
   - 通过读取 FAT 表和根目录实现文件操作。
3. **命令行接口（Shell）**：
   - 提供 `DIR`、`TYPE` 等命令，调用文件系统模块完成操作。

---

### **5. 测试与验证**

#### **测试步骤**
1. 准备一个 FAT12 格式的软盘映像：
   ```bash
   mkfs.fat -F 12 -C floppy.img 1440
   ```
2. 将测试文件复制到软盘映像：
   ```bash
   mcopy -i floppy.img file.txt ::file.txt
   ```
3. 在模拟器中加载和测试：
   ```bash
   qemu-system-x86_64 -fda floppy.img
   ```

---

### **总结**
1. **模块实现顺序**：
   - 读取 BPB 信息。
   - 解析根目录。
   - 读取文件数据。
   - 在命令行中实现 `DIR`、`TYPE` 等功能。

2. **开发工具**：
   - 汇编器（NASM）
   - 模拟器（QEMU）。


引入了 FAT12 文件系统支持的基础模块，包括读取根目录和显示文件列表的基本逻辑。以下是已添加的主要功能：

list_files：

实现了列出根目录所有文件的功能。
基于 FAT12 文件系统的标准，解析根目录并显示文件名。
read_sector：

读取磁盘扇区的通用函数，用于加载 BPB、根目录或文件数据。
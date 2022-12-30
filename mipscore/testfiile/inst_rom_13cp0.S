   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   ori $1,$0,0xf    # $1 = 0x0f
   mtc0 $1,$11,0x0  # 将0xf写入cp0中Compare寄存器
   lui $1,0x1000
   ori $1,$1,0x401  # $1 = 0x10000401
   mtc0 $1,$12,0x0  # 将0x10000401写入cp0中Status寄存器
   mfc0 $2,$12,0x0  # 读Status寄存器，保存到$2,$2 = 0x10000401

_loop:
   j _loop
   nop
   
   

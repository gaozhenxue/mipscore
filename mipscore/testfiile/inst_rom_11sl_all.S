   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   ori $1,$0,0x1234    # $1 = 0x00001234
   sw  $1,0x0($0)      # [0x0] = 0x00001234

   ori $1,$0,0x5678    # $1 = 0x00005678
   sc  $1,0x0($0)      # 因为之前没有执行ll指令,所以此处的sc指令不会修改数据存储器
                       # 存储失败,通用寄存器$1变为0,即$1 = 0x0
   lw  $1,0x0($0)      # 从数据存储器0x0处加载字,用来验证上一条sc指令确实没有修改
                       # 数据存储器,加载后使得寄存器 $1 = 0x00001234
   nop

   ori $1,$0,0x0       # $1 = 0x0
   ll  $1,0x0($0)      # 从数据存储器0x0处加载字,保存到寄存器$1,
                       # 执行完毕后,使得寄存器 $1 = 0x00001234
   nop
   addi $1,$1,0x1      # 读出数据加1,$1 = 0x00001235
   sc  $1,0x0($0)      # 将修改后的数据再保存回数据存储器,保存成功会设置寄存器$1,
                       # 使得 $1 = 0x1
   lw  $1,0x0($0)      # 从数据存储器0x0处加载字,以验证是否是sc指令存储的数据,
                       # 执行完毕后,使得寄存器 $1 = 0x00001235               
    
_loop:
   j _loop
   nop

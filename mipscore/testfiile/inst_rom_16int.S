   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start
_start:
   ori $1,$0,0x100     # $1 = 0x100
   jr $1
   nop

   .org 0x20
   addi $2,$2,0x1
   mfc0 $1,$11,0x0
   addi $1,$1,10
   mtc0 $1,$11,0x0
   eret
   nop

   .org 0x100
   ori $2,$0,0x0
   ori $1,$0,100
   mtc0 $1,$11,0x0  
   lui $1,0x1000
   ori $1,$1,0x401
   mtc0 $1,$12,0x0
   lui $3,0x1000
   ori $4,$0,0x2

_loop:
   sw   $3,0x8($0)
   div $zero,$3,$4
   lw   $5,0x8($0)
   mflo $3
   j _loop
   nop

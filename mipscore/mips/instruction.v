`include "defines.v"
//logic
function instr_ori(input [31:0] i);  instr_ori = (i[31:26]==`EXE_ORI); endfunction
function instr_andi(input [31:0] i);  instr_andi = (i[31:26]==`EXE_ANDI); endfunction
function instr_xori(input [31:0] i);  instr_xori = (i[31:26]==`EXE_XORI); endfunction
function instr_lui(input [31:0] i);  instr_lui = (i[31:26]==`EXE_LUI); endfunction
function instr_and(input [31:0] i);  instr_and = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_AND)); endfunction
function instr_or(input [31:0] i);  instr_or = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_OR)); endfunction
function instr_xor(input [31:0] i);  instr_xor = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_XOR)); endfunction
function instr_nor(input [31:0] i);  instr_nor = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_NOR)); endfunction
//shift
function instr_sll(input [31:0] i);  instr_sll = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SLL)); endfunction
function instr_srl(input [31:0] i);  instr_srl = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SRL)); endfunction
function instr_sra(input [31:0] i);  instr_sra = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SRA)); endfunction
function instr_sllv(input [31:0] i);  instr_sllv = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SLLV)); endfunction
function instr_srlv(input [31:0] i);  instr_srlv = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SRLV)); endfunction
function instr_srav(input [31:0] i);  instr_srav = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SRAV)); endfunction
//nop
function instr_pref(input [31:0] i);  instr_pref = (i[31:26]==`EXE_PREF); endfunction
function instr_sync(input [31:0] i);  instr_sync = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SYNC)); endfunction
function instr_nop(input [31:0] i);  instr_nop = (i==`InstBusWidth'h00000000); endfunction
//move
function instr_movn(input [31:0] i);  instr_movn = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_MOVN)); endfunction
function instr_movz(input [31:0] i);  instr_movz = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_MOVZ)); endfunction
function instr_mfhi(input [31:0] i);  instr_mfhi = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_MFHI)); endfunction
function instr_mflo(input [31:0] i);  instr_mflo = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_MFLO)); endfunction
function instr_mthi(input [31:0] i);  instr_mthi = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_MTHI)); endfunction
function instr_mtlo(input [31:0] i);  instr_mtlo = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_MTLO)); endfunction
//arithmetic
//simple
function instr_add(input [31:0] i);   instr_add = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_ADD)); endfunction
function instr_addu(input [31:0] i);  instr_addu = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_ADDU)); endfunction
function instr_sub(input [31:0] i);   instr_sub = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SUB)); endfunction
function instr_subu(input [31:0] i);  instr_subu = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SUBU)); endfunction
function instr_slt(input [31:0] i);   instr_slt = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SLT)); endfunction
function instr_sltu(input [31:0] i);  instr_sltu = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SLTU)); endfunction
function instr_addi(input [31:0] i);  instr_addi = (i[31:26]==`EXE_ADDI); endfunction
function instr_addiu(input [31:0] i);  instr_addiu = (i[31:26]==`EXE_ADDIU); endfunction
function instr_slti(input [31:0] i);  instr_slti = (i[31:26]==`EXE_SLTI); endfunction
function instr_sltiu(input [31:0] i);  instr_sltiu = (i[31:26]==`EXE_SLTIU); endfunction
function instr_clz(input [31:0] i);   instr_clz = ((i[31:26]==`EXE_SPECIAL2)&(i[5:0]==`EXE_SPECIAL2_CLZ)); endfunction
function instr_clo(input [31:0] i);   instr_clo = ((i[31:26]==`EXE_SPECIAL2)&(i[5:0]==`EXE_SPECIAL2_CLO)); endfunction
function instr_mul(input [31:0] i);   instr_mul = ((i[31:26]==`EXE_SPECIAL2)&(i[5:0]==`EXE_SPECIAL2_MUL)); endfunction
function instr_mult(input [31:0] i);   instr_mult = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_MULT)); endfunction
function instr_multu(input [31:0] i);  instr_multu = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_MULTU)); endfunction
//mul+add
function instr_madd(input [31:0] i);   instr_madd = ((i[31:26]==`EXE_SPECIAL2)&(i[5:0]==`EXE_SPECIAL2_MADD)); endfunction
function instr_maddu(input [31:0] i);   instr_maddu = ((i[31:26]==`EXE_SPECIAL2)&(i[5:0]==`EXE_SPECIAL2_MADDU)); endfunction
function instr_msub(input [31:0] i);   instr_msub = ((i[31:26]==`EXE_SPECIAL2)&(i[5:0]==`EXE_SPECIAL2_MSUB)); endfunction
function instr_msubu(input [31:0] i);   instr_msubu = ((i[31:26]==`EXE_SPECIAL2)&(i[5:0]==`EXE_SPECIAL2_MSUBU)); endfunction
//div
function instr_div(input [31:0] i);   instr_div = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_DIV)); endfunction
function instr_divu(input [31:0] i);  instr_divu = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_DIVU)); endfunction
///jump
//jump
function instr_jr(input [31:0] i);      instr_jr = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_JR)); endfunction
function instr_jalr(input [31:0] i);    instr_jalr = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_JALR)); endfunction
function instr_j(input [31:0] i);       instr_j = (i[31:26]==`EXE_J); endfunction
function instr_jal(input [31:0] i);     instr_jal = (i[31:26]==`EXE_JAL); endfunction
//branch
function instr_beq(input [31:0] i);       instr_beq = (i[31:26]==`EXE_BEQ); endfunction
function instr_bgtz(input [31:0] i);     instr_bgtz = (i[31:26]==`EXE_BGTZ); endfunction
function instr_blez(input [31:0] i);       instr_blez = (i[31:26]==`EXE_BLEZ); endfunction
function instr_bne(input [31:0] i);     instr_bne = (i[31:26]==`EXE_BNE); endfunction
function instr_bltz(input [31:0] i);      instr_bltz = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_BLTZ)); endfunction
function instr_bltzal(input [31:0] i);    instr_bltzal = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_BLTZAL)); endfunction
function instr_bgez(input [31:0] i);      instr_bgez = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_BGEZ)); endfunction
function instr_bgezal(input [31:0] i);    instr_bgezal = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_BGEZAL)); endfunction
///load&store
//load
function instr_lb(input [31:0] i);       instr_lb = (i[31:26]==`EXE_LB); endfunction
function instr_lbu(input [31:0] i);      instr_lbu = (i[31:26]==`EXE_LBU); endfunction
function instr_lh(input [31:0] i);       instr_lh = (i[31:26]==`EXE_LH); endfunction
function instr_lhu(input [31:0] i);      instr_lhu = (i[31:26]==`EXE_LHU); endfunction
function instr_lw(input [31:0] i);       instr_lw = (i[31:26]==`EXE_LW); endfunction
function instr_lwl(input [31:0] i);      instr_lwl = (i[31:26]==`EXE_LWL); endfunction
function instr_lwr(input [31:0] i);      instr_lwr = (i[31:26]==`EXE_LWR); endfunction
function instr_ll(input [31:0] i);      instr_ll = (i[31:26]==`EXE_LL); endfunction
//store
function instr_sb(input [31:0] i);       instr_sb = (i[31:26]==`EXE_SB); endfunction
function instr_sh(input [31:0] i);       instr_sh = (i[31:26]==`EXE_SH); endfunction
function instr_sw(input [31:0] i);       instr_sw = (i[31:26]==`EXE_SW); endfunction
function instr_swl(input [31:0] i);      instr_swl = (i[31:26]==`EXE_SWL); endfunction
function instr_swr(input [31:0] i);      instr_swr = (i[31:26]==`EXE_SWR); endfunction
function instr_sc(input [31:0] i);      instr_sc = (i[31:26]==`EXE_SC); endfunction
///cp0
function instr_mtc0(input [31:0] i);      instr_mtc0 = ((i[31:26]==`EXE_COP0)&({1'b1,i[25:21]}==`EXE_COP0_MTC0)); endfunction
function instr_mfc0(input [31:0] i);      instr_mfc0 = ((i[31:26]==`EXE_COP0)&({1'b1,i[25:21]}==`EXE_COP0_MFC0)); endfunction
///exception
//trap
function instr_teq(input [31:0] i);      instr_teq = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_TEQ)); endfunction
function instr_tge(input [31:0] i);      instr_tge = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_TGE)); endfunction
function instr_tgeu(input [31:0] i);      instr_tgeu = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_TGEU)); endfunction
function instr_tlt(input [31:0] i);      instr_tlt = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_TLT)); endfunction
function instr_tltu(input [31:0] i);      instr_tltu = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_TLTU)); endfunction
function instr_tne(input [31:0] i);      instr_tne = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_TNE)); endfunction
function instr_teqi(input [31:0] i);    instr_teqi = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_TEQI)); endfunction
function instr_tgei(input [31:0] i);    instr_tgei = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_TGEI)); endfunction
function instr_tgeiu(input [31:0] i);    instr_tgeiu = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_TGEIU)); endfunction
function instr_tlti(input [31:0] i);    instr_tlti = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_TLTI)); endfunction
function instr_tltiu(input [31:0] i);    instr_tltiu = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_TLTIU)); endfunction
function instr_tnei(input [31:0] i);    instr_tnei = ((i[31:26]==`EXE_REGIMM)&({1'b0,i[20:16]}==`EXE_REGIMM_TNEI)); endfunction
//syscall
function instr_syscall(input [31:0] i);      instr_syscall = ((i[31:26]==`EXE_SPECIAL)&(i[5:0]==`EXE_SPECIAL_SYSCALL)); endfunction
//eret
function instr_eret(input [31:0] i);      instr_eret = (i==32'b0100_0010_0000_0000_0000_0000_0001_1000); endfunction

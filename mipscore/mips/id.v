`include "defines.v"


module id(

	input [`InstAddrBusWidth-1:0]			pc_i,              //译码阶段的指令地址
	input [`InstBusWidth-1:0]              inst_i,             //译码阶段的指令


	//与regfile的接口
	output                                 reg1_read_o,
	output [`RegAddrBusWidth-1:0]          reg1_addr_o,
	input [`RegWidth-1:0]                  reg1_data_i,
	        
	output                                 reg2_read_o,     
	output [`RegAddrBusWidth-1:0]          reg2_addr_o, 	      
	input [`RegWidth-1:0]                  reg2_data_i,
	
	//与reghilo的接口
	output                                 reghi_read_o,
	input [`RegWidth-1:0]                  reghi_data_i,
	        
	output                                 reglo_read_o,
	input [`RegWidth-1:0]                  reglo_data_i,
	
    //与regLLbit的接口
	output                                 regLLbit_read_o,
	input                                  regLLbit_data_i,
	
    //与cp0的接口
	output                                 cp0_read_o,     
	output [`RegAddrBusWidth-1:0]          cp0_addr_o, 	      
	input [`RegWidth-1:0]                  cp0_data_i,
	
	//送到执行阶段的信息
	output [`AluOpBusWidth-1:0]            aluop_o,            //译码后的指令子类型
	output [`AluSelBusWidth-1:0]           alusel_o,           //译码后的指令类型
	output [`RegWidth-1:0]                 reg1_o,             //译码后的源操作数1
	output [`RegWidth-1:0]                 reg2_o,             //译码后的源操作数2
	output [`RegAddrBusWidth-1:0]          wd_o,               //译码后写入的目的寄存器
	output                                 wreg_o,             //译码后是否写入目的寄存器
	output                                 wreg_hi_o,          //译码后是否写HI的寄存器
	output                                 wreg_lo_o,          //译码后是否写LO的寄存器
	output [`RegWidth-1:0]                 reghi_o,            //译码后的源操作数hi
	output [`RegWidth-1:0]                 reglo_o,            //译码后的源操作数lo
	output                                 wreg_LLbit_o,       //译码后是否写LLbit的寄存器
	output                                 regLLbit_o,         //译码后的源操作数LLbit
	output [`RegAddrBusWidth-1:0]          wd_cp0_o,           //译码后写入的目的寄存器
	output                                 wreg_cp0_o,         //译码后是否写入目的寄存器
	
	//译码阶段的暂停输出
	output                                 id_to_pausereq,
	
    input                                  oitf_match,
    input                                  oitf_hi_match,
    input                                  oitf_lo_match,
    input                                  oitf_LLbit_match,
    input                                  oitf_cp0_match,
	input  [5:0]                           pause,
	
	//jump
	input                                  pc_flush_en,
	output  [`InstAddrBusWidth-1:0]        pc_o,
	output                                 pc_flush,
    
    //branch
	output [`RegWidth-1:0]                 offset,
    
    input  wire                            rst_n
);
`include "instruction.v"

    wire[5:0] op = inst_i[31:26];
    wire[5:0] func = inst_i[5:0];
    wire[31:0] sa = {27'b0,inst_i[10:6]};
    wire[`RegWidth-1:0]	imm;
    //reg instvalid;

//    wire[`AluOpBusWidth-1:0]            aluop_pre;            //译码后的指令子类型
//    wire[`AluSelBusWidth-1:0]           alusel_pre;           //译码后的指令类型
//    wire[`RegWidth-1:0]                 reg1_pre;             //译码后的源操作数1
//    wire[`RegWidth-1:0]                 reg2_pre;             //译码后的源操作数2
//    wire[`RegAddrBusWidth-1:0]          wd_pre;               //译码后写入的目的寄存器
//    wire                                wreg_pre;             //译码后是否写入目的寄存器
    
    //instruction type
    wire                                instruction_R;
    wire                                instruction_I;
    wire                                instruction_J;
    
    
    wire                                read_hi;
    wire                                read_lo;
    wire                                write_hi;
    wire                                write_lo;
    wire                                read_LLbit;
    wire                                write_LLbit;
    
    wire                                instruction_R_special;
    wire                                instruction_R_special2_r;
    wire                                instruction_R_special2_hilo;
    wire                                instruction_R_special2;
    wire                                instruction_I_regimm;
    wire                                instruction_I_regimm_exception;
    
    wire                                need_sa;
    //AluSel type
    wire                                exe_res_logic;
    wire                                exe_res_shift;
    wire                                exe_res_nop;
    wire                                exe_res_move;
    wire                                exe_res_arithmetic;
    wire                                exe_res_mul;
    wire                                exe_res_cmul;
    wire                                exe_res_div;
    wire                                exe_res_jump;
    wire                                exe_res_branch;
    wire                                exe_res_store;
    wire                                exe_res_load;
    wire                                exe_res_cp0;
    wire                                exe_res_exception;

    wire                                data_enable;
    wire                                data_hi_enable;
    wire                                data_lo_enable;
    wire                                data_LLbit_enable;
    wire                                data_cp0_enable;
    
    assign instruction_R_special = instr_and(inst_i)|instr_or(inst_i)|instr_xor(inst_i)|instr_nor(inst_i)|instr_sll(inst_i)
                                    |instr_srl(inst_i)|instr_sra(inst_i)|instr_sllv(inst_i)|instr_srlv(inst_i)|instr_srav(inst_i)
                                    |instr_sync(inst_i)
                                    |instr_movn(inst_i)|instr_movz(inst_i)|instr_mfhi(inst_i)|instr_mflo(inst_i)|instr_mthi(inst_i)|instr_mtlo(inst_i)
                                    |instr_add(inst_i)|instr_addu(inst_i)|instr_sub(inst_i)|instr_subu(inst_i)|instr_slt(inst_i)|instr_sltu(inst_i)|instr_mult(inst_i)|instr_multu(inst_i)
                                    |instr_div(inst_i)|instr_divu(inst_i)
                                    |instr_jr(inst_i)|instr_jalr(inst_i)
                                    |instr_teq(inst_i)|instr_tge(inst_i)|instr_tgeu(inst_i)|instr_tlt(inst_i)|instr_tltu(inst_i)|instr_tne(inst_i)
                                    |instr_syscall(inst_i)
                                    ;
    assign instruction_R_special2_r = instr_clz(inst_i)|instr_clo(inst_i)|instr_mul(inst_i);
    assign instruction_R_special2_hilo = instr_madd(inst_i)|instr_maddu(inst_i)|instr_msub(inst_i)|instr_msubu(inst_i);
    assign instruction_R_special2 = instruction_R_special2_r
                                    |instruction_R_special2_hilo
                                    ;
    assign instruction_R = instruction_R_special|instruction_R_special2;
    
    assign instruction_I_regimm = instr_bltz(inst_i)|instr_bltzal(inst_i)|instr_bgez(inst_i)|instr_bgezal(inst_i);
    assign instruction_I_regimm_exception = instr_teqi(inst_i)|instr_tgei(inst_i)|instr_tgeiu(inst_i)|instr_tlti(inst_i)|instr_tltiu(inst_i)|instr_tnei(inst_i);
    assign instruction_I = instr_ori(inst_i)|instr_andi(inst_i)|instr_xori(inst_i)|instr_lui(inst_i)
                            |instr_pref(inst_i)
                            |instr_addi(inst_i)|instr_addiu(inst_i)|instr_slti(inst_i)|instr_sltiu(inst_i)
                            |exe_res_branch
                            |exe_res_store|exe_res_load
                            |instruction_I_regimm_exception
                            ;
    assign instruction_J = instr_j(inst_i)|instr_jal(inst_i);
    
    
    assign read_hi = instr_mfhi(inst_i)
                    |instr_madd(inst_i)|instr_maddu(inst_i)|instr_msub(inst_i)|instr_msubu(inst_i)
                    ;
    assign read_lo = instr_mflo(inst_i)
                    |instr_madd(inst_i)|instr_maddu(inst_i)|instr_msub(inst_i)|instr_msubu(inst_i)
                    ;
    assign write_hi = instr_mthi(inst_i)|instr_mult(inst_i)|instr_multu(inst_i)
                    |instr_madd(inst_i)|instr_maddu(inst_i)|instr_msub(inst_i)|instr_msubu(inst_i)
                    |instr_div(inst_i)|instr_divu(inst_i)
                    ;
    assign write_lo = instr_mtlo(inst_i)|instr_mult(inst_i)|instr_multu(inst_i)
                    |instr_madd(inst_i)|instr_maddu(inst_i)|instr_msub(inst_i)|instr_msubu(inst_i)
                    |instr_div(inst_i)|instr_divu(inst_i)
                    ;
    assign read_LLbit = instr_sc(inst_i)
                        ;
    assign write_LLbit = instr_sc(inst_i)|instr_ll(inst_i)
                        ;
    
    assign reghi_read_o = read_hi;
    assign reglo_read_o = read_lo;

	assign regLLbit_read_o = read_LLbit;

    wire is_mfc0 = instr_mfc0(inst_i);
    wire is_mtc0 = instr_mtc0(inst_i);
    assign cp0_read_o = is_mfc0;
    assign cp0_addr_o = {`RegAddrBusWidth{is_mfc0}}&inst_i[15:11];
    
    wire is_eret = instr_eret(inst_i);
    assign need_sa = instruction_R&
                    (instr_sll(inst_i)|instr_srl(inst_i)|instr_sra(inst_i));
    
    assign exe_res_logic = instr_ori(inst_i)|instr_andi(inst_i)|instr_xori(inst_i)|instr_lui(inst_i)|instr_and(inst_i)|instr_or(inst_i)|instr_xor(inst_i)|instr_nor(inst_i);
    assign exe_res_shift = (~exe_res_nop)&(instr_sll(inst_i)|instr_srl(inst_i)|instr_sra(inst_i)|instr_sllv(inst_i)|instr_srlv(inst_i)|instr_srav(inst_i));
    assign exe_res_nop = instr_sync(inst_i)|instr_pref(inst_i)|instr_nop(inst_i);
    assign exe_res_move = instr_movn(inst_i)|instr_movz(inst_i)|instr_mfhi(inst_i)|instr_mflo(inst_i)|instr_mthi(inst_i)|instr_mtlo(inst_i);
    assign exe_res_arithmetic = instr_add(inst_i)|instr_addu(inst_i)|instr_sub(inst_i)|instr_subu(inst_i)|instr_slt(inst_i)|instr_sltu(inst_i)
                                |instr_addi(inst_i)|instr_addiu(inst_i)|instr_slti(inst_i)|instr_sltiu(inst_i)
                                |instr_clz(inst_i)|instr_clo(inst_i)
                                ;
    assign exe_res_mul = instr_mul(inst_i)|instr_mult(inst_i)|instr_multu(inst_i);
    assign exe_res_cmul = instr_madd(inst_i)|instr_maddu(inst_i)|instr_msub(inst_i)|instr_msubu(inst_i);
    assign exe_res_div = instr_div(inst_i)|instr_divu(inst_i);
    assign exe_res_jump = instr_jr(inst_i)|instr_jalr(inst_i)|instr_j(inst_i)|instr_jal(inst_i);
    assign exe_res_branch = instruction_I_regimm|instr_beq(inst_i)|instr_bgtz(inst_i)|instr_blez(inst_i)|instr_bne(inst_i);
    assign exe_res_load = instr_lb(inst_i)|instr_lbu(inst_i)|instr_lh(inst_i)|instr_lhu(inst_i)|instr_lw(inst_i)|instr_lwl(inst_i)|instr_lwr(inst_i)|instr_ll(inst_i);
    assign exe_res_store = instr_sb(inst_i)|instr_sh(inst_i)|instr_sw(inst_i)|instr_swl(inst_i)|instr_swr(inst_i)|instr_sc(inst_i);
    assign exe_res_cp0 = is_mtc0|is_mfc0;
    assign exe_res_exception = instr_teq(inst_i)|instr_tge(inst_i)|instr_tgeu(inst_i)|instr_tlt(inst_i)|instr_tltu(inst_i)|instr_tne(inst_i)|
                                instr_teqi(inst_i)|instr_tgei(inst_i)|instr_tgeiu(inst_i)|instr_tlti(inst_i)|instr_tltiu(inst_i)|instr_tnei(inst_i)|
                                instr_syscall(inst_i)|
                                is_eret
                                ;
    
    assign reg1_read_o = (~exe_res_nop)//&(~read_hi)&(~read_lo)
                        &(instruction_R|instruction_I);
    assign reg1_addr_o = inst_i[25:21];
    assign reg2_read_o = (~exe_res_nop)//&(~read_hi)&(~read_lo)
                        &((instruction_R)
                            |(exe_res_branch&(~instruction_I_regimm))
                            |(exe_res_load|exe_res_store)
                            |is_mtc0
                          );
    assign reg2_addr_o = inst_i[20:16];
    
    assign data_enable = (~oitf_match)&(~pause[2]);
    assign data_hi_enable = (~oitf_hi_match)&(~pause[2]);
    assign data_lo_enable = (~oitf_lo_match)&(~pause[2]);
    assign data_LLbit_enable = (~oitf_LLbit_match)&(~pause[2]);
    assign data_cp0_enable = (~oitf_cp0_match)&(~pause[2]);
    wire data_enable_all = data_lo_enable&data_hi_enable&data_LLbit_enable&data_enable&data_cp0_enable;

    
    wire[`RegWidth-1:0] imm_pre =  ({`RegWidth{instruction_I}}&{16'h0, inst_i[15:0]})
                                    |({`RegWidth{instruction_J}}&{6'h0, inst_i[25:0]})
                                    ;
    
    
    wire[`AluSelBusWidth-1:0]  alusel_o_pre =({`AluSelBusWidth{exe_res_logic}}&`EXE_RES_LOGIC)
                                            |({`AluSelBusWidth{exe_res_shift}}&`EXE_RES_SHIFT)
                                            |({`AluSelBusWidth{exe_res_nop}}&`EXE_RES_NOP)
                                            |({`AluSelBusWidth{exe_res_move}}&`EXE_RES_MOVE)
                                            |({`AluSelBusWidth{exe_res_arithmetic}}&`EXE_RES_ARITHMETIC)
                                            |({`AluSelBusWidth{exe_res_mul}}&`EXE_RES_MUL)
                                            |({`AluSelBusWidth{exe_res_cmul}}&`EXE_RES_CMUL)
                                            |({`AluSelBusWidth{exe_res_div}}&`EXE_RES_DIV)
                                            |({`AluSelBusWidth{exe_res_jump}}&`EXE_RES_JUMP)
                                            |({`AluSelBusWidth{exe_res_branch}}&`EXE_RES_BRANCH)
                                            |({`AluSelBusWidth{exe_res_store}}&`EXE_RES_STORE)
                                            |({`AluSelBusWidth{exe_res_load}}&`EXE_RES_LOAD)
                                            |({`AluSelBusWidth{exe_res_cp0}}&`EXE_RES_CP0)
                                            |({`AluSelBusWidth{exe_res_exception}}&`EXE_RES_EXCEPTION)
                                            ;
                        
    wire[`AluOpBusWidth-1:0]   aluop_o_pre = ({`AluOpBusWidth{(instruction_I&(~(instruction_I_regimm|instruction_I_regimm_exception)))|instruction_J}}&{2'b00,op})
                                            |({`AluOpBusWidth{instruction_R_special}}&{2'b01,func})
                                            |({`AluOpBusWidth{instruction_R_special2}}&{2'b10,func})
                                            |({`AluOpBusWidth{instruction_I_regimm|instruction_I_regimm_exception}}&{2'b11,{1'b0,inst_i[20:16]}})
                                            |({`AluOpBusWidth{exe_res_cp0}}&{2'b11,{1'b1,inst_i[25:21]}})
                                            |({`AluOpBusWidth{is_eret}}&{2'b11,func})
                                            ;
                        
    wire                       wreg_o_pre = (//(instruction_R|instruction_I)//command type R and I has rd
                                            ((instruction_R_special&(~instr_jr(inst_i))&(~exe_res_exception))|(instruction_I&((~(exe_res_branch|exe_res_store|exe_res_exception))))))
                                            |instruction_R_special2_r
                                            |(instruction_J&instr_jal(inst_i))
                                            |(instr_bltzal(inst_i)|instr_bgezal(inst_i))
                                            |read_LLbit//sc指令
                                            |is_mfc0
                                            ;
                    
    wire[`RegAddrBusWidth-1:0] wd_o_pre = ({`RegAddrBusWidth{instruction_I}}&inst_i[20:16])
                                            |({`RegAddrBusWidth{instruction_R}}&inst_i[15:11])
                                            |({`RegAddrBusWidth{(instruction_J&instr_jal(inst_i))|(instr_bltzal(inst_i)|instr_bgezal(inst_i))}}&5'b11111)
                                            |({`RegAddrBusWidth{is_mfc0}}&inst_i[20:16])
                                            ;
    wire[`RegWidth-1:0]         reg1_o_pre = need_sa?sa:
                                       reg1_read_o?reg1_data_i:imm;
                      
    wire[`RegWidth-1:0]         reg2_o_pre = is_mfc0?cp0_data_i:
                                            reg2_read_o?reg2_data_i:imm;
                    
                    
    
    assign imm =    //({`RegWidth{data_enable}})
                    /*&*/imm_pre;
    
    assign offset = ({`RegWidth{exe_res_branch}}&imm)
                    |({`RegWidth{exe_res_store|exe_res_load}}&{{16{imm[15]}},imm[15:0]})
                    ;
    
    assign alusel_o = //({`AluSelBusWidth{data_enable&data_hi_enable&data_lo_enable}})
                      /*&*/alusel_o_pre;
                        
    assign aluop_o = //({`AluOpBusWidth{data_enable&data_hi_enable&data_lo_enable}})
                     /*&*/aluop_o_pre;
                     
    assign wreg_o = data_enable_all
                    &(~exe_res_nop)&(~write_hi)&(~write_lo)
                    &wreg_o_pre//command type R and I has rd
                    ;
    assign wd_o = //({`RegAddrBusWidth{wreg_o}})
                    /*&*/wd_o_pre;
                    
    assign reg1_o = //({`RegWidth{data_enable}})
                    /*&*/({`RegWidth{~exe_res_nop}})
                    &reg1_o_pre;
                    
    assign reg2_o = //({`RegWidth{data_enable}})
                    /*&*/({`RegWidth{~exe_res_nop}})
                    &reg2_o_pre;
                    
    assign wreg_hi_o = data_enable_all
                        &write_hi;
    
    assign wreg_lo_o = data_enable_all
                        &write_lo;

    assign reghi_o = //({`RegWidth{data_hi_enable}})
                     /*&*/reghi_data_i;
    
	assign reglo_o = //({`RegWidth{data_lo_enable}})
                     /*&*/reglo_data_i;
                     
    //与regLLbit的接口
    assign wreg_LLbit_o = data_enable_all
                            &write_LLbit;
    
	assign regLLbit_o = aluop_o_pre == `EXE_LL_OP? 1'b1:
                        aluop_o_pre == `EXE_SC_OP?regLLbit_data_i:1'b0;         //译码后的源操作数LLbit

	assign wreg_cp0_o = data_enable_all
                            &is_mtc0;
	assign wd_cp0_o = {`RegAddrBusWidth{is_mtc0}}&inst_i[15:11];

    assign pc_o = pc_i;
    assign pc_flush = exe_res_jump|exe_res_branch;
    //wire pc_flush_en_inter = (pc_flush_en===1'bX|pc_flush_en===1'bZ)?1'b0:pc_flush_en;
    
    assign id_to_pausereq = 1'b0;//(~pc_flush_en_inter)&((exe_res_jump===1'bX|exe_res_jump===1'bZ)?1'b0:exe_res_jump);
endmodule

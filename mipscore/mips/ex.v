`include "defines.v"

module ex(	
	//送到执行阶段的信息
	input [`AluOpBusWidth-1:0]         aluop_i,
	input [`AluSelBusWidth-1:0]        alusel_i,
	input [`RegWidth-1:0]              reg1_i,
	input [`RegWidth-1:0]              reg2_i,
	input [`RegAddrBusWidth-1:0]       wd_i,
	input                              wreg_i,
    input                              wreg_hi_i,
	input                              wreg_lo_i,
	input [`RegWidth-1:0]              reghi_i,
	input [`RegWidth-1:0]              reglo_i,
	input                              wreg_LLbit_i,
	input                              regLLbit_i,
	input [`RegAddrBusWidth-1:0]       wd_cp0_i,
	input                              wreg_cp0_i,
	input [`InstAddrBusWidth-1:0]	   pc_i,
	input                              pc_flush_i,
	input [`RegWidth-1:0]              offset_i,

	
	output [`RegAddrBusWidth-1:0]      wd_o,
	output                             wreg_o,
	output [`RegWidth-1:0]			   wdata_o,
	output                             wreg_real_o,
    output                             wreg_hi_o,
    output [`RegWidth-1:0]             wdata_hi_o,
    output                             wreg_lo_o,
    output [`RegWidth-1:0]             wdata_lo_o,
	output                             wreg_LLbit_o,
	output                             wreg_LLbit_wb_o,
	output                             wdata_LLbit_o,
	output [`RegAddrBusWidth-1:0]      wd_cp0_o,
	output                             wreg_cp0_o,
	output [`RegWidth-1:0]			   wdata_cp0_o,
	output [`InstAddrBusWidth-1:0]	   pc_o,
	output [`ExceptionTypeWidth-1:0]   excepttype_o,

	output                             ex_to_pausereq,	
	output                             jp_to_pausereq,	
    input                              pc_flush_en,

    //div
    output [`RegWidth-1:0]             div_opdata1_o,
	output [`RegWidth-1:0]             div_opdata2_o,
	output                             div_start_o,
	output                             signed_div_o,
    input  [`DoubleRegWidth-1:0]       div_result_i,
	input                              div_ready_i,
	
	//jump
	output [`InstAddrBusWidth-1:0]     pc_jump_o,
	output                             pc_flush_o,

	//mem
	output [`AluOpBusWidth-1:0]        mem_aluop_o,
    output [`DataAddrBusWidth-1:0]     mem_addr_o,
	output [`RegWidth-1:0]             mem_reg2_o ,
	output                             mem_wreg_o,
	output                             mem_wreg_LLbit,
	output                             mem_wdata_LLbit,
	input  [`RegWidth-1:0]             mem_data_i,
	input  [3:0]				       mem_sel_i,
	input                              mem_data_vaild_i,
	input                              mem_is_load_i,
	input                              mem_is_store_i,
	input                              mem_load_pause,

    input                              clk,
	input      						   rst_n
);

	wire[`RegWidth-1:0] logicout;

    assign logicout =   ({`RegWidth{(aluop_i==`EXE_ORI_OP)|(aluop_i==`EXE_OR_OP)}}&(reg1_i | reg2_i))
                        |({`RegWidth{(aluop_i==`EXE_ANDI_OP)|(aluop_i==`EXE_AND_OP)}}&(reg1_i & reg2_i))
                        |({`RegWidth{(aluop_i==`EXE_XORI_OP)|(aluop_i==`EXE_XOR_OP)}}&(reg1_i ^ reg2_i))
                        |({`RegWidth{(aluop_i==`EXE_NOR_OP)}}&(~(reg1_i |reg2_i)))
                        |({`RegWidth{(aluop_i==`EXE_LUI_OP)}}&({reg2_i[15:0],16'h0}))
                        ;
                        
                        
	wire[`RegWidth-1:0] shiftout;
    assign shiftout =   ({`RegWidth{(aluop_i==`EXE_SLL_OP)|(aluop_i==`EXE_SLLV_OP)}}&(reg2_i << reg1_i[4:0]))
                        |({`RegWidth{(aluop_i==`EXE_SRL_OP)|(aluop_i==`EXE_SRLV_OP)}}&(reg2_i >> reg1_i[4:0]))
                        |({`RegWidth{(aluop_i==`EXE_SRA_OP)|(aluop_i==`EXE_SRAV_OP)}}&(({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]}))| (reg2_i >> reg1_i[4:0])))
                        ;

	wire[`RegWidth-1:0] nopout;
    assign nopout = `RegWidth'b0;
    
    
	wire[`RegWidth-1:0] moveout;
    wire                moveout_condition;
    assign moveout =   ({`RegWidth{(aluop_i==`EXE_MOVN_OP)}}&(reg1_i))
                        |({`RegWidth{(aluop_i==`EXE_MOVZ_OP)}}&(reg1_i))
                        |({`RegWidth{(aluop_i==`EXE_MFHI_OP)}}&(reghi_i))
                        |({`RegWidth{(aluop_i==`EXE_MFLO_OP)}}&(reglo_i))
                        ;
    assign moveout_condition = ((aluop_i==`EXE_MOVN_OP)&(reg2_i != `RegWidth'b0))
                                |((aluop_i==`EXE_MOVZ_OP)&(reg2_i == `RegWidth'b0))
                                |(aluop_i==`EXE_MFHI_OP)
                                |(aluop_i==`EXE_MFLO_OP)
                                ;

	wire[`RegWidth-1:0]     arithmeticout;
    wire[`RegWidth-1:0]     reg2_i_signed;
    wire[`RegWidth-1:0]     reg2_i_mux;
    wire[`RegWidth-1:0]     reg1_i_not;
	wire[`RegWidth-1:0]     result_sum;
	wire ov_sum;
	wire reg1_eq_reg2;
	wire reg1_lt_reg2;
    assign reg2_i_signed = ((aluop_i==`EXE_ADDI_OP)
                            ||(aluop_i==`EXE_ADDIU_OP)
                            ||(aluop_i==`EXE_SLTI_OP)
                            ||(aluop_i==`EXE_SLTIU_OP)
                            ||(aluop_i==`EXE_TEQI_OP)
                            ||(aluop_i==`EXE_TGEI_OP)
                            ||(aluop_i==`EXE_TGEIU_OP)
                            ||(aluop_i==`EXE_TLTI_OP)
                            ||(aluop_i==`EXE_TLTIU_OP)
                            ||(aluop_i==`EXE_TNEI_OP)
                            )?{{16{reg2_i[15]}}, reg2_i[15:0]}:reg2_i
                            ;

    assign reg2_i_mux = (
                        (aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||(aluop_i == `EXE_SLT_OP)
                      ||(aluop_i == `EXE_TLT_OP) || (aluop_i == `EXE_TLTI_OP) ||(aluop_i == `EXE_TGE_OP)||(aluop_i == `EXE_TGEI_OP)
                         ) 
                         ? (~reg2_i_signed)+1 : reg2_i_signed;

	assign result_sum = reg1_i + reg2_i_mux;										 

	assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
									((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));  
									
	assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)
	                       ||(aluop_i == `EXE_TLT_OP) || (aluop_i == `EXE_TLTI_OP) ||(aluop_i == `EXE_TGE_OP)||(aluop_i == `EXE_TGEI_OP)
	                       ) ?
												 ((reg1_i[31] && !reg2_i_signed[31]) || 
												 (!reg1_i[31] && !reg2_i_signed[31] && result_sum[31])||
			                   (reg1_i[31] && reg2_i_signed[31] && result_sum[31]))
			                   :	(reg1_i < reg2_i_signed);
    assign reg1_i_not = ~reg1_i;

    assign arithmeticout = ({`RegWidth{((aluop_i==`EXE_SLT_OP)||(aluop_i==`EXE_SLTU_OP)||(aluop_i==`EXE_SLTI_OP)||(aluop_i==`EXE_SLTIU_OP))}}&(reg1_lt_reg2))
                            |({`RegWidth{((aluop_i==`EXE_ADD_OP)||(aluop_i==`EXE_ADDU_OP)||(aluop_i==`EXE_ADDI_OP)
                                    ||(aluop_i==`EXE_ADDIU_OP)||(aluop_i==`EXE_SUB_OP)||(aluop_i==`EXE_SUBU_OP))}}&(result_sum))
                            |({`RegWidth{(aluop_i==`EXE_CLZ_OP)}}&(reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
                                                                     reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
                                                                     reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
                                                                     reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
                                                                     reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
                                                                     reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
                                                                     reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
                                                                     reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
                                                                     reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
                                                                     reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
                                                                     reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ))
                            |({`RegWidth{(aluop_i==`EXE_CLO_OP)}}&(reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
                                                                     reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
                                                                     reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 : 
                                                                     reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
                                                                     reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 : 
                                                                     reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 : 
                                                                     reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
                                                                     reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 : 
                                                                     reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 : 
                                                                     reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 : 
                                                                     reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32))
                            ;
    //*************mul*************//
	wire[`DoubleRegWidth-1:0]      mulres;
	wire[`RegWidth-1:0]            opdata1_mult;
	wire[`RegWidth-1:0]            opdata2_mult;
	wire[`DoubleRegWidth-1:0]      hilo_temp;
    wire                           signedmul;
    wire                           overflow;
    assign overflow  = ((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || (aluop_i == `EXE_SUB_OP)) 
                        && (ov_sum == 1'b1);
    assign signedmul = (aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)
                        ||(aluop_i==`EXE_MADD_OP)||(aluop_i==`EXE_MSUB_OP)
                        ;
    assign opdata1_mult = (signedmul
                           && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
    
    assign opdata2_mult = (signedmul
                            && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;		
    
    assign hilo_temp = opdata1_mult * opdata2_mult;		
    assign mulres = (signedmul&&(reg1_i[31] ^ reg2_i[31]))?~hilo_temp + 1:hilo_temp;

    //*************cmul*************//
	wire[`DoubleRegWidth-1:0]      cmulres;
	assign cmulres = ({`DoubleRegWidth{((aluop_i==`EXE_MADD_OP)||(aluop_i==`EXE_MADDU_OP))}}&({reghi_i,reglo_i} + mulres ))
	                   |({`DoubleRegWidth{((aluop_i==`EXE_MSUB_OP)||(aluop_i==`EXE_MSUBU_OP))}}&({reghi_i,reglo_i} + ~mulres + 1 ))
                        ;
    //*************div*************//
 	wire[`DoubleRegWidth-1:0]      div;
    assign div_opdata1_o = reg1_i;
    assign div_opdata2_o = reg2_i;
    assign div_start_o = (~div_ready_i)&((aluop_i==`EXE_DIV_OP)||(aluop_i==`EXE_DIVU_OP));
    assign signed_div_o = (~div_ready_i)&(aluop_i==`EXE_DIV_OP);

 	assign div = {`DoubleRegWidth{div_ready_i}}&div_result_i;
 	
    //*************jump*************//
    wire[`InstAddrBusWidth-1:0]      jump;
    wire[`InstAddrBusWidth-1:0]      pc_rd;
    
    assign jump = ({`InstAddrBusWidth{((aluop_i==`EXE_J_OP)|(aluop_i==`EXE_JAL_OP))}}&{pc_rd[31:28],reg1_i[25:0],2'b00})
                    |({`InstAddrBusWidth{((aluop_i==`EXE_JR_OP)|(aluop_i==`EXE_JALR_OP))}}&reg1_i)
                    ;
 	assign pc_rd = pc_i + 4;

    //*************branch*************//
    wire[`InstAddrBusWidth-1:0]      branch;
    
    wire                             branch_jump;

 	assign branch = {{14{offset_i[15]}}, offset_i[15:0], 2'b00 } + pc_i;
 	
 	assign branch_jump = ((aluop_i==`EXE_BEQ_OP)&(reg1_i==reg2_i))
 	                      |((aluop_i==`EXE_BGTZ_OP)&((reg1_i[31] == 1'b0) && (reg1_i != `ZeroWord)))
 	                      |((aluop_i==`EXE_BLEZ_OP)&((reg1_i[31] == 1'b1) || (reg1_i == `ZeroWord)))
 	                      |((aluop_i==`EXE_BNE_OP)&(reg1_i!=reg2_i))
 	                      |(((aluop_i==`EXE_BLTZ_OP)|(aluop_i==`EXE_BLTZAL_OP))&(reg1_i[31] == 1'b1))
 	                      |(((aluop_i==`EXE_BGEZ_OP)|(aluop_i==`EXE_BGEZAL_OP))&(reg1_i[31] == 1'b0))
 	                      ;
 	                      
    //*************mem*************//
    wire [`RegWidth-1:0]                   mem_wdata;
    
    assign mem_aluop_o  =  aluop_i;
    assign mem_addr_o = offset_i+reg1_i;
    assign mem_reg2_o = reg2_i;
    assign mem_wreg_o = wreg_i;
	assign mem_wreg_LLbit = wreg_LLbit_i;
	assign mem_wdata_LLbit = regLLbit_i;

    assign mem_wdata = ({`RegWidth{mem_is_load_i&mem_data_vaild_i}}&{mem_sel_i[3]?mem_data_i[31:24]:reg2_i[31:24],
                                                                    mem_sel_i[2]?mem_data_i[23:16]:reg2_i[23:16],
                                                                    mem_sel_i[1]?mem_data_i[15:8]:reg2_i[15:8],
                                                                    mem_sel_i[0]?mem_data_i[7:0]:reg2_i[7:0]
                                                                    })
                        ;
                        
    //*************exception*************//
    wire tr_exception;
    assign tr_exception = ({(aluop_i == `EXE_TEQ_OP)|(aluop_i == `EXE_TEQI_OP)}&(reg1_i == reg2_i))
                          |({(aluop_i == `EXE_TGE_OP)|(aluop_i == `EXE_TGEI_OP)|(aluop_i == `EXE_TGEU_OP)|(aluop_i == `EXE_TGEIU_OP)}&(~reg1_lt_reg2))
                          |({(aluop_i == `EXE_TLT_OP)|(aluop_i == `EXE_TLTI_OP)|(aluop_i == `EXE_TLTU_OP)|(aluop_i == `EXE_TLTIU_OP)}&(reg1_lt_reg2))
                          |({(aluop_i == `EXE_TNE_OP)|(aluop_i == `EXE_TNEI_OP)}&(reg1_i != reg2_i))
                          ;
 	                      
 	                      
    assign wdata_o =    (
                        ({`RegWidth{(alusel_i == `EXE_RES_LOGIC)}}&logicout)
                        |({`RegWidth{(alusel_i == `EXE_RES_SHIFT)}}&shiftout)
                        |({`RegWidth{(alusel_i == `EXE_RES_NOP)}}&nopout)
                        |({`RegWidth{(alusel_i == `EXE_RES_MOVE)&moveout_condition}}&moveout)
                        |({`RegWidth{(alusel_i == `EXE_RES_ARITHMETIC)}}&arithmeticout)
                        |({`RegWidth{(alusel_i == `EXE_RES_MUL)}}&mulres[31:0])
                        |({`RegWidth{(alusel_i == `EXE_RES_JUMP)|(alusel_i == `EXE_RES_BRANCH)}}&pc_rd)
                        |({`RegWidth{(alusel_i == `EXE_RES_LOAD)&mem_data_vaild_i}}&mem_wdata)
                        |({`RegWidth{(aluop_i == `EXE_SC_OP)}}&(wreg_LLbit_i&regLLbit_i?1'b1:1'b0))
                        |({`RegWidth{(aluop_i == `EXE_MFC0_OP)}}&reg2_i)
                        );
    
    assign wd_o = (
                    ({`RegAddrBusWidth{(alusel_i == `EXE_RES_LOGIC)}}&wd_i)
                    |({`RegAddrBusWidth{(alusel_i == `EXE_RES_SHIFT)}}&wd_i)
                    |({`RegAddrBusWidth{(alusel_i == `EXE_RES_NOP)}}&wd_i)
                    |({`RegAddrBusWidth{(alusel_i == `EXE_RES_MOVE)}}&wd_i)
                    |({`RegAddrBusWidth{(alusel_i == `EXE_RES_ARITHMETIC)}}&wd_i)
                    |({`RegAddrBusWidth{(alusel_i == `EXE_RES_MUL)}}&wd_i)
                    |({`RegAddrBusWidth{(alusel_i == `EXE_RES_JUMP)|(alusel_i == `EXE_RES_BRANCH)}}&wd_i)
                    |({`RegAddrBusWidth{(alusel_i == `EXE_RES_LOAD)}}&wd_i)
                    |({`RegAddrBusWidth{(aluop_i == `EXE_SC_OP)}}&wd_i)
                    |({`RegAddrBusWidth{(alusel_i == `EXE_RES_CP0)}}&wd_i)
                    );
    assign wreg_o = (~ex_to_pausereq)&(
                    ({1{(alusel_i == `EXE_RES_LOGIC)}}&wreg_i)
                    |({1{(alusel_i == `EXE_RES_SHIFT)}}&wreg_i)
                    |({1{(alusel_i == `EXE_RES_NOP)}}&1'b0)
                    |({1{(alusel_i == `EXE_RES_MOVE)}}&wreg_i)
                    |({1{(alusel_i == `EXE_RES_ARITHMETIC)}}&wreg_i)
                    |({1{(alusel_i == `EXE_RES_MUL)}}&wreg_i)
                    |({1{(alusel_i == `EXE_RES_JUMP)|(alusel_i == `EXE_RES_BRANCH)}}&wreg_i)
                    |({1{(alusel_i == `EXE_RES_LOAD)&mem_data_vaild_i}}&wreg_i)
                    |({1{(aluop_i == `EXE_SC_OP)}}&wreg_i)
                    |({1{(alusel_i == `EXE_RES_CP0)}}&wreg_i)
                    );
                    
    assign wreg_real_o = (~ex_to_pausereq)&(
                        ((alusel_i == `EXE_RES_LOGIC))
                        |((alusel_i == `EXE_RES_SHIFT))
                        |((alusel_i == `EXE_RES_NOP)&1'b0)
                        |((alusel_i == `EXE_RES_MOVE)&moveout_condition)
                        |((alusel_i == `EXE_RES_ARITHMETIC)&(~overflow))
                        |((alusel_i == `EXE_RES_MUL))
                        |((alusel_i == `EXE_RES_JUMP))
                        |((alusel_i == `EXE_RES_BRANCH))
                        |((alusel_i == `EXE_RES_LOAD)&mem_is_load_i)
                        |((aluop_i == `EXE_SC_OP))
                        |((alusel_i == `EXE_RES_CP0))
                        );


                    
    assign wreg_hi_o = wreg_hi_i&
                        (
                        (aluop_i==`EXE_MTHI_OP)
                        |((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP))
                        |((alusel_i == `EXE_RES_CMUL))
                        |((alusel_i == `EXE_RES_DIV)&&div_ready_i)
                        );
    assign wdata_hi_o = ({`RegWidth{(aluop_i==`EXE_MTHI_OP)}}&(reg1_i))
                        |({`RegWidth{(aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)}}&(mulres[63:32]))
                        |({`RegWidth{(alusel_i == `EXE_RES_CMUL)}}&(cmulres[63:32]))
                        |({`RegWidth{(alusel_i == `EXE_RES_DIV)}}&(div[63:32]))
                        ;
    assign wreg_lo_o = wreg_lo_i&
                        (
                        (aluop_i==`EXE_MTLO_OP)
                        |((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP))
                        |((alusel_i == `EXE_RES_CMUL))
                        |((alusel_i == `EXE_RES_DIV)&&div_ready_i)
                        );
                        
    assign wdata_lo_o = ({`RegWidth{(aluop_i==`EXE_MTLO_OP)}}&(reg1_i))
                        |({`RegWidth{(aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)}}&(mulres[31:0]))
                        |({`RegWidth{(alusel_i == `EXE_RES_CMUL)}}&(cmulres[31:0]))
                        |({`RegWidth{(alusel_i == `EXE_RES_DIV)}}&(div[31:0]))
                        ;
	assign wreg_LLbit_o = (aluop_i == `EXE_LL_OP)?(mem_data_vaild_i&wreg_LLbit_i):
	                       ((aluop_i == `EXE_SC_OP)&wreg_LLbit_i&regLLbit_i)//?1'b1:1'b0
	                       ;
	assign wreg_LLbit_wb_o = (aluop_i == `EXE_LL_OP)?(mem_data_vaild_i&wreg_LLbit_i):
	                       ((aluop_i == `EXE_SC_OP)&wreg_LLbit_i)//?1'b1:1'b0
	                       ;
	assign wdata_LLbit_o = (aluop_i == `EXE_LL_OP)?(mem_data_vaild_i&regLLbit_i):1'b0
	                       ;
    assign wd_cp0_o = wd_cp0_i;
	assign wreg_cp0_o = wreg_cp0_i;
	assign wdata_cp0_o = {`RegWidth{wreg_cp0_i}}&reg2_i;
	
	assign pc_o = pc_i;

    assign ex_to_pausereq = ((div_start_o===1'bX|div_start_o===1'bZ)?1'b0:div_start_o)
                            |((mem_data_vaild_i===1'bX|mem_data_vaild_i===1'bZ
                                //|alusel_i =={`AluSelBusWidth{1'bX}}
                                //|alusel_i =={`AluSelBusWidth{1'bZ}}
                                )?1'b0:mem_load_pause)//
                            ;
    
//    wire pc_flush_en_inter = (pc_flush_en===1'bX|pc_flush_en===1'bZ)?1'b0:pc_flush_en;
//    assign jp_to_pausereq = (~pc_flush_en_inter)&((pc_flush_i===1'bX|pc_flush_i===1'bZ)?1'b0:pc_flush_i);
    
    assign pc_jump_o = ({`InstAddrBusWidth{(alusel_i == `EXE_RES_JUMP)}}&jump)
                        |({`InstAddrBusWidth{(alusel_i == `EXE_RES_BRANCH)}}&branch)
                        ;
    
    assign pc_flush_o = ((alusel_i == `EXE_RES_JUMP)&pc_flush_i)
                        |((alusel_i == `EXE_RES_BRANCH)&pc_flush_i&branch_jump)
                        ;
    
    assign excepttype_o = (
                    ({32{(aluop_i == `EXE_ERET_OP)}}&`EXCEPTION_ERET)
                    |({32{(aluop_i == `EXE_SYSCALL_OP)}}&`EXCEPTION_SYSCALL)
                    |({32{tr_exception}}&`EXCEPTION_TR)
                    );
endmodule

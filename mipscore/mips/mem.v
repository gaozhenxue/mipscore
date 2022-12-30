`include "defines.v"

module mem(
	
	//与ex模块的接口	
	input [`AluOpBusWidth-1:0]            aluop_i,
    input [`DataAddrBusWidth-1:0]         ex_addr_i,
	input [`RegWidth-1:0]                 reg2_i ,
    input                                 ex_wreg_i,
	input                                 ex_wreg_LLbit,
	input                                 ex_wdata_LLbit,
    input                                 oitf_match,
	output[`RegWidth-1:0]                 ex_data_o,
	output [3:0]				          ex_sel_o,
	output                                ex_data_vaild_o,
	output                                ex_is_load_o,
	output                                ex_is_store_o,
	output                                ex_load_pause,
	
	//与数据ram的接口
    output [`DataAddrBusWidth-1:0]        mem_addr_o,
	output                                mem_we_o,
	output [3:0]				          mem_sel_o,
	output [`RegWidth-1:0]                mem_data_o,
	output                                mem_ce_o,
	input  [`RegWidth-1:0]                mem_data_i,


    input 								  clk,
    input   							  rst_n
);
//主要业务描述
//ex模块完成目标寄存器数据取数和指令op的传递，并且传递读写目标地址，以上参数由ex模块完成
//当前模块要根据操作op目标地址和reg2的数据，计算出对外部ram的操作信号
//目标操作地址，掩码，读写，ce，输入输出数据
//目前先写当前模块


wire [`AluOpBusWidth-1:0]            last_aluop_i;
wire [`DataAddrBusWidth-1:0]         last_ex_addr_i;
wire [`RegWidth-1:0]                 last_reg2_i;

gnrl_dfflr #(`AluOpBusWidth) aluop_dffr (1'b1,aluop_i, last_aluop_i, clk, rst_n);
gnrl_dfflr #(`DataAddrBusWidth) ex_addr_dffr (1'b1,ex_addr_i, last_ex_addr_i, clk, rst_n);
gnrl_dfflr #(`RegWidth) reg2_dffr (1'b1,reg2_i, last_reg2_i, clk, rst_n);


wire is_lb = aluop_i == `EXE_LB_OP;
wire is_lbu = aluop_i == `EXE_LBU_OP;
wire is_lh = aluop_i == `EXE_LH_OP;
wire is_lhu = aluop_i == `EXE_LHU_OP;
wire is_lw = aluop_i == `EXE_LW_OP;
wire is_lwl = aluop_i == `EXE_LWL_OP;
wire is_lwr = aluop_i == `EXE_LWR_OP;
wire is_ll = aluop_i == `EXE_LL_OP;
wire is_load = is_lb|is_lbu|is_lh|is_lhu|is_lw|is_lwl|is_lwr|is_ll;

wire is_sb = aluop_i == `EXE_SB_OP;
wire is_sh = aluop_i == `EXE_SH_OP;
wire is_sw = aluop_i == `EXE_SW_OP;
wire is_swl = aluop_i == `EXE_SWL_OP;
wire is_swr = aluop_i == `EXE_SWR_OP;
wire is_sc = (aluop_i == `EXE_SC_OP)&ex_wreg_LLbit&ex_wdata_LLbit;
wire is_store = is_sb|is_sh|is_sw|is_swl|is_swr|is_sc;

    
    wire load_pause_en = is_load&ex_wreg_i&((aluop_i != last_aluop_i)|(ex_addr_i != last_ex_addr_i)|(reg2_i != last_reg2_i));
    
    gnrl_sgnl_edge_probe gnrl_sgnl_edge_probe_ex_load_pause(
	.clk(clk),
	.signal(load_pause_en),
	.polarity(1'b1),//test pos or nege
	
	.res(ex_load_pause)
    );


assign ex_is_load_o = is_load;
assign ex_is_store_o = is_store;
assign mem_addr_o = {ex_addr_i[31:2],2'b00};
assign mem_we_o = is_store;
assign mem_ce_o = is_store|is_load;

wire [1:0]          shift_addr = 2'b11 - ex_addr_i[1:0];

wire [`RegWidth-1:0]    reg2_i_r_shift = (reg2_i>>{ex_addr_i[1:0],3'b000});
wire [`RegWidth-1:0]    reg2_i_l_shift = (reg2_i<<{shift_addr[1:0],3'b000});
wire [`RegWidth-1:0]    reg2_i_l_h_shift = (reg2_i<<{shift_addr[1],4'b0000});

//wire [`RegWidth-1:0]    reg2_i_r_shift_unsigned_b = (reg2_i_l_shift&32'h0000_0011);
//wire [`RegWidth-1:0]    reg2_i_r_shift_unsigned_h = (reg2_i_l_h_shift&32'h0000_FFFF);

assign mem_data_o = ({`RegWidth{is_sb}}&reg2_i_l_shift)
                   |({`RegWidth{is_sh}}&reg2_i_l_h_shift)
                   |({`RegWidth{is_sw|is_sc}}&reg2_i)
                   |({`RegWidth{is_swr}}&reg2_i_l_shift)
                   |({`RegWidth{is_swl}}&reg2_i_r_shift)
                   ;
                   
assign mem_sel_o = ({4{is_sw|is_sc}})
                  |({4{is_sb}}&{{shift_addr[1:0]==2'b11},
                                {shift_addr[1:0]==2'b10},
                                {shift_addr[1:0]==2'b01},
                                {shift_addr[1:0]==2'b00}
                                })
                  |({4{is_sh}}&{{2{shift_addr[1]==1'b1}},
                                {2{shift_addr[1]==1'b0}}
                                })
                  |({4{is_swr}}&{1'b1,
                                 {(ex_addr_i[1:0]>2'b00)?1'b1:1'b0},
                                 {(ex_addr_i[1:0]>2'b01)?1'b1:1'b0},
                                 {(ex_addr_i[1:0]>2'b10)?1'b1:1'b0}
                                })
                  |({4{is_swl}}&{
                                 {(ex_addr_i[1:0]<2'b01)?1'b1:1'b0},
                                 {(ex_addr_i[1:0]<2'b10)?1'b1:1'b0},
                                 {(ex_addr_i[1:0]<2'b11)?1'b1:1'b0},
                                 1'b1
                                })
                  ;
                  
wire [`RegWidth-1:0]    mem_data_i_r_shift = (mem_data_i>>{shift_addr[1:0],3'b000});
wire [`RegWidth-1:0]    mem_data_i_h_r_shift = (mem_data_i>>{shift_addr[1],4'b0000});
wire [`RegWidth-1:0]    mem_data_i_l_shift = (mem_data_i<<{ex_addr_i[1:0],3'b000});

wire [`RegWidth-1:0]    mem_data_i_r_shift_unsigned_b = (mem_data_i_r_shift&32'h0000_00FF);
wire [`RegWidth-1:0]    mem_data_i_r_shift_unsigned_h = (mem_data_i_h_r_shift&32'h0000_FFFF);


assign ex_data_o = ({`RegWidth{is_lb}}&(mem_data_i_r_shift_unsigned_b|{{24{mem_data_i_r_shift_unsigned_b[7]}},8'h00}))
                   |({`RegWidth{is_lbu}}&mem_data_i_r_shift_unsigned_b)
                   |({`RegWidth{is_lh}}&(mem_data_i_r_shift_unsigned_h|{{16{mem_data_i_r_shift_unsigned_h[15]}},16'h00}))
                   |({`RegWidth{is_lhu}}& mem_data_i_r_shift_unsigned_h)
                   |({`RegWidth{is_lw|is_ll}}& mem_data_i)
                   |({`RegWidth{is_lwl}}&mem_data_i_l_shift)
                   |({`RegWidth{is_lwr}}&mem_data_i_r_shift)
                   ;
                   
assign ex_sel_o = ({4{is_lb|is_lbu|is_ll|is_lh|is_lhu|is_lw}})
                  |({4{is_lwl}}&{1'b1,
                                 {(ex_addr_i[1:0]<2'b11)?1'b1:1'b0},
                                 {(ex_addr_i[1:0]<2'b10)?1'b1:1'b0},
                                 {(ex_addr_i[1:0]<2'b01)?1'b1:1'b0}
                                })
                  |({4{is_lwr}}&{
                                 {(ex_addr_i[1:0]>2'b10)?1'b1:1'b0},
                                 {(ex_addr_i[1:0]>2'b01)?1'b1:1'b0},
                                 {(ex_addr_i[1:0]>2'b00)?1'b1:1'b0},
                                 1'b1
                                })
                  ;

gnrl_dfflr #(1)    ex_data_vaild_o_dfflr (1'b1, ex_load_pause, ex_data_vaild_o, clk, rst_n);//ram取数需要一个拍

endmodule

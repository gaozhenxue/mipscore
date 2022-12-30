`include "defines.v"

module mem_wb(
	//来自访存阶段的信息	
    input [`RegAddrBusWidth-1:0]           mem_wd,
	input                                  mem_wreg,
	input [`RegWidth-1:0]				   mem_wdata,
	input                                  mem_wreg_real,
    input                                  mem_wreg_hi,
    input [`RegWidth-1:0]                  mem_wdata_hi,
    input                                  mem_wreg_lo,
    input [`RegWidth-1:0]                  mem_wdata_lo,
	input                                  mem_wreg_LLbit,
	input                                  mem_wreg_LLbit_wb,
	input                                  mem_wdata_LLbit,
	input [`RegAddrBusWidth-1:0]           mem_wd_cp0,
	input                                  mem_wreg_cp0,
	input [`RegWidth-1:0]			       mem_wdata_cp0,
	
	
	
	//送到回写阶段的信息
	output [`RegAddrBusWidth-1:0]          wb_wd,
	output                                 wb_wreg,
	output [`RegWidth-1:0]				   wb_wdata,
	output                                 wb_wreg_real,
    output                                 wb_wreg_hi,
    output [`RegWidth-1:0]                 wb_wdata_hi,
    output                                 wb_wreg_lo,
    output [`RegWidth-1:0]                 wb_wdata_lo,
	output                                 wb_wreg_LLbit,
	output                                 wb_wreg_LLbit_wb,
	output                                 wb_wdata_LLbit,
	output [`RegAddrBusWidth-1:0]          wb_wd_cp0,
	output                                 wb_wreg_cp0,
	output [`RegWidth-1:0]			       wb_wdata_cp0,
	
	input  [5:0]                           pause,
	//input 
	
	//异常相关
	input [`InstAddrBusWidth-1:0]	       mem_pc,
	input [`InstAddrBusWidth-1:0]          mem_pc_jump,
	input                                  mem_pc_flush,
	input                                  ex_to_pausereq,	
	
	input [`ExceptionTypeWidth-1:0]        excepttype_i,
	input [`RegWidth-1:0]                  cp0_status_i,
	input [`RegWidth-1:0]                  cp0_cause_i,
	input [`RegWidth-1:0]                  cp0_epc_i,

	output                                 exception_en,
    output                                 is_exception,
    output                                 is_interrupt,
	output [31:0]                          excepttype_o,
	output [`InstAddrBusWidth-1:0]	       pc_next,
	output                                 is_slot,
	
	
    input 										clk,
	input 										rst_n
);

wire mem_wb_en;
assign mem_wb_en = (~pause[4]);

wire rst_clear_n = ~is_exception;

wire [`InstAddrBusWidth-1:0]	       mem_pc_last;
wire is_new_pc = (mem_pc!=mem_pc_last)&(~ex_to_pausereq);
gnrl_dfflr #(`InstAddrBusWidth)             pc_dfflr ((~ex_to_pausereq), mem_pc, mem_pc_last, clk, rst_n);


gnrl_dfflr #(`RegAddrBusWidth)      wd_dfflr (mem_wb_en, mem_wd, wb_wd, clk, rst_n);
wire wb_wreg_r;
assign wb_wreg = wb_wreg_r;//&is_new_pc;
gnrl_dfflr #(1)                     wreg_dfflr (mem_wb_en, mem_wreg, wb_wreg_r, clk, rst_n);
gnrl_dfflr #(`RegWidth)             wdata_dfflr (mem_wb_en, mem_wdata, wb_wdata, clk, rst_n);
gnrl_dfflr #(1)                     wreg_real_dfflr (mem_wb_en, mem_wreg_real, wb_wreg_real, clk, rst_n);
gnrl_dfflr #(1)                     wreg_hi_dfflr (mem_wb_en, mem_wreg_hi, wb_wreg_hi, clk, rst_n);
gnrl_dfflr #(`RegWidth)             wdata_hi_dfflr (mem_wb_en, mem_wdata_hi, wb_wdata_hi, clk, rst_n);
gnrl_dfflr #(1)                     wreg_lo_dfflr (mem_wb_en, mem_wreg_lo, wb_wreg_lo, clk, rst_n);
gnrl_dfflr #(`RegWidth)             wdata_lo_dfflr (mem_wb_en, mem_wdata_lo, wb_wdata_lo, clk, rst_n);
gnrl_dfflr #(1)                     wreg_LLbit_dfflr (mem_wb_en, mem_wreg_LLbit, wb_wreg_LLbit, clk, rst_n);
gnrl_dfflr #(1)                     wreg_LLbit_wb_dfflr (mem_wb_en, mem_wreg_LLbit_wb, wb_wreg_LLbit_wb, clk, rst_n);
gnrl_dfflr #(1)                     wdata_LLbit_dfflr (mem_wb_en, mem_wdata_LLbit, wb_wdata_LLbit, clk, rst_n);
gnrl_dfflr #(`RegAddrBusWidth)      wd_cp0_dfflr (mem_wb_en, mem_wd_cp0, wb_wd_cp0, clk, rst_n);
gnrl_dfflr #(1)                     wreg_cp0_dfflr (mem_wb_en, mem_wreg_cp0, wb_wreg_cp0, clk, rst_n);
gnrl_dfflr #(`RegWidth)             wdata_cp0_dfflr (mem_wb_en, mem_wdata_cp0, wb_wdata_cp0, clk, rst_n);

wire [`InstAddrBusWidth-1:0]	       mem_pc_jump_last;
gnrl_dfflr #(`InstAddrBusWidth)             pc_jump_dfflr (mem_pc_flush, mem_pc_jump, mem_pc_jump_last, clk, rst_n);


wire pc_flush_last;
wire pc_flush_last_enable = mem_pc_flush|is_new_pc;
wire pc_flush_last_next = mem_pc_flush|(~is_new_pc);

gnrl_dfflr #(1)                     pc_flush_dfflr (pc_flush_last_enable,pc_flush_last_next , pc_flush_last, clk, rst_n);

assign is_slot = pc_flush_last&is_new_pc;

assign is_exception = excepttype_i != 32'b0;
assign is_interrupt = (((cp0_cause_i[15:8] & (cp0_status_i[15:8])) != 8'h00) && (cp0_status_i[1] == 1'b0) && (cp0_status_i[0] == 1'b1))
                  &(~mem_pc_flush)  ;

//异常和中断的区别就是回写是否执行，异常的逻辑为不执行回写，直接把EPC的值指向next，相当于略过这一条产生异常的指令
//中断的逻辑为执行回写，相当于在触发中断flush之前执行完此条指令
//由于异常的指令都没有回写功能，所以中断和异常同意逻辑，都进行回写

assign exception_en = is_new_pc&(is_exception|(is_interrupt));
assign pc_next = exception_en?
                    is_slot?mem_pc_jump_last:mem_pc
                    :{`InstAddrBusWidth{1'b0}};
assign excepttype_o = is_exception?excepttype_i: 
                        is_interrupt? `EXCEPTION_INT :32'b0;

endmodule

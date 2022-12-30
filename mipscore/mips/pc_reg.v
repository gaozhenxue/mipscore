`include "defines.v"

module pc_reg(
    output [`InstAddrBusWidth-1:0]		   pc,
	output                                 ce,

	input                                  oitf_match,
	input  [5:0]                           pause,
	
	//pc flash
    input  [`InstAddrBusWidth-1:0]         pc_jump,
	input                                  pc_flush,
	
	//exception pc flash
    input  [`InstAddrBusWidth-1:0]         pc_exception_jump,
	input                                  pc_exception_flush,

	input                                  clk,
    input  							       rst_n
);
wire pc_en;
assign pc_en = (~oitf_match)&(~pause[0]);


wire[`InstAddrBusWidth-1:0]			 pc_next;
wire[`InstAddrBusWidth-1:0]			 pc_current;
wire flash_en = ((pc_flush!==1'bX&pc_flush!==1'bZ)&pc_flush);
wire flash_exception_en = ((pc_exception_flush!==1'bX&pc_exception_flush!==1'bZ)&pc_exception_flush);

assign pc_next = pc_en ?pc + 4'h4:pc;

assign pc = flash_exception_en?pc_exception_jump:
                        flash_en?pc_jump:pc_current;

gnrl_dfflr #(`InstAddrBusWidth) pc_dfflr ((ce&pc_en|flash_en), pc_next, pc_current, clk, rst_n);


wire ce_pre;

assign ce = ce_pre&pc_en;//&(~flash_exception_en);

gnrl_dfflr #(1) ce_dfflr (1'b1, 1'b1, ce_pre, clk, rst_n);

endmodule

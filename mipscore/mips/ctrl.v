`include "defines.v"

module ctrl(
    input                              exception_en,
	input  [`ExceptionTypeWidth-1:0]   excepttype_i,
	input  [`RegWidth-1:0]             cp0_epc_i,

	output [`RegWidth-1:0]             pc_exception_jump,
	output                             pc_exception_flush,	

    //来自译码阶段的暂停请求
	input                              pausereq_from_id,

    //来自执行阶段的暂停请求
	input                              pausereq_from_ex,
	
	//输出暂停标识
	output [5:0]                       pause,
	
	input                              rst_n
);
wire [5:0]             stall_next;

assign pause = ({6{pausereq_from_id}}&6'b000011)
               |({6{pausereq_from_ex}}&6'b001111)
               ;
    //gnrl_dfflr #(6) pc_dfflr (1'b1, stall_next, pause, clk, rst_n);

assign pc_exception_flush = exception_en;

assign pc_exception_jump = {`RegWidth{exception_en}}&
                            (
                            ({`RegWidth{excepttype_i== `EXCEPTION_INT}}&32'h00000020)
                            |({`RegWidth{excepttype_i== `EXCEPTION_SYSCALL}}&32'h00000040)
                            |({`RegWidth{excepttype_i== `EXCEPTION_RI}}&32'h00000040)
                            |({`RegWidth{excepttype_i== `EXCEPTION_OV}}&32'h00000040)
                            |({`RegWidth{excepttype_i== `EXCEPTION_TR}}&32'h00000040)
                            |({`RegWidth{excepttype_i== `EXCEPTION_ERET}}&cp0_epc_i)
                            )
                            ;
endmodule

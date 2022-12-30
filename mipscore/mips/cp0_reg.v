`include "defines.v"
module cp0_reg(

	input                                  we_i,
	input      [4:0]                       waddr_i,
	input      [`RegWidth-1:0]             data_i,
	
	input                                  rd_i,
	input      [4:0]                       raddr_i,
	output     [`RegWidth-1:0]             data_o,
	
	input      [5:0]                       int_i,
	
	output     [`RegWidth-1:0]             count_o,
	output     [`RegWidth-1:0]             compare_o,
	output     [`RegWidth-1:0]             status_o,
	output     [`RegWidth-1:0]             cause_o,
	output     [`RegWidth-1:0]             epc_o,
	output     [`RegWidth-1:0]             config_o,
	output     [`RegWidth-1:0]             prid_o,
               
	output                                 timer_int_o,
	
	//“Ï≥£œ‡πÿ
    input                                  exception_en,
    input                                  is_exception,
    input                                  is_interrupt,
	input [`ExceptionTypeWidth-1:0]        excepttype_i,
	input [`InstAddrBusWidth-1:0]	       pc_next,
	input                                  is_slot,

    input						           clk,
	input 						           rst_n
);

wire compare_ena = we_i&(waddr_i==`CP0_REG_COMPARE);
gnrl_dfflr #(`RegWidth)    compare_dfflr (compare_ena, data_i, compare_o, clk, rst_n);


wire        count_ena = we_i&(waddr_i==`CP0_REG_COUNT);
wire [`RegWidth-1:0] count_next = compare_ena?1'b0:
                                    count_ena?data_i:count_o+1'b1;
gnrl_dfflr #(`RegWidth)    count_dfflr (1'b1, count_next, count_o, clk, rst_n);



wire status_ena = we_i&(waddr_i==`CP0_REG_STATUS);
wire [`RegWidth-1:0] status_next = ({`RegWidth{status_ena}}&data_i)
                                    |({`RegWidth{exception_en&(excepttype_i != `EXCEPTION_ERET)}}&(status_o|32'h0000_0002))
                                    |({`RegWidth{exception_en&(excepttype_i == `EXCEPTION_ERET)}}&(status_o&32'hFFFF_FFFD))
                                    ;
gnrl_dfflrd #(`RegWidth)   status_dfflr (status_ena|exception_en, status_next, status_o, 32'b00010000000000000000000000000000, clk, rst_n);

wire cause_ena = we_i&(waddr_i==`CP0_REG_CAUSE);
//cause_o[15:10]
wire [`RegWidth-1:0] cause_next = ({`RegWidth{cause_ena}}&{cause_o[`RegWidth-1:24],data_i[23:22],cause_o[21:10], data_i[9:8],cause_o[7:0]})
                                    |{cause_o[`RegWidth-1:16],int_i, cause_o[9:0]}
                                    |({`RegWidth{exception_en&is_interrupt}}&{is_slot, cause_o[30:7], 5'b00000,cause_o[1:0]})
                                    |({`RegWidth{exception_en&is_exception&(excepttype_i != `EXCEPTION_ERET)}}&{(status_o[1] == 1'b0)?is_slot:cause_o[31], cause_o[30:7], excepttype_i[4:0],cause_o[1:0]})
                                    ;
gnrl_dfflr #(`RegWidth)    cause_dfflr (1'b1, cause_next, cause_o, clk, rst_n);

wire epc_we = we_i&(waddr_i==`CP0_REG_EPC);
wire epc_int = exception_en&is_interrupt;
wire epc_exception = exception_en&is_exception&(status_o[1] == 1'b0)&(excepttype_i != `EXCEPTION_ERET);
wire epc_ena = epc_we|epc_int|epc_exception;
wire [`RegWidth-1:0] epc_next = (
                                ({`RegWidth{epc_we}}&data_i)
                                |({`RegWidth{epc_int}}&pc_next)
                                |({`RegWidth{epc_exception}}&pc_next)
                                );
gnrl_dfflr #(`RegWidth)    epc_dfflr (epc_ena, epc_next, epc_o, clk, rst_n);

//wire config_ena = we_i&(waddr_i==`CP0_REG_CONFIG);
gnrl_dfflrd #(`RegWidth)   config_dfflr (1'b0, data_i, config_o, 32'b00000000000000001000000000000000, clk, rst_n);

//wire prid_ena = we_i&(waddr_i==`CP0_REG_PrId);
gnrl_dfflrd #(`RegWidth)   prid_dfflr (1'b0, data_i, prid_o, 32'b00000000010011000000000100000010, clk, rst_n);

wire timer_int_condition = (compare_o != `ZeroWord && count_o == compare_o);
wire timer_int_cancel_condition = compare_ena;//exception_en;
wire timer_int_ena = timer_int_cancel_condition|timer_int_condition;
wire timer_int_next = (~timer_int_cancel_condition)|timer_int_condition;
gnrl_dfflr #(1)    timer_int_dfflr (timer_int_ena, timer_int_next, timer_int_o, clk, rst_n);


assign data_o = {`RegWidth{rd_i}}&(
                                    ({`RegWidth{(raddr_i==`CP0_REG_COUNT)}}&count_o)
                                    |({`RegWidth{(raddr_i==`CP0_REG_COMPARE)}}&compare_o)
                                    |({`RegWidth{(raddr_i==`CP0_REG_STATUS)}}&status_o)
                                    |({`RegWidth{(raddr_i==`CP0_REG_CAUSE)}}&cause_o)
                                    |({`RegWidth{(raddr_i==`CP0_REG_EPC)}}&epc_o)
                                    |({`RegWidth{(raddr_i==`CP0_REG_CONFIG)}}&config_o)
                                    |({`RegWidth{(raddr_i==`CP0_REG_PrId)}}&prid_o)
                                    )
                                    ;
endmodule

`include "defines.v"

module min_sopc(

	input	wire										clk,
    input   wire										rst_n
	
);

wire[`InstAddrBusWidth-1:0] inst_addr;
wire[`InstBusWidth-1:0] inst;
wire rom_ce;

	//与数据ram的接口
wire     [`DataAddrBusWidth-1:0]        mem_addr_o;
wire	                                 mem_we_o;
wire	 [3:0]				             mem_sel_o;
wire	 [`RegWidth-1:0]                 mem_data_o;
wire	                                 mem_ce_o;
wire	 [`RegWidth-1:0]                 mem_data_i;
wire    [5:0]                           int;
wire                                    timer_int;
 
  //assign int = {5'b00000, timer_int, gpio_int, uart_int};
  assign int = {5'b00000, timer_int};



mipscore u_mipscore(
    .rom_addr_o(inst_addr),
    .rom_data_i(inst),
    .rom_ce_o(rom_ce),
    
    //与数据ram的接口
    .mem_addr_o(mem_addr_o),
	.mem_we_o(mem_we_o),
	.mem_sel_o(mem_sel_o),
	.mem_data_o(mem_data_o),
	.mem_ce_o(mem_ce_o),
	.mem_data_i(mem_data_i),
	
	
	.int_i(int),
	.timer_int_o(timer_int),
	
	
    .clk(clk),
    .rst_n(rst_n)


);

rom#
(
    .DLY(0),
    .RAM_WIDTH(`InstBusWidth),
    .RAM_DEPTH(65536),
    .ADDR_WIDTH(16)
)
u_rom
(
    .wr_clk(),
    .wr_en(),
    .wr_addr(),
    .wr_data(),
    
    .rd_clk(clk),
    .rd_en(rom_ce),
    .rd_addr(inst_addr[17:2]),
    .rd_data(inst),

    .rst_n(rst_n)
);

ram#
(
    .DLY(0),
    .RAM_WIDTH(`InstBusWidth),
    .RAM_DEPTH(65536),
    .ADDR_WIDTH(16),
    .MASK_WIDTH(4)
)
u_ram
(
    .wr_clk(clk),
    .wr_en(mem_we_o&mem_ce_o),
    .wr_addr(mem_addr_o[17:2]),
    .wr_data(mem_data_o),
    .mask(mem_sel_o),
    
    .rd_clk(clk),
    .rd_en((~mem_we_o)&mem_ce_o),
    .rd_addr(mem_addr_o[17:2]),
    .rd_data(mem_data_i)
    
);

endmodule

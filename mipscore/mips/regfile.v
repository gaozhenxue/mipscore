`include "defines.v"

module regfile(
	//Ð´¶Ë¿Ú
	input  wire								     we,
	input  wire[`RegAddrBusWidth-1:0]		     waddr,
	input  wire[`RegWidth-1:0]				     wdata,
	
	//¶Á¶Ë¿Ú1
	input  wire								     re1,
	input  wire[`RegAddrBusWidth-1:0]		     raddr1,
	output wire[`RegWidth-1:0]                   rdata1,
	
	//¶Á¶Ë¿Ú2
	input  wire								     re2,
	input  wire[`RegAddrBusWidth-1:0]		     raddr2,
	output wire[`RegWidth-1:0]                  rdata2,
	

    input	wire					             clk,
	input   wire					             rst_n
	
);

reg[`RegWidth-1:0]  regs[0:`RegNum-1];


always@(posedge clk)
begin
    if(we)
        regs[waddr] <=  wdata;
end

assign rdata1 = regs[raddr1];
assign rdata2 = regs[raddr2];


endmodule

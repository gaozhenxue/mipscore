`include "defines.v"

module reghilo(
	//д�˿�hi
	input  wire								     wehi,
	input  wire[`RegWidth-1:0]				     wdatahi,
	
	//д�˿�lo
	input  wire								     welo,
	input  wire[`RegWidth-1:0]				     wdatalo,
	
	//���˿�hi
	input  wire								     rehi,
	output wire[`RegWidth-1:0]                  rdatahi,
	
	//���˿�lo
	input  wire								     relo,
	output wire[`RegWidth-1:0]                  rdatalo,
	

    input	wire					             clk,
	input   wire					             rst_n
	
);

reg[`RegWidth-1:0]  reghi;
reg[`RegWidth-1:0]  reglo;


always@(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        reghi <=  'b0;
    else if(wehi)
        reghi <=  wdatahi;
end

always@(posedge clk)
begin
    if(rst_n == 1'b0)
        reglo <=  'b0;
    else if(welo)
        reglo <=  wdatalo;
end

assign rdatahi = {`RegWidth{rehi}}&reghi;
assign rdatalo = {`RegWidth{relo}}&reglo;


endmodule

`timescale 1ns / 1ps

module regLLbit(
	//д�˿�lo
	input  								     weLLbit,
	input                  				     wdataLLbit,
	
	//���˿�lo
	input  							         reLLbit,
	output                                   rdataLLbit,
	

    input						             clk,
	input   					             rst_n
    );
    reg LLbit;
    always@(posedge clk)
    begin
        if(rst_n == 1'b0)
            LLbit <=  'b0;
        else if(weLLbit)
            LLbit <=  wdataLLbit;
    end
    
    assign rdataLLbit = {{reLLbit}}&LLbit;

    
endmodule

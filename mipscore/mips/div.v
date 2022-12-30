`include "defines.v"

module div(

	input                           signed_div_i,
	input [`RegWidth-1:0]           opdata1_i,
	input [`RegWidth-1:0]  		    opdata2_i,
	input                           start_i,
	input                           annul_i,
	
	output [`DoubleRegWidth-1:0]    result_o,
	output 			                ready_o,
	
    input                           clk,
	input 						    rst_n

    );


wire[32:0] div_temp;
wire[5:0]  cnt;
wire[64:0] dividend;
wire[1:0]  div_curr_state;
wire[1:0]  div_nxt_state;
wire[31:0] divisor;	 
wire[31:0] temp_op1;
wire[31:0] temp_op2;
	
	
wire [1:0] state_divfree_nxt;
wire [1:0] state_divbyzero_nxt;
wire [1:0] state_divon_nxt;
wire [1:0] state_divend_nxt;

wire state_divfree_ena;
wire state_divbyzero_ena;
wire state_divon_ena;
wire state_divend_ena;

wire dc_sta_is_divfree              = (div_curr_state == `DivFree       );
wire dc_sta_is_divbyzero            = (div_curr_state == `DivByZero     );
wire dc_sta_is_divon                = (div_curr_state == `DivOn         );
wire dc_sta_is_divend               = (div_curr_state == `DivEnd        );



assign state_divfree_ena = dc_sta_is_divfree&((start_i == `DivStart && annul_i == 1'b0));
assign state_divfree_nxt = (opdata2_i == `ZeroWord)?`DivByZero:`DivOn
                            ;

assign state_divbyzero_ena = dc_sta_is_divbyzero;
assign state_divbyzero_nxt = `DivEnd;

wire  state_divon_canel_ena = dc_sta_is_divon&(annul_i != 1'b0);
wire  state_divon_calc_ena = dc_sta_is_divon&(~state_divon_canel_ena)&(cnt != 6'b100000);
wire  state_divon_calc_end_ena = dc_sta_is_divon&(~state_divon_canel_ena)&(cnt == 6'b100000);
assign state_divon_ena = (state_divon_canel_ena|state_divon_calc_end_ena);
assign state_divon_nxt = (({2{state_divon_canel_ena}})&`DivFree)
                        |(({2{state_divon_calc_end_ena}})&`DivEnd)
                        ;

assign state_divend_ena = dc_sta_is_divend&(start_i == `DivStop);
assign state_divend_nxt = `DivFree;

wire div_state_ena = 
                state_divfree_ena     |state_divbyzero_ena    |state_divon_ena |state_divend_ena
                ;
                
assign div_nxt_state = 
              ({2{state_divfree_ena             }} & state_divfree_nxt          )
            | ({2{state_divbyzero_ena           }} & state_divbyzero_nxt        )
            | ({2{state_divon_ena               }} & state_divon_nxt            )
            | ({2{state_divend_ena              }} & state_divend_nxt           )
            ;

gnrl_dfflr #(2)         state_dfflr (div_state_ena, div_nxt_state, div_curr_state, clk, rst_n);

assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};


assign temp_op1 = {32{state_divfree_ena}}
                &((signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 )?~opdata1_i + 1:opdata1_i);

assign temp_op2 = {32{state_divfree_ena}}
                &((signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 )?~opdata2_i + 1:opdata2_i);


wire dividend_init_ena = (state_divfree_ena&(opdata2_i != `ZeroWord));
wire dividend_divbyzero_ena = state_divbyzero_ena;
wire dividend_divon_calc_ena = state_divon_calc_ena;
wire dividend_divon_calc_end_ena = state_divon_calc_end_ena;

wire dividend_ena = dividend_init_ena
                    |dividend_divbyzero_ena
                    |dividend_divon_calc_ena
                    |dividend_divon_calc_end_ena
                    ;
wire [31:0] dividend_next_lo =  (dividend_divon_calc_end_ena&&(signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1))? (~dividend[31:0] + 1):dividend[31:0];
wire [31:0] dividend_next_hi =  (dividend_divon_calc_end_ena&&(signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1))? (~dividend[64:33] + 1):dividend[64:33];
wire [64:0] dividend_next = (({65{dividend_init_ena}})&{32'b0,temp_op1,1'b0})
                            |(({65{dividend_divbyzero_ena}})&{1'b0,`ZeroWord,`ZeroWord})
                            |(({65{dividend_divon_calc_ena&(div_temp[32] == 1'b1)}})&{dividend[63:0] , 1'b0})
                            |(({65{dividend_divon_calc_ena&(div_temp[32] == 1'b0)}})&{div_temp[31:0] , dividend[31:0] , 1'b1})
                            |(({65{dividend_divon_calc_end_ena}})&{dividend_next_hi, 1'b0, dividend_next_lo})
                             ;

gnrl_dfflr #(65)        dividend_dfflr (dividend_ena, dividend_next, dividend, clk, rst_n);

wire cnt_ena = state_divon_calc_ena|dividend_init_ena|state_divon_calc_end_ena;
wire [5:0] cnt_next = ({6{state_divon_calc_ena}})&(cnt + 1'b1);
gnrl_dfflr #(6)        cnt_dfflr (cnt_ena, cnt_next, cnt, clk, rst_n);


wire divisor_init_ena = dividend_init_ena;
wire divisor_ena = divisor_init_ena;
wire [31:0] divisor_next = (({32{divisor_init_ena}})&temp_op2);

gnrl_dfflr #(32)        divisor_dfflr (divisor_ena, divisor_next, divisor, clk, rst_n);

                
wire result_init_ena = ((~state_divfree_ena)&dc_sta_is_divfree);
wire result_divend_ena = dc_sta_is_divend&(start_i != `DivStop);
wire result_divend_out_ena = state_divend_ena;
wire result_ena = result_init_ena|result_divend_ena|result_divend_out_ena;
wire [63:0] result_next = (({64{result_init_ena|result_divend_out_ena}})&{`ZeroWord,`ZeroWord})
                            |(({64{result_divend_ena}})&{dividend[64:33], dividend[31:0]})
                            ;

gnrl_dfflr #(64)        result_dfflr (result_ena, result_next, result_o, clk, rst_n);


wire ready_next = ((result_init_ena|result_divend_out_ena)&`DivResultNotReady)
                    |(result_divend_ena&`DivResultReady)
                    ;


gnrl_dfflr #(1)         ready_dfflr (result_ena, ready_next, ready_o, clk, rst_n);

endmodule

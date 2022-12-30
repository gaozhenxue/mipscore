// ===========================================================================
//
// Description:
//  Verilog module gnrl sgnl
//  signal to delay and widen
//
// ===========================================================================


module gnrl_sgnl_delay_widen(
    input               pulse_i,        //��������
    output              pulse_o,        //�������?
    
    input   [11:0]      delay_num,      //�ź���ʱclock����
    input   [3:0]       widen_num,      //չ��clock����
    
    input               clk,
    input               rst_n
    );
    
reg     [11:0]      delay_num_reg;
reg     [3:0]       widen_num_reg;
reg                 pulse_enable;
reg                 pulse_o_reg;

assign pulse_o = pulse_o_reg;
always @ (posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        delay_num_reg <= 12'b0;
        pulse_enable  <= 1'b0;
        widen_num_reg <= 4'b0;
        pulse_o_reg  <= 1'b0;
    end
    else if(pulse_i == 'b1) begin
        delay_num_reg <= 12'b0;
        pulse_enable  <= 1'b1;
    end
    else if(delay_num_reg == delay_num) begin
        pulse_o_reg <= 1'b1;
        pulse_enable  <= 1'b0;
        widen_num_reg <= widen_num_reg + 'b1;
        if(widen_num_reg == widen_num)
            delay_num_reg <= 12'b0;
        else
            delay_num_reg <= delay_num_reg;
    end
    else if(pulse_enable == 'b1) begin
        delay_num_reg <= delay_num_reg + 'b1;
    end
    else begin
        delay_num_reg <= delay_num_reg;
        pulse_enable <= pulse_enable;
        pulse_o_reg <= 1'b0;
    end
end

    
endmodule

// ===========================================================================
//
// Description:
//  Verilog module gnrl sgnl
//  signal to (postive or negtive)edge probe
//
// ===========================================================================

module gnrl_sgnl_edge_probe(
	input clk,
	input signal,
	input polarity,//test pos or nege
	
	output res
    );
		reg signal_delay1;
		reg res_internal;
        assign res = res_internal;
 always @(posedge clk)
 begin
	   signal_delay1 <= signal;
 end
 
 always@*
 begin
 case (polarity)
 	1'b1:
 		res_internal = signal&(~signal_delay1);
 	1'b0:
 	   	res_internal = signal_delay1&(~signal);
 	default:
 		res_internal = signal&(~signal_delay1);
 	endcase
 end
endmodule


// ===========================================================================
//
// Description:
//  Verilog module gnrl sgnl
//  signal counter
//  counter_pulseand clk must be in the same CD
// ===========================================================================

module gnrl_sgnl_counter # (
  parameter CW = 15
) (
	input          clk,
	input          start_pulse,
	input          counter_pulse,
	input [CW-1:0] counter,
	
	output [CW-1:0] currentcount,
	
	output         res
    );
wire            start_pulse_final;
wire  [CW-1:0]  current_count;
wire  [CW-1:0]  next_count;
wire            next_count_ena;
gnrl_sgnl_edge_probe signal_edge_probe_counter (
  .clk(clk),            // input wire clk
  .signal(start_pulse),      // input wire signal
  .polarity(1'b1),  // input wire polarity
  .res(start_pulse_final)            // output wire res
);
//assign res = ~next_count_ena; 
assign next_count_ena = (current_count < counter);
assign next_count = current_count + 1'b1;
gnrl_dfflr #(CW) dc_current_state_dfflr (next_count_ena, next_count, current_count, counter_pulse, ~start_pulse_final);

//gnrl_sgnl_edge_probe signal_edge_probe_res (
//  .clk(clk),            // input wire clk
//  .signal(current_count >= counter),      // input wire signal
//  .polarity(1'b1),  // input wire polarity
//  .res(res)            // output wire res
//);
assign res = current_count >= counter;
assign currentcount = current_count;

endmodule
// ===========================================================================
//
// Description:
//  Verilog module gnrl sgnl
//  signal to (postive or negtive)edge probe
//
// ===========================================================================

module gnrl_sgnl_pulse2level(

	input clk,
	input pulse4high,
	input pulse4low,
	
	output res,
    input rst_n
);
wire    pulse4high_wire;
wire    pulse4low_wire;
gnrl_sgnl_edge_probe signal_edge_probe_pulse4high (
  .clk(clk),            // input wire clk
  .signal(pulse4high),      // input wire signal
  .polarity(1'b1),  // input wire polarity
  .res(pulse4high_wire)            // output wire res
);

gnrl_sgnl_edge_probe signal_edge_probe_pulse4low (
  .clk(clk),            // input wire clk
  .signal(pulse4low),      // input wire signal
  .polarity(1'b1),  // input wire polarity
  .res(pulse4low_wire)            // output wire res
);
wire res_next_ena = pulse4high_wire|pulse4low_wire;
wire res_next = pulse4high_wire|(~pulse4low_wire);
wire res_tmp;
gnrl_dfflr #(10) res_dfflr (res_next_ena, res_next, res_tmp, clk, rst_n);

assign res = res_next_ena?res_next:res_tmp;

endmodule
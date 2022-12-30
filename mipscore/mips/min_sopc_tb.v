`include "../../sources_1/new/defines.v"
`timescale 1ns/1ps


`define ITCM u_min_sopc.u_rom
`define ITCMDATA u_min_sopc.u_ram
`define REGFILE u_min_sopc.u_mipscore.u_regfile


module min_sopc_tb();


parameter T = 10;       //100M

  reg     main_clk;
  reg     rst_n;
  
       
  initial begin
    main_clk = 1'b0;
    rst_n = 1'b0;
    
    #100 rst_n = 1'b1;
    //#1000 $stop;
    end

        integer i;
        reg [31:0] itcm_mem [0:65535];
        
initial begin
      //$readmemh({testcase, ".verilog"}, itcm_mem);//D:\Work\IC\NucleiStudio_workspace\test\Debug\test.verilog
        $readmemh( "E:/Study/IC/CPU/OpenMIPS/OpenMIPS_simulation/inst_rom.data", itcm_mem);
      for (i=0;i<65536;i=i+1) begin
          `ITCM.memory[i] = itcm_mem[i];
      end
        $readmemh( "E:/Study/IC/CPU/OpenMIPS/OpenMIPS_simulation/inst_rom.rodata", itcm_mem);
      for (i=0;i<65536;i=i+1) begin
          `ITCMDATA.memory[i] = itcm_mem[i];
      end

        $display("ITCM 0x00: %h", `ITCM.memory[16'h00]);
        $display("ITCM 0x01: %h", `ITCM.memory[16'h01]);
        $display("ITCM 0x02: %h", `ITCM.memory[16'h02]);
        $display("ITCM 0x03: %h", `ITCM.memory[16'h03]);
        $display("ITCM 0x04: %h", `ITCM.memory[16'h04]);
        $display("ITCM 0x05: %h", `ITCM.memory[16'h05]);
        $display("ITCM 0x06: %h", `ITCM.memory[16'h06]);
        $display("ITCM 0x07: %h", `ITCM.memory[16'h07]);
        $display("ITCM 0x16: %h", `ITCM.memory[16'h16]);
        $display("ITCM 0x20: %h", `ITCM.memory[16'h20]);
        
        
        
      for (i=0;i<`RegNum;i=i+1) begin
          `REGFILE.regs[i] = `RegWidth'b0;
      end

end

always	#(T/2) main_clk = ~main_clk;

min_sopc u_min_sopc(
    .clk(main_clk),
    .rst_n(rst_n)	
);

endmodule
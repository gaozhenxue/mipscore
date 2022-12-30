`include "defines.v"

module oitfcp0(
    //fifo的变化
    input                              cp0_wreg,
    input  [`RegAddrBusWidth-1:0]      cp0_wreg_i_rdidx,
   
    input                              cp0_wreg_wb,
    input [`RegAddrBusWidth-1:0]       cp0_wreg_wb_i_rdidx,
    
    input                              cp0_readen,
    input  [`RegAddrBusWidth-1:0]      cp0_readidx,
     
    //fifo的比对及结果
    output                             cp0_oitfrd_match_disprs,
   
	input 							   clk,
	input 							   rst_n
);
    
    wire [`OitfDepth-1:0] vld_set;
    wire [`OitfDepth-1:0] vld_clr;
    wire [`OitfDepth-1:0] vld_ena;
    wire [`OitfDepth-1:0] vld_nxt;
    wire [`OitfDepth-1:0] vld_r;
    wire [`RegAddrBusWidth-1:0] rdidx_r[`OitfDepth-1:0];

    wire [`OitfWidth-1:0] alc_ptr_r;
    wire [`OitfWidth-1:0] ret_ptr_r;
  
    wire [`OitfWidth-1:0] alc_ptr_nxt; 
    wire [`OitfWidth-1:0] ret_ptr_nxt; 

    wire alc_ptr_ena = cp0_wreg;
    wire ret_ptr_ena = cp0_wreg_wb;
        
    
    assign alc_ptr_nxt = alc_ptr_ena ? (alc_ptr_r + 1'b1) :`OitfWidth'b0 ;
      
    gnrl_dfflr #(`RegAddrBusWidth) alc_ptr_dfflrs(cp0_wreg, alc_ptr_nxt, alc_ptr_r, clk, rst_n);
    
    assign ret_ptr_nxt = ret_ptr_ena ? (ret_ptr_r + 1'b1) :`OitfWidth'b0 ;

    gnrl_dfflr #(`RegAddrBusWidth) ret_ptr_dfflrs(ret_ptr_ena, ret_ptr_nxt, ret_ptr_r, clk, rst_n);
    
  wire [`OitfDepth-1:0] rd_match_rs1idx;

  genvar i;
  generate //{
      for (i=0; i<`OitfDepth; i=i+1) begin:oitf_entries//{
        
        assign vld_set[i] = alc_ptr_ena & (alc_ptr_r == i);
        assign vld_clr[i] = ret_ptr_ena & (ret_ptr_r == i)&(rdidx_r[i] == cp0_wreg_wb_i_rdidx);
        assign vld_ena[i] = vld_set[i] |   vld_clr[i];
        assign vld_nxt[i] = vld_set[i] | (~vld_clr[i]);
  
        gnrl_dfflr #(1) vld_dfflrs(vld_ena[i], vld_nxt[i], vld_r[i], clk, rst_n);
        //Payload only set, no need to clear
        gnrl_dffl #(`RegAddrBusWidth) rdidx_dfflrs(vld_set[i], cp0_wreg_i_rdidx, rdidx_r[i], clk);
        
        
        assign rd_match_rs1idx[i] = vld_r[i] & cp0_readen & (rdidx_r[i] == cp0_readidx);
  
      end//}
  endgenerate//}
  
    assign cp0_oitfrd_match_disprs = |rd_match_rs1idx;
endmodule

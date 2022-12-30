`include "defines.v"

module oitfhi(
    //fifo的变化
    input                              wreg,
   
    input                              wreg_wb,
    
    //fifo的比对及结果
    
    input                              readenhi,
     
    output                             oitfhi_match,
   
   
	input 							   clk,
	input 							   rst_n
);
    
    wire [`OitfDepth-1:0] vld_set;
    wire [`OitfDepth-1:0] vld_clr;
    wire [`OitfDepth-1:0] vld_ena;
    wire [`OitfDepth-1:0] vld_nxt;
    wire [`OitfDepth-1:0] vld_r;

    wire [`OitfWidth-1:0] alc_ptr_r;
    wire [`OitfWidth-1:0] ret_ptr_r;
  
    wire [`OitfWidth-1:0] alc_ptr_nxt; 
    wire [`OitfWidth-1:0] ret_ptr_nxt; 

    wire alc_ptr_ena = wreg;
    wire ret_ptr_ena = wreg_wb;
        
    
    assign alc_ptr_nxt = alc_ptr_ena ? (alc_ptr_r + 1'b1) :`OitfWidth'b0 ;
      
    gnrl_dfflr #(`RegAddrBusWidth) alc_ptr_dfflrs(alc_ptr_ena, alc_ptr_nxt, alc_ptr_r, clk, rst_n);
    
    assign ret_ptr_nxt = ret_ptr_ena ? (ret_ptr_r + 1'b1) :`OitfWidth'b0 ;

    gnrl_dfflr #(`RegAddrBusWidth) ret_ptr_dfflrs(ret_ptr_ena, ret_ptr_nxt, ret_ptr_r, clk, rst_n);
    
  wire [`OitfDepth-1:0] rd_match_rs1idx;

  genvar i;
  generate //{
      for (i=0; i<`OitfDepth; i=i+1) begin:oitf_entries//{
        
        assign vld_set[i] = alc_ptr_ena & (alc_ptr_r == i);
        assign vld_clr[i] = ret_ptr_ena & (ret_ptr_r == i);
        assign vld_ena[i] = vld_set[i] |   vld_clr[i];
        assign vld_nxt[i] = vld_set[i] | (~vld_clr[i]);
  
        gnrl_dfflr #(1) vld_dfflrs(vld_ena[i], vld_nxt[i], vld_r[i], clk, rst_n);
        
        
        assign rd_match_rs1idx[i] = vld_r[i] & readenhi;
  
      end//}
  endgenerate//}
  
    assign oitfhi_match = |rd_match_rs1idx;
 

endmodule

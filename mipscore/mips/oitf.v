`include "defines.v"

module oitf(
    //fifo的变化
    input                              wreg,
    input  [`RegAddrBusWidth-1:0]             wreg_i_rdidx,
   
    input                              wreg_wb,
    input [`RegAddrBusWidth-1:0]             wreg_wb_i_rdidx,
    
    //fifo的比对及结果
    
    input                              readen1,
    input  [`RegAddrBusWidth-1:0]             readidx1,
    input                              readen2,
    input  [`RegAddrBusWidth-1:0]             readidx2,
     
    output                             oitfrd_match_disprs1,
    output                             oitfrd_match_disprs2,
   
   
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

    wire alc_ptr_ena = wreg;//&(wreg_i_rdidx!=`RegAddrBusWidth'b0);
    wire ret_ptr_ena = wreg_wb;//&(wreg_wb_i_rdidx!=`RegAddrBusWidth'b0);
        
    
    assign alc_ptr_nxt = alc_ptr_ena ? (alc_ptr_r + 1'b1) :`OitfWidth'b0 ;
      
    gnrl_dfflr #(`RegAddrBusWidth) alc_ptr_dfflrs(wreg, alc_ptr_nxt, alc_ptr_r, clk, rst_n);
    
    assign ret_ptr_nxt = ret_ptr_ena ? (ret_ptr_r + 1'b1) :`OitfWidth'b0 ;

    gnrl_dfflr #(`RegAddrBusWidth) ret_ptr_dfflrs(ret_ptr_ena, ret_ptr_nxt, ret_ptr_r, clk, rst_n);
    
  wire [`OitfDepth-1:0] rd_match_rs1idx;
  wire [`OitfDepth-1:0] rd_match_rs2idx;

  genvar i;
  generate //{
      for (i=0; i<`OitfDepth; i=i+1) begin:oitf_entries//{
        
        assign vld_set[i] = alc_ptr_ena & (alc_ptr_r == i);
        assign vld_clr[i] = ret_ptr_ena & (ret_ptr_r == i)&(rdidx_r[i] == wreg_wb_i_rdidx);
        assign vld_ena[i] = vld_set[i] |   vld_clr[i];
        assign vld_nxt[i] = vld_set[i] | (~vld_clr[i]);
  
        gnrl_dfflr #(1) vld_dfflrs(vld_ena[i], vld_nxt[i], vld_r[i], clk, rst_n);
        //Payload only set, no need to clear
        gnrl_dffl #(`RegAddrBusWidth) rdidx_dfflrs(vld_set[i], wreg_i_rdidx, rdidx_r[i], clk);
        
        
        assign rd_match_rs1idx[i] = vld_r[i] & readen1 & (rdidx_r[i] == readidx1);
        assign rd_match_rs2idx[i] = vld_r[i] & readen2 & (rdidx_r[i] == readidx2);
  
      end//}
  endgenerate//}
  
    assign oitfrd_match_disprs1 = |rd_match_rs1idx;
    assign oitfrd_match_disprs2 = |rd_match_rs2idx;
 

endmodule

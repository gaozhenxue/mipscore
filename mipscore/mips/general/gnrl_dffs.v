// ===========================================================================
//
// Description:
//  Verilog module gnrl DFF with Load-enable and Reset
//  Default reset value is def
//
// ===========================================================================

module gnrl_dfflrd # (
  parameter DW = 32
) (

  input               lden, 
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,
  input      [DW-1:0] def,
  
  input               clk,
  input               rst_n
);

reg [DW-1:0] qout_r;

always @(posedge clk or negedge rst_n)
begin : DFFLRS_PROC
  if (rst_n == 1'b0)
    qout_r <= def;
  else if (lden == 1'b1)
    qout_r <= dnxt;
end

assign qout = qout_r;

endmodule
// ===========================================================================
//
// Description:
//  Verilog module gnrl DFF with Load-enable and Reset
//  Default reset value is 1
//
// ===========================================================================

module gnrl_dfflrs # (
  parameter DW = 32
) (

  input               lden, 
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
);

reg [DW-1:0] qout_r;

always @(posedge clk or negedge rst_n)
begin : DFFLRS_PROC
  if (rst_n == 1'b0)
    qout_r <= {DW{1'b1}};
  else if (lden == 1'b1)
    qout_r <= dnxt;
end

assign qout = qout_r;

endmodule
// ===========================================================================
//
// Description:
//  Verilog module gnrl DFF with Load-enable and Reset
//  Default reset value is 0
//
// ===========================================================================

module gnrl_dfflr # (
  parameter DW = 32
) (

  input               lden, 
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
);

reg [DW-1:0] qout_r;

always @(posedge clk or negedge rst_n)
begin : DFFLR_PROC
  if (rst_n == 1'b0)
    qout_r <= {DW{1'b0}};
  else if (lden == 1'b1)
    qout_r <= dnxt;
end

assign qout = qout_r;

endmodule
// ===========================================================================
//
// Description:
//  Verilog module gnrl DFF with Load-enable, no reset 
//
// ===========================================================================

module gnrl_dffl # (
  parameter DW = 32
) (

  input               lden, 
  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk 
);

reg [DW-1:0] qout_r;

always @(posedge clk)
begin : DFFL_PROC
  if (lden == 1'b1)
    qout_r <= dnxt;
end

assign qout = qout_r;

endmodule
// ===========================================================================
//
// Description:
//  Verilog module gnrl DFF with Reset, no load-enable
//  Default reset value is 1
//
// ===========================================================================

module gnrl_dffrs # (
  parameter DW = 32
) (

  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
);

reg [DW-1:0] qout_r;

always @(posedge clk or negedge rst_n)
begin : DFFRS_PROC
  if (rst_n == 1'b0)
    qout_r <= {DW{1'b1}};
  else                  
    qout_r <=dnxt;
end

assign qout = qout_r;

endmodule
// ===========================================================================
//
// Description:
//  Verilog module gnrl DFF with Reset, no load-enable
//  Default reset value is 0
//
// ===========================================================================

module gnrl_dffr # (
  parameter DW = 32
) (

  input      [DW-1:0] dnxt,
  output     [DW-1:0] qout,

  input               clk,
  input               rst_n
);

reg [DW-1:0] qout_r;

always @(posedge clk or negedge rst_n)
begin : DFFR_PROC
  if (rst_n == 1'b0)
    qout_r <= {DW{1'b0}};
  else                  
    qout_r <= dnxt;
end

assign qout = qout_r;

endmodule
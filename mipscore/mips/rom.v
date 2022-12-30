module rom #
(
    parameter integer DLY               =   1,          //
    parameter integer RAM_WIDTH         =   8,          //
    parameter integer RAM_DEPTH         =   16,         //
    parameter integer ADDR_WIDTH        =   4           //
)
(
    input   wire                        wr_clk,
    input   wire                        wr_en,
    input   wire    [ADDR_WIDTH-1:0]    wr_addr,
    input   wire    [RAM_WIDTH-1:0]     wr_data,

    input   wire                        rd_clk,
    input   wire                        rd_en,
    input   wire    [ADDR_WIDTH-1:0]    rd_addr,
    output  reg     [RAM_WIDTH-1:0]     rd_data,
    
    input   							   rst_n

);


(* ram_style = "block" *)reg [RAM_WIDTH-1:0]  memory[RAM_DEPTH-1:0];


always@(posedge wr_clk)
begin
    if(wr_en)
        memory[wr_addr] <= #DLY wr_data;
end


always@(posedge rd_clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
        rd_data <= 32'b0;
    else if(rd_en)
        rd_data <= #DLY memory[rd_addr];
end


endmodule
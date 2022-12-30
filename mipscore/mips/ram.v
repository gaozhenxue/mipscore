`timescale 1ns / 1ps

module ram#
(
    parameter integer DLY               =   1,          //
    parameter integer RAM_WIDTH         =   32,          //
    parameter integer RAM_DEPTH         =   16,         //
    parameter integer ADDR_WIDTH        =   4,          //
    parameter integer MASK_WIDTH        =   4           //
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

    input   wire    [MASK_WIDTH-1:0]    mask

);


(* ram_style = "block" *)reg [RAM_WIDTH-1:0]  memory[RAM_DEPTH-1:0];


always@(posedge wr_clk)
begin
    if(wr_en) begin
        if(mask[0])
            memory[wr_addr][7:0] <= #DLY wr_data[8:0];
        if(mask[1])
            memory[wr_addr][15:8] <= #DLY wr_data[15:8];
        if(mask[2])
            memory[wr_addr][23:16] <= #DLY wr_data[23:16];
        if(mask[3])
            memory[wr_addr][31:24] <= #DLY wr_data[31:24];
    end
end


always@(posedge rd_clk)
begin
    if(rd_en)
        rd_data <= #DLY memory[rd_addr];
end


endmodule

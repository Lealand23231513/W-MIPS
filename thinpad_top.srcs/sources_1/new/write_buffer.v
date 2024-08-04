`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/23 19:08:13
// Design Name: 
// Module Name: write_buffer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module write_buffer(
    input wire clk, reset,
    output wire full,
    output wire empty,
    input wire [31:0]din_vaddr,
    input wire [31:0]din,
    input wire [3:0] din_be,
    input wire wr_en, rd_en,
    output wire [31:0]dout,
    output wire [31:0]dout_vaddr,
    output wire [3:0] dout_be
    );
    wire [67:0]din_d = {din_be, din, din_vaddr};
    wire [67:0]dout_d = {dout_be, dout, dout_vaddr};
    fifo_generator_0 write_buffer_fifo (
      .clk(clk),      // input wire clk
      .srst(reset),    // input wire srst
      .din(din_d),      // input wire [67 : 0] din
      .wr_en(wr_en),  // input wire wr_en
      .rd_en(rd_en),  // input wire rd_en
      .dout(dout),    // output wire [67 : 0] dout
      .full(full),    // output wire full
      .empty(empty)  // output wire empty
    );
    
endmodule

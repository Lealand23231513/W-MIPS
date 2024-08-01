`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/24 22:58:15
// Design Name: 
// Module Name: sim_fifo
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


module sim_fifo(

    );
    reg clk, reset;
    reg [31:0] din;
    wire [31:0] dout;
    reg wr_en, rd_en;
    wire full,empty;
    always #10 clk=~clk;
    fifo_generator_0 your_instance_name (
      .clk(clk),      // input wire clk
      .srst(reset),    // input wire srst
      .din(din),      // input wire [67 : 0] din
      .wr_en(wr_en),  // input wire wr_en
      .rd_en(rd_en),  // input wire rd_en
      .dout(dout),    // output wire [67 : 0] dout
      .full(full),    // output wire full
      .empty(empty)  // output wire empty
    );
    always @(posedge clk) begin
        if (reset) din<=1;
        else din<=din+1;
    end
    integer i;
    initial begin
        clk=0;
        reset=1;
        din=0;
        wr_en=0;
        rd_en=0;
        #20
        reset=0;
        wr_en=1;
        rd_en=1; 
        #110
        rd_en=0;
        #580
        rd_en=1;
    end
endmodule

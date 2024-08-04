`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/08 19:47:14
// Design Name: 
// Module Name: sim_pll
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


module sim_pll(

    );
    wire locked, clk_100M, clk_20M;
    reg clk_50M;
    reg reset_btn;
    reg w;
    integer i;
    clk_wiz_0 pll
    (
    // Clock out ports
    .clk_out1(clk_100M),     // output clk_out1
    // Status and control signals
    .reset(reset_btn), // input reset
    .locked(locked),       // output locked
    // Clock in ports
    .clk_in1(clk_50M));      // input clk_in1
     reg reset;
    //     异步复位，同步释放，将locked信号转为后级电路的复位reset
    always@(posedge clk_100M or negedge locked) begin
        if(~locked) reset <= 1'b1;
        else        reset <= 1'b0;
    end
    always #10 clk_50M=~clk_50M;
    initial begin
        clk_50M=0;
        reset_btn=1;
        #100
        reset_btn=0;
    end
endmodule

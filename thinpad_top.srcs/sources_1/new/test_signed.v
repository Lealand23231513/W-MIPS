`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 17:28:41
// Design Name: 
// Module Name: test_signed
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


module test_signed(
    input wire signed [7:0]a,
    input wire signed [7:0]b,
    output wire signed [7:0]r1,
    output wire signed [8:0]r2
    );
    assign r1=a+b;
    assign r2=a+b;
//    wire [7:0] r3 = a*b;
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/17 08:15:15
// Design Name: 
// Module Name: maxer
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


module maxer(
    input wire [31:0] A,
    input wire [31:0] B,
    output wire[31:0] R
    );
    assign R=($unsigned(A)>$unsigned(B))?A:B;
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/16 20:10:56
// Design Name: 
// Module Name: sim_mult
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


module sim_mult(

    );
    reg clk;
    reg [31:0] A, B;
    wire [31:0] P;
    always #10 clk<=!clk;
    mult_gen_0 your_instance_name (
      .CLK(clk),  // input wire CLK
      .A(A),      // input wire [31 : 0] A
      .B(B),      // input wire [31 : 0] B
      .P(P)      // output wire [63 : 0] P
    );
    initial begin
        clk=0;
        A=1;
        B=2;
        #210
        A=32'hFFFFFFF0;
        B=5;
        #20
        A=0;
        B=0;
    end
endmodule

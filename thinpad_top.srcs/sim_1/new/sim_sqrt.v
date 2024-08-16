`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/16 20:37:40
// Design Name: 
// Module Name: sim_sqrt
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


module sim_sqrt(

    );
    reg clk;
    always #10 clk<=~clk;
    wire stall;
    reg v, reset;
    reg [31:0] A;
    wire [31:0] R;
    sqrter sqrter(
        .clk(clk), 
        .reset(reset),
        .A(A),
        .R(R),
        .valid(v),
        .stall(stall) 
    );
    initial begin
        reset=1;
        clk=0;
        A=31;
        v=0;
        #105
        reset=0;
        #5
        v=1;
        #20;
        v=0;
        #560
        v=1;
        A=32'hFF123568;
        #20
        v=0;
    end
    
endmodule

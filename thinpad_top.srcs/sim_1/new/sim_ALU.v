`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 12:32:39
// Design Name: 
// Module Name: sim_ALU
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


module sim_ALU(

    );
    reg signed [31:0] A=32'h00000005;
    reg signed [31:0] B=32'hdbbad0b0;
    reg [3:0] ALUOP;
    wire [31:0] R;
//    wire [32:0] R2=B>>>A[4:0];
    wire OF;
    reg clk;
    reg reset;
    wire done;
    always #10 begin
        clk = ~clk;
    end
    ALU ALU(
        .clk(clk), 
        .reset(reset),
        .A(A),
        .B(B),
        .ALUOP(ALUOP),
        .R(R),
        .OF(OF),
        .done(done)
    );
    initial begin
        A=-12345678;
        B=-2;
        ALUOP=4'b1010;
        reset=0;
        clk=0;
        #5
        reset=1;
        #25
        reset=0;
//        R2=$signed(B)>>>$signed(A[4:0]);
//        R2=;
    end
endmodule

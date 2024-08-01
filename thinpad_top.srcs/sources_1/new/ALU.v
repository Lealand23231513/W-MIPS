`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 16:34:15
// Design Name: 
// Module Name: ALU
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


module ALU(
    input wire clk,reset,
    input wire signed [31:0]A,
    input wire signed [31:0]B,
    input wire [3:0]ALUOP,
    
    output wire [31:0]R,
    output wire OF,
    output wire EQUAL,done
    );
    assign EQUAL=(A==B);
    reg [32:0] tmp;
    wire [31:0] mult_R;
    wire mult_done, valid;
    assign done=(ALUOP==4'b1010)?mult_done:1;
    assign valid=(ALUOP==4'b1010);
    multiplier multiplier(
        .clk(clk), .reset(reset), .valid(valid),
        .A(A), .B(B),
        .LO(mult_R),
        .done(mult_done)
    );
    always @(*) begin
        case(ALUOP)
            4'b0000: tmp=A|B;
            4'b0001: tmp=A-B;
            4'b0010: tmp=A+B;
            4'b0011: tmp=($unsigned(A)<$unsigned(B));
            4'b0100: tmp=(A<B);
            4'b0101: tmp=B<<A[4:0];
            4'b0110: tmp=B>>>A[4:0];
            4'b0111: tmp=$unsigned(B)>>$unsigned(A[4:0]);
            4'b1000: tmp=A&B;
            4'b1001: tmp=A^B;
//            4'b1010: tmp=$signed(A)*$signed(B);
            4'b1010: tmp={1'b0, mult_R};
            default: tmp=32'dx;
        endcase
    end
    assign R=tmp[31:0];
    assign OF=((ALUOP==4'b0001)&(ALUOP==4'b0010))?(tmp[32]!=tmp[31]):0;
endmodule

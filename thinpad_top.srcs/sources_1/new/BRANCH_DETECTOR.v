`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/07 13:22:33
// Design Name: 
// Module Name: BRANCH_DETECTOR
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
//`define BEQ 3'd1;
//`define BNE 3'd2;
//`define BGEZ 3'd3;
//`define BGTZ 3'd4;
//`define BLEZ 3'd5;
//`define BLTZ 3'd6;

module BRANCH_DETECTOR(
    input wire [2:0] BTYPE,
    input wire signed [31:0] RS_D,
    input wire signed [31:0] RT_D,
    output reg Branch
    );
    always @(*)begin
        case(BTYPE)
           3'd1: Branch=(RS_D==RT_D);
           3'd2: Branch=(RS_D!=RT_D);
           3'd3: Branch=(RS_D>=0);
           3'd4: Branch=(RS_D>0);
           3'd5: Branch=(RS_D<=0);
           3'd6: Branch=(RS_D<0);
           default: Branch=1'd0;
        endcase
    end
endmodule

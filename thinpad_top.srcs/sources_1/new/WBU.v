`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/02 23:32:02
// Design Name: 
// Module Name: WBU
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


module WBU(
    input wire WB_RegWrite,
    input wire [31:0]WB_PC,
    input wire [4:0]WB_WA,
    input wire [31:0] WB_WD,
    input wire WB2_RegWrite,
    input wire [31:0]WB2_PC,
    input wire [4:0]WB2_WA,
    input wire [31:0] WB2_WD,
    
    input wire head_PC_valid,
    input wire [63:0]head_PC_st,
    output wire [1:0]issue_rd_ori,
    
    output wire [1:0]commit,// WB_PC(?) commit 
    
    output wire [1:0] RGF_WE_st,
    output wire [9:0] RGF_WA_st,
    output wire [63:0] RGF_WD_st
    );
    wire RGF_WE[1:0];
    wire [4:0]RGF_WA[1:0];
    wire [31:0]RGF_WD[1:0];
    wire [31:0]head_PC[1:0];
    wire WB_hit[1:0];
    wire WB2_hit[1:0];
    
    genvar j;
    generate
        for (j=0;j<2;j=j+1) begin
            assign head_PC[j]=head_PC_st[32*(j+1)-1:32*j];
            assign RGF_WE_st[j]=RGF_WE[j];
            assign RGF_WA_st[5*(j+1)-1:5*j]=RGF_WA[j];
            assign RGF_WD_st[32*(j+1)-1:32*j]=RGF_WD[j];
        end
    endgenerate
    assign WB_hit[0]=(head_PC[0]==WB_PC)&head_PC_valid;
    assign WB_hit[1]=(head_PC[1]==WB_PC)&head_PC_valid;
    assign WB2_hit[0]=(head_PC[0]==WB2_PC)&head_PC_valid;
    assign WB2_hit[1]=(head_PC[1]==WB2_PC)&head_PC_valid;
    assign commit[0]=!WB_RegWrite|!WB_WA|WB_hit[0]|WB_hit[1]&WB2_hit[0];
    assign commit[1]=!WB2_RegWrite|!WB2_WA|WB2_hit[0]|WB2_hit[1]&WB_hit[0];
    assign issue_rd_ori[0]=WB_hit[0]|WB2_hit[0];
    assign issue_rd_ori[1]=WB_hit[0]&WB2_hit[1]|WB2_hit[0]&WB_hit[1];
    assign RGF_WE[0]=WB2_hit[0]?WB2_RegWrite:WB_RegWrite;
    assign RGF_WE[1]=WB2_hit[0]&WB_hit[1]?WB_RegWrite:WB_hit[0]&WB2_hit[1]?WB2_RegWrite:0;
    assign RGF_WA[0]=WB2_hit[0]?WB2_WA:WB_WA;
    assign RGF_WA[1]=WB2_hit[0]&WB_hit[1]?WB_WA:WB_hit[0]&WB2_hit[1]?WB2_WA:0;
    assign RGF_WD[0]=WB2_hit[0]?WB2_WD:WB_WD;
    assign RGF_WD[1]=WB2_hit[0]&WB_hit[1]?WB_WD:WB_hit[0]&WB2_hit[1]?WB2_WD:0;
    
endmodule

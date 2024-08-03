`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/02 09:19:40
// Design Name: 
// Module Name: IFU
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


module PFU(
    input wire en,
    input wire reset,
    input wire clk,
    input wire EX_BranchTaken,
    input wire IF_PredictBranch,
    input wire EX_PredictBranch,
    input wire ID_JMP,
    input wire EX_JR,
    input wire [31:0] ID_JMP_PC,
    input wire [31:0] EX_JR_PC,
    input wire [31:0] EX_PC,
    input wire [31:0] IF_PredictBranchAddr,
    input wire [31:0] EX_BranchAddr,
    output wire [31:0] pc
    );
    
    reg [31:0]pc_reg;
    reg [31:0]pc_next;
    assign PC_next=pc_next;
    parameter pc_begin=32'h80000000;
    
    always @(*) begin
        if(en) begin
            if (EX_JR) pc_next=EX_JR_PC;
            else if (ID_JMP) pc_next=ID_JMP_PC;
            else if (EX_BranchTaken!=EX_PredictBranch) pc_next=EX_BranchTaken?EX_BranchAddr:EX_PC+8;
            else if (IF_PredictBranch) pc_next=IF_PredictBranchAddr;
            else pc_next=pc_reg+4;
        end
        else pc_next=pc_reg;
    end
    always @(posedge clk, posedge reset)begin
        if(reset) begin
            pc_reg<=pc_begin;
        end
        else begin
            pc_reg<=pc_next;
        end
    end
    assign pc=pc_reg;
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/04 17:33:16
// Design Name: 
// Module Name: BRU
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

`include "global_def.vh"
module BRU(
    input wire clk,
    input wire reset,
    input wire ID2BR_en,
    input wire ID2BR_cl,
    
    output wire [31:0]BR_PC,
    output wire [31:0]BR_BranchAddr,
    output wire [2:0]BR_BTYPE,
    output wire BR_BranchTaken,
    output wire BR_PredictBranch,
    output wire BR_JR,
    output wire [31:0] BR_JR_PC,
    
    input wire [`ID2BR_BUS_WIDTH-1:0] ID2BR_bus
    );
    wire [31:0] BR_IR, BR_RD1, BR_RD2;
    pipeline_stage 
    #(.BUS_WIDTH(`ID2BR_BUS_WIDTH))
    ID2BR(
        .clk(clk),
        .reset(reset),
        .en(ID2BR_en),
        .cl(ID2BR_cl),
        .bus_i(ID2BR_bus),
        .bus_o({BR_PC, BR_IR, BR_BTYPE, BR_JR, BR_PredictBranch, BR_RD1, BR_RD2})
    );    
    BRANCH_DETECTOR BRD(
       .BTYPE(BR_BTYPE),
       .RS_D(BR_RD1),
       .RT_D(BR_RD2),
       .Branch(BR_BranchTaken)
   );
   assign BR_BranchAddr={{14{BR_IR[15]}}, BR_IR[15:0], 2'd0}+BR_PC+32'd4;
   assign BR_JR_PC=BR_RD1;
endmodule

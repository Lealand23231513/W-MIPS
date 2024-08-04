`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/22 23:53:04
// Design Name: 
// Module Name: pipeline_ctrl
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


module pipeline_ctrl(
    input wire clk,reset,
    input wire IC_stall,
    input wire DM_stall,
    input wire ID_EXload,
    input wire ID_JMP,
    input wire EX_BranchTaken,
    input wire EX_PredictBranch,
    input wire EX_JR,
    input wire ID_MCY,
    input wire ID_EM1_r,

    output wire IFU_en,
    output wire PF2IF_en,
    output wire icache_en,
    output wire IF2ID_en,
    output wire ID2EX_en,
    output wire EX2MEM_en,
    output wire MEM2WB_en,
    output wire ID2EM1_en,
    output wire EM12EM2_en,
    output wire EM22WB2_en,
    
    output wire PF2IF_flush,
    output wire IF2ID_bubble,
    output wire ID2EX_bubble,
    output wire EX2MEM_bubble,
    output wire MEM2WB_bubble,
    output wire ID2EM1_bubble,
    output wire EM12EM2_bubble,
    output wire EM22WB2_bubble
    );
    wire PredictErr;
    assign PredictErr=(EX_BranchTaken!=EX_PredictBranch);
    assign IFU_en=!ID_EXload&!DM_stall&!IC_stall&!ID_EM1_r;
    assign PF2IF_en=!ID_EXload&!DM_stall&!IC_stall&!ID_EM1_r;
    assign icache_en=!ID_EXload&!DM_stall&!ID_EM1_r;
    assign IF2ID_en=!ID_EXload&!IC_stall&!DM_stall&!ID_EM1_r;
    assign ID2EX_en=(!IC_stall|ID_EXload|ID_EM1_r)&!DM_stall;
    assign EX2MEM_en=(!IC_stall|ID_EXload|ID_EM1_r)&!DM_stall;
    assign MEM2WB_en=(!IC_stall|ID_EXload|ID_EM1_r)&!DM_stall;
    assign ID2EM1_en=(!IC_stall|ID_EXload|ID_EM1_r)&!DM_stall;
    assign EM12EM2_en=(!IC_stall|ID_EXload|ID_EM1_r)&!DM_stall;
    assign EM22WB2_en=(!IC_stall|ID_EXload|ID_EM1_r)&!DM_stall;
    
    
    assign PF2IF_flush=ID_JMP|PredictErr|EX_JR;
    assign IF2ID_bubble=PredictErr|EX_JR;
    assign ID2EX_bubble=ID_EXload|ID_EM1_r|ID_MCY;
    assign ID2EM1_bubble=ID_EXload|ID_EM1_r|!ID_MCY;
    assign EM12EM2_bubble=0;
    assign EX2MEM_bubble=0;
    assign MEM2WB_bubble=0;
    assign EM22WB2_bubble=0;
    
    
endmodule

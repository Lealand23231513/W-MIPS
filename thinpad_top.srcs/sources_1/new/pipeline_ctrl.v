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

`include "global_def.vh"
module pipeline_ctrl(
    input wire clk,reset,
    input wire IC_stall,
    input wire DM_stall,
    input wire ID_JMP,
    input wire BR_BranchTaken,
    input wire BR_PredictBranch,
    input wire BR_JR,
    input wire [2:0] IS_FUID,
    input wire [1:0] FID_hit,
    input wire [1:0] commit,
    
    input wire EX_relate,
    input wire EXF_relate,
    input wire AG_relate,
    input wire MEM_relate,
    input wire LSF_relate,

    output wire PFU_en,
    output wire PF2IF_en,
    output wire icache_en,
    output wire IF2ID_en,
    output wire ID2IS_en,
    output wire ID2EX_en,
    output wire EX2EXF_en,
    output wire ID2AG_en,
    output wire AG2MEM_en,
    output wire MEM2LSF_en,
    output wire ID2BR_en,
    output wire RO2WB_en,
    
    output wire issue,
    output wire issue_wr_en,
    output wire [1:0]issue_rd_en,
    
    
    output wire PF2IF_cl,
    output wire IF2ID_cl,
    output wire ID2IS_cl,
    output wire ID2EX_cl,
    output wire EX2EXF_cl,
    output wire ID2AG_cl,
    output wire AG2MEM_cl,
    output wire MEM2LSF_cl,
    output wire ID2BR_cl,
    output wire RO2WB_cl
    );
    wire PredictErr;
//    wire data_conflict_check;//1: can solve
    wire EXF_commit, LSF_commit;
    wire EXU_permit, LSU_permit, BRU_permit;
    wire IS_ready;
    wire issue_to_EXU, issue_to_LSU, issue_to_BRU;
    wire IS_access_permit;
    wire FU_permission[3:0];
    assign PredictErr=(BR_BranchTaken!=BR_PredictBranch);
    assign IS_access_permit=FU_permission[IS_FUID];
    assign FU_permission[`EXU_ID]=EXU_permit;
    assign FU_permission[`LSU_ID]=LSU_permit;
    assign FU_permission[`BRU_ID]=BRU_permit;
    assign issue_to_EXU=(IS_FUID==`EXU_ID);
    assign issue_to_LSU=(IS_FUID==`LSU_ID);
    assign issue_to_BRU=(IS_FUID==`BRU_ID);
    assign EXF_commit=commit[`EXU_ID];
    assign LSF_commit=commit[`LSU_ID];
    assign EXU_permit=EXF_commit;
    assign LSU_permit=LSF_commit&!DM_stall;
    assign BRU_permit=1;
    assign IS_ready=!AG_relate&!(DM_stall&MEM_relate);
    
    assign RO2WB_en=1;
    assign RO2WB_cl=0;
    assign EX2EXF_en=EXF_commit;
    assign EX2EXF_cl=0;
    assign ID2EX_en=EXF_commit;
    assign ID2EX_cl=!issue_to_EXU|IC_stall|!IS_ready;
    assign MEM2LSF_en=LSF_commit;
    assign MEM2LSF_cl=DM_stall;
    assign AG2MEM_en=LSF_commit&!DM_stall;
    assign AG2MEM_cl=0;
    assign ID2AG_en=LSF_commit&!DM_stall;
    assign ID2AG_cl=!issue_to_LSU|IC_stall|!IS_ready;
    assign ID2BR_en=!IC_stall&IS_ready&IS_access_permit;
    assign ID2BR_cl=!issue_to_BRU;
    assign ID2IS_en=!IC_stall&IS_ready&IS_access_permit;
    assign ID2IS_cl=PredictErr|BR_JR;
    assign IF2ID_en=!IC_stall&IS_ready&IS_access_permit;
    assign IF2ID_cl=PredictErr|BR_JR;
    assign PF2IF_en=!IC_stall&IS_ready&IS_access_permit;
    assign PF2IF_cl=ID_JMP|PredictErr|BR_JR;
    assign PFU_en=!IC_stall&IS_ready&IS_access_permit;
    assign icache_en=IS_ready&IS_access_permit;
    assign issue=!IC_stall&IS_ready&IS_access_permit;
    assign issue_wr_en=issue&!issue_to_BRU;

    assign issue_rd_en[0]=FID_hit[0];
    assign issue_rd_en[1]=FID_hit[0]&FID_hit[1];

    
endmodule

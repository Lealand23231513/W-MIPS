`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/12 16:20:12
// Design Name: 
// Module Name: RELATE
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
module RELATE(
    input wire clk,
    input wire reset,

    input wire IS_RA1_Read,
    input wire IS_RA2_Read,
    input wire [4:0] IS_RA1,
    input wire [4:0] IS_RA2,
    input wire [`RELATE_BUS_WIDTH-1:0] EX_rel_bus,
    input wire [`RELATE_BUS_WIDTH-1:0] EXF_rel_bus,
    input wire [`RELATE_BUS_WIDTH-1:0] AG_rel_bus,
    input wire [`RELATE_BUS_WIDTH-1:0] MEM_rel_bus,
    input wire [`RELATE_BUS_WIDTH-1:0] LSF_rel_bus,

    output wire EX_relate,
    output wire EXF_relate,
    output wire AG_relate,
    output wire MEM_relate,
    output wire LSF_relate,
    
    output wire to_IS_RD1,
    output wire to_IS_RD2,
    output wire [31:0] to_IS_RD1_D,
    output wire [31:0] to_IS_RD2_D

    );
    parameter EX_ID=0;
    parameter EXF_ID=1;
    parameter AG_ID=2;
    parameter MEM_ID=3;
    parameter LSF_ID=4;
    wire IS_read[1:0];
    wire [4:0]IS_RA[1:0];
    wire [31:0] EX_D, EXF_D, EM1_D, EM2_D, EMF_D, AG_D, MEM_D, LSF_D;
    wire [4:0] EX_WA, EXF_WA, EM1_WA, EM2_WA, EMF_WA, AG_WA, MEM_WA, LSF_WA;
    wire EX_RegWrite, EXF_RegWrite, EM1_RegWrite, EM2_RegWrite, EMF_RegWrite, AG_RegWrite, MEM_RegWrite, LSF_RegWrite;
    wire EX_ready, EXF_ready, EM1_ready, EM2_ready, EMF_ready, AG_ready, MEM_ready, LSF_ready;
    wire [1:0]EX_rel;
    wire [1:0]EXF_rel;
    wire [1:0]AG_rel;
    wire [1:0]MEM_rel;
    wire [1:0]LSF_rel;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EX_FID_idx, EXF_FID_idx, EM1_FID_idx, EM2_FID_idx, EMF_FID_idx, AG_FID_idx, MEM_FID_idx, LSF_FID_idx;

    //depth: 0: EX, 1:EXF, 2:AG, 3:MEM, 4:LSF
    //width: 0: RD1 1: RD2
    wire [1:0]send_ready[4:0];
    wire [1:0]FU_send_ready[3:0];
    wire [1:0]FU_send_ready_st[1:0];//0: RD1 1: RD2
    wire [31:0]FU_send_D[1:0][1:0];
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] FU_FID_idx[1:0][1:0];
    wire [`ISSUE_LOG_DEPTH_WIDTH*2-1:0] FU_FID_idx_st[1:0];
    wire FU_send_id[1:0];
    wire FU_send_v[1:0];
    function relate_judge;
        input [4:0]RA;
        input RE;
        input [4:0]WA;
        input WE;
        relate_judge=RE && WE && RA==WA;
    endfunction
    genvar j, j2;
    generate 
        for(j=0;j<2;j=j+1) begin
            assign EX_rel[j]=relate_judge(IS_RA[j], IS_read[j], EX_WA, EX_RegWrite);
            assign send_ready[EX_ID][j]=EX_rel[j]&EX_ready;
            assign EXF_rel[j]=relate_judge(IS_RA[j], IS_read[j], EXF_WA, EXF_RegWrite);
            assign send_ready[EXF_ID][j]=EXF_rel[j]&EXF_ready;
            assign AG_rel[j]=relate_judge(IS_RA[j], IS_read[j], AG_WA, AG_RegWrite);
            assign send_ready[AG_ID][j]=AG_rel[j]&AG_ready;
            assign MEM_rel[j]=relate_judge(IS_RA[j], IS_read[j], MEM_WA, MEM_RegWrite);
            assign send_ready[MEM_ID][j]=MEM_rel[j]&MEM_ready;
            assign LSF_rel[j]=relate_judge(IS_RA[j], IS_read[j], LSF_WA, LSF_RegWrite);
            assign send_ready[LSF_ID][j]=LSF_rel[j]&LSF_ready;
            assign {FU_send_ready[`EXU_ID][j], FU_FID_idx[`EXU_ID][j], FU_send_D[`EXU_ID][j]}=send_ready[EX_ID][j]?{send_ready[EX_ID][j], EX_FID_idx, EX_D}:{send_ready[EXF_ID][j], EXF_FID_idx, EXF_D};
            assign {FU_send_ready[`LSU_ID][j], FU_FID_idx[`LSU_ID][j], FU_send_D[`LSU_ID][j]}=send_ready[MEM_ID][j]?{send_ready[MEM_ID][j], MEM_FID_idx, MEM_D}:{send_ready[LSF_ID][j], LSF_FID_idx, LSF_D};

            sel_from_2 
            #(.VALUE_WIDTH(`ISSUE_LOG_DEPTH_WIDTH))
            sel_from_2(
                .value_st(FU_FID_idx_st[j]),
                .valid_st(FU_send_ready_st[j]),
                .sel_idx(FU_send_id[j]),
                .valid_o(FU_send_v[j])
            );
        end
        for(j=0;j<2;j=j+1) begin
            for(j2=0;j2<2;j2=j2+1) begin
                assign FU_FID_idx_st[j2][`ISSUE_LOG_DEPTH_WIDTH*(j+1)-1:`ISSUE_LOG_DEPTH_WIDTH*j]=FU_FID_idx[j][j2]; 
                assign FU_send_ready_st[j2][j]=FU_send_ready[j][j2];
            end
        end
    endgenerate
    assign IS_read[0]=IS_RA1_Read;
    assign IS_read[1]=IS_RA2_Read;
    assign IS_RA[0]=IS_RA1;
    assign IS_RA[1]=IS_RA2;
    assign {EX_D, EX_WA, EX_FID_idx, EX_RegWrite, EX_ready} = EX_rel_bus;
    assign {EXF_D, EXF_WA, EXF_FID_idx, EXF_RegWrite, EXF_ready} = EXF_rel_bus;
    assign {AG_D, AG_WA, AG_FID_idx, AG_RegWrite, AG_ready} = AG_rel_bus;
    assign {MEM_D, MEM_WA, MEM_FID_idx, MEM_RegWrite, MEM_ready} = MEM_rel_bus;
    assign {LSF_D, LSF_WA, LSF_FID_idx, LSF_RegWrite, LSF_ready} = LSF_rel_bus;
    assign EX_relate=EX_rel[0]|EX_rel[1];
    assign EXF_relate=EXF_rel[0]|EXF_rel[1];
    assign AG_relate=AG_rel[0]|AG_rel[1];
    assign MEM_relate=MEM_rel[0]|MEM_rel[1];
    assign LSF_relate=LSF_rel[0]|LSF_rel[1];
    assign to_IS_RD1=FU_send_v[0];
    assign to_IS_RD2=FU_send_v[1];
    assign to_IS_RD1_D=FU_send_D[FU_send_id[0]][0];
    assign to_IS_RD2_D=FU_send_D[FU_send_id[1]][1];
endmodule

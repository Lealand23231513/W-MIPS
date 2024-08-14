`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/07 20:52:41
// Design Name: 
// Module Name: ROU
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
module ROU(
    input wire clk,reset,
    input wire RO2WB_en,RO2WB_cl,
    input wire [`FU2RO_BUS_WIDTH-1:0] EX2RO_bus,
    input wire [`FU2RO_BUS_WIDTH-1:0] LS2RO_bus,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EXF_FID_idx,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] LSF_FID_idx,
    
    output wire [1:0] commit,//0:EXF, 1:LSF
    output wire [1:0] FID_hit,

    output wire WB_WE1,
    output wire WB_WE2,
    output wire [4:0] WB_WA1,
    output wire [4:0] WB_WA2,
    output wire [31:0] WB_WD1,
    output wire [31:0] WB_WD2
    ); 
    wire RO_WE[1:0], WB_WE[1:0];
    wire [4:0] RO_WA[1:0], WB_WA[1:0];
    wire [31:0] RO_WD[1:0], WB_WD[1:0];
    wire [31:0] EXF_PC, EXF_IR, EXF_D, EMF_PC, EMF_IR, EMF_D, LSF_PC, LSF_IR, LSF_D;
    wire [`FID_WIDTH-1:0] EXF_FID, EMF_FID, LSF_FID;
    wire EXF_RegWrite, EMF_RegWrite, LSF_RegWrite;
    wire [4:0] EXF_WA, EMF_WA, LSF_WA;
    wire EXF_sup, EMF_sup, LSF_sup;
    wire EXF_FID_v, EMF_FID_v, LSF_FID_v;
    assign {EXF_PC, EXF_FID, EXF_FID_v, EXF_IR, EXF_RegWrite, EXF_sup, EXF_WA, EXF_D}=EX2RO_bus;
    assign {LSF_PC, LSF_FID, LSF_FID_v, LSF_IR, LSF_RegWrite, LSF_sup, LSF_WA, LSF_D}=LS2RO_bus;
    genvar j;
    generate 
        for(j=0;j<2;j=j+1) begin
            assign FID_hit[j]=(EXF_FID_idx==j|LSF_FID_idx==j);
            assign RO_WE[j]=commit[0]&EXF_FID_idx==j?EXF_RegWrite:commit[1]&LSF_FID_idx==j?LSF_RegWrite:0;
            assign RO_WA[j]=commit[0]&EXF_FID_idx==j?EXF_WA:commit[1]&LSF_FID_idx==j?LSF_WA:0;
            assign RO_WD[j]=commit[0]&EXF_FID_idx==j?EXF_D:commit[1]&LSF_FID_idx==j?LSF_D:0;
        end
    endgenerate
    assign commit[0]=!EXF_FID_v||EXF_FID_idx==0||EXF_FID_idx==1&&FID_hit[0];
    assign commit[1]=!LSF_FID_v||LSF_FID_idx==0||LSF_FID_idx==1&&FID_hit[0];
    generate
        for(j=0;j<2;j=j+1) begin
            pipeline_stage 
            #(.BUS_WIDTH(`RO2WB_BUS_WIDTH))
            RO2WB(
                .clk(clk),
                .reset(reset),
                .en(RO2WB_en),
                .cl(RO2WB_cl),
                .bus_i({RO_WE[j], RO_WA[j], RO_WD[j]}),
                .bus_o({WB_WE[j], WB_WA[j], WB_WD[j]})
            );
        end
    endgenerate
    assign {WB_WE1, WB_WA1, WB_WD1, WB_WE2, WB_WA2, WB_WD2}={WB_WE[0], WB_WA[0], WB_WD[0], WB_WE[1], WB_WA[1], WB_WD[1]};
endmodule

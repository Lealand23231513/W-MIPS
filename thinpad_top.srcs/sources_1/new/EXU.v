`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/04 01:44:31
// Design Name: 
// Module Name: EXU
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
module EXU(
    input wire clk,
    input wire reset,
    input wire ID2EX_en,
    input wire EX2EXF_en,
    input wire ID2EX_cl,
    input wire EX2EXF_cl,
    
    output wire [`RELATE_BUS_WIDTH-1:0] EX_rel_bus,
    output wire [`RELATE_BUS_WIDTH-1:0] EXF_rel_bus,
    
    input wire [`ID2EX_BUS_WIDTH-1:0] ID2EX_bus,
    output wire [`FU2RO_BUS_WIDTH-1:0] EX2RO_bus,
    
    output wire [`FID_WIDTH:0] EX_FID_bus,
    output wire [`FID_WIDTH:0] EXF_FID_bus,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EX_FID_idx,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EXF_FID_idx
    );
    wire [31:0] EX_PC, EX_IR, EXF_PC, EXF_IR, EX_EXTD, EX_RD1, EX_RD2;
    wire EX_ALUSource, EX_RegWrite, EX_USE_SA, EX_LUI, EX_JAL, EX_POF, EXF_RegWrite;
    wire [3:0] EX_ALUOP;
    wire [4:0] EX_WA, EX_SA, EXF_WA;
    wire [31:0] ALU_A, ALU_B, LUI_Res, JAL_Res, ALU_Res;
    wire OF, EX_sup, EXF_sup;
    wire [31:0] EX_D, EXF_D;
    wire EX_FID_v, EXF_FID_v;
    wire [`FID_WIDTH-1:0] EX_FID, EXF_FID;
    pipeline_stage 
    #(.BUS_WIDTH(`ID2EX_BUS_WIDTH))
    ID2EX(
        .clk(clk),
        .reset(reset),
        .en(ID2EX_en),
        .cl(ID2EX_cl),
        .bus_i(ID2EX_bus),
        .bus_o({EX_PC, EX_FID, EX_FID_v, EX_IR, EX_ALUOP, EX_ALUSource, EX_RegWrite, EX_WA, EX_EXTD, EX_RD1, EX_RD2, EX_USE_SA, EX_LUI, EX_JAL, EX_POF})
    );
    assign EX_FID_bus={EX_FID_v, EX_FID};
    assign EX_SA=EX_IR[10:6];
    assign ALU_A=EX_USE_SA?{27'd0, EX_SA}:EX_RD1;
    assign ALU_B=EX_ALUSource?EX_EXTD:EX_RD2;
    assign LUI_Res={EX_EXTD[15:0],16'd0};
    assign JAL_Res=EX_PC+8;
    assign EX_sup=(EX_RegWrite&!EX_WA);
    assign EX_D=EX_LUI?LUI_Res:EX_JAL?JAL_Res:ALU_Res;
    assign EX_rel_bus={EX_D, EX_WA, EX_FID_idx, EX_RegWrite, 1'd1};
    ALU ALU(
        .clk(clk),
        .reset(reset),
        .A(ALU_A),
        .B(ALU_B),
        .ALUOP(EX_ALUOP),
        .R(ALU_Res),
        .OF(OF)
    );
    pipeline_stage 
    #(.BUS_WIDTH(`FU2RO_BUS_WIDTH))
    EX2EXF(
        .clk(clk),
        .reset(reset),
        .en(EX2EXF_en),
        .cl(EX2EXF_cl),
        .bus_i({EX_PC, EX_FID, EX_FID_v, EX_IR, EX_POF&OF?1'd0:EX_RegWrite, EX_sup, EX_WA, EX_D}),
        .bus_o({EXF_PC, EXF_FID, EXF_FID_v, EXF_IR, EXF_RegWrite, EXF_sup, EXF_WA, EXF_D})
    );
    assign EXF_FID_bus={EXF_FID_v, EXF_FID};
    assign EXF_rel_bus={EXF_D, EXF_WA, EXF_FID_idx, EXF_RegWrite, 1'd1};
    assign EX2RO_bus={EXF_PC, EXF_FID, EXF_FID_v, EXF_IR, EXF_RegWrite, EXF_sup, EXF_WA, EXF_D};
endmodule

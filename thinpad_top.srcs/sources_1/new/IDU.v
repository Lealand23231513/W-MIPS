`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/10 00:32:21
// Design Name: 
// Module Name: IDU
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
module IDU(
    input wire clk, reset,
    input wire ID2IS_en,
    input wire ID2IS_cl,
    
    output wire ID_JMP,
    output wire[31:0] ID_JMP_PC,
    output wire [4:0] IS_RA1,
    output wire [4:0] IS_RA2,
    output wire IS_RA1_READ,
    output wire IS_RA2_READ,
    output wire [2:0] IS_FUID,
    input wire [31:0] RD1_r,
    input wire [31:0] RD2_r,
    input wire [`FID_WIDTH-1:0] FID_curr,
    input wire issue,
    input wire to_IS_RD1,
    input wire to_IS_RD2,
    input wire [31:0] to_IS_RD1_D,
    input wire [31:0] to_IS_RD2_D,
    
    input wire [`IF2ID_BUS_WIDTH-1:0] IF2ID_bus,
    output wire [`ID2EX_BUS_WIDTH-1:0] ID2EX_bus,
    output wire [`ID2LS_BUS_WIDTH-1:0] ID2LS_bus,
    output wire [`ID2BR_BUS_WIDTH-1:0] ID2BR_bus
    );
    parameter REG_RA=5'd31;
    wire [31:0] ID_PC, ID_IR, IS_PC, IS_IR, ID_EXTD, IS_EXTD, ID_PredictBranchAddr, IS_PredictBranchAddr;
    wire ID_PredictBranch, IS_PredictBranch;
    wire [3:0] ID_ALUOP, IS_ALUOP;
    wire [2:0] ID_BTYPE, IS_BTYPE;
    wire ID_MemWrite, IS_MemWrite;
    wire ID_ALUSource, IS_ALUSource, ID_RegWrite, IS_RegWrite, ID_RegDst, ID_EXTOP, ID_LUI, IS_LUI;
    wire IS_JMP, ID_JR, IS_JR, ID_JAL, IS_JAL, ID_MemLoad, IS_MemLoad, ID_RA1_READ, ID_RA2_READ;
    wire ID_LB_SB, IS_LB_SB, ID_POF, IS_POF, ID_USE_SA, IS_USE_SA;
    wire [2:0] ID_FUID;
    wire [4:0] ID_RA1, ID_RA2, ID_WA, IS_WA, rd;
    wire [15:0] offset;
    wire [31:0] IS_RD1, IS_RD2;
    wire ID_MUL, IS_MUL;
    wire [`FID_WIDTH-1:0] IS_FID;
    assign {ID_PC, ID_IR, ID_PredictBranch, ID_PredictBranchAddr}=IF2ID_bus;
    assign offset=ID_IR[15:0];
    assign ID_EXTD=ID_EXTOP?{{16{offset[15]}}, offset}:{16'd0,offset};
    assign ID_RA1=ID_IR[25:21];
    assign ID_RA2=ID_IR[20:16];
    assign rd=ID_IR[15:11];
    
    assign ID_WA=ID_JAL?REG_RA:ID_RegDst?rd:ID_RA2;
    assign ID_JMP_PC={ID_PC[31:28], ID_IR[25:0], 2'd0};

    controler controler(
        .IR(ID_IR),
        .ALUOP(ID_ALUOP),
        .BTYPE(ID_BTYPE),
        .MemWrite(ID_MemWrite),
        .ALUSource(ID_ALUSource),
        .RegWrite(ID_RegWrite),
        .RegDst(ID_RegDst),
        .EXTOP(ID_EXTOP),
        .LUI(ID_LUI),
        .JMP(ID_JMP),
        .JR(ID_JR),
        .JAL(ID_JAL),
        .MemLoad(ID_MemLoad),
        .RA1_READ(ID_RA1_READ),
        .RA2_READ(ID_RA2_READ),
        .LB_SB(ID_LB_SB),
        .POF(ID_POF),
        .USE_SA(ID_USE_SA),
        .FUID(ID_FUID),
        .MUL(ID_MUL)
    );
    
    pipeline_stage 
    #(.BUS_WIDTH(`ID2IS_BUS_WIDTH))
    ID2IS(
        .clk(clk),
        .reset(reset),
        .en(ID2IS_en),
        .cl(ID2IS_cl),
        .bus_i({ID_PC, ID_IR, ID_PredictBranch, ID_PredictBranchAddr, ID_ALUOP, ID_BTYPE, ID_MemWrite, ID_ALUSource, ID_RegWrite, ID_LUI, ID_JMP, ID_JR, ID_JAL, ID_MemLoad, ID_RA1_READ, ID_RA2_READ, ID_LB_SB, ID_POF, ID_USE_SA, ID_FUID, ID_RA1, ID_RA2, ID_WA, ID_EXTD, ID_MUL}),
        .bus_o({IS_PC, IS_IR, IS_PredictBranch, IS_PredictBranchAddr, IS_ALUOP, IS_BTYPE, IS_MemWrite, IS_ALUSource, IS_RegWrite, IS_LUI, IS_JMP, IS_JR, IS_JAL, IS_MemLoad, IS_RA1_READ, IS_RA2_READ, IS_LB_SB, IS_POF, IS_USE_SA, IS_FUID, IS_RA1, IS_RA2, IS_WA, IS_EXTD, IS_MUL})
    );
    assign IS_RD1=(to_IS_RD1&&IS_RA1)?to_IS_RD1_D:RD1_r;
    assign IS_RD2=(to_IS_RD2&&IS_RA2)?to_IS_RD2_D:RD2_r;
    assign IS_FID=FID_curr;
    assign ID2EX_bus={IS_PC, IS_FID, issue, IS_IR, IS_ALUOP, IS_ALUSource, IS_RegWrite, IS_WA, IS_EXTD, IS_RD1, IS_RD2, IS_USE_SA, IS_LUI, IS_JAL, IS_POF};
    assign ID2LS_bus={IS_PC, IS_FID, issue, IS_IR, IS_MemLoad, IS_MemWrite, IS_EXTD, IS_RD1, IS_RD2, IS_RegWrite, IS_LB_SB, IS_WA, IS_MUL};
    assign ID2BR_bus={IS_PC, IS_IR, IS_BTYPE, IS_JR, IS_PredictBranch, IS_RD1, IS_RD2};
endmodule

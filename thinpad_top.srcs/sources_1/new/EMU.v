`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/04 00:41:01
// Design Name: 
// Module Name: EMU
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
module EMU(
    input wire clk,
    input wire reset,
    input wire ID2EM1_en,
    input wire EM12EM2_en,
    input wire EM22EMF_en,
    input wire ID2EM1_cl,
    input wire EM12EM2_cl,
    input wire EM22EMF_cl,
    
    output wire [`RELATE_BUS_WIDTH-1:0] EM1_rel_bus,
    output wire [`RELATE_BUS_WIDTH-1:0] EM2_rel_bus,
    output wire [`RELATE_BUS_WIDTH-1:0] EMF_rel_bus,
    
    input wire[`ID2EM_BUS_WIDTH-1:0] ID2EM_bus,
    output wire[`FU2RO_BUS_WIDTH-1:0] EM2RO_bus,
    output wire [`FID_WIDTH:0] EM1_FID_bus,
    output wire [`FID_WIDTH:0] EM2_FID_bus,
    output wire [`FID_WIDTH:0] EMF_FID_bus,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EM1_FID_idx,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EM2_FID_idx,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EMF_FID_idx
    );
    wire [31:0] EM1_RD1, EM1_RD2, EM2_D;
    wire [31:0] EM1_PC, EM1_IR, EM2_PC, EM2_IR, EMF_PC, EMF_IR;
    wire EM1_RegWrite, EM2_RegWrite, EMF_RegWrite;
    wire [4:0] EM1_WA, EM2_WA, EMF_WA;
//    wire [`EM12EM2_BUS_WIDTH-1:0] EM12EM2_bus;
    wire [31:0] EM1_ll,EM1_lh,EM1_hl,EM1_hh, EM2_ll,EM2_lh,EM2_hl,EM2_hh;
    wire [31:0] EM2_LO, EM2_HI, EMF_D;
    wire EM2_sup, EMF_sup;
    wire EM1_FID_v, EM2_FID_v, EMF_FID_v;
    wire [`FID_WIDTH-1:0] EM1_FID, EM2_FID, EMF_FID;
    pipeline_stage 
    #(.BUS_WIDTH(`ID2EM_BUS_WIDTH))
    ID2EM1(
        .clk(clk),
        .reset(reset),
        .en(ID2EM1_en),
        .cl(ID2EM1_cl),
        .bus_i(ID2EM_bus),
        .bus_o({EM1_PC, EM1_FID, EM1_FID_v, EM1_IR, EM1_RegWrite, EM1_WA, EM1_RD1, EM1_RD2})
    );
    assign EM1_FID_bus={EM1_FID_v, EM1_FID};
    assign EM1_rel_bus={32'd0, EM1_WA, EM1_FID_idx, EM1_RegWrite, 1'd0};
    assign EM1_ll=$unsigned(EM1_RD1[15:0])*$unsigned(EM1_RD2[15:0]);
    assign EM1_lh=$unsigned(EM1_RD1[15:0])*$unsigned(EM1_RD2[31:16]);
    assign EM1_hl=$unsigned(EM1_RD1[31:16])*$unsigned(EM1_RD2[15:0]);
    assign EM1_hh=$unsigned(EM1_RD1[31:16])*$unsigned(EM1_RD2[31:16]);
    pipeline_stage 
    #(.BUS_WIDTH(`EM12EM2_BUS_WIDTH))
    EM12EM2(
        .clk(clk),
        .reset(reset),
        .en(EM12EM2_en),
        .cl(EM12EM2_cl),
        .bus_i({EM1_PC, EM1_FID, EM1_FID_v, EM1_IR, EM1_RegWrite, EM1_WA, EM1_ll, EM1_lh, EM1_hl, EM1_hh}),
        .bus_o({EM2_PC, EM2_FID, EM2_FID_v, EM2_IR, EM2_RegWrite, EM2_WA, EM2_ll, EM2_lh, EM2_hl, EM2_hh})
    );
    assign EM2_FID_bus={EM2_FID_v, EM2_FID};
    assign EM2_rel_bus={EM2_D, EM2_WA, EM2_FID_idx, EM2_RegWrite, 1'd1};
    assign EM2_LO=EM2_ll+{EM2_lh[15:0],16'b0}+{EM2_hl[15:0], 16'b0};
    assign EM2_HI={16'b0,EM2_lh[31:16]}+{16'b0,EM2_hl[31:16]}+EM2_hh;
    assign EM2_D=EM2_LO;
    assign EM2_sup=(EM2_RegWrite&&!EM2_WA);
    pipeline_stage 
    #(.BUS_WIDTH(`FU2RO_BUS_WIDTH))
    EM22EMF(
        .clk(clk),
        .reset(reset),
        .en(EM12EM2_en),
        .cl(EM12EM2_cl),
        .bus_i({EM2_PC, EM2_FID, EM2_FID_v, EM2_IR, EM2_RegWrite, EM2_sup, EM2_WA, EM2_D}),
        .bus_o({EMF_PC, EMF_FID, EMF_FID_v, EMF_IR, EMF_RegWrite, EMF_sup, EMF_WA, EMF_D})
    );
    assign EMF_FID_bus={EMF_FID_v, EMF_FID};
    assign EMF_rel_bus={EMF_D, EMF_WA, EMF_FID_idx, EMF_RegWrite, 1'd1};
    assign EM2RO_bus={EMF_PC, EMF_FID, EMF_FID_v, EMF_IR, EMF_RegWrite, EMF_sup, EMF_WA, EMF_D};
    
endmodule

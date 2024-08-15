`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/04 17:51:44
// Design Name: 
// Module Name: LSU
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
module LSU(
    input wire clk,
    input wire reset,
    output wire DM_stall,
    output wire AG_stall,
    
    input wire ID2AG_en,
    input wire AG2MEM_en,
    input wire MEM2LSF_en,
    input wire ID2AG_cl,
    input wire AG2MEM_cl,
    input wire MEM2LSF_cl,
    
    output wire [`RELATE_BUS_WIDTH-1:0] AG_rel_bus,
    output wire [`RELATE_BUS_WIDTH-1:0] MEM_rel_bus,
    output wire [`RELATE_BUS_WIDTH-1:0] LSF_rel_bus,
    
    input wire [`ID2LS_BUS_WIDTH-1:0] ID2LS_bus,
    output wire [`FU2RO_BUS_WIDTH-1:0] LS2RO_bus,
    
    output wire [`MEM_SEND_BUS_WIDTH-1:0] base_send_bus,
    input wire [`MEM_RECV_BUS_WIDTH-1:0] base_recv_bus,
    output wire [`MEM_SEND_BUS_WIDTH-1:0] ext_send_bus,
    input wire [`MEM_RECV_BUS_WIDTH-1:0] ext_recv_bus,
    output wire [`MEM_SEND_BUS_WIDTH-1:0] SPC_send_bus,
    input wire [`MEM_RECV_BUS_WIDTH-1:0] SPC_recv_bus,
    output wire [`FID_WIDTH:0] AG_FID_bus,
    output wire [`FID_WIDTH:0] MEM_FID_bus,
    output wire [`FID_WIDTH:0] LSF_FID_bus,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] AG_FID_idx,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] MEM_FID_idx,
    input wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] LSF_FID_idx,
    output wire [32:0] dirty_bus
    );
    parameter INVALID_ID=0;
    parameter BASE_ID=1;
    parameter EXT_ID=2;
    parameter SPC_ID=3;
    wire [31:0] AG_PC, AG_IR, MEM_PC, MEM_IR, LSF_PC, LSF_IR;
    wire AG_MemLoad, MEM_MemLoad, AG_MemWrite, MEM_MemWrite;
    wire [31:0] AG_EXTD, AG_RD1, AG_RD2, MEM_RD2, MEM_D_w, MEM_D_r, AG_vaddr, MEM_D;
    wire [31:0] MEM_vaddr;
    wire [4:0] AG_WA, MEM_WA, LSF_WA;
    wire AG_RegWrite, MEM_RegWrite, LSF_RegWrite;
    wire AG_LB_SB, MEM_LB_SB;
    wire [19:0] AG_paddr_wd, MEM_paddr_wd;
    wire [1:0] AG_dst, MEM_dst; 
    wire [1:0] AG_pad, MEM_pad;
    wire [31:0] MEM_D_r_ori;
    wire [3:0] AG_be, MEM_be;
    wire MEM_sup, LSF_sup;
    wire AG_FID_v, MEM_FID_v, LSF_FID_v;
    wire [`FID_WIDTH-1:0] AG_FID, MEM_FID, LSF_FID;
    wire [`MEM_SEND_BUS_WIDTH-1:0] MEM_send_bus_ori;
    wire [`MEM_RECV_BUS_WIDTH-1:0] MEM_recv_bus_arr[3:0];
    wire [31:0] LSF_D, AG_ll, AG_lh, AG_hl, AG_hh, MEM_ll, MEM_lh, MEM_hl, MEM_hh, MEM_HI, MEM_LO;
    wire MEM_new_one, AG_MUL, MEM_MUL, AG_new_one;
    wire dirty_start;
    wire [31:0] dir_vaddr;
    wire [31:0] AG_DIV_D, MEM_DIV_D;
    pipeline_stage 
    #(.BUS_WIDTH(`ID2LS_BUS_WIDTH))
    ID2AG(
        .clk(clk),
        .reset(reset),
        .en(ID2AG_en),
        .cl(ID2AG_cl),
        .bus_i(ID2LS_bus),
        .bus_o({AG_PC, AG_FID, AG_FID_v, AG_IR, AG_MemLoad, AG_MemWrite, AG_EXTD, AG_RD1, AG_RD2, AG_RegWrite, AG_LB_SB, AG_WA, AG_MUL}),
        .new_one(AG_new_one)
    );
    
//    assign dirty_start=AG_MemWrite&AG_new_one;
//    assign dirty_vaddr=AG_vaddr;
    assign AG_rel_bus={32'd0, AG_WA, AG_FID_idx, AG_RegWrite, 1'd0};
    assign AG_FID_bus={AG_FID_v, AG_FID};
    assign AG_vaddr=AG_RD1+AG_EXTD;
    assign AG_pad=AG_vaddr[1:0];
    assign AG_ll=$unsigned(AG_RD1[15:0])*$unsigned(AG_RD2[15:0]);
    assign AG_lh=$unsigned(AG_RD1[15:0])*$unsigned(AG_RD2[31:16]);
    assign AG_hl=$unsigned(AG_RD1[31:16])*$unsigned(AG_RD2[15:0]);
    assign AG_hh=$unsigned(AG_RD1[31:16])*$unsigned(AG_RD2[31:16]);
    ADDR_MAPPING_v2 addr_mapping(
        .vaddr(AG_vaddr),
        .paddr_wd(AG_paddr_wd),
        .dst(AG_dst)//0:invalid 1: base 2: ext 3: spc
    );
    DIV DIV(
        .clk(clk), 
        .reset(reset),
        .en(AG_MUL), 
        .new_one(AG_new_one),
        .A(AG_RD1), //dividend
        .B(AG_RD2), //divisor
        .R(AG_DIV_D),
        .stall(AG_stall)
    );
    pipeline_stage 
    #(.BUS_WIDTH(`AG2MEM_BUS_WIDTH))
    AG2MEM(
        .clk(clk),
        .reset(reset),
        .en(AG2MEM_en),
        .cl(AG2MEM_cl),
        .bus_i({AG_PC, AG_FID, AG_FID_v, AG_IR, AG_RegWrite, AG_WA, AG_RD2, AG_paddr_wd, AG_pad, AG_dst, AG_MemLoad, AG_MemWrite, AG_LB_SB, AG_MUL, AG_DIV_D, AG_vaddr}),
        .bus_o({MEM_PC, MEM_FID, MEM_FID_v, MEM_IR, MEM_RegWrite, MEM_WA, MEM_RD2, MEM_paddr_wd, MEM_pad, MEM_dst, MEM_MemLoad, MEM_MemWrite, MEM_LB_SB, MEM_MUL, MEM_DIV_D, MEM_vaddr}),
        .new_one(MEM_new_one)
    );
    //MEM
    data_transformer data_transformer(
        .data_w_ori(MEM_RD2),
        .data_r_ori(MEM_D_r_ori),
        .pad(MEM_pad),
        .LB_SB(MEM_LB_SB),
        .be(MEM_be), 
        .data_w(MEM_D_w),
        .data_r(MEM_D_r)

    );
    transceiver transceiver(
        .clk(clk), 
        .reset(reset),
        .stall(DM_stall),
        .oe(MEM_MemLoad), 
        .we(MEM_MemWrite),
        .new_one(MEM_new_one),
        .be(MEM_be),
        .paddr_wd(MEM_paddr_wd),
        .data_w(MEM_D_w),
        .data_r_ori(MEM_D_r_ori),
        // MEM BUS
        .send_bus(MEM_send_bus_ori),
        .recv_bus(MEM_recv_bus_arr[MEM_dst])
    );
    assign dirty_start=MEM_MemWrite&MEM_new_one;
    assign dirty_vaddr=MEM_vaddr;
    assign dirty_bus = {dirty_start, MEM_vaddr};
//    assign MEM_LO=MEM_ll+{MEM_lh[15:0],16'b0}+{MEM_hl[15:0], 16'b0};
//    assign MEM_HI={16'b0,MEM_lh[31:16]}+{16'b0,MEM_hl[31:16]}+MEM_hh;
    assign MEM_FID_bus={MEM_FID_v, MEM_FID};
    assign MEM_D=MEM_MUL?MEM_DIV_D:MEM_D_r;
    assign MEM_rel_bus={MEM_D, MEM_WA, MEM_FID_idx, MEM_RegWrite, 1'd1};
    assign MEM_sup=(MEM_RegWrite&&!MEM_WA);
    assign base_send_bus=(MEM_dst==BASE_ID)?MEM_send_bus_ori:0;
    assign ext_send_bus=(MEM_dst==EXT_ID)?MEM_send_bus_ori:0;
    assign SPC_send_bus=(MEM_dst==SPC_ID)?MEM_send_bus_ori:0;

    assign MEM_recv_bus_arr[INVALID_ID]=0;
    assign MEM_recv_bus_arr[BASE_ID]=base_recv_bus;
    assign MEM_recv_bus_arr[EXT_ID]=ext_recv_bus;
    assign MEM_recv_bus_arr[SPC_ID]=SPC_recv_bus;
    pipeline_stage 
    #(.BUS_WIDTH(`FU2RO_BUS_WIDTH))
    MEM2LSF(
        .clk(clk),
        .reset(reset),
        .en(MEM2LSF_en),
        .cl(MEM2LSF_cl),
        .bus_i({MEM_PC, MEM_FID, MEM_FID_v, MEM_IR, MEM_RegWrite, MEM_sup, MEM_WA, MEM_D}),
        .bus_o({LSF_PC, LSF_FID, LSF_FID_v, LSF_IR, LSF_RegWrite, LSF_sup, LSF_WA, LSF_D})
    );
    //LSF
    assign LSF_FID_bus={LSF_FID_v, LSF_FID};
    assign LSF_rel_bus={LSF_D, LSF_WA, LSF_FID_idx, LSF_RegWrite, 1'd1};
    assign LS2RO_bus={LSF_PC, LSF_FID, LSF_FID_v, LSF_IR, LSF_RegWrite, LSF_sup, LSF_WA, LSF_D};
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/19 22:21:09
// Design Name: 
// Module Name: bridge
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
module bridge(
    input wire clk,reset,
    //DM_transceiver
    input wire DM_start_req,
    input wire [31:0]DM_vaddr_req,
    input wire [31:0]DM_data_req,
    input wire DM_write_req,
    input wire [3:0] DM_be_req,
    output reg [31:0]DM_data_resp,
    output reg DM_end_resp,
    //icache
    input wire IC_send_req,
    input wire [31:0]IC_word_size_req,
    input wire [31:0] IC_start_vaddr_req,
    output reg IC_ready_resp,
    output reg [32*`BLOCK_SIZE-1:0] IC_data_bus_resp,
    //base_ram
    output reg base_start_req,
    output reg [31:0] base_data_w_req,//单字写入数据
    output reg [19:0] base_start_ram_addr_req,// 字偏移
    output reg [31:0] base_word_size_req,//要从sram读入的字数
    output reg [3:0] base_be_req,
    output reg base_write_req,
    input wire [31:0] base_data_resp, //单字，就是总线的低32位
    input wire base_end_resp,
    input wire [32*`BLOCK_SIZE-1:0] base_data_bus_resp, //多字
    //ext_ram
    output reg ext_start_req,
    output reg [31:0] ext_data_w_req,//单字写入数据
    output reg [19:0] ext_start_ram_addr_req,// 字偏移
    output reg [31:0] ext_word_size_req,//要从sram读入的字数
    output reg [3:0] ext_be_req,
    output reg ext_write_req,
    input wire [31:0] ext_data_resp, //单字，就是总线的低32位
    input wire ext_end_resp,
    input wire [32*`BLOCK_SIZE-1:0] ext_data_bus_resp, //多字
    //SPC 异步握手写了，但是没有检查对错
    output reg SPC_start_req,
    output reg [31:0] SPC_WD,
    output reg SPC_WE,//1有效
    output reg SPC_RE,//1有效
    output reg SPC_addr,
    input wire [31:0] SPC_RD,
    input wire SPC_end_resp
    );
    wire [19:0] DM_paddr_wd; 
    wire [19:0]IC_start_paddr_wd;
    wire [1:0] DM_dst, IC_dst;
    ADDR_MAPPING_v2 DM_addr_mapping(
        .vaddr(DM_vaddr_req),
        .paddr_wd(DM_paddr_wd),
        .dst(DM_dst)//0:invalid 1: base 2: ext 3: spc
    );
    ADDR_MAPPING_v2 IC_addr_mapping(
        .vaddr(IC_start_vaddr_req),
        .paddr_wd(IC_start_paddr_wd),
        .dst(IC_dst)//0:invalid 1: base 2: ext 3: spc
    );
    reg base_free, ext_free, spc_free;
    reg [1:0]base_src, ext_src, base_src_nxt, ext_src_nxt;//0,3:invalid, 1:from icache, 2: from DM
    reg [1:0] IC_src, IC_src_nxt;//0,3:, 1:base, 2:ext
    reg [1:0] DM_src, DM_src_nxt;//0:invalid, 1:base, 2:ext, 3:spc
    reg SPC_src, SPC_src_nxt;//0: invalid, 1: DM
    (*ASYNC_REG="true"*)reg base_end_resp_d, ext_end_resp_d, SPC_end_resp_d;
    always @(*) begin
        case (IC_src)
            1: begin//base
//                IC_ready_resp=base_end_resp;
                IC_data_bus_resp=base_data_bus_resp;
            end
            2: begin//ext
//                IC_ready_resp=ext_end_resp;
                IC_data_bus_resp=ext_data_bus_resp;
            end
            default: begin
//                IC_ready_resp=0;
                IC_data_bus_resp=0;
            end
        endcase 
        case (DM_src) 
            1: begin//base
                DM_data_resp=base_data_resp;
//                DM_end_resp=base_end_resp;
            end
            2: begin//ext
                DM_data_resp=ext_data_resp;
//                DM_end_resp=ext_end_resp; 
            end
            3: begin
                DM_data_resp=SPC_RD;
//                DM_end_resp=SPC_end_resp;
            end 
            default: begin
                DM_data_resp=0;
//                DM_end_resp=0;
            end
        endcase
//        case(base_src) 
//            1: begin//IC
//                base_start_req=IC_send_req;
//                base_start_ram_addr_req=IC_start_paddr_wd;
//                base_word_size_req=IC_word_size_req;
//                base_be_req=0;
//                base_write_req=0;
//            end
//            2: begin//DM
//                base_start_req=DM_start_req;
//                base_data_w_req=DM_data_req;
//                base_start_ram_addr_req=DM_paddr_wd;
//                base_word_size_req=1;
//                base_be_req=DM_be_req;
//                base_write_req=DM_write_req;
//            end
//            default: begin
//                base_start_req=0;
//                base_data_w_req=0;
//                base_start_ram_addr_req=0;
//                base_word_size_req=1;
//                base_be_req=0;
//                base_write_req=0;
//            end
//        endcase
//        case(ext_src) 
//            1: begin//IC
//                ext_start_req=IC_send_req;
//                ext_start_ram_addr_req=IC_start_paddr_wd;
//                ext_word_size_req=IC_word_size_req;
//                ext_be_req=0;
//                ext_write_req=0;
//            end
//            2: begin//DM
//                ext_start_req=DM_start_req;
//                ext_data_w_req=DM_data_req;
//                ext_start_ram_addr_req=DM_paddr_wd;
//                ext_word_size_req=1;
//                ext_be_req=DM_be_req;
//                ext_write_req=DM_write_req;
//            end
//            default: begin
//                ext_start_req=0;
//                ext_data_w_req=0;
//                ext_start_ram_addr_req=0;
//                ext_word_size_req=1;
//                ext_be_req=0;
//                ext_write_req=0;
//            end
//        endcase
//        case (SPC_src)
//            1: begin
//                SPC_start_req=DM_start_req;
//                SPC_WD=DM_data_req;
//                SPC_WE=DM_write_req;
//                SPC_RE=!DM_write_req;
//                SPC_addr=DM_paddr_wd[0:0];
//            end
//            default: begin
//                SPC_start_req=0;
//                SPC_WD=0;
//                SPC_WE=0;
//                SPC_RE=0;
//                SPC_addr=0;
//            end
//        endcase
    end
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            base_free<=1;
            ext_free<=1;
            spc_free<=1;
            base_src<=0;
            ext_src<=0;
            SPC_src<=0;
            DM_src<=0;
            IC_src<=0;
//            base_src_nxt<=0;
//            ext_src_nxt<=0;
//            SPC_src_nxt<=0;
//            DM_src_nxt<=0;
//            IC_src_nxt<=0;
            base_end_resp_d<=0;
            ext_end_resp_d<=0;
        end
        else begin
            if (base_free) begin
                if (DM_start_req&DM_dst==1) begin
                    base_start_req<=1;
                    base_data_w_req<=DM_data_req;
                    base_start_ram_addr_req<=DM_paddr_wd;
                    base_word_size_req<=1;
                    base_be_req<=DM_be_req;
                    base_write_req<=DM_write_req;
                    DM_end_resp<=DM_write_req;//
//                    base_src<=2;
                    DM_src<=1;
                    base_free<=0;
                end
                else if (IC_send_req&IC_dst==1) begin
//                    base_src<=1;
                    IC_src<=1;
                    base_start_req<=1;
                    base_start_ram_addr_req<=IC_start_paddr_wd;
                    base_word_size_req<=IC_word_size_req;
                    base_be_req<=0;
                    base_write_req<=0;
                    IC_ready_resp<=0;
                    base_free<=0;
                end
            end
            else begin
                if (DM_src==1) begin
                    if (base_write_req) begin
                        DM_end_resp<=0;
                    end
                    else if (base_end_resp) begin
                        DM_end_resp<=1;
                        base_free<=1;
                    end
                end
                if (!DM_start_req&!base_end_resp&base_src==2)begin
                    base_src<=0;
                    DM_src<=0;
                    base_free<=1;
                end
                else if (!IC_send_req&!base_end_resp&base_src==1)begin
                    base_src<=0;
                    IC_src<=0;
                    base_free<=1;
                end
            end
            if (ext_free) begin
                if (DM_start_req&DM_dst==2) begin
                    ext_src<=2;
                    DM_src<=2;
                    ext_free<=0;
                end
                else if (IC_send_req&IC_dst==2) begin
                    ext_src<=1;
                    IC_src<=2;
                    ext_free<=0;
                end
            end
            else begin
                if (!DM_start_req&!ext_end_resp&ext_src==2)begin
                    ext_src<=0;
                    DM_src<=0;
                    ext_free<=1;
                end
                else if (!IC_send_req&!ext_end_resp&ext_src==1)begin
                    ext_src<=0;
                    IC_src<=0;
                    ext_free<=1;
                end
            end
            if (DM_dst==3) begin
                if (DM_start_req) begin
                    SPC_src<=1;
                    DM_src<=3;
                end
                else if (!SPC_end_resp) begin
                    SPC_src<=0;
                    DM_src<=0;
                end
            end
        end
        base_end_resp_d<=base_end_resp;
        ext_end_resp_d<=ext_end_resp;
        SPC_end_resp_d<=SPC_end_resp;
    end
endmodule

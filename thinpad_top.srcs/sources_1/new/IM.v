`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 16:42:26
// Design Name: 
// Module Name: IM
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


module IM(
    input wire clk,
    input wire reset,
    input wire[31:0] vaddr,
    input wire DM_USE_BASE,
    
    output reg [31:0] IR,
    input wire[31:0] base_ram_data_R,  //BaseRAM数据，低8位与CPLD串口控制器共享
//    output wire [31:0] base_ram_data_o,
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n       //BaseRAM写使能，低有效
    );
    wire [19:0]paddr;
    ADDR_MAPPING addr_mapping(
        .vaddr(vaddr),
        .paddr(paddr) 
    );
//    parameter [31:0] BASE_RAM_START=32'h80000000;
//    parameter [31:0] EXT_RAM_START=32'h80400000;
//    wire is_base=(vaddr<EXT_RAM_START);
//    wire [31:0] trans_addr=is_base?vaddr-BASE_RAM_START:vaddr-EXT_RAM_START;
//    wire [19:0] raddr=trans_addr[21:2];
    always @(negedge clk,  posedge reset) begin
        if (reset) begin
            IR<=0;
        end
        else if(!clk) begin
            IR<=base_ram_data_R;
        end
    end
//    assign base_ram_data=32'bz;
//    wire [31:0] trans_addr=vaddr-BASE_RAM_START;
    
    assign base_ram_addr=clk|!DM_USE_BASE?paddr:20'dz;
    assign base_ram_be_n=clk|!DM_USE_BASE?4'd0:4'dz;
    assign base_ram_ce_n=clk|!DM_USE_BASE?1'd0:1'dz;
    assign base_ram_oe_n=clk|!DM_USE_BASE?1'd0:1'dz;
    assign base_ram_we_n=clk|!DM_USE_BASE?1'd1:1'dz;
    
endmodule

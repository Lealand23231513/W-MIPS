`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 22:17:31
// Design Name: 
// Module Name: DM
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


module DM(
    input wire clk,
    input wire reset,
    input wire [31:0] vaddr,
//    input wire ce,//高有效
    input wire oe,//高有效
    input wire we,//高有效
    input wire LB_SB,
    input wire [31:0] mem_data_in,//输入DM的data
    output wire [31:0] mem_data_out,//从DM读出的data
    inout wire [31:0] ext_ram_data,
    output wire [19:0] ext_ram_addr,
    output wire [3:0]ext_ram_be_n,
    output wire ext_ram_ce_n,
    output wire ext_ram_oe_n,
    output wire ext_ram_we_n,
    input wire [31:0] base_ram_data_R,
    output reg [31:0] base_ram_data_W,
    output wire [19:0] base_ram_addr,
    output wire [3:0]base_ram_be_n,
    output wire base_ram_ce_n,
    output wire base_ram_oe_n,
    output wire base_ram_we_n,
    output wire [31:0] SPC_WD,
    output wire SPC_WE,//高有效
    input wire [31:0] SPC_RD,
    output wire [19:0] SPC_addr,
    output wire DM_USE_BASE
    );
    wire [1:0] addr_offset;
    wire [19:0] paddr;
    wire ISSA;//1表示访问串口控制器,0表示访问RAM
    wire ISEXT;
    ADDR_MAPPING addr_mapping(
        .vaddr(vaddr),
        .paddr(paddr),
        .offset(addr_offset),
        .ISSA(ISSA),
        .ISEXT(ISEXT)
    );
//    always @(negedge clk, posedge reset) begin
//        if (reset) DM_USE_BASE<=0;
//        else DM_USE_BASE<=!ISEXT&!clk&(we|oe);
//    end
    wire WriteRam=we&!clk;
    wire ReadRam=oe&!clk;
    assign DM_USE_BASE=(WriteRam|ReadRam)&!ISEXT;
    assign base_ram_addr=DM_USE_BASE?paddr:19'dz;
    assign ext_ram_addr=ISEXT?paddr:19'dz;
    assign SPC_addr=paddr;
    assign ext_ram_ce_n=ISEXT&!clk?ISSA:1'dz;
    assign base_ram_ce_n=DM_USE_BASE?ISSA:1'dz;

    wire [31:0] DataRead=ISSA?SPC_RD:
                          ISEXT?ext_ram_data:base_ram_data_R;
    wire [7:0] membyte= (addr_offset==2'd0)?DataRead[7:0]:
                        (addr_offset==2'd1)?DataRead[15:8]:
                        (addr_offset==2'd2)?DataRead[23:16]:
                        DataRead[31:24];
    wire [3:0] be = LB_SB?
                        ((addr_offset==2'd0)?4'b1110:
                         (addr_offset==2'd1)?4'b1101:
                         (addr_offset==2'd2)?4'b1011:4'b0111)
                        :4'b0000;
    assign ext_ram_be_n=ISEXT&!clk?be:4'dz;
    assign base_ram_be_n=DM_USE_BASE?be:4'dz;
    
    wire [7:0] databyte=mem_data_in[7:0];
    wire [31:0] data2mem=LB_SB?(
                        (addr_offset==2'd0)?{24'd0,databyte}:
                        (addr_offset==2'd1)?{16'd0,databyte,8'd0}:
                        (addr_offset==2'd2)?{8'd0,databyte,16'd0}:
                        {databyte,24'd0}
                        ):mem_data_in;
    assign mem_data_out=LB_SB?{{24{membyte[7]}}, membyte}:DataRead;
    assign ext_ram_data=WriteRam&ISEXT?data2mem:32'bz;
    always @(*) begin
        base_ram_data_W<=WriteRam&!ISEXT?data2mem:32'bz;
    end
//    assign 
    assign SPC_WD=data2mem;
    assign SPC_WE=ISSA&we;
    assign ext_ram_oe_n=!(ReadRam&ISEXT);
    assign base_ram_oe_n=DM_USE_BASE?!ReadRam:1'dz;
    assign ext_ram_we_n=!(WriteRam&ISEXT);
    assign base_ram_we_n=DM_USE_BASE?!WriteRam:1'dz;
endmodule
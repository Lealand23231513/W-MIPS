`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/17 21:38:12
// Design Name: 
// Module Name: sim_cache
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


module sim_cache(

    );
//    reg [7:0] data;
//    wire busy;
//    reg start;
//    reg send;
    reg clk;
    reg reset;
    parameter HALF_CYCLE = 10;
    always #HALF_CYCLE begin
        clk = ~clk;
    end
    wire [31:0]base_ram_data;
    wire[19:0] base_ram_addr;
    wire[3:0] base_ram_be_n;
    wire base_ram_ce_n;
    wire base_ram_oe_n;
    wire base_ram_we_n;
//    reg [31:0] vaddr;
    wire [31:0] IR_lst;
    wire[31:0] ext_ram_data;
    wire[19:0] ext_ram_addr;
    wire[3:0] ext_ram_be_n;
    wire ext_ram_ce_n;
    wire ext_ram_oe_n;
    wire ext_ram_we_n;
//    reg [31:0]dip_sw;
//    wire txd;
//    wire [15:0] leds;
//    wire  rxd;
    ram #(.lab(6), .ADDR_WIDTH(10), .random_code(1)) 
    base_ram(
    .ram_data(base_ram_data),  
    .ram_addr(base_ram_addr), 
    .ram_be_n(base_ram_be_n),
    .ram_ce_n(base_ram_ce_n),       
    .ram_oe_n(base_ram_oe_n),       
    .ram_we_n(base_ram_we_n),       
    .clk(clk)
    );
    
    ram #(.lab(6), .ADDR_WIDTH(10), .ISEXT(1))
    ext_ram(
    .ram_data(ext_ram_data),  
    .ram_addr(ext_ram_addr), 
    .ram_be_n(ext_ram_be_n),
    .ram_ce_n(ext_ram_ce_n),       
    .ram_oe_n(ext_ram_oe_n),       
    .ram_we_n(ext_ram_we_n),       
    .clk(clk)
    );
    
    
    test_cache test_cache(
    .clk_50M(clk),           //50MHz 时钟输入
//    .clk_11M0592(clk),
//    .clock_btn(clk),
    .reset_btn(reset),
//    .dip_sw(dip_sw),
//    .leds(leds),
//    .vaddr(vaddr),
//    .IR_lst(IR_lst),

    //BaseRAM信号
    .base_ram_data(base_ram_data),  //BaseRAM数据，低8位与CPLD串口控制器共享
    .base_ram_addr(base_ram_addr), //BaseRAM地址
    .base_ram_be_n(base_ram_be_n),  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    .base_ram_ce_n(base_ram_ce_n),       //BaseRAM片选，低有效
    .base_ram_oe_n(base_ram_oe_n),       //BaseRAM读使能，低有效
    .base_ram_we_n(base_ram_we_n),       //BaseRAM写使能，低有效

    //ExtRAM信号
    .ext_ram_data(ext_ram_data),  //ExtRAM数据
    .ext_ram_addr(ext_ram_addr), //ExtRAM地址
    .ext_ram_be_n(ext_ram_be_n),  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    .ext_ram_ce_n(ext_ram_ce_n),       //ExtRAM片选，低有效
    .ext_ram_oe_n(ext_ram_oe_n),       //ExtRAM读使能，低有效
    .ext_ram_we_n(ext_ram_we_n)      //ExtRAM写使能，低有效
    );
    integer i;
    initial begin
        clk=0;
        #5
        reset=1;
        #20
        reset=0;
//        for (i=0;i<32;i=i+1) begin
//            #20
//            vaddr=i;
//        end
    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/09 21:36:18
// Design Name: 
// Module Name: sim_cpu_lab2
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

//`define SIMULATION
module sim_cpu_lab2(

    );
    reg clk;
    wire clk_core;
    reg reset;
    parameter HALF_CYCLE = 10;
//    parameter SPC_CYCLE=5;
    parameter SPC_CYCLE=7.142857;
    always #HALF_CYCLE begin
        clk = ~clk;
    end
    wire [31:0]base_ram_data;
    wire[19:0] base_ram_addr;
    wire[3:0] base_ram_be_n;
    wire base_ram_ce_n;
    wire base_ram_oe_n;
    wire base_ram_we_n;
    
    wire[31:0] ext_ram_data;
    wire[19:0] ext_ram_addr;
    wire[3:0] ext_ram_be_n;
    wire ext_ram_ce_n;
    wire ext_ram_oe_n;
    wire ext_ram_we_n;
    reg [31:0]dip_sw;
    wire txd;
    wire [15:0] leds;
    wire clk_140m;
    reg  rxd;
    ram #(.lab(2)) 
    base_ram(
    .ram_data(base_ram_data),  
    .ram_addr(base_ram_addr[9:0]), 
    .ram_be_n(base_ram_be_n),
    .ram_ce_n(base_ram_ce_n),       
    .ram_oe_n(base_ram_oe_n),       
    .ram_we_n(base_ram_we_n),       
    .clk(clk_140m)
    );
    
    ram #(.random_code(32'h421), .lab(2))
    ext_ram(
    .ram_data(ext_ram_data),  
    .ram_addr(ext_ram_addr[9:0]), 
    .ram_be_n(ext_ram_be_n),
    .ram_ce_n(ext_ram_ce_n),       
    .ram_oe_n(ext_ram_oe_n),       
    .ram_we_n(ext_ram_we_n),       
    .clk(clk_140m)
    );
    
    
    cpu CPU(
    .clk_50M(clk),           //50MHz 时钟输入
    .clk_140m(clk_140m),
    .clk_core(clk_core),
    .clk_11M0592(clk),
    .clock_btn(clk),
    .reset_btn(reset),
    .dip_sw(dip_sw),
    .leds(leds),

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
    .ext_ram_we_n(ext_ram_we_n),      //ExtRAM写使能，低有效
    
    .txd(txd),  //直连串口发送端
    .rxd(rxd)  //直连串口接收端
    );
//    reg [31:0] r1,r2;
//    reg idx;
//    wire r2=(idx==1'dz)?1:1'dz;
    
    initial begin
//        idx=1'dz;
        reset=0;
        clk=0;
        dip_sw=0;
        dip_sw[1]=1'b1;
        rxd=1;
//        r1=$signed(32'h0xdbbad0b0)>>>32'h0x00000005;
//        $display("%x", r1);
        #5
        reset=1;
        #100
        reset=0;
        #15000
        //T
        rxd=0;
        #(3*SPC_CYCLE)
        rxd=1;
        #SPC_CYCLE
        rxd=0;
        #SPC_CYCLE
        rxd=1;
        #SPC_CYCLE
        rxd=0;
        #SPC_CYCLE
        rxd=1;
        #SPC_CYCLE
        rxd=0;
        #SPC_CYCLE
        rxd=1;
        
    end

endmodule

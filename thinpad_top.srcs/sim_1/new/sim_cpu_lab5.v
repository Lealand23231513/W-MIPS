`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/14 16:39:30
// Design Name: 
// Module Name: sim_cpu_lab5
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
module sim_cpu_lab5(

    );
    reg [7:0] data;
    wire busy;
    reg start;
    reg send;
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
    
    wire[31:0] ext_ram_data;
    wire[19:0] ext_ram_addr;
    wire[3:0] ext_ram_be_n;
    wire ext_ram_ce_n;
    wire ext_ram_oe_n;
    wire ext_ram_we_n;
    reg [31:0]dip_sw;
    wire txd;
    wire [15:0] leds;
    wire  rxd;
    wire clk_core;
    `ifdef CLK_200M
    parameter CLK_FREQ=200000000;
    `elsif CLK_100M
    parameter CLK_FREQ=100000000;
    `else
    parameter CLK_FREQ=140000000;
    `endif
    ram #(.lab(5), .ADDR_WIDTH(20), .random_code(1)) 
    base_ram(
    .ram_data(base_ram_data),  
    .ram_addr(base_ram_addr), 
    .ram_be_n(base_ram_be_n),
    .ram_ce_n(base_ram_ce_n),       
    .ram_oe_n(base_ram_oe_n),       
    .ram_we_n(base_ram_we_n),       
    .clk(clk_core)
    );
    
    ram #(.lab(5), .ADDR_WIDTH(20), .ISEXT(1))
    ext_ram(
    .ram_data(ext_ram_data),  
    .ram_addr(ext_ram_addr), 
    .ram_be_n(ext_ram_be_n),
    .ram_ce_n(ext_ram_ce_n),       
    .ram_oe_n(ext_ram_oe_n),       
    .ram_we_n(ext_ram_we_n),       
    .clk(clk_core)
    );
    
    
    cpu CPU(
    .clk_50M(clk),           //50MHz 时钟输入
    .clk_11M0592(clk),
    .clk_core(clk_core),
//    .clk_core(clk_140m),
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
    
    async_transmitter #(.ClkFrequency(CLK_FREQ),.Baud(9600)) //发送模块，9600无检验位
        ext_uart_t(
            .clk(clk_core),                  //外部时钟信号
            .TxD(rxd),                      //串行信号输出
            .TxD_busy(busy),       //发送器忙状态指示
            .TxD_start(start),    //开始发送信号
            .TxD_data(data)        //待发送的数据
    );
    always @(posedge clk_core) begin //将WD发送出去
        if(!busy&&send)begin 
            start <= 1;
        end else begin 
            start <= 0;
        end
    end
    initial begin
        reset=0;
        clk=0;
        dip_sw=0;
        dip_sw[1]=1'b1;
        data=0;
        send=0;
        #5
        reset=1;
        #100
        reset=0;
        #2100
        CPU.RGF.DataReg[2]=32'h7FFFF;
        CPU.RGF.DataReg[3]=32'h805FFFFC;
        CPU.RGF.DataReg[4]=32'h80400000;
        CPU.RGF.DataReg[5]=32'hdeadbeef;
        CPU.RGF.DataReg[6]=32'hfaceb00c;
        CPU.RGF.DataReg[7]=32'h100000;
        CPU.RGF.DataReg[8]=32'h80000;
        $display("%x", ext_ram.memory[32'h5beef]);
    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/13 23:19:33
// Design Name: 
// Module Name: sim_cpu_lab3
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
module sim_cpu_lab3(

    );
    reg [7:0] data;
    wire busy;
    reg start;
    reg send;
    reg clk;
    wire clk_200M, clk_140m, clk_core;
    reg reset;
    parameter HALF_CYCLE = 10;
    parameter SPC_CYCLE=5;
    always #HALF_CYCLE begin
        clk = ~clk;
    end
//    always #(SPC_CYCLE/2) begin
//        clk_200M = ~clk_200M;
//    end
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
    ram #(.lab(3), .ADDR_WIDTH(20)) 
    base_ram(
    `ifdef OVER_CLOCK
    .clk(clk_core),
    `else
    .clk(clk_140m),
    `endif
    .ram_data(base_ram_data),  
    .ram_addr(base_ram_addr), 
    .ram_be_n(base_ram_be_n),
    .ram_ce_n(base_ram_ce_n),       
    .ram_oe_n(base_ram_oe_n),       
    .ram_we_n(base_ram_we_n)   
    );
    
    ram #(.lab(3), .ADDR_WIDTH(20))
    ext_ram(
    `ifdef OVER_CLOCK
    .clk(clk_core),
    `else
    .clk(clk_140m),
    `endif
    .ram_data(ext_ram_data),  
    .ram_addr(ext_ram_addr), 
    .ram_be_n(ext_ram_be_n),
    .ram_ce_n(ext_ram_ce_n),       
    .ram_oe_n(ext_ram_oe_n),       
    .ram_we_n(ext_ram_we_n)       
    );
    
    
    cpu CPU(
    .clk_50M(clk),           //50MHz 时钟输入
    .clk_11M0592(clk),
    .clk_200m(clk_200M),
    .clk_140m(clk_140m),
    .clk_core(clk_core),
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
    
    async_transmitter #(.ClkFrequency(140000000),.Baud(9600)) //发送模块，9600无检验位
        ext_uart_t(
            .clk(clk_140m),                  //外部时钟信号
            .TxD(rxd),                      //串行信号输出
            .TxD_busy(busy),       //发送器忙状态指示
            .TxD_start(start),    //开始发送信号
            .TxD_data(data)        //待发送的数据
    );
    always @(posedge clk) begin //将WD发送出去
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
        #30000
        send=1;
        data=8'h44;
        #(5*SPC_CYCLE)
        send=0;
        #(1000)
        send=1;
        data=8'h00;
        #(5*SPC_CYCLE)
        send=0;
        #(1000)
        send=1;
        data=8'h00;
        #(5*SPC_CYCLE)
        send=0;
        #(1000)
        send=1;
        data=8'h00;
        #(5*SPC_CYCLE)
        send=0;
        #(1000)
        send=1;
        data=8'h80;
        #(5*SPC_CYCLE)
        send=0;
        #(1000)
        send=1;
        data=8'h40;
        #(5*SPC_CYCLE)
        send=0;
        #(1000)
        send=1;
        data=8'h00;
        #(5*SPC_CYCLE)
        send=0;
        #(1000)
        send=1;
        data=8'h00;
        #(5*SPC_CYCLE)
        send=0;
        #(1000)
        send=1;
        data=8'h00;
        #(5*SPC_CYCLE)
        send=0;
        
    end
endmodule

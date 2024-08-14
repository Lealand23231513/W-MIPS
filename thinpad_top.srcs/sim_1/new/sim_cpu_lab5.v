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
    .clk_50M(clk),           //50MHz ʱ������
    .clk_11M0592(clk),
    .clk_core(clk_core),
//    .clk_core(clk_140m),
    .clock_btn(clk),
    .reset_btn(reset),
    .dip_sw(dip_sw),
    .leds(leds),

    //BaseRAM�ź�
    .base_ram_data(base_ram_data),  //BaseRAM���ݣ���8λ��CPLD���ڿ���������
    .base_ram_addr(base_ram_addr), //BaseRAM��ַ
    .base_ram_be_n(base_ram_be_n),  //BaseRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    .base_ram_ce_n(base_ram_ce_n),       //BaseRAMƬѡ������Ч
    .base_ram_oe_n(base_ram_oe_n),       //BaseRAM��ʹ�ܣ�����Ч
    .base_ram_we_n(base_ram_we_n),       //BaseRAMдʹ�ܣ�����Ч

    //ExtRAM�ź�
    .ext_ram_data(ext_ram_data),  //ExtRAM����
    .ext_ram_addr(ext_ram_addr), //ExtRAM��ַ
    .ext_ram_be_n(ext_ram_be_n),  //ExtRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    .ext_ram_ce_n(ext_ram_ce_n),       //ExtRAMƬѡ������Ч
    .ext_ram_oe_n(ext_ram_oe_n),       //ExtRAM��ʹ�ܣ�����Ч
    .ext_ram_we_n(ext_ram_we_n),      //ExtRAMдʹ�ܣ�����Ч
    
    .txd(txd),  //ֱ�����ڷ��Ͷ�
    .rxd(rxd)  //ֱ�����ڽ��ն�
    );
    
    async_transmitter #(.ClkFrequency(CLK_FREQ),.Baud(9600)) //����ģ�飬9600�޼���λ
        ext_uart_t(
            .clk(clk_core),                  //�ⲿʱ���ź�
            .TxD(rxd),                      //�����ź����
            .TxD_busy(busy),       //������æ״ָ̬ʾ
            .TxD_start(start),    //��ʼ�����ź�
            .TxD_data(data)        //�����͵�����
    );
    always @(posedge clk_core) begin //��WD���ͳ�ȥ
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

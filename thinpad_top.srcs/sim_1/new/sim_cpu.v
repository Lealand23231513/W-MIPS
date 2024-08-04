`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/05 16:35:14
// Design Name: 
// Module Name: sim_cpu
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


module sim_cpu(

    );
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
    
    ram base_ram(
    .ram_data(base_ram_data),  
    .ram_addr(base_ram_addr[9:0]), 
    .ram_be_n(base_ram_be_n),
    .ram_ce_n(base_ram_ce_n),       
    .ram_oe_n(base_ram_oe_n),       
    .ram_we_n(base_ram_we_n),       
    .clk(clk)
    );
    
    ram ext_ram(
    .ram_data(ext_ram_data),  
    .ram_addr(ext_ram_addr[9:0]), 
    .ram_be_n(ext_ram_be_n),
    .ram_ce_n(ext_ram_ce_n),       
    .ram_oe_n(ext_ram_oe_n),       
    .ram_we_n(ext_ram_we_n),       
    .clk(clk)
    );
    
    
    cpu CPU(
    .clk_50M(clk),           //50MHz ʱ������
    .clock_btn(clk),
    .reset_btn(reset),
    .dip_sw(dip_sw),

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
    .ext_ram_we_n(ext_ram_we_n)      //ExtRAMдʹ�ܣ�����Ч
    );

    initial begin
        reset=1;
        clk=0;
        dip_sw=0;
        dip_sw[1]=1'b1;
        #100
        reset=0;
    end

endmodule

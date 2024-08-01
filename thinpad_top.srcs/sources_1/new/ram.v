`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/05 16:39:01
// Design Name: 
// Module Name: ram
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


module ram#(
    parameter ADDR_WIDTH=10,
    parameter random_code=0,
    parameter lab=1,
    parameter ISEXT=0
)(
    inout wire [31:0] ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    input wire[ADDR_WIDTH-1:0] ram_addr, //BaseRAM地址
    input wire[3:0] ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    input wire ram_ce_n,       //BaseRAM片选，低有效
    input wire ram_oe_n,       //BaseRAM读使能，低有效
    input wire ram_we_n,       //BaseRAM写使能，低有效
    input wire clk
    );

    reg [31:0] memory[2**ADDR_WIDTH-1:0];
    assign ram_data=(!ram_ce_n&!ram_oe_n&ram_we_n) ? 
                    {!ram_be_n[3]?memory[ram_addr][31:24]:8'hff,
                     !ram_be_n[2]?memory[ram_addr][23:16]:8'hff,
                     !ram_be_n[1]?memory[ram_addr][15:8]:8'hff,
                     !ram_be_n[0]?memory[ram_addr][7:0]:8'hff} 
                    : 32'dz;
//    assign ram_data=(!ram_ce_n&!ram_oe_n&ram_we_n) ? memory[ram_addr] : 32'dz;
    always @(posedge clk) begin
        if (!ram_ce_n&!ram_we_n)begin
//            memory[ram_addr]<=ram_data;
            memory[ram_addr]<={
                !ram_be_n[3]?ram_data[31:24]:8'd0,
                !ram_be_n[2]?ram_data[23:16]:8'd0,
                !ram_be_n[1]?ram_data[15:8]:8'd0,
                !ram_be_n[0]?ram_data[7:0]:8'd0
            };
        end
    end
    
    integer file_bin;
    integer code;
//    reg [31:0] mem [127:0];
    integer i,j,k;
    initial begin
        for (i=0;i<2**ADDR_WIDTH;i=i+1)begin
            memory[i]=0;
        end
        if (!ISEXT) begin
            if (lab==1) file_bin= $fopen("C:/Users/wang/Desktop/longxin/lab1.bin", "rb");
            else if (lab==2) file_bin= $fopen("C:/Users/wang/Desktop/longxin/lab2.bin", "rb");
            else if (lab==3) file_bin= $fopen("C:/Users/wang/Desktop/longxin/kernel.bin", "rb");
            else if (lab==4) file_bin= $fopen("C:/Users/wang/Desktop/longxin/test_UTEST_STREAM.bin", "rb");
            else if (lab==5) file_bin= $fopen("C:/Users/wang/Desktop/longxin/UTEST_CRYPTONIGHT_2.bin", "rb");
            else if (lab==6);
            else begin
                $display("wrong lab num!");
                $stop(0);
            end
            if (lab!=6) code = $fread(memory,file_bin);
    //        $readmemb("C:/Users/wang/Desktop/longxin/lab1.bin", memory);
    //        if (lab==3) begin
    //            $display("%x", memory[32'h800]);
    //        end
            for(i=0;i<code/4;i=i+1)begin
                k=memory[i];
                memory[i][31:24]=k[7:0];
                memory[i][23:16]=k[15:8];
                memory[i][15:8]=k[23:16];
                memory[i][7:0]=k[31:24];
            end
        end
        if (lab==2&&random_code) begin
            memory[32'h41]=random_code;
            memory[32'h42]=32'h7ead0521;
        end
        if (lab==4&&random_code) begin
//            memory[32'h20040000]=32'h12345678;
            for (i=0;i<100;i=i+1) begin
                memory[32'h20040000+i]=i+1;
            end
        end
        if (lab==5&&ISEXT) begin
            for (i=0;i<32'h80000;i=i+1)begin
                memory[i]=i;
            end
        end
        if (lab==6&&!ISEXT) begin
            for(i=0;i<1024;i=i+1) begin
                memory[i]=i;
            end
        end
    end


endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/09 19:12:56
// Design Name: 
// Module Name: SPC
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


module SPC(
    input wire clk,
    input wire reset,
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端
    input wire  paddr,
    input wire [31:0] WD,
    input wire WE, //1有效
    input wire RE,//1有效
    input wire start_req,
    input wire [1:0] DM_dst_req,
    output reg [31:0] RD,
    output reg end_resp,
    output reg DM_hold_resp,
    //test
    output wire [7:0] number
    );
    parameter CLK_FREQ=50000000;
    wire [7:0] ext_uart_rx;
    (*mark_debug = "true"*)reg  [7:0] ext_uart_buffer; 
    (*mark_debug = "true"*)reg [7:0]ext_uart_tx;//ext_uart_buffer要读入cpu储存串口数据
    assign number=ext_uart_buffer;
    wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
//    reg start_req_d;
    reg ext_uart_start,  ext_uart_recv;
    async_receiver #(.ClkFrequency(CLK_FREQ),.Baud(9600)) //接收模块，9600无检验位
        ext_uart_r(
            .clk(clk),                       //外部时钟信号
            .RxD(rxd),                           //外部串行信号输入
            .RxD_data_ready(ext_uart_ready),  //数据接收到标志
            .RxD_clear(ext_uart_clear),       //清除接收标志
            .RxD_data(ext_uart_rx)             //接收到的一字节数据
        );
    
    assign ext_uart_clear = ext_uart_ready; //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            end_resp<=0;
            DM_hold_resp<=0;
        end
        else if (start_req&!end_resp) begin
            end_resp<=1;
        end
        else if (!start_req&end_resp) begin
            end_resp<=0;
        end
    end
    always @(posedge clk, posedge reset) begin //接收到缓冲区ext_uart_buffer
        if (reset) begin
            ext_uart_buffer<=8'd0;
            ext_uart_recv<=1'd0;
            RD<=0;
        end
        else if(ext_uart_ready)begin
            ext_uart_buffer <= ext_uart_rx;
            ext_uart_recv <= 1'b1;
        end
        else if (RE & start_req & !end_resp & DM_dst_req==3) begin
            RD<=paddr?{30'd0, ext_uart_recv, !ext_uart_busy}:{24'd0, ext_uart_buffer};
            ext_uart_recv<=paddr?ext_uart_recv:1'b0;
            ext_uart_buffer<=paddr?ext_uart_buffer:8'd0;
        end
    end
    always @(posedge clk) begin //将WD发送出去
        if (reset) begin
            ext_uart_start<=1'd0;
            ext_uart_tx<=8'd0;
        end
        else if(!ext_uart_busy & WE & start_req & !end_resp & DM_dst_req==3)begin 
            ext_uart_tx <= WD[7:0];
            ext_uart_start <= 1;
        end else begin 
            ext_uart_start <= 0;
        end
    end
    
    async_transmitter #(.ClkFrequency(CLK_FREQ),.Baud(9600)) //发送模块，9600无检验位
        ext_uart_t(
            .clk(clk),                  //外部时钟信号
            .TxD(txd),                      //串行信号输出
            .TxD_busy(ext_uart_busy),       //发送器忙状态指示
            .TxD_start(ext_uart_start),    //开始发送信号
            .TxD_data(ext_uart_tx)        //待发送的数据
        );
endmodule

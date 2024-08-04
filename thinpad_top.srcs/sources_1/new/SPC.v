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
    output wire txd,  //ֱ�����ڷ��Ͷ�
    input  wire rxd,  //ֱ�����ڽ��ն�
    input wire  paddr,
    input wire [31:0] WD,
    input wire WE, //1��Ч
    input wire RE,//1��Ч
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
    (*mark_debug = "true"*)reg [7:0]ext_uart_tx;//ext_uart_bufferҪ����cpu���洮������
    assign number=ext_uart_buffer;
    wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
//    reg start_req_d;
    reg ext_uart_start,  ext_uart_recv;
    async_receiver #(.ClkFrequency(CLK_FREQ),.Baud(9600)) //����ģ�飬9600�޼���λ
        ext_uart_r(
            .clk(clk),                       //�ⲿʱ���ź�
            .RxD(rxd),                           //�ⲿ�����ź�����
            .RxD_data_ready(ext_uart_ready),  //���ݽ��յ���־
            .RxD_clear(ext_uart_clear),       //������ձ�־
            .RxD_data(ext_uart_rx)             //���յ���һ�ֽ�����
        );
    
    assign ext_uart_clear = ext_uart_ready; //�յ����ݵ�ͬʱ�������־����Ϊ������ȡ��ext_uart_buffer��
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
    always @(posedge clk, posedge reset) begin //���յ�������ext_uart_buffer
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
    always @(posedge clk) begin //��WD���ͳ�ȥ
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
    
    async_transmitter #(.ClkFrequency(CLK_FREQ),.Baud(9600)) //����ģ�飬9600�޼���λ
        ext_uart_t(
            .clk(clk),                  //�ⲿʱ���ź�
            .TxD(txd),                      //�����ź����
            .TxD_busy(ext_uart_busy),       //������æ״ָ̬ʾ
            .TxD_start(ext_uart_start),    //��ʼ�����ź�
            .TxD_data(ext_uart_tx)        //�����͵�����
        );
endmodule

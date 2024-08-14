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
    
    input wire[`MEM_SEND_BUS_WIDTH-1:0] LSU_send_bus,
    output wire[`MEM_RECV_BUS_WIDTH-1:0] LSU_recv_bus,
    //test
    output wire [7:0] number
    );
    parameter CLK_FREQ=50000000;
    wire [7:0] ext_uart_rx;
    (*mark_debug = "true"*)reg  [7:0] ext_uart_buffer; 
    (*mark_debug = "true"*)reg [7:0]ext_uart_tx;//ext_uart_bufferҪ����cpu���洮������
    assign number=ext_uart_buffer;
    wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
    wire start_req, write_req;
    wire [19:0] paddr_wd_req;
    wire paddr;
    wire [31:0] data_req;
    wire [3:0] be_req;
    reg recv_resp, end_resp;
    reg [31:0] data_resp;
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
    assign {start_req, paddr_wd_req, data_req, write_req, be_req}=LSU_send_bus;
    assign LSU_recv_bus={recv_resp, end_resp, data_resp};
    assign paddr=paddr_wd_req[0];
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            end_resp<=0;
            recv_resp<=0;
        end
        else if (start_req&!recv_resp) begin
            recv_resp<=1;
        end
        else if (!start_req&recv_resp) begin
            recv_resp<=0;
        end
        else if (start_req&recv_resp) begin
            recv_resp<=0;
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
            data_resp<=0;
        end
        else if(ext_uart_ready)begin
            ext_uart_buffer <= ext_uart_rx;
            ext_uart_recv <= 1'b1;
        end
        else if (!write_req & start_req & recv_resp) begin
            data_resp<=paddr?{30'd0, ext_uart_recv, !ext_uart_busy}:{24'd0, ext_uart_buffer};
            ext_uart_recv<=paddr?ext_uart_recv:1'b0;
            ext_uart_buffer<=paddr?ext_uart_buffer:8'd0;
        end
    end
    always @(posedge clk) begin //��WD���ͳ�ȥ
        if (reset) begin
            ext_uart_start<=1'd0;
            ext_uart_tx<=8'd0;
        end
        else if(!ext_uart_busy & write_req & start_req)begin 
            ext_uart_tx <= data_req[7:0];
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/09 23:18:00
// Design Name: 
// Module Name: sim_SPC
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


module sim_SPC(

    );
    reg clk;
    reg reset;
    parameter HALF_CYCLE = 10;
    always #HALF_CYCLE begin
        clk = ~clk;
    end
    reg [31:0]dip_sw;
    wire txd;
    wire [15:0] leds;
    wire  rxd;
    reg [3:0] touch_btn;
    
    test_SPC CPU(
    .clk_50M(clk),           //50MHz ʱ������
    .reset_btn(reset),
    .dip_sw(dip_sw),
    .leds(leds),
    .touch_btn(touch_btn),
    
    .txd(txd),  //ֱ�����ڷ��Ͷ�
    .rxd(rxd)  //ֱ�����ڽ��ն�
    );
    reg [7:0] data, data_buffer=0;
    wire busy;
    reg start;
    reg send;
    async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //����ģ�飬9600�޼���λ
        ext_uart_t(
            .clk(clk),                  //�ⲿʱ���ź�
            .TxD(rxd),                      //�����ź����
            .TxD_busy(busy),       //������æ״ָ̬ʾ
            .TxD_start(start),    //��ʼ�����ź�
            .TxD_data(data)        //�����͵�����
    );
    always @(posedge clk) begin //��WD���ͳ�ȥ
        if(!busy&&send)begin 
//            data_buffer <= data;
            start <= 1;
        end else begin 
            start <= 0;
        end
    end
    initial begin
//        idx=1'dz;
        reset=0;
        clk=0;
        dip_sw=0;
        dip_sw[1]=1'b1;
        touch_btn=0;
        send=0;
        #5
        reset=1;
        #100
        reset=0;
        touch_btn[0]=1;
        #105
        send=1;
        data=8'h44;
        #240
        data=8'h00;
        #240
        data=8'h00;
        #240
        data=8'h00;
        #240
        data=8'h80;
        #240
        data=8'h40;
        #240
        data=8'h00;
        #240
        data=8'h00;
        #240
        send=0;
//        data=8'h44;
//        #20
//        data=8'h00;
//        #20
//        data=8'h00;
//        #20
//        data=8'h00;
//        #20
//        data=8'h80;
//        #20
//        data=8'h40;
//        #20
//        data=8'h00;
//        #20
//        data=8'h00;
//        send=0;
//        #2000
//        reset=1;
//        #100
//        reset=0;
        
    end
endmodule

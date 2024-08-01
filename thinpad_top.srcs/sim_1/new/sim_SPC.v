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
    .clk_50M(clk),           //50MHz 时钟输入
    .reset_btn(reset),
    .dip_sw(dip_sw),
    .leds(leds),
    .touch_btn(touch_btn),
    
    .txd(txd),  //直连串口发送端
    .rxd(rxd)  //直连串口接收端
    );
    reg [7:0] data, data_buffer=0;
    wire busy;
    reg start;
    reg send;
    async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
        ext_uart_t(
            .clk(clk),                  //外部时钟信号
            .TxD(rxd),                      //串行信号输出
            .TxD_busy(busy),       //发送器忙状态指示
            .TxD_start(start),    //开始发送信号
            .TxD_data(data)        //待发送的数据
    );
    always @(posedge clk) begin //将WD发送出去
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

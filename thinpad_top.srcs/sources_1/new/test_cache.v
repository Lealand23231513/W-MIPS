`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 10:06:17
// Design Name: 
// Module Name: test_cache
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

module test_cache(
    input wire clk_50M,           //50MHz ʱ������
    input wire clk_11M0592,       //11.0592MHz ʱ�����루���ã��ɲ��ã�
    

    input wire clock_btn,         //BTN5�ֶ�ʱ�Ӱ�ť���أ���������·������ʱΪ1
    input wire reset_btn,         //BTN6�ֶ���λ��ť���أ���������·������ʱΪ1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4����ť���أ�����ʱΪ1
    input  wire[31:0] dip_sw,     //32λ���뿪�أ�����"ON"ʱΪ1
    output wire[15:0] leds,       //16λLED�����ʱ1����
    output wire[7:0]  dpy0,       //����ܵ�λ�źţ�����С���㣬���1����
    output wire[7:0]  dpy1,       //����ܸ�λ�źţ�����С���㣬���1����

    //BaseRAM�ź�
    inout wire[31:0] base_ram_data,  //BaseRAM���ݣ���8λ��CPLD���ڿ���������
    output wire[19:0] base_ram_addr, //BaseRAM��ַ
    output wire[3:0] base_ram_be_n,  //BaseRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output wire base_ram_ce_n,       //BaseRAMƬѡ������Ч
    output wire base_ram_oe_n,       //BaseRAM��ʹ�ܣ�����Ч
    output wire base_ram_we_n,       //BaseRAMдʹ�ܣ�����Ч

    //ExtRAM�ź�
    inout wire[31:0] ext_ram_data,  //ExtRAM����
    output wire[19:0] ext_ram_addr, //ExtRAM��ַ
    output wire[3:0] ext_ram_be_n,  //ExtRAM�ֽ�ʹ�ܣ�����Ч�������ʹ���ֽ�ʹ�ܣ��뱣��Ϊ0
    output wire ext_ram_ce_n,       //ExtRAMƬѡ������Ч
    output wire ext_ram_oe_n,       //ExtRAM��ʹ�ܣ�����Ч
    output wire ext_ram_we_n,       //ExtRAMдʹ�ܣ�����Ч

    //ֱ�������ź�
    output wire txd,  //ֱ�����ڷ��Ͷ�
    input  wire rxd,  //ֱ�����ڽ��ն�

    //Flash�洢���źţ��ο� JS28F640 оƬ�ֲ�
    output wire [22:0]flash_a,      //Flash��ַ��a0����8bitģʽ��Ч��16bitģʽ������
    inout  wire [15:0]flash_d,      //Flash����
    output wire flash_rp_n,         //Flash��λ�źţ�����Ч
    output wire flash_vpen,         //Flashд�����źţ��͵�ƽʱ���ܲ�������д
    output wire flash_ce_n,         //FlashƬѡ�źţ�����Ч
    output wire flash_oe_n,         //Flash��ʹ���źţ�����Ч
    output wire flash_we_n,         //Flashдʹ���źţ�����Ч
    output wire flash_byte_n,       //Flash 8bitģʽѡ�񣬵���Ч����ʹ��flash��16λģʽʱ����Ϊ1

    //ͼ������ź�
    output wire[2:0] video_red,    //��ɫ���أ�3λ
    output wire[2:0] video_green,  //��ɫ���أ�3λ
    output wire[1:0] video_blue,   //��ɫ���أ�2λ
    output wire video_hsync,       //��ͬ����ˮƽͬ�����ź�
    output wire video_vsync,       //��ͬ������ֱͬ�����ź�
    output wire video_clk,         //����ʱ�����
    output wire video_de           //��������Ч�źţ���������������
    );
//     reg reset;
//     wire clk;
//`ifdef USE_PLL
    reg reset_50M, reset_80M;
    wire locked, clk_10M, clk_20M, clk_80M;
//    parameter CLK_FREQ=80000000;
    pll_example clock_gen 
     (
      // Clock in ports
      .clk_in1(clk_50M),  // �ⲿʱ������
      // Clock out ports
      .clk_out1(clk_10M), // ʱ�����1��Ƶ����IP���ý���������
      .clk_out2(clk_20M), // ʱ�����2��Ƶ����IP���ý���������
      .clk_out3(clk_80M),
      // Status and control signals
      .reset(reset_btn|dip_sw[0]), // PLL��λ����
      .locked(locked)    // PLL����ָʾ�����"1"��ʾʱ���ȶ���
                         // �󼶵�·��λ�ź�Ӧ���������ɣ����£�
     );

//     �첽��λ��ͬ���ͷţ���locked�ź�תΪ�󼶵�·�ĸ�λreset
    always@(posedge clk_80M or negedge locked) begin
        if(~locked) reset_80M <= 1'b1;
        else        reset_80M <= 1'b0;
    end
//    assign clk=clk_80M;
    //clock   
//`else
//     generate reset
    reg rst_s1;
//    parameter CLK_FREQ=50000000;
    always @(posedge clk_50M or posedge reset_btn) begin
       if(reset_btn|dip_sw[0]) begin
           rst_s1 <= 1'b1;
           reset_50M <= 1'b1;
       end
       else begin
           rst_s1 <= 1'b0;
           reset_50M <= rst_s1;
       end
    end
//    assign clk=clk_50M;
//`endif
//    reg [31:0] i;
    reg [19:0] addr;
    reg [31:0] ext_data;
//    reg [31:0] data;
//    reg [31:0] dataRead;
    reg ce;
//    reg we;
    reg oe;
    reg ext_we;
    reg ext_ce;
    reg [19:0] ext_addr;
    assign base_ram_be_n=0;
    assign base_ram_ce_n=~ce;
    assign base_ram_oe_n=~oe;
    assign base_ram_we_n=1;
    assign ext_ram_be_n=0;
    assign ext_ram_ce_n=~ext_ce;
    assign ext_ram_oe_n=1;
    assign ext_ram_we_n=~ext_we;
//    assign base_ram_data=data;
    assign base_ram_addr=addr;
    assign ext_ram_addr=ext_addr;
    assign ext_ram_data=ext_data;
//    always @(posedge clk, posedge reset) begin
//        if (reset) begin
//            i<=0;
//            addr<=0;
//            data<=0;
//            ce<=0;
//            we<=0;
//        end
//        else begin
//            i<=i+1;
//            if (i%4==0) begin
//                addr<=i/4;
//                data<=i;     
//                ce<=0;
//                we<=0;      
//            end
//            else begin
//                ce<=1;
//                we<=1;
//            end

//        end
//    end
//    assign leds=i;
    
    reg [31:0] vaddr;
    reg [31:0] vaddr_lst;
    wire [31:0] vaddr_lst_trans;
    wire [19:0] start_paddr_req;
    reg [19:0] paddr_w;
    reg [31:0] data_w;
    reg valid;
    wire done;
    reg valid_w;
    //state
    reg base_ram_state;
    parameter FREE=0;
    parameter TRANSPORT=1;
//    parameter OFFSET_WIDTH=4;
    reg pre_transport;
    reg ext_free;
    reg stall;
    reg [1:0]sender_state;//0: free 1: send 2: end
    //EXT write bus
    reg start_w_req;
    reg end_w_resp;
    //Ram bus
    wire send_req;
    (*ASYNC_REG="true"*)reg send_req_d;
    wire [31:0] word_size_req;
    wire [31:0] start_vaddr_req;
    reg ready_resp;
    reg [31:0] data_resp[`BLOCK_SIZE-1:0];
    wire [32*`BLOCK_SIZE-1:0] data_bus_resp;
    wire done_lst;
    wire [31:0] IR_lst;
    reg base_ram_valid;
    reg data_prepared;
    reg [31:0] data_r[`BLOCK_SIZE-1:0];
    reg [31:0] num_finished;
    reg [31:0] num_send;
    integer i;
    genvar j;
    generate
        for (j=0;j<`BLOCK_SIZE;j=j+1) begin
            assign data_bus_resp[32*(j+1)-1:32*j]=data_resp[j];
        end
    endgenerate
    assign vaddr_lst_trans=vaddr_lst-32'h80000000;
    icache icache(
        .clk(clk_80M),
        .reset(reset_80M),
    //cpu bus
        .vaddr(vaddr),
        .valid(valid),
        .done(done),
        .done_lst(done_lst),
        .IR_lst(IR_lst),
    //RAM bus
        .send_req(send_req),
        .word_size_req(word_size_req),
        .start_vaddr_req(start_vaddr_req),
        .ready_resp(ready_resp),
        .data_bus_resp(data_bus_resp)
    );
    ADDR_MAPPING addr_mapping(
        .vaddr(start_vaddr_req),//4��OFFSET_WIDTH,��Ҫ����������
        .paddr(start_paddr_req) 
    );
    always @(*) begin
        valid=!stall;
    end
    always @(posedge clk_80M, posedge reset_80M) begin
        if (reset_80M) begin
            vaddr<=32'h80000000;
            vaddr_lst<=0;
            paddr_w<=0;
            data_w<=0;
            valid_w<=0;
            start_w_req<=0;
            stall<=0;
            sender_state<=0;
        end
        else begin
            if (done&!stall) begin
                if(vaddr<32'h80001000) vaddr<=vaddr+4;
                else vaddr<=vaddr;
                vaddr_lst<=vaddr;
            end
            case (sender_state) 
                0: begin//free
                    sender_state<=1;
                    paddr_w<=vaddr_lst_trans[21:2];
                    data_w<=IR_lst;
                    valid_w<=done_lst;
                    start_w_req<=1; 
                    stall<=1;  
                end
                1: begin//send
                    if (end_w_resp) begin
                        sender_state<=2;
                        start_w_req<=0;
                    end
                end
                2: begin//end
                    if (!end_w_resp) begin
                        sender_state<=0;
                        stall<=0;
                    end
                end
            endcase
        end
    end 
    always @(posedge clk_50M, posedge reset_50M) begin
        if (reset_50M) begin
            base_ram_state<=FREE;
            pre_transport<=0;
            addr<=0;
            send_req_d<=0;
            ce<=0;
            oe<=0;
            ext_addr<=0;
            ext_ce<=0;
            ext_we<=0;
            ext_data<=0;
            ready_resp<=0;
            end_w_resp<=0;
            base_ram_valid<=0;
            data_prepared<=0;
            num_finished<=0;
            num_send<=0;
            for(i=0;i<`BLOCK_SIZE;i=i+1)begin
                data_r[i]<=0;
                data_resp[i]<=0;
            end
        end
        else begin
            send_req_d<=send_req;
            case (base_ram_state) 
               FREE: begin
                    if(send_req_d) begin
                        base_ram_state<=TRANSPORT;
                        oe<=1;
                        ce<=1;
                        addr<=start_paddr_req;
                        num_finished<=1;
                        num_send<=0;
                    end
               end 
               TRANSPORT: begin
                    if (send_req_d) begin
                        //prepare data
                        if (num_finished<word_size_req) begin //׼������
                            data_resp[num_finished-1]<=base_ram_data;
                            addr<=addr+1;
                            num_finished<=num_finished+1;
                        end
                        else if(send_req_d&!ready_resp) begin //��ʼ����
                            data_resp[num_finished-1]<=base_ram_data;
                            ready_resp<=1;
                            oe<=0;
                            ce<=0;
                        end
                    end
                    else begin// trans to FREE���������
                        base_ram_state<=FREE;
                        ready_resp<=0;
                    end
               end
            endcase
            //ext read
            if (start_w_req) begin
                ext_we<=1;
                ext_ce<=1;
                ext_addr<=paddr_w;
                ext_data<=data_w;
                end_w_resp<=1;
            end
            else begin
                ext_we<=0;
                ext_ce<=0;
                ext_addr<=0;
                ext_data<=0;
                end_w_resp<=0;
            end
        end
    end
    
endmodule

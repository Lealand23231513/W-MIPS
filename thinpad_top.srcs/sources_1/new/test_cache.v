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
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）
    

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到"ON"时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
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
      .clk_in1(clk_50M),  // 外部时钟输入
      // Clock out ports
      .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
      .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
      .clk_out3(clk_80M),
      // Status and control signals
      .reset(reset_btn|dip_sw[0]), // PLL复位输入
      .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                         // 后级电路复位信号应当由它生成（见下）
     );

//     异步复位，同步释放，将locked信号转为后级电路的复位reset
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
        .vaddr(start_vaddr_req),//4是OFFSET_WIDTH,需要解决这个问题
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
                        if (num_finished<word_size_req) begin //准备数据
                            data_resp[num_finished-1]<=base_ram_data;
                            addr<=addr+1;
                            num_finished<=num_finished+1;
                        end
                        else if(send_req_d&!ready_resp) begin //开始发送
                            data_resp[num_finished-1]<=base_ram_data;
                            ready_resp<=1;
                            oe<=0;
                            ce<=0;
                        end
                    end
                    else begin// trans to FREE，传输结束
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 15:15:03
// Design Name: 
// Module Name: cpu
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


module cpu(
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
    //clock
    wire clk=clk_50M;
    
    // generate reset
    reg rst_s1;
    reg reset;
    always @(posedge clk or posedge reset_btn) begin
       if(reset_btn) begin
           rst_s1 <= 1'b1;
           reset <= 1'b1;
       end
       else begin
           rst_s1 <= 1'b0;
           reset <= rst_s1;
       end
    end
    
    //STAGE IF
    // IFU
    parameter EN=1;
    wire BEQ;
    wire BNE;
    wire EQUAL;
    wire JMP;
    wire JR;
    wire [31:0] ID_RD1;
    wire [31:0] ID_PC;
    wire [31:0] ID_IR;
    wire [31:0] PC;
    IFU IFU(
        .en(EN),
        .reset(reset),
        .clk(clk),
        .beq(BEQ),
        .bne(BNE),
        .equal(EQUAL),
        .jmp(JMP),
        .jr(JR),
        .id_rd1(ID_RD1),
        .id_pc(ID_PC),
        .id_ir(ID_IR),
        .pc(PC)
    );
    
    //IM
    wire [31:0] IR;
    IM IM(
    .vaddr(PC),
    .IR(IR),
    .base_ram_data(base_ram_data),  
    .base_ram_addr(base_ram_addr), 
    .base_ram_be_n(base_ram_be_n),  
    .base_ram_ce_n(base_ram_ce_n),       
    .base_ram_oe_n(base_ram_oe_n),       
    .base_ram_we_n(base_ram_we_n)       
    );
    
    //STAGE ID
    assign ID_IR=IR;
    assign ID_PC=PC;
    //controler
    wire[3:0] ALUOP;
    wire MemToReg;
    wire MemWrite;
    wire ALUSource;
    wire RegWrite;
    wire RegDst;
    wire EXTOP;
    wire LUI;
    wire JAL;
    wire MemLoad;
    wire RA1_READ;
    wire RA2_READ;
    controler controler(
    .IR(IR),
    .ALUOP(ALUOP),
    .BEQ(BEQ),
    .BNE(BNE),
    .MemToReg(MemToReg),
    .MemWrite(MemWrite),
    .ALUSource(ALUSource),
    .RegWrite(RegWrite),
    .RegDst(RegDst),
    .EXTOP(EXTOP),
    .LUI(LUI),
    .JMP(JMP),
    .JR(JR),
    .JAL(JAL),
    .MemLoad(MemLoad),
    .RA1_READ(RA1_READ),
    .RA2_READ(RA2_READ)
    );
    //GRF
    wire [4:0] rs=IR[25:21];
    wire [4:0] rt=IR[20:16];
    wire [4:0] rd=IR[15:11];
    wire [15:0] offset=IR[15:0];
    parameter [4:0]REG_RA=5'd31;
    wire [4:0] WA=JAL?REG_RA:
                  RegDst?rd:rt;
    wire [31:0] WB_WD;
    wire [31:0] WD=LUI?{offset,16'd0}:
                    JAL?PC+8:WB_WD;
    wire [31:0]RD1;
    wire [31:0]RD2;
    GRF GRF(
     .clk(clk),
     .WE(RegWrite),
     .reset(reset),
     .Ra1(rs),
     .Ra2(rt), 
     .WA(WA),
     .WD(WD),
     .Rd1(RD1),
     .Rd2(RD2)
     );
     //EXT
     wire [31:0] EXTD=EXTOP?{{16{offset[15]}}, offset}:{16'd0,offset};
     
     //STAGE EX
     //ALU
     wire [31:0] B=ALUSource ? EXTD : RD2;
     wire [31:0] R;
     wire OF;
     ALU ALU(
        .A(RD1),
        .B(B),
        .ALUOP(ALUOP),
        .R(R),
        .OF(OF),
        .EQUAL(EQUAL)
    );
    assign ID_RD1=RD1;
     //STAGE MEM
     //DM
     parameter [3:0]DM_BE=4'b1111;
     wire [31:0] MemDout;
//     wire [31:0] ext_ram_data_w;
     DM DM(
        .vaddr(R),
        .be(DM_BE),//高有效
        .ce(1),//高有效
        .oe(1),//高有效
        .we(MemWrite),//高有效
        .mem_data_in(RD2),//输入DM的data
        .mem_data_out(MemDout),//从DM读出的data
        .ext_ram_data(ext_ram_data),
        .ext_ram_addr(ext_ram_addr),
        .ext_ram_be_n(ext_ram_be_n),
        .ext_ram_ce_n(ext_ram_ce_n),
        .ext_ram_oe_n(ext_ram_oe_n),
        .ext_ram_we_n(ext_ram_we_n)
    );
    
    //STAGE WB
    assign WB_WD=MemToReg?MemDout:R;
    
    //for test
//    wire [31:0] disp=(!ext_ram_we_n)?ext_ram_data:32'bz;
    SEG7_LUT segL(.oSEG1(dpy0), .iDIG(IR[27:24])); //dpy0是低位数码管
    SEG7_LUT segH(.oSEG1(dpy1), .iDIG(IR[31:28])); //dpy1是高位数码管
    assign leds=IR[31:16];
//    assign ext_ram_data=ext_ram_data_w;
endmodule

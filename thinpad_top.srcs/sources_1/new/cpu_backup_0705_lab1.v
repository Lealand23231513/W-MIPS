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
        .be(DM_BE),//����Ч
        .ce(1),//����Ч
        .oe(1),//����Ч
        .we(MemWrite),//����Ч
        .mem_data_in(RD2),//����DM��data
        .mem_data_out(MemDout),//��DM������data
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
    SEG7_LUT segL(.oSEG1(dpy0), .iDIG(IR[27:24])); //dpy0�ǵ�λ�����
    SEG7_LUT segH(.oSEG1(dpy1), .iDIG(IR[31:28])); //dpy1�Ǹ�λ�����
    assign leds=IR[31:16];
//    assign ext_ram_data=ext_ram_data_w;
endmodule

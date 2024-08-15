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

`include "global_def.vh"
module cpu(
    input wire clk_50M,           //50MHz ʱ������
    input wire clk_11M0592,       //11.0592MHz ʱ�����루���ã��ɲ��ã�
    `ifdef SIMULATION
    output wire clk_200m,
    output wire clk_140m,
    output wire clk_core,
    `endif
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
    reg  reset;
    wire locked, clk_80M, clk_100M, clk_140M, clk_200M, clk_255M, clk_260M, clk_280M, clk_300M, clk;
    parameter CLK_80M_FREQ=80000000;
    parameter CLK_100M_FREQ=100000000;
    parameter CLK_140M_FREQ=140000000;
    parameter CLK_200M_FREQ=200000000;
    parameter CLK_225M_FREQ=225000000;
    parameter CLK_250M_FREQ=250000000;
    parameter CLK_255M_FREQ=255000000;
    parameter CLK_260M_FREQ=260000000;
    parameter CLK_300M_FREQ=300000000;
    parameter CLK_280M_FREQ=280000000;
    `ifdef CLK_300M
    parameter CLK_FREQ=CLK_300M_FREQ;
    assign clk=clk_300M;
    clk_gen_300M clk_gen_300M
    (
        // Clock out ports
        .clk_300M(clk_300M),     // output clk_250M
        // Status and control signals
        .reset(reset_btn), // input reset
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1(clk_50M)
     ); 
    `elsif CLK_280M
    parameter CLK_FREQ=CLK_280M_FREQ;
    assign clk=clk_280M;
    clk_gen_280M clk_gen_280M
    (
        // Clock out ports
        .clk_280M(clk_280M),     // output clk_250M
        // Status and control signals
        .reset(reset_btn), // input reset
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1(clk_50M)
     ); 
    `elsif CLK_260M
    parameter CLK_FREQ=CLK_260M_FREQ;
    assign clk=clk_260M;
    clk_gen_260M clk_gen_260M
    (
        // Clock out ports
        .clk_260M(clk_260M),     // output clk_250M
        // Status and control signals
        .reset(reset_btn), // input reset
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1(clk_50M)
     ); 
    `elsif CLK_255M
    parameter CLK_FREQ=CLK_255M_FREQ;
    assign clk=clk_255M;
    clk_gen_255M clk_gen_255M
    (
        // Clock out ports
        .clk_255M(clk_255M),     // output clk_255M
        // Status and control signals
        .reset(reset_btn), // input reset
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1(clk_50M)
     ); 
    `elsif CLK_250M
    parameter CLK_FREQ=CLK_250M_FREQ;
    assign clk=clk_250M;
    clk_gen_250M clk_gen_250M
    (
        // Clock out ports
        .clk_250M(clk_250M),     // output clk_250M
        // Status and control signals
        .reset(reset_btn), // input reset
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1(clk_50M)
     ); 
    `elsif CLK_225M
    parameter CLK_FREQ=CLK_225M_FREQ;
    assign clk=clk_225M;
    clk_gen_225M clk_gen_225M
    (
        // Clock out ports
        .clk_225M(clk_225M),     // output clk_250M
        // Status and control signals
        .reset(reset_btn), // input reset
        .locked(locked),       // output locked
       // Clock in ports
        .clk_in1(clk_50M)
     ); 
    `elsif CLK_200M
    parameter CLK_FREQ=CLK_200M_FREQ;
    assign clk=clk_200M;
    pll_example clock_gen 
     (
      // Clock in ports
      .clk_in1(clk_50M),  
      // Clock out ports
      .clk_100M(clk_100M),
      .clk_140M(clk_140M), 
      .clk_200M(clk_200M),
      // Status and control signals
      .reset(reset_btn), 
      .locked(locked)    
                         
     );
    `elsif CLK_100M
    parameter CLK_FREQ=CLK_100M_FREQ;
    assign clk=clk_100M;
    pll_example clock_gen 
     (
      // Clock in ports
      .clk_in1(clk_50M),  
      // Clock out ports
      .clk_100M(clk_100M),
      .clk_140M(clk_140M), 
      .clk_200M(clk_200M),
      // Status and control signals
      .reset(reset_btn), 
      .locked(locked)    
                         
     );
    `else
    parameter CLK_FREQ=CLK_140M_FREQ;
    assign clk=clk_140M;
    pll_example clock_gen 
     (
      // Clock in ports
      .clk_in1(clk_50M),  
      // Clock out ports
      .clk_100M(clk_100M),
      .clk_140M(clk_140M), 
      .clk_200M(clk_200M),
      // Status and control signals
      .reset(reset_btn), 
      .locked(locked)    
                         
     );
    `endif

//     �첽��λ��ͬ���ͷţ���locked�ź�תΪ�󼶵�·�ĸ�λreset
    always@(posedge clk or negedge locked) begin
        if(~locked) begin
            reset <= 1'b1;
        end
        else begin
            reset <= 1'b0;
        end
    end
    `ifdef SIMULATION
    assign clk_200m=clk_200M;
    assign clk_140m=clk_140M;
    assign clk_core=clk;
    `endif
    //IO_BUFFER
    wire [31:0]base_ram_data_R;
    wire [31:0]base_ram_data_W;
    wire [31:0]ext_ram_data_R;
    wire [31:0]ext_ram_data_W;
    wire base_ram_IO_ctrl;
    wire ext_ram_IO_ctrl;
    genvar i;
    generate
        for(i=0;i<32;i=i+1)
            begin
                IOBUF IOBUF_inst_io0 (
                    .IO(base_ram_data[i]),   // pad�ӿ�/�ܽ�
                    .O(base_ram_data_R[i]),     // IO_pad���롣�ܽž���IBUF����������ڲ��ź�
                    .I(base_ram_data_W[i]),    // �����IO_pad���ڲ��źž���OBUF���嵽�ܽ�
                    .T(base_ram_IO_ctrl)   // ��IO_pad��Ҫ�����ʱ��ʹ��OBUFʹ���������̬��
                );
                IOBUF IOBUF_inst_io1 (
                    .IO(ext_ram_data[i]),   // pad�ӿ�/�ܽ�
                    .O(ext_ram_data_R[i]),     // IO_pad���롣�ܽž���IBUF����������ڲ��ź�
                    .I(ext_ram_data_W[i]),    // �����IO_pad���ڲ��źž���OBUF���嵽�ܽ�
                    .T(ext_ram_IO_ctrl)   // ��IO_pad��Ҫ�����ʱ��ʹ��OBUFʹ���������̬��
                );
             end
    endgenerate
    
    //wires
    //params
    wire PFU_en;
    parameter [4:0]REG_RA=5'd31;
    //icache bus
    wire IC_send_req;
    wire [`OFFSET_WIDTH-`PAD_WIDTH:0]IC_word_size_req;
    wire [31:0] IC_start_vaddr_req;
    wire IC_ready_resp[3:0];
//    wire [32*`BLOCK_SIZE-1:0] IC_data_bus_resp[3:0];
    wire [31:0] IC_data_bus_resp[3:0];
    //icache sigs
    wire IC_done_lst;
    wire IC_done;
    wire IC_valid;
    //DM bus
    wire DM_start_req;
    wire [31:0]DM_vaddr_req;
    wire [31:0]DM_data_req;
    wire DM_write_req;
    wire [3:0] DM_be_req;
    wire [31:0]DM_data_resp[3:0];
    wire DM_end_resp[3:0];
    //base_ram_ctrl
    wire base_start_req;
    wire [31:0] base_data_w_req;
    wire [19:0] base_start_ram_addr_req;
    wire [31:0] base_word_size_req;//Ҫ��sram���������
    wire [3:0] base_be_req;
    wire base_write_req;
    wire [31:0] base_data_resp; //���֣��������ߵĵ�32λ
    wire base_end_resp;
    wire [32*`BLOCK_SIZE-1:0] base_data_bus_resp; //����
    //ext_ram_ctrl
    wire ext_start_req;
    wire [31:0] ext_data_w_req;
    wire [19:0] ext_start_ram_addr_req;
    wire [31:0] ext_word_size_req;//Ҫ��sram���������
    wire [3:0] ext_be_req;
    wire ext_write_req;
    wire [31:0] ext_data_resp; //���֣��������ߵĵ�32λ
    wire ext_end_resp;
    wire [32*`BLOCK_SIZE-1:0] ext_data_bus_resp; //����
    //SPC_ctrl
    wire SPC_start_req;
    wire SPC_end_resp;
    wire [31:0]SPC_WD;
    wire SPC_WE;
    wire SPC_RE;
    wire [31:0]SPC_RD;
    wire SPC_addr;
    //PC
    wire [31:0] PF_PC;
    wire [31:0] IF_PC;
    wire [31:0] ID_PC;
    wire [31:0] PC_next;
    wire [31:0] EX_PC;
    wire [31:0] BR_PC;
    wire [31:0] EM1_PC;
    wire [31:0] EM2_PC;
    wire [31:0] WB2_PC;
    wire [31:0] MEM_PC;
    wire [31:0] WB_PC;
    //IR
    wire [31:0] IF_IR;
    wire [31:0] ID_IR;
    wire [31:0] EX_IR;
    wire [31:0] EM1_IR;
    wire [31:0] EM2_IR;
    wire [31:0] WB2_IR;
    wire [31:0] MEM_IR;
    wire [31:0] WB_IR;
    //control signals
    wire IM_DM_clash;
    
    wire BR_BranchTaken;
    wire ID_JMP;
    wire EX_JMP;
    wire ID_JR;
    wire BR_JR;
    wire[3:0] ID_ALUOP;
    wire[3:0] EX_ALUOP;
    wire [2:0] ID_BTYPE;
    wire [2:0] BR_BTYPE;
    wire ID_MemToReg;
    wire EX_MemToReg;
    wire MEM_MemToReg;
    wire WB_MemToReg;
    wire ID_MemWrite;
    wire EX_MemWrite;
    wire MEM_MemWrite;
    wire WB_MemWrite;
    wire ID_ALUSource;
    wire EX_ALUSource;
    wire EM1_RegWrite;
    wire EM2_RegWrite;
    wire WB2_RegWrite;
    wire ID_RegWrite;
    wire EX_RegWrite_old;
    wire EX_RegWrite;
    wire EX_RegWrite_new;
    wire MEM_RegWrite;
    wire WB_RegWrite;
    wire ID_RegDst;
    wire EXTOP;
    wire ID_LUI;
    wire EX_LUI;
    wire ID_JAL;
    wire EX_JAL;
    wire ID_MemLoad;
    wire EX_MemLoad;
    wire MEM_MemLoad;
    wire ID_RA1_READ;
    wire ID_RA2_READ;
    wire ID_LB_SB;
    wire EX_LB_SB;
    wire MEM_LB_SB;
    wire ID_POF;
    wire EX_POF;
    wire ID_USE_SA;
    wire EX_USE_SA;
    wire ID_RegUse;
    
    wire EX_ALUD2ID_RD1;
    wire EX_ALUD2ID_RD2;
    wire MEM_ALUD2ID_RD1;
    wire MEM_ALUD2ID_RD2;
    wire MEM_MemDout2ID_RD1;
    wire MEM_MemDout2ID_RD2;
    wire ID_MEM_ALUD2EX_RD1;
    wire EX_MEM_ALUD2EX_RD1;
    wire ID_MEM_ALUD2EX_RD2;
    wire EX_MEM_ALUD2EX_RD2;
    wire ID_WB_WD2EX_RD1;
    wire EX_WB_WD2EX_RD1;
    wire ID_WB_WD2EX_RD2;
    wire EX_WB_WD2EX_RD2;
    wire WB_WD2ID_RD1;
    wire WB_WD2ID_RD2;
    wire EM2_EM_D2ID_RD1;
    wire EM2_EM_D2ID_RD2;
    wire WB2_EM_D2ID_RD1;
    wire WB2_EM_D2ID_RD2;
    
    wire [4:0] IS_RA1;
    wire [4:0] IS_RA2;
    wire [4:0] rd;
    wire [15:0] offset;
    wire [4:0] ID_WA;
    wire [4:0] EX_WA;
    wire [4:0] EM1_WA;
    wire [4:0] EM2_WA;
    wire [4:0] WB2_WA;
    wire [4:0] MEM_WA;
    wire [4:0] WB_WA;

    wire [31:0] WB_WD;
    wire [31:0] RD1_r;
    wire [31:0] RD2_r;
    wire [31:0] ID_RD1;
    wire [31:0] ID_RD2;
    wire [31:0] EX_RD1, EX_RD1_old, EX_RD1_new;
    wire [31:0] EX_RD2, EX_RD2_old, EX_RD2_new;
    wire [31:0] EM1_RD1, EM1_RD2;
    wire [4:0] EX_SA;

    wire IF2ID_cl;
    wire ID2EX_cl;
    wire EX2MEM_bubble;
    wire MEM2WB_bubble;
    wire [31:0] ID_EXTD;
    wire [31:0] EX_EXTD;
    wire [31:0] EX_ALUD;
    wire [31:0] MEM_ALUD;
    wire [31:0] WB_ALUD;
    wire [31:0] MEM_RD2;

    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    wire [31:0] ALU_Res;
    wire EX_ALU_DONE;
    wire OF;
    wire [31:0] WB_MemDout;
    wire DM_done;
    wire DM_stall;
    wire IC_stall;

    wire PF2IF_en;
    wire IF2ID_en;
    wire ID2EX_en;
    wire EX2MEM_en;
    wire MEM2WB_en;
    wire ID_EXload;
    wire IM_DM_clash_nxt;
    wire Read_IF_IR_buffer;
    wire [31:0]IC_IR_lst, IC_IR_lst_buffer;
    reg IC_IR_src;
    wire reset_IF_IR;
    wire [19:0] IC_start_paddr_wd_req;
    wire [1:0] IC_dst_req;
    wire [19:0] DM_paddr_wd_req;
    wire [1:0] DM_dst_req;
    wire ram_busy[3:0];
    wire ram_will_busy[3:0];
    wire [31:0] BR_BranchAddr;
    wire PF_PredictBranch;
    wire IF_PredictBranch;
    wire ID_PredictBranch;
    wire BR_PredictBranch;
    wire [31:0] PF_PredictBranchAddr, IF_PredictBranchAddr, ID_PredictBranchAddr;
    wire [3:0] DM_hold_resp;
    wire PF2IF_cl;
    wire [15:0]EX_IR_offset;
    wire [31:0]EX_IR_offset_se;
    wire icache_en;
    wire [31:0] LUI_Res, JAL_Res;
    wire ID_MCY, EM1_MCY, EM2_MCY;
    wire ID2EM1_en, EM12EM2_en, EM22WB2_en;
    wire ID2EM1_cl, EM12EM2_cl, EM22WB2_bubble;
    wire [31:0] EM1_ll,EM1_lh,EM1_hl,EM1_hh, EM2_ll,EM2_lh,EM2_hl,EM2_hh;
    wire [31:0] EM2_LO;
    wire [31:0] EM2_EM_D, WB2_EM_D;
    wire RGF_WE[1:0];
    wire [4:0] RGF_WA[1:0];
    wire [31:0] RGF_WD[1:0];
    wire ID_EM1_r;
    wire issue;
    wire [1:0] issue_rd_ori;
    wire [1:0]issue_wr, issue_rd;
    wire head_PC_valid;
    wire [63:0] PC_issue_st;
    wire [63:0] head_PC_st;
    wire [1:0]wr_en;
    wire [1:0]rd_en;
    wire [1:0]RGF_WE_st;
    wire [9:0] RGF_WA_st;
    wire [63:0] RGF_WD_st;
    wire ID_MEM_loadUse;
    wire [2:0] IS_FUID;
    wire [`FID_WIDTH-1:0]FID_curr;
    wire issue_wr_en;
    wire [1:0] issue_rd_en;
    wire [1:0] FID_hit;
    wire [`FID_WIDTH:0] EX_FID_bus;
    wire [`FID_WIDTH:0] EXF_FID_bus;
    wire [`FID_WIDTH:0] EM1_FID_bus;
    wire [`FID_WIDTH:0] EM2_FID_bus;
    wire [`FID_WIDTH:0] EMF_FID_bus;
    wire [`FID_WIDTH:0] AG_FID_bus;
    wire [`FID_WIDTH:0] MEM_FID_bus;
    wire [`FID_WIDTH:0] LSF_FID_bus;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EX_FID_idx;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EXF_FID_idx;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EM1_FID_idx;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EM2_FID_idx;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EMF_FID_idx;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] AG_FID_idx;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] MEM_FID_idx;
    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] LSF_FID_idx;
    wire RO2WB_en, RO2WB_cl;
    wire [`FU2RO_BUS_WIDTH-1:0] EX2RO_bus;
    wire [`FU2RO_BUS_WIDTH-1:0] EM2RO_bus;
    wire [`FU2RO_BUS_WIDTH-1:0] LS2RO_bus;
    
    wire [1:0] commit;//0:EXF; 1:EMF; 2:LSF
    wire AG_stall;
    
    wire WB_WE1;
    wire WB_WE2;
    wire WB_WE3;
    wire [4:0] WB_WA1;
    wire [4:0] WB_WA2;
    wire [4:0] WB_WA3;
    wire [31:0] WB_WD1;
    wire [31:0] WB_WD2;
    wire [31:0] WB_WD3;
    wire EM22EMF_cl;
    wire ID2AG_cl;
    wire AG2MEM_cl;
    wire MEM2LSF_cl;
    wire ID2BR_cl;
    wire EX2EXF_en;
    wire EM22EMF_en;
    wire ID2AG_en;
    wire AG2MEM_en;
    wire MEM2LSF_en;
    wire ID2BR_en;
    wire [`RELATE_BUS_WIDTH-1:0] EX_rel_bus;
    wire [`RELATE_BUS_WIDTH-1:0] EXF_rel_bus;
    wire [`RELATE_BUS_WIDTH-1:0] EM1_rel_bus;
    wire [`RELATE_BUS_WIDTH-1:0] EM2_rel_bus;
    wire [`RELATE_BUS_WIDTH-1:0] EMF_rel_bus;
    wire [`RELATE_BUS_WIDTH-1:0] AG_rel_bus;
    wire [`RELATE_BUS_WIDTH-1:0] MEM_rel_bus;
    wire [`RELATE_BUS_WIDTH-1:0] LSF_rel_bus;
    wire [`ID2LS_BUS_WIDTH-1:0] ID2LS_bus;
    wire [`MEM_SEND_BUS_WIDTH-1:0] base_send_bus;
    wire [`MEM_RECV_BUS_WIDTH-1:0] base_recv_bus;
    wire [`MEM_SEND_BUS_WIDTH-1:0] ext_send_bus;
    wire [`MEM_RECV_BUS_WIDTH-1:0] ext_recv_bus;
    wire [`MEM_SEND_BUS_WIDTH-1:0] SPC_send_bus;
    wire [`MEM_RECV_BUS_WIDTH-1:0] SPC_recv_bus;
    wire [`ID2EM_BUS_WIDTH-1:0] ID2EM_bus;
    wire [`ID2EX_BUS_WIDTH-1:0] ID2EX_bus;
    wire [`ID2BR_BUS_WIDTH-1:0] ID2BR_bus;
    wire EX_relate;
    wire EXF_relate;
    wire EM1_relate;
    wire EM2_relate;
    wire EMF_relate;
    wire AG_relate;
    wire MEM_relate;
    wire LSF_relate;
    
    wire to_IS_RD1;
    wire to_IS_RD2;
    wire [31:0] to_IS_RD1_D;
    wire [31:0] to_IS_RD2_D;
    wire [31:0] BR_JR_PC;
    wire [31:0] ID_JMP_PC;
    wire ID2IS_en, ID2IS_cl;
    wire [`IF2ID_BUS_WIDTH-1:0] IF2ID_bus;
    wire [32:0] dirty_bus;
    //test
    wire [7:0] number;
    //stage PF
    // PFU
    PFU PFU(
        .clk(clk),
        .reset(reset),
        .en(PFU_en),
        .BR_BranchTaken(BR_BranchTaken),
        .IF_PredictBranch(IF_PredictBranch),
        .BR_PredictBranch(BR_PredictBranch),
        .IF_PredictBranchAddr(IF_PredictBranchAddr),
        .ID_JMP(ID_JMP),
        .ID_JMP_PC(ID_JMP_PC),
        .BR_JR(BR_JR),
        .BR_JR_PC(BR_JR_PC),
        .BR_BranchAddr(BR_BranchAddr),
        .BR_PC(BR_PC),
        .pc(PF_PC)
    );
    BTB BTB(
        .clk(clk),
        .reset(reset),
        .PC(PF_PC),
        .BR_BTYPE(BR_BTYPE),
        .BR_BranchTaken(BR_BranchTaken),
        .BR_PredictBranch(BR_PredictBranch),
        .BR_PC(BR_PC),
        .BR_BranchAddr(BR_BranchAddr),
        .PredictBranch(PF_PredictBranch),
        .PredictBranchAddr(PF_PredictBranchAddr)
    );
    //stage IF
    //icache
    assign IC_ready_resp[3]=0;
    assign IC_ready_resp[0]=0;
    assign IC_data_bus_resp[3]=0;
    assign IC_data_bus_resp[0]=0;
    icache icache(
        .clk(clk),
        .reset(reset),
        .PF2IF_en(PF2IF_en),
        .icache_en(icache_en),
        .flush(PF2IF_cl),
        .stall(IC_stall),
        //cpu
        .PF_PC(PF_PC),
        .IF_PC(IF_PC),
        .PF_PredictBranch(PF_PredictBranch),
        .PF_PredictBranchAddr(PF_PredictBranchAddr),
        .IF_IR(IF_IR),
        .IF_PredictBranch(IF_PredictBranch),
        .IF_PredictBranchAddr(IF_PredictBranchAddr),
        //RAM bus
        .send_req(IC_send_req),
        .word_size_req(IC_word_size_req),
        .start_paddr_wd_req(IC_start_paddr_wd_req),
        .dst_req(IC_dst_req),
        .ready_resp(IC_ready_resp[IC_dst_req]),
        .data_bus_resp(IC_data_bus_resp[IC_dst_req]),
        .dirty_bus(dirty_bus)
    );

    IF2ID IF2ID(
        .clk(clk),
        .reset(reset),
        .en(IF2ID_en),
        .bubble(IF2ID_cl),
        .IF_PC(IF_PC),
        .IF_IR(IF_IR),
        .ID_PC(ID_PC),
        .ID_IR(ID_IR),
        .PredictBranch(IF_PredictBranch),
        .PredictBranchAddr(IF_PredictBranchAddr),
        .PredictBranch_o(ID_PredictBranch),
        .PredictBranchAddr_o(ID_PredictBranchAddr)
    );
    
    //IDU
    assign IF2ID_bus={ID_PC, ID_IR, ID_PredictBranch, ID_PredictBranchAddr};
    IDU IDU(
        .clk(clk), 
        .reset(reset),
        .ID2IS_en(ID2IS_en),
        .ID2IS_cl(ID2IS_cl),
        
        .ID_JMP(ID_JMP),
        .ID_JMP_PC(ID_JMP_PC),
        .IS_RA1(IS_RA1),
        .IS_RA2(IS_RA2),
        .IS_RA1_READ(IS_RA1_READ),
        .IS_RA2_READ(IS_RA2_READ),
        .IS_FUID(IS_FUID),
        .RD1_r(RD1_r),
        .RD2_r(RD2_r),
        .FID_curr(FID_curr),
        .issue(issue),
        .to_IS_RD1(to_IS_RD1),
        .to_IS_RD2(to_IS_RD2),
        .to_IS_RD1_D(to_IS_RD1_D),
        .to_IS_RD2_D(to_IS_RD2_D),
        
        .IF2ID_bus(IF2ID_bus),
        .ID2EX_bus(ID2EX_bus),
        .ID2LS_bus(ID2LS_bus),
        .ID2BR_bus(ID2BR_bus)
    );
    

    //EXU
    EXU EXU(
        .clk(clk),
        .reset(reset),
        .ID2EX_en(ID2EX_en),
        .EX2EXF_en(EX2EXF_en),
        .ID2EX_cl(ID2EX_cl),
        .EX2EXF_cl(EX2EXF_cl),
        
        .EX_rel_bus(EX_rel_bus),
        .EXF_rel_bus(EXF_rel_bus),
        
        .ID2EX_bus(ID2EX_bus),
        .EX2RO_bus(EX2RO_bus),
        
        .EX_FID_bus(EX_FID_bus),
        .EXF_FID_bus(EXF_FID_bus),
        .EX_FID_idx(EX_FID_idx),
        .EXF_FID_idx(EXF_FID_idx)
    );
    //EMU
//    EMU EMU(
//        .clk(clk),
//        .reset(reset),
//        .ID2EM1_en(ID2EM1_en),
//        .EM12EM2_en(EM12EM2_en),
//        .EM22EMF_en(EM22EMF_en),
//        .ID2EM1_cl(ID2EM1_cl),
//        .EM12EM2_cl(EM12EM2_cl),
//        .EM22EMF_cl(EM22EMF_cl),
        
//        .EM1_rel_bus(EM1_rel_bus),
//        .EM2_rel_bus(EM2_rel_bus),
//        .EMF_rel_bus(EMF_rel_bus),
        
//        .ID2EM_bus(ID2EM_bus),
//        .EM2RO_bus(EM2RO_bus),
//        .EM1_FID_bus(EM1_FID_bus),
//        .EM2_FID_bus(EM2_FID_bus),
//        .EMF_FID_bus(EMF_FID_bus),
//        .EM1_FID_idx(EM1_FID_idx),
//        .EM2_FID_idx(EM2_FID_idx),
//        .EMF_FID_idx(EMF_FID_idx)
//    );
    
    //LSU
    LSU LSU(
        .clk(clk),
        .reset(reset),
        .DM_stall(DM_stall),
        .AG_stall(AG_stall),
        
        .ID2AG_en(ID2AG_en),
        .AG2MEM_en(AG2MEM_en),
        .MEM2LSF_en(MEM2LSF_en),
        .ID2AG_cl(ID2AG_cl),
        .AG2MEM_cl(AG2MEM_cl),
        .MEM2LSF_cl(MEM2LSF_cl),
        
        .AG_rel_bus(AG_rel_bus),
        .MEM_rel_bus(MEM_rel_bus),
        .LSF_rel_bus(LSF_rel_bus),
        
        .ID2LS_bus(ID2LS_bus),
        .LS2RO_bus(LS2RO_bus),
        
        .base_send_bus(base_send_bus),
        .base_recv_bus(base_recv_bus),
        .ext_send_bus(ext_send_bus),
        .ext_recv_bus(ext_recv_bus),
        .SPC_send_bus(SPC_send_bus),
        .SPC_recv_bus(SPC_recv_bus),
        .AG_FID_bus(AG_FID_bus),
        .MEM_FID_bus(MEM_FID_bus),
        .LSF_FID_bus(LSF_FID_bus),
        .AG_FID_idx(AG_FID_idx),
        .MEM_FID_idx(MEM_FID_idx),
        .LSF_FID_idx(LSF_FID_idx),
        .dirty_bus(dirty_bus)
    );
    //BRU
    BRU BRU(
    .clk(clk),
    .reset(reset),
    .ID2BR_en(ID2BR_en),
    .ID2BR_cl(ID2BR_cl),
    
    .BR_PC(BR_PC),
    .BR_BranchAddr(BR_BranchAddr),
    .BR_BTYPE(BR_BTYPE),
    .BR_BranchTaken(BR_BranchTaken),
    .BR_PredictBranch(BR_PredictBranch),
    .BR_JR(BR_JR),
    .BR_JR_PC(BR_JR_PC),
    
    .ID2BR_bus(ID2BR_bus)
    );
    //RO stage
    //issue log
    issue_log issue_log(
        .clk(clk),
        .reset(reset),
        .FID_curr(FID_curr),
        .wr_en(issue_wr_en),
        .rd_en(issue_rd_en),
        .EX_FID_bus(EX_FID_bus),
        .EXF_FID_bus(EXF_FID_bus),
        .AG_FID_bus(AG_FID_bus),
        .MEM_FID_bus(MEM_FID_bus),
        .LSF_FID_bus(LSF_FID_bus),
        .EX_FID_idx(EX_FID_idx),
        .EXF_FID_idx(EXF_FID_idx),
        .AG_FID_idx(AG_FID_idx),
        .MEM_FID_idx(MEM_FID_idx),
        .LSF_FID_idx(LSF_FID_idx)
    );

    ROU ROU(
        .clk(clk),
        .reset(reset),
        .RO2WB_en(RO2WB_en),
        .RO2WB_cl(RO2WB_cl),
        .EX2RO_bus(EX2RO_bus),
        .LS2RO_bus(LS2RO_bus),
        .EXF_FID_idx(EXF_FID_idx),
        .LSF_FID_idx(LSF_FID_idx),
    
        .commit(commit),//0:EXF, 1:LSF
        .FID_hit(FID_hit),
        
        
        .WB_WE2(WB_WE2),
        .WB_WA2(WB_WA2),
        .WB_WD2(WB_WD2),
        
        .WB_WE1(WB_WE1),
        .WB_WA1(WB_WA1),
        .WB_WD1(WB_WD1)
    );
    //RGF
    RGF RGF(
        .clk(clk),
        .reset(reset),
        .Ra1(IS_RA1),
        .Ra2(IS_RA2), 
        .Rd1(RD1_r),
        .Rd2(RD2_r),
        
        .WE2(WB_WE2),
        .WA2(WB_WA2),
        .WD2(WB_WD2),
        
        .WE1(WB_WE1),
        .WA1(WB_WA1),
        .WD1(WB_WD1)
    );
    
    // Relate
    RELATE RELATE(
        .clk(clk),
        .reset(reset),
        .IS_RA1_Read(IS_RA1_READ),
        .IS_RA2_Read(IS_RA2_READ),
        .IS_RA1(IS_RA1),
        .IS_RA2(IS_RA2),
        .EX_rel_bus(EX_rel_bus),
        .EXF_rel_bus(EXF_rel_bus),
        .AG_rel_bus(AG_rel_bus),
        .MEM_rel_bus(MEM_rel_bus),
        .LSF_rel_bus(LSF_rel_bus),
    
        .EX_relate(EX_relate),
        .EXF_relate(EXF_relate),
        .AG_relate(AG_relate),
        .MEM_relate(MEM_relate),
        .LSF_relate(LSF_relate),
        
        .to_IS_RD1(to_IS_RD1),
        .to_IS_RD2(to_IS_RD2),
        .to_IS_RD1_D(to_IS_RD1_D),
        .to_IS_RD2_D(to_IS_RD2_D)
    );
    //base
    sram_ctrl #(.ram_id(1))base_controler(
        .clk(clk),
        .reset(reset),
        //sram
        .data_r(base_ram_data_R),
        .data_w(base_ram_data_W),
        .addr(base_ram_addr),
        .be(base_ram_be_n),
        .ce(base_ram_ce_n),
        .oe(base_ram_oe_n),
        .we(base_ram_we_n),
        .IO_ctrl(base_ram_IO_ctrl),
        //LSU
        .LSU_send_bus(base_send_bus),
        .LSU_recv_bus(base_recv_bus),
        //icache
        .IC_send_req(IC_send_req),
        .IC_dst_req(IC_dst_req),
        .IC_word_size_req(IC_word_size_req),
        .IC_start_paddr_wd_req(IC_start_paddr_wd_req),
        .IC_ready_resp(IC_ready_resp[1]),
        .IC_data_bus_resp(IC_data_bus_resp[1])
    );
    //ext
    sram_ctrl #(.ram_id(2))ext_controler(
        .clk(clk),
        .reset(reset),
        //sram
        .data_r(ext_ram_data_R),
        .data_w(ext_ram_data_W),
        .addr(ext_ram_addr),
        .be(ext_ram_be_n),
        .ce(ext_ram_ce_n),
        .oe(ext_ram_oe_n),
        .we(ext_ram_we_n),
        .IO_ctrl(ext_ram_IO_ctrl),
        //LSU
        .LSU_send_bus(ext_send_bus),
        .LSU_recv_bus(ext_recv_bus),
        //icache
        .IC_send_req(IC_send_req),
        .IC_dst_req(IC_dst_req),
        .IC_word_size_req(IC_word_size_req),
        .IC_start_paddr_wd_req(IC_start_paddr_wd_req),
        .IC_ready_resp(IC_ready_resp[2]),
        .IC_data_bus_resp(IC_data_bus_resp[2])
    );
    //SPC
    SPC
    #(.CLK_FREQ(CLK_FREQ))
    SPC(
        .clk(clk),
        .reset(reset),
        .txd(txd),  //ֱ�����ڷ��Ͷ�
        .rxd(rxd),  //ֱ�����ڽ��ն�
        .LSU_send_bus(SPC_send_bus),
        .LSU_recv_bus(SPC_recv_bus),
        .number(number)
    );
    // pipeline ctrl
    pipeline_ctrl pipeline_ctrl(
        .clk(clk),
        .reset(reset),
        .IC_stall(IC_stall),
        .DM_stall(DM_stall),
        .AG_stall(AG_stall),
        .ID_JMP(ID_JMP),
        .BR_BranchTaken(BR_BranchTaken),
        .BR_PredictBranch(BR_PredictBranch),
        .BR_JR(BR_JR),
        .IS_FUID(IS_FUID),
        .FID_hit(FID_hit),
        .commit(commit),
        
        .EX_relate(EX_relate),
        .EXF_relate(EXF_relate),
        .AG_relate(AG_relate),
        .MEM_relate(MEM_relate),
        .LSF_relate(LSF_relate),
        
        .PFU_en(PFU_en),
        .PF2IF_en(PF2IF_en),
        .icache_en(icache_en),
        .IF2ID_en(IF2ID_en),
        .ID2IS_en(ID2IS_en),
        .ID2EX_en(ID2EX_en),
        .EX2EXF_en(EX2EXF_en),
        .ID2AG_en(ID2AG_en),
        .AG2MEM_en(AG2MEM_en),
        .MEM2LSF_en(MEM2LSF_en),
        .ID2BR_en(ID2BR_en),
        .RO2WB_en(RO2WB_en),
        
        .issue(issue),
        .issue_wr_en(issue_wr_en),
        .issue_rd_en(issue_rd_en),
        
        .PF2IF_cl(PF2IF_cl),
        .IF2ID_cl(IF2ID_cl),
        .ID2IS_cl(ID2IS_cl),
        .ID2EX_cl(ID2EX_cl),
        .EX2EXF_cl(EX2EXF_cl),
        .ID2AG_cl(ID2AG_cl),
        .AG2MEM_cl(AG2MEM_cl),
        .MEM2LSF_cl(MEM2LSF_cl),
        .ID2BR_cl(ID2BR_cl),
        .RO2WB_cl(RO2WB_cl)
    );
    //for test
    SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0�ǵ�λ�����
    SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1�Ǹ�λ�����
    assign leds=dip_sw;
endmodule

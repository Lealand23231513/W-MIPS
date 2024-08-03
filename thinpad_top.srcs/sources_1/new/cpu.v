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
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）
    `ifdef SIMULATION
    output wire clk_200m,
    output wire clk_140m,
    output wire clk_core,
    `endif
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
    reg reset;
    wire locked, clk_80M, clk_100M, clk_140M, clk_200M, clk_225M, clk_240M;
    wire clk;
    parameter CLK_80M_FREQ=80000000;
    parameter CLK_100M_FREQ=100000000;
    parameter CLK_140M_FREQ=140000000;
    parameter CLK_200M_FREQ=200000000;
    parameter CLK_225M_FREQ=225000000;
    parameter CLK_240M_FREQ=240000000;
    parameter CLK_250M_FREQ=250000000;
    pll_example clock_gen 
     (
      // Clock in ports
      .clk_in1(clk_50M),  // 外部时钟输入
      // Clock out ports
      .clk_100M(clk_100M),
      .clk_140M(clk_140M), // 时钟输出1，频率在IP配置界面中设置
//      .clk_225M(clk_225M),
//      .clk_240M(clk_240M),
//      .clk_250M(clk_250M),
      .clk_200M(clk_200M),
      // Status and control signals
      .reset(reset_btn), // PLL复位输入
      .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                         // 后级电路复位信号应当由它生成（见下）
     );
    `ifdef CLK_250M
    assign clk=clk_250M;
    parameter CLK_FREQ=CLK_250M_FREQ;   
    `elsif CLK_240M
    assign clk=clk_240M;
    parameter CLK_FREQ=CLK_240M_FREQ;   
    `elsif CLK_225M
    assign clk=clk_225M;
    parameter CLK_FREQ=CLK_225M_FREQ;
    `elsif CLK_200M
    assign clk=clk_200M;
    parameter CLK_FREQ=CLK_200M_FREQ;
    `elsif CLK_100M
    assign clk=clk_100M;
    parameter CLK_FREQ=CLK_100M_FREQ;
    `else
    assign clk=clk_140M;
    parameter CLK_FREQ=CLK_140M_FREQ;
    `endif
//     异步复位，同步释放，将locked信号转为后级电路的复位reset
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
    reg core_stage;
//    always @(posedge clk_200M, posedge reset_200M) begin
//        if (reset_200M) core_stage<=0;
//        else core_stage<=~core_stage;
//    end
//    assign core_stage=~clk_100M;
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
                    .IO(base_ram_data[i]),   // pad接口/管脚
                    .O(base_ram_data_R[i]),     // IO_pad输入。管脚经过IBUF缓冲输出到内部信号
                    .I(base_ram_data_W[i]),    // 输出到IO_pad。内部信号经过OBUF缓冲到管脚
                    .T(base_ram_IO_ctrl)   // 当IO_pad需要输入的时候，使能OBUF使其输出高组态。
                );
                IOBUF IOBUF_inst_io1 (
                    .IO(ext_ram_data[i]),   // pad接口/管脚
                    .O(ext_ram_data_R[i]),     // IO_pad输入。管脚经过IBUF缓冲输出到内部信号
                    .I(ext_ram_data_W[i]),    // 输出到IO_pad。内部信号经过OBUF缓冲到管脚
                    .T(ext_ram_IO_ctrl)   // 当IO_pad需要输入的时候，使能OBUF使其输出高组态。
                );
             end
    endgenerate
    
    //wires
    //params
    wire IFU_EN;
    parameter [4:0]REG_RA=5'd31;
    //icache bus
    wire IC_send_req;
    wire [`OFFSET_WIDTH-`PAD_WIDTH:0]IC_word_size_req;
    wire [31:0] IC_start_vaddr_req;
    wire IC_ready_resp[3:0];
    wire [32*`BLOCK_SIZE-1:0] IC_data_bus_resp[3:0];
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
    wire [31:0] base_word_size_req;//要从sram读入的字数
    wire [3:0] base_be_req;
    wire base_write_req;
    wire [31:0] base_data_resp; //单字，就是总线的低32位
    wire base_end_resp;
    wire [32*`BLOCK_SIZE-1:0] base_data_bus_resp; //多字
    //ext_ram_ctrl
    wire ext_start_req;
    wire [31:0] ext_data_w_req;
    wire [19:0] ext_start_ram_addr_req;
    wire [31:0] ext_word_size_req;//要从sram读入的字数
    wire [3:0] ext_be_req;
    wire ext_write_req;
    wire [31:0] ext_data_resp; //单字，就是总线的低32位
    wire ext_end_resp;
    wire [32*`BLOCK_SIZE-1:0] ext_data_bus_resp; //多字
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
    
    wire EX_BranchTaken;
    wire ID_JMP;
    wire EX_JMP;
    wire ID_JR;
    wire EX_JR;
    wire[3:0] ID_ALUOP;
    wire[3:0] EX_ALUOP;
    wire [2:0] ID_BTYPE;
    wire [2:0] EX_BTYPE;
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
    
    wire [4:0] rs;
    wire [4:0] rt;
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
    wire [31:0] ID_RD1_ori;
    wire [31:0] ID_RD2_ori;
    wire [31:0] ID_RD1;
    wire [31:0] ID_RD2;
    wire [31:0] EX_RD1, EX_RD1_old, EX_RD1_new;
    wire [31:0] EX_RD2, EX_RD2_old, EX_RD2_new;
    wire [31:0] EM1_RD1, EM1_RD2;
    wire [4:0] EX_SA;

    wire IF2ID_bubble;
    wire ID2EX_bubble;
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
    (*mark_debug = "true"*)wire [31:0] MEM_MemDout;
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
    wire [31:0] EX_BranchAddr;
    wire PF_PredictBranch;
    wire IF_PredictBranch;
    wire ID_PredictBranch;
    wire EX_PredictBranch;
    wire [31:0] PF_PredictBranchAddr, IF_PredictBranchAddr, ID_PredictBranchAddr;
    wire [3:0] DM_hold_resp;
    wire PF2IF_flush;
    wire [15:0]EX_IR_offset;
    wire [31:0]EX_IR_offset_se;
    wire icache_en;
    wire [31:0] LUI_Res, JAL_Res;
    wire ID_MCY, EM1_MCY, EM2_MCY;
    wire ID2EM1_en, EM12EM2_en, EM22WB2_en;
    wire ID2EM1_bubble, EM12EM2_bubble, EM22WB2_bubble;
    wire [31:0] EM1_ll,EM1_lh,EM1_hl,EM1_hh, EM2_ll,EM2_lh,EM2_hl,EM2_hh;
    wire [31:0] EM2_LO;
    wire [31:0] EM2_EM_D, WB2_EM_D;
    wire RGF_WE;
    wire [4:0] RGF_WA;
    wire [31:0] RGF_WD;
    wire ID_EM1_r;
    assign ram_busy[0]=0;
    assign ram_busy[3]=0;
    assign ram_will_busy[0]=0;
    assign ram_will_busy[3]=0;
    //test
    wire [7:0] number;
    //stage PF
    // PFU
    PFU PFU(
        .clk(clk),
        .reset(reset),
        .en(IFU_EN),
        .EX_BranchTaken(EX_BranchTaken),
        .IF_PredictBranch(IF_PredictBranch),
        .EX_PredictBranch(EX_PredictBranch),
        .IF_PredictBranchAddr(IF_PredictBranchAddr),
        .ID_JMP(ID_JMP),
        .ID_JMP_PC({ID_PC[31:28], ID_IR[25:0], 2'd0}),
        .EX_JR(EX_JR),
        .EX_JR_PC(EX_RD1),
        .EX_BranchAddr(EX_BranchAddr),
        .EX_PC(EX_PC),
        .pc(PF_PC)
    );
    BTB BTB(
        .clk(clk),
        .reset(reset),
        .PC(PF_PC),
        .EX_Btype(EX_BTYPE),
        .EX_BranchTaken(EX_BranchTaken),
        .EX_PredictBranch(EX_PredictBranch),
        .EX_PC(EX_PC),
        .EX_BranchAddr(EX_BranchAddr),
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
        .flush(PF2IF_flush),
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
        .data_bus_resp(IC_data_bus_resp[IC_dst_req])
    );

    IF2ID IF2ID(
        .clk(clk),
        .reset(reset),
        .en(IF2ID_en),
        .bubble(IF2ID_bubble),
        .IF_PC(IF_PC),
        .IF_IR(IF_IR),
        .ID_PC(ID_PC),
        .ID_IR(ID_IR),
        .PredictBranch(IF_PredictBranch),
        .PredictBranchAddr(IF_PredictBranchAddr),
        .PredictBranch_o(ID_PredictBranch),
        .PredictBranchAddr_o(ID_PredictBranchAddr)
    );
    
    //STAGE ID
    assign rs=ID_IR[25:21];
    assign rt=ID_IR[20:16];
    assign rd=ID_IR[15:11];
    assign offset=ID_IR[15:0];
    assign ID_WA=ID_JAL?REG_RA:ID_RegDst?rd:rt;
    assign ID_RD1=EX_ALUD2ID_RD1?EX_ALUD
                :EM2_EM_D2ID_RD1?EM2_EM_D
                :MEM_ALUD2ID_RD1?MEM_ALUD
                :MEM_MemDout2ID_RD1?MEM_MemDout
                :WB2_EM_D2ID_RD1?WB2_EM_D
                :WB_WD2ID_RD1?WB_WD:ID_RD1_ori;
    assign ID_RD2=EX_ALUD2ID_RD2?EX_ALUD
                :EM2_EM_D2ID_RD2?EM2_EM_D
                :MEM_ALUD2ID_RD2?MEM_ALUD
                :MEM_MemDout2ID_RD2?MEM_MemDout
                :WB2_EM_D2ID_RD2?WB2_EM_D
                :WB_WD2ID_RD2?WB_WD:ID_RD2_ori;
    //controler
    controler controler(
        .IR(ID_IR),
        .ALUOP(ID_ALUOP),
        .BTYPE(ID_BTYPE),
        .MemToReg(ID_MemToReg),
        .MemWrite(ID_MemWrite),
        .ALUSource(ID_ALUSource),
        .RegWrite(ID_RegWrite),
        .RegDst(ID_RegDst),
        .EXTOP(EXTOP),
        .LUI(ID_LUI),
        .JMP(ID_JMP),
        .JR(ID_JR),
        .JAL(ID_JAL),
        .MemLoad(ID_MemLoad),
        .RA1_READ(ID_RA1_READ),
        .RA2_READ(ID_RA2_READ),
        .LB_SB(ID_LB_SB),
        .POF(ID_POF),
        .USE_SA(ID_USE_SA),
        .ID_RegUse(ID_RegUse),
        .MCY(ID_MCY)
    );
    //RGF
    RGF RGF(
        .clk(clk),
        .reset(reset),
        .WE(RGF_WE),
        .Ra1(rs),
        .Ra2(rt), 
        .WA(RGF_WA),
        .WD(RGF_WD),
        .Rd1(ID_RD1_ori),
        .Rd2(ID_RD2_ori)
    );
     //EXT
     assign ID_EXTD=EXTOP?{{16{offset[15]}}, offset}:{16'd0,offset};

     ID2EX ID2EX(
        .clk(clk),
        .reset(reset),
        .en(ID2EX_en),
        .bubble(ID2EX_bubble),
        .ID_PC(ID_PC),
        .ID_IR(ID_IR),
        .ALUOP(ID_ALUOP),
        .MemLoad(ID_MemLoad),
        .MemToReg(ID_MemToReg),
        .MemWrite(ID_MemWrite),
        .ALUSource(ID_ALUSource),
        .RegWrite(ID_RegWrite),
        .JMP(ID_JMP),
        .JR(ID_JR),
        .LUI(ID_LUI),
        .JAL(ID_JAL),
        .BType(ID_BTYPE),
        .LB_SB(ID_LB_SB),
        .POF(ID_POF),
        .EX_PC(EX_PC),
        .EX_IR(EX_IR),
        .EXTD(ID_EXTD),
        .WA(ID_WA),
        .RD1(ID_RD1),
        .RD2(ID_RD2),
        .USE_SA(ID_USE_SA),
        .MEM_ALUD2EX_RD1(ID_MEM_ALUD2EX_RD1),
        .MEM_ALUD2EX_RD2(ID_MEM_ALUD2EX_RD2),
        .WB_WD2EX_RD1(ID_WB_WD2EX_RD1),
        .WB_WD2EX_RD2(ID_WB_WD2EX_RD2),
        .PredictBranch(ID_PredictBranch),
        
        .ALUOP_o(EX_ALUOP),
        .MemLoad_o(EX_MemLoad),
        .MemToReg_o(EX_MemToReg),
        .MemWrite_o(EX_MemWrite),
        .ALUSource_o(EX_ALUSource),
        .RegWrite_o(EX_RegWrite),
        .JMP_o(EX_JMP),
        .JR_o(EX_JR),
        .LUI_o(EX_LUI),
        .JAL_o(EX_JAL),
        .BType_o(EX_BTYPE),
        .LB_SB_o(EX_LB_SB),
        .POF_o(EX_POF),
        .EXTD_o(EX_EXTD),
        .WA_o(EX_WA),
        .RD1_o(EX_RD1),
        .RD2_o(EX_RD2),
        .USE_SA_o(EX_USE_SA),
        .MEM_ALUD2EX_RD1_o(EX_MEM_ALUD2EX_RD1),
        .MEM_ALUD2EX_RD2_o(EX_MEM_ALUD2EX_RD2),
        .WB_WD2EX_RD1_o(EX_WB_WD2EX_RD1),
        .WB_WD2EX_RD2_o(EX_WB_WD2EX_RD2),
        .PredictBranch_o(EX_PredictBranch)
    );
     //STAGE EX 
    assign EX_SA=EX_IR[10:6];
    assign ALU_A=EX_USE_SA?{27'd0, EX_SA}:EX_RD1;
    assign ALU_B=EX_ALUSource?EX_EXTD:EX_RD2;
    assign EX_BranchAddr={{14{EX_IR[15]}}, EX_IR[15:0], 2'd0}+EX_PC+32'd4;
    assign LUI_Res={EX_EXTD[15:0],16'd0};
    assign JAL_Res=EX_PC+8;
    assign EX_ALUD=EX_LUI?LUI_Res:EX_JAL?JAL_Res:ALU_Res;
    // BRD
    BRANCH_DETECTOR BRD(
       .BTYPE(EX_BTYPE),
       .RS_D(EX_RD1),
       .RT_D(EX_RD2),
       .Branch(EX_BranchTaken)
       );
    //ALU
    ALU ALU(
        .clk(clk),
        .reset(reset),
        .A(ALU_A),
        .B(ALU_B),
        .ALUOP(EX_ALUOP),
        .R(ALU_Res),
        .OF(OF),
        .done(EX_ALU_DONE)
    );

    assign EX_RegWrite_new=EX_POF&OF?1'd0:EX_RegWrite;// overflow exception
    EX2MEM EX2MEM(
     .clk(clk),
     .reset(reset),
     .en(EX2MEM_en),
     .bubble(EX2MEM_bubble),
     .EX_PC(EX_PC),
     .EX_IR(EX_IR),
     .MemLoad(EX_MemLoad),
     .MemToReg(EX_MemToReg),
     .MemWrite(EX_MemWrite),
     .RegWrite(EX_RegWrite_new),
     .LB_SB(EX_LB_SB),
     .WA(EX_WA),
     .ALUD(EX_ALUD),
     .RD2(EX_RD2),
     .MEM_PC(MEM_PC),
     .MEM_IR(MEM_IR),
     .MemLoad_o(MEM_MemLoad),
     .MemToReg_o(MEM_MemToReg),
     .MemWrite_o(MEM_MemWrite),
     .RegWrite_o(MEM_RegWrite),
     .LB_SB_o(MEM_LB_SB),
     .WA_o(MEM_WA),
     .ALUD_o(MEM_ALUD),
     .RD2_o(MEM_RD2)
    );
    //STATE EM1
    ID2EM1 ID2EM1(
        .clk(clk),
        .reset(reset),
        .en(ID2EM1_en),
        .bubble(ID2EM1_bubble),
        
        .ID_PC(ID_PC),
        .ID_IR(ID_IR),
        .MCY(ID_MCY),
        .RegWrite(ID_RegWrite),
        .WA(ID_WA),
        .RD1(ID_RD1),
        .RD2(ID_RD2),
        
        .EM1_PC(EM1_PC),
        .EM1_IR(EM1_IR),
        .MCY_o(EM1_MCY),
        .RegWrite_o(EM1_RegWrite),
        .WA_o(EM1_WA),
        .RD1_o(EM1_RD1),
        .RD2_o(EM1_RD2)
    );
    assign EM1_ll=$unsigned(EM1_RD1[15:0])*$unsigned(EM1_RD2[15:0]);
    assign EM1_lh=$unsigned(EM1_RD1[15:0])*$unsigned(EM1_RD2[31:16]);
    assign EM1_hl=$unsigned(EM1_RD1[31:16])*$unsigned(EM1_RD2[15:0]);
    assign EM1_hh=$unsigned(EM1_RD1[31:16])*$unsigned(EM1_RD2[31:16]);
    
    EM12EM2 EM12EM2(
        .clk(clk),
        .reset(reset),
        .en(EM12EM2_en),
        .bubble(EM12EM2_bubble),
        
        .EM1_PC(EM1_PC),
        .EM1_IR(EM1_IR),
        .MCY(EM1_MCY),
        .RegWrite(EM1_RegWrite),
        .WA(EM1_WA),
        .ll(EM1_ll),
        .lh(EM1_lh),
        .hl(EM1_hl),
        .hh(EM1_hh),
        
        .EM2_PC(EM2_PC),
        .EM2_IR(EM2_IR),
        .MCY_o(EM2_MCY),
        .RegWrite_o(EM2_RegWrite),
        .WA_o(EM2_WA),
        .ll_o(EM2_ll),
        .lh_o(EM2_lh),
        .hl_o(EM2_hl),
        .hh_o(EM2_hh)
    );
    
    //STATE EM2
    assign EM2_LO=EM2_ll+{EM2_lh[15:0],16'b0}+{EM2_hl[15:0], 16'b0};
    assign EM2_EM_D=EM2_LO;
    EM22WB2 EM22WB2(
        .clk(clk),
        .reset(reset),
        .en(EM22WB2_en),
        .bubble(EM22WB2_bubble),
        
        .EM2_PC(EM2_PC),
        .EM2_IR(EM2_IR),
        .RegWrite(EM2_RegWrite),
        .WA(EM2_WA),
        .EM_D(EM2_EM_D),
        
        .WB2_PC(WB2_PC),
        .WB2_IR(WB2_IR),
        .RegWrite_o(WB2_RegWrite),
        .WA_o(WB2_WA),
        .EM_D_o(WB2_EM_D)
    );
    //STAGE MEM
    assign DM_data_resp[0]=0;
    assign DM_end_resp[0]=0;
    assign DM_hold_resp[0]=0;
    DM_transceiver_v2 DM_transceiver_v2(
        .clk(clk),
        .reset(reset),
        .stall(DM_stall),
        .stage(core_stage),
        //cpu
        .MEM_PC(MEM_PC),
        .vaddr(MEM_ALUD),
        .oe(MEM_MemLoad),
        .we(MEM_MemWrite),
        .LB_SB(MEM_LB_SB),
        .mem_data_in(MEM_RD2),
        .mem_data_out(MEM_MemDout),
        // bridge
        .start_req(DM_start_req),
        .paddr_wd_req(DM_paddr_wd_req),
        .dst_req(DM_dst_req),
        .data_req(DM_data_req),
        .write_req(DM_write_req),
        .be_req(DM_be_req),
        .hold_resp(DM_hold_resp[DM_dst_req]),
        .data_resp(DM_data_resp[DM_dst_req]),
        .end_resp(DM_end_resp[DM_dst_req]),
        .will_busy({ram_will_busy[3], ram_will_busy[2], ram_will_busy[1], ram_will_busy[0]})
    );
    MEM2WB MEM2WB(
        .clk(clk),
        .reset(reset),
        .en(MEM2WB_en),
        .bubble(MEM2WB_bubble),
        .MEM_PC(MEM_PC),
        .MEM_IR(MEM_IR),
        .MemToReg(MEM_MemToReg),
        .RegWrite(MEM_RegWrite),
        .WA(MEM_WA),
        .ALUD(MEM_ALUD),
        .MemDout(MEM_MemDout),
        .WB_PC(WB_PC),
        .WB_IR(WB_IR),
        .MemToReg_o(WB_MemToReg),
        .RegWrite_o(WB_RegWrite),
        .WA_o(WB_WA),
        .ALUD_o(WB_ALUD),
        .MemDout_o(WB_MemDout)
    );
    //STAGE WB
    assign WB_WD=WB_MemToReg?WB_MemDout:WB_ALUD;
    assign RGF_WD=WB2_RegWrite?WB2_EM_D:WB_WD;
    assign RGF_WA=WB2_RegWrite?WB2_WA:WB_WA;
    assign RGF_WE=WB2_RegWrite|WB_RegWrite;
    // Relata
    RELATE RELATE(
        .clk(clk),
        .reset(reset),
        .ID_RA1_Read(ID_RA1_READ),
        .ID_RA2_Read(ID_RA2_READ),
        .ID_RA1(rs),
        .ID_RA2(rt),
        .EX_WA(EX_WA),
        .EX_RegWrite(EX_RegWrite),
        .EX_MemLoad(EX_MemLoad),
        .MEM_WA(MEM_WA),
        .MEM_RegWrite(MEM_RegWrite),
        .WB_WA(WB_WA),
        .WB_RegWrite(WB_RegWrite),
        .MEM_MemLoad(MEM_MemLoad),
        .EM1_WA(EM1_WA),
        .EM1_RegWrite(EM1_RegWrite),
        .EM2_WA(EM2_WA),
        .EM2_RegWrite(EM2_RegWrite),
        .WB2_WA(WB2_WA),
        .WB2_RegWrite(WB2_RegWrite),
        
        .ID_EXload(ID_EXload),
        .ID_EM1_r(ID_EM1_r),
        .EX_ALUD2ID_RD1(EX_ALUD2ID_RD1),
        .EX_ALUD2ID_RD2(EX_ALUD2ID_RD2),
        .MEM_ALUD2ID_RD1(MEM_ALUD2ID_RD1),
        .MEM_ALUD2ID_RD2(MEM_ALUD2ID_RD2),
        .MEM_MemDout2ID_RD1(MEM_MemDout2ID_RD1),
        .MEM_MemDout2ID_RD2(MEM_MemDout2ID_RD2),
        .WB_WD2ID_RD1(WB_WD2ID_RD1),
        .WB_WD2ID_RD2(WB_WD2ID_RD2),
        .WB2_EM_D2ID_RD1(WB2_EM_D2ID_RD1),
        .WB2_EM_D2ID_RD2(WB2_EM_D2ID_RD2),
        .EM2_EM_D2ID_RD1(EM2_EM_D2ID_RD1),
        .EM2_EM_D2ID_RD2(EM2_EM_D2ID_RD2)
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
        //DM_transceiver
        .DM_start_req(DM_start_req),
        .DM_dst_req(DM_dst_req),
        .DM_paddr_wd_req(DM_paddr_wd_req),
        .DM_data_req(DM_data_req),
        .DM_write_req(DM_write_req),
        .DM_be_req(DM_be_req),
        .DM_data_resp(DM_data_resp[1]),
        .DM_hold_resp(DM_hold_resp[1]),
        .DM_end_resp(DM_end_resp[1]),
        //icache
        .IC_send_req(IC_send_req),
        .IC_dst_req(IC_dst_req),
        .IC_word_size_req(IC_word_size_req),
        .IC_start_paddr_wd_req(IC_start_paddr_wd_req),
        .IC_ready_resp(IC_ready_resp[1]),
        .IC_data_bus_resp(IC_data_bus_resp[1]),
        //busy
        .busy(ram_busy[1]),
        .will_busy(ram_will_busy[1])
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
        //DM_transceiver
        .DM_start_req(DM_start_req),
        .DM_dst_req(DM_dst_req),
        .DM_paddr_wd_req(DM_paddr_wd_req),
        .DM_data_req(DM_data_req),
        .DM_write_req(DM_write_req),
        .DM_be_req(DM_be_req),
        .DM_data_resp(DM_data_resp[2]),
        .DM_hold_resp(DM_hold_resp[2]),
        .DM_end_resp(DM_end_resp[2]),
        //icache
        .IC_send_req(IC_send_req),
        .IC_dst_req(IC_dst_req),
        .IC_word_size_req(IC_word_size_req),
        .IC_start_paddr_wd_req(IC_start_paddr_wd_req),
        .IC_ready_resp(IC_ready_resp[2]),
        .IC_data_bus_resp(IC_data_bus_resp[2]),
        //busy
        .busy(ram_busy[2]),
        .will_busy(ram_will_busy[2])
    );
    //SPC
    SPC
    #(.CLK_FREQ(CLK_FREQ))
    SPC(
        .clk(clk),
        .reset(reset),
        .txd(txd),  //直连串口发送端
        .rxd(rxd),  //直连串口接收端
        .paddr(DM_paddr_wd_req[0]),
        .start_req(DM_start_req),
        .DM_dst_req(DM_dst_req),
        .end_resp(DM_end_resp[3]),
        .DM_hold_resp(DM_hold_resp[3]),
        .WD(DM_data_req),
        .WE(DM_write_req), //1有效
        .RE(!DM_write_req),
        .RD(DM_data_resp[3]),
        .number(number)
    );
    // pipeline ctrl
    pipeline_ctrl pipeline_ctrl(
        .clk(clk),
        .reset(reset),
        .IC_stall(IC_stall),
        .DM_stall(DM_stall),
        .ID_EXload(ID_EXload),
        .ID_JMP(ID_JMP),
        .EX_BranchTaken(EX_BranchTaken),
        .EX_PredictBranch(EX_PredictBranch),
        .EX_JR(EX_JR),
        .ID_MCY(ID_MCY),
        .ID_EM1_r(ID_EM1_r),
        
        .IFU_en(IFU_EN),
        .PF2IF_en(PF2IF_en),
        .icache_en(icache_en),
        .IF2ID_en(IF2ID_en),
        .ID2EX_en(ID2EX_en),
        .EX2MEM_en(EX2MEM_en),
        .MEM2WB_en(MEM2WB_en),
        .ID2EM1_en(ID2EM1_en),
        .EM12EM2_en(EM12EM2_en),
        .EM22WB2_en(EM22WB2_en),
        
        .PF2IF_flush(PF2IF_flush),
        .IF2ID_bubble(IF2ID_bubble),
        .ID2EX_bubble(ID2EX_bubble),
        .EX2MEM_bubble(EX2MEM_bubble),
        .MEM2WB_bubble(MEM2WB_bubble),
        .ID2EM1_bubble(ID2EM1_bubble),
        .EM12EM2_bubble(EM12EM2_bubble),
        .EM22WB2_bubble(EM22WB2_bubble)
    );
    //for test
    SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
    SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管
    assign leds=dip_sw;
endmodule

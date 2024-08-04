`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/12 15:44:55
// Design Name: 
// Module Name: PIPLINE
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
module PF2IF(
    input wire clk,en,reset,flush,
    input wire [31:0]PF_PC,
    input wire PredictBranch,
    input wire [31:0] PredictBranchAddr,
//    input wire [`SET_SIZE-1:0] way_hit,
    output reg [31:0]IF_PC_ori,
    output reg PredictBranch_o,
    output reg [31:0] PredictBranchAddr_o,
    output reg flush_IF
//    output reg [`SET_SIZE-1:0] way_hit_o
);
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            IF_PC_ori<=0;
            PredictBranch_o<=0;
            PredictBranchAddr_o<=0;
            flush_IF<=0;
//            way_hit_o<=0;
        end
        else if (en) begin
            PredictBranch_o<=flush?0:PredictBranch;
            PredictBranchAddr_o<=flush?0:PredictBranchAddr;
            flush_IF<=flush;
            IF_PC_ori<=PF_PC;
//            way_hit_o<=flush?0:way_hit;
        end
    end 
endmodule

module IF2ID(
    input wire clk,
    input wire en,
    input wire reset,
    input wire bubble,
    
    input wire [31:0] IF_PC,
    input wire [31:0] IF_IR,
    input wire PredictBranch,
    input wire [31:0] PredictBranchAddr,
    
    output reg [31:0] ID_PC,
    output reg [31:0] ID_IR,
    output reg PredictBranch_o,
    output reg [31:0] PredictBranchAddr_o
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            ID_PC<=0;
            ID_IR<=0;
            PredictBranch_o<=0;
            PredictBranchAddr_o<=0;
        end
        else if (en) begin
            ID_PC<=bubble?0:IF_PC;
            ID_IR<=bubble?0:IF_IR;
            PredictBranch_o<=bubble?0:PredictBranch;
            PredictBranchAddr_o<=bubble?0:PredictBranchAddr;
        end
    end
endmodule

module ID2EM1(
    input wire clk,
    input wire en,
    input wire reset,
    input wire bubble,
    
    input wire [31:0] ID_PC,
    input wire [31:0] ID_IR,
    input wire MCY,
    input wire RegWrite,
    input wire [4:0] WA,
    input wire [31:0] RD1,
    input wire [31:0] RD2,
    
    output reg [31:0] EM1_PC,
    output reg [31:0] EM1_IR,
    output reg MCY_o,
    output reg RegWrite_o,
    output reg [4:0] WA_o,
    output reg [31:0] RD1_o,
    output reg [31:0] RD2_o
);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            EM1_PC<=0;
            EM1_IR<=0;
            MCY_o<=0;
            RegWrite_o<=0;
            WA_o<=0;
            RD1_o<=0;
            RD2_o<=0;
        end
        else if (en) begin
            EM1_PC<=bubble?0:ID_PC;
            EM1_IR<=bubble?0:ID_IR;
            MCY_o<=bubble?0:MCY;
            RegWrite_o<=bubble?0:RegWrite;
            WA_o<=bubble?0:WA;
            RD1_o<=bubble?0:RD1;
            RD2_o<=bubble?0:RD2;
        end
    end
endmodule

module EM12EM2(
    input wire clk,
    input wire en,
    input wire reset,
    input wire bubble,
    
    input wire [31:0] EM1_PC,
    input wire [31:0] EM1_IR,
    input wire MCY,
    input wire RegWrite,
    input wire [4:0] WA,
    input wire [31:0] ll,
    input wire [31:0] lh,
    input wire [31:0] hl,
    input wire [31:0] hh,
    
    output reg [31:0] EM2_PC,
    output reg [31:0] EM2_IR,
    output reg MCY_o,
    output reg RegWrite_o,
    output reg [4:0] WA_o,
    output reg [31:0] ll_o,
    output reg [31:0] lh_o,
    output reg [31:0] hl_o,
    output reg [31:0] hh_o
);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            EM2_PC<=0;
            EM2_IR<=0;
            MCY_o<=0;
            RegWrite_o<=0;
            WA_o<=0;
            ll_o<=0;
            lh_o<=0;
            hl_o<=0;
            hh_o<=0;
        end
        else if (en) begin
            EM2_PC<=bubble?0:EM1_PC;
            EM2_IR<=bubble?0:EM1_IR;
            MCY_o<=bubble?0:MCY;
            RegWrite_o<=bubble?0:RegWrite;
            WA_o<=bubble?0:WA;
            ll_o<=bubble?0:ll;
            lh_o<=bubble?0:lh;
            hl_o<=bubble?0:hl;
            hh_o<=bubble?0:hh;
        end
    end
endmodule

module EM22WB2(
    input wire clk,
    input wire en,
    input wire reset,
    input wire bubble,
    
    input wire [31:0] EM2_PC,
    input wire [31:0] EM2_IR,
    input wire RegWrite,
    input wire [4:0] WA,
    input wire [31:0] EM_D,
    
    output reg [31:0] WB2_PC,
    output reg [31:0] WB2_IR,
    output reg RegWrite_o,
    output reg [4:0] WA_o,
    output reg [31:0] EM_D_o
);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            WB2_PC<=0;
            WB2_IR<=0;
            RegWrite_o<=0;
            WA_o<=0;
            EM_D_o<=0;
        end
        else if (en) begin
            WB2_PC<=bubble?0:EM2_PC;
            WB2_IR<=bubble?0:EM2_IR;
            RegWrite_o<=bubble?0:RegWrite;
            WA_o<=bubble?0:WA;
            EM_D_o<=bubble?0:EM_D;
        end
    end
endmodule

module ID2EX(
    input wire clk,
    input wire en,
    input wire reset,
    input wire bubble,
    
    input wire [31:0] ID_PC,
    input wire [31:0] ID_IR,
    input wire [3:0] ALUOP,
    input wire MemLoad,
    input wire MemToReg,
    input wire MemWrite,
    input wire ALUSource,
    input wire RegWrite,
    input wire JMP,
    input wire JR,
    input wire LUI,
    input wire JAL,
    input wire [2:0] BType,
    input wire LB_SB,
    input wire POF,
    input wire [4:0] WA,
    input wire [31:0] EXTD,
    input wire [31:0] RD1,
    input wire [31:0] RD2,
    input wire USE_SA,
    input wire MEM_ALUD2EX_RD1,
    input wire MEM_ALUD2EX_RD2,
    input wire WB_WD2EX_RD1,
    input wire WB_WD2EX_RD2,
    input wire PredictBranch,
//    input wire [31:0] PredictBranchAddr,
    
    output reg [31:0] EX_PC,
    output reg [31:0] EX_IR,
    output reg [3:0] ALUOP_o,
    output reg MemLoad_o,
    output reg MemToReg_o,
    output reg MemWrite_o,
    output reg ALUSource_o,
    output reg RegWrite_o,
    output reg JMP_o,
    output reg JR_o,
    output reg LUI_o,
    (* max_fanout = "10" *)output reg JAL_o,
    output reg [2:0] BType_o,
    output reg LB_SB_o,
    output reg POF_o,
    output reg [4:0] WA_o,
    output reg [31:0] EXTD_o,
    output reg [31:0] RD1_o,
    output reg [31:0] RD2_o,
    output reg USE_SA_o,
    output reg MEM_ALUD2EX_RD1_o,
    output reg MEM_ALUD2EX_RD2_o,
    output reg WB_WD2EX_RD1_o,
    output reg WB_WD2EX_RD2_o,
    output reg PredictBranch_o
//    output reg [31:0] PredictBranchAddr_o
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            EX_PC<=0;
            EX_IR<=0;
            ALUOP_o<=0;
            MemLoad_o<=0;
            MemToReg_o<=0;
            MemWrite_o<=0;
            ALUSource_o<=0;
            RegWrite_o<=0;
            JMP_o<=0;
            JR_o<=0;
            LUI_o<=0;
            JAL_o<=0;
            BType_o<=0;
            LB_SB_o<=0;
            POF_o<=0;
            WA_o<=0;
            EXTD_o<=0;
            RD1_o<=0;
            RD2_o<=0;
            USE_SA_o<=0;
            MEM_ALUD2EX_RD1_o<=0;
            MEM_ALUD2EX_RD2_o<=0;
            WB_WD2EX_RD1_o<=0;
            WB_WD2EX_RD2_o<=0;
            PredictBranch_o<=0;
//            PredictBranchAddr_o<=0;
        end
        else if (en) begin
            EX_PC<=bubble?0:ID_PC;
            EX_IR<=bubble?0:ID_IR;
            ALUOP_o<=bubble?0:ALUOP;
            MemLoad_o<=bubble?0:MemLoad;
            MemToReg_o<=bubble?0:MemToReg;
            MemWrite_o<=bubble?0:MemWrite;
            ALUSource_o<=bubble?0:ALUSource;
            RegWrite_o<=bubble?0:RegWrite;
            JMP_o<=bubble?0:JMP;
            JR_o<=bubble?0:JR;
            LUI_o<=bubble?0:LUI;
            JAL_o<=bubble?0:JAL;
            BType_o<=bubble?0:BType;
            LB_SB_o<=bubble?0:LB_SB;
            POF_o<=bubble?0:POF;
            WA_o<=bubble?0:WA;
            EXTD_o<=bubble?0:EXTD;
            RD1_o<=bubble?0:RD1;
            RD2_o<=bubble?0:RD2;
            USE_SA_o<=bubble?0:USE_SA;
            MEM_ALUD2EX_RD1_o<=bubble?0:MEM_ALUD2EX_RD1;
            MEM_ALUD2EX_RD2_o<=bubble?0:MEM_ALUD2EX_RD2;
            WB_WD2EX_RD1_o<=bubble?0:WB_WD2EX_RD1;
            WB_WD2EX_RD2_o<=bubble?0:WB_WD2EX_RD2;
            PredictBranch_o<=bubble?0:PredictBranch;
//            PredictBranchAddr_o<=bubble?0:PredictBranchAddr;
        end
    end
endmodule

module EX2MEM(
    input wire clk,
    input wire en,
    input wire reset,
    input wire bubble,
    
    input wire [31:0] EX_PC,
    input wire [31:0] EX_IR,
    input wire MemLoad,
    input wire MemToReg,
    input wire MemWrite,
    input wire RegWrite,
    input wire LB_SB,
    input wire [4:0] WA,
    input wire [31:0] ALUD,
    input wire [31:0] RD2,
    
    output reg [31:0] MEM_PC,
    output reg [31:0] MEM_IR,
    output reg MemLoad_o,
    output reg MemToReg_o,
    output reg MemWrite_o,
    output reg RegWrite_o,
    output reg LB_SB_o,
    output reg [4:0] WA_o,
    output reg [31:0] ALUD_o,
    output reg [31:0] RD2_o
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            MEM_PC<=0;
            MEM_IR<=0;
            MemLoad_o<=0;
            MemToReg_o<=0;
            MemWrite_o<=0;
            RegWrite_o<=0;
            LB_SB_o<=0;
            WA_o<=0;
            ALUD_o<=0;
            RD2_o<=0;
        end
        else if (en) begin
            MEM_PC<=bubble?0:EX_PC;
            MEM_IR<=bubble?0:EX_IR;
            MemLoad_o<=bubble?0:MemLoad;
            MemToReg_o<=bubble?0:MemToReg;
            MemWrite_o<=bubble?0:MemWrite;
            RegWrite_o<=bubble?0:RegWrite;
            LB_SB_o<=bubble?0:LB_SB;
            WA_o<=bubble?0:WA;
            ALUD_o<=bubble?0:ALUD;
            RD2_o<=bubble?0:RD2;
        end
    end
endmodule

module MEM2WB(
    input wire clk,
    input wire en,
    input wire reset,
    input wire bubble,
    
    input wire [31:0] MEM_PC,
    input wire [31:0] MEM_IR,
    input wire MemToReg,
    input wire RegWrite,
    input wire [4:0] WA,
    input wire [31:0] ALUD,
    input wire [31:0] MemDout,
    
    output reg [31:0] WB_PC,
    output reg [31:0] WB_IR,
    output reg MemToReg_o,
    output reg RegWrite_o,
    output reg [4:0] WA_o,
    output reg [31:0] ALUD_o,
    output reg [31:0] MemDout_o
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            WB_PC<=0;
            WB_IR<=0;
            MemToReg_o<=0;
            RegWrite_o<=0;
            WA_o<=0;
            ALUD_o<=0;
            MemDout_o<=0;
        end
        else if (en) begin
            WB_PC<=bubble?0:MEM_PC;
            WB_IR<=bubble?0:MEM_IR;
            MemToReg_o<=bubble?0:MemToReg;
            RegWrite_o<=bubble?0:RegWrite;
            WA_o<=bubble?0:WA;
            ALUD_o<=bubble?0:ALUD;
            MemDout_o<=bubble?0:MemDout;
        end
    end
endmodule
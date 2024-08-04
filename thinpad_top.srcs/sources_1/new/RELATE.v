`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/12 16:20:12
// Design Name: 
// Module Name: RELATE
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


module RELATE(
    input wire clk,
    input wire reset,

    input wire ID_RA1_Read,
    input wire ID_RA2_Read,
    input wire [4:0] ID_RA1,
    input wire [4:0] ID_RA2,
    input wire [4:0] EX_WA,
    input wire EX_RegWrite,
    input wire EX_MemLoad,
    input wire [4:0] MEM_WA,
    input wire MEM_RegWrite,
    input wire MEM_MemLoad,
    input wire [4:0] WB_WA,
    input wire WB_RegWrite,
    input wire [4:0] EM1_WA,
    input wire EM1_RegWrite,
    input wire [4:0] EM2_WA,
    input wire EM2_RegWrite,
    input wire [4:0] WB2_WA,
    input wire WB2_RegWrite,
    
    output reg ID_EXload,
    output reg ID_EM1_r,
    output reg EX_ALUD2ID_RD1,
    output reg EX_ALUD2ID_RD2,
    output reg MEM_ALUD2ID_RD1,
    output reg MEM_ALUD2ID_RD2,
    output reg MEM_MemDout2ID_RD1,
    output reg MEM_MemDout2ID_RD2,
    output reg WB_WD2ID_RD1,
    output reg WB_WD2ID_RD2,
    output reg WB2_EM_D2ID_RD1,
    output reg WB2_EM_D2ID_RD2,
    output reg EM2_EM_D2ID_RD1,
    output reg EM2_EM_D2ID_RD2
    );
    reg ID_RA1_r_EX_WA;
    reg ID_RA2_r_EX_WA;
    reg ID_r_EX;
    reg ID_RA1_r_EM1_WA;
    reg ID_RA2_r_EM1_WA;
//    reg ID_r_EM1;
    reg ID_RA1_r_EM2_WA;
    reg ID_RA2_r_EM2_WA;
//    reg ID_r_EM2;
    reg ID_RA1_r_MEM_WA;
    reg ID_RA2_r_MEM_WA;
//    reg ID_r_MEM;
    reg ID_RA1_r_WB_WA;
    reg ID_RA2_r_WB_WA;
//    reg ID_r_WB;
    reg ID_RA1_r_WB2_WA;
    reg ID_RA2_r_WB2_WA;
    always @(*) begin
        ID_RA1_r_EX_WA=(ID_RA1_Read && ID_RA1 && ID_RA1==EX_WA && EX_RegWrite);
        ID_RA2_r_EX_WA=(ID_RA2_Read && ID_RA2 && ID_RA2==EX_WA && EX_RegWrite);
        ID_r_EX=ID_RA1_r_EX_WA|ID_RA2_r_EX_WA;
        ID_RA1_r_EM1_WA=(ID_RA1_Read && ID_RA1 && ID_RA1==EM1_WA && EM1_RegWrite);
        ID_RA2_r_EM1_WA=(ID_RA2_Read && ID_RA2 && ID_RA2==EM1_WA && EM1_RegWrite);
        ID_EM1_r=ID_RA1_r_EM1_WA|ID_RA2_r_EM1_WA;
        ID_RA1_r_EM2_WA=(ID_RA1_Read && ID_RA1 && ID_RA1==EM2_WA && EM2_RegWrite);
        ID_RA2_r_EM2_WA=(ID_RA2_Read && ID_RA2 && ID_RA2==EM2_WA && EM2_RegWrite);
        ID_r_EX=ID_RA1_r_EX_WA|ID_RA2_r_EX_WA;
        ID_RA1_r_MEM_WA=(ID_RA1_Read && ID_RA1 && ID_RA1==MEM_WA && MEM_RegWrite);
        ID_RA2_r_MEM_WA=(ID_RA2_Read && ID_RA2 && ID_RA2==MEM_WA && MEM_RegWrite);
//        ID_r_MEM=ID_RA1_r_MEM_WA|ID_RA2_r_MEM_WA;
        ID_EXload=ID_r_EX&EX_MemLoad;
        ID_RA1_r_WB_WA=(ID_RA1_Read && ID_RA1 && ID_RA1==WB_WA && WB_RegWrite);
        ID_RA2_r_WB_WA=(ID_RA2_Read && ID_RA2 && ID_RA2==WB_WA && WB_RegWrite);
//        ID_r_WB=ID_RA1_r_WB_WA|ID_RA2_r_WB_WA;
        ID_RA1_r_WB2_WA=(ID_RA1_Read && ID_RA1 && ID_RA1==WB2_WA && WB2_RegWrite);
        ID_RA2_r_WB2_WA=(ID_RA2_Read && ID_RA2 && ID_RA2==WB2_WA && WB2_RegWrite);
    end
    always @(*) begin
        EX_ALUD2ID_RD1=ID_RA1_r_EX_WA&!EX_MemLoad;
        EX_ALUD2ID_RD2=ID_RA2_r_EX_WA&!EX_MemLoad;
        MEM_ALUD2ID_RD1=ID_RA1_r_MEM_WA&!MEM_MemLoad;
        MEM_ALUD2ID_RD2=ID_RA2_r_MEM_WA&!MEM_MemLoad;
        MEM_MemDout2ID_RD1=ID_RA1_r_MEM_WA&MEM_MemLoad;
        MEM_MemDout2ID_RD2=ID_RA2_r_MEM_WA&MEM_MemLoad;
        WB_WD2ID_RD1=ID_RA1_r_WB_WA;
        WB_WD2ID_RD2=ID_RA2_r_WB_WA;
        WB2_EM_D2ID_RD1=ID_RA1_r_WB2_WA;
        WB2_EM_D2ID_RD2=ID_RA2_r_WB2_WA;
        EM2_EM_D2ID_RD1=ID_RA1_r_EM2_WA;
        EM2_EM_D2ID_RD2=ID_RA2_r_EM2_WA;
    end
endmodule

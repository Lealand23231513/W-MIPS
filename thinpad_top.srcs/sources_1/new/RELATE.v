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
    
    output reg ID_EXload,
    output reg MEM_ALUD2EX_RD1,
    output reg MEM_ALUD2EX_RD2,
    output reg WB_WD2EX_RD1,
    output reg WB_WD2EX_RD2
    );
    reg ID_RA1_r_EX_WA;
    reg ID_RA2_r_EX_WA;
    reg ID_r_EX;
    reg ID_RA1_r_MEM_WA;
    reg ID_RA2_r_MEM_WA;
    reg ID_r_MEM;
    always @(*) begin
        ID_RA1_r_EX_WA=(ID_RA1_Read && ID_RA1 && ID_RA1==EX_WA && EX_RegWrite);
        ID_RA2_r_EX_WA=(ID_RA2_Read && ID_RA2 && ID_RA2==EX_WA && EX_RegWrite);
        ID_r_EX=ID_RA1_r_EX_WA|ID_RA2_r_EX_WA;
        ID_RA1_r_MEM_WA=(ID_RA1_Read && ID_RA1 && ID_RA1==MEM_WA && MEM_RegWrite);
        ID_RA2_r_MEM_WA=(ID_RA2_Read && ID_RA2 && ID_RA2==MEM_WA && MEM_RegWrite);
        ID_r_MEM=ID_RA1_r_MEM_WA|ID_RA2_r_MEM_WA;
        ID_EXload=ID_r_EX&EX_MemLoad;
    end
    always @(*) begin
        WB_WD2EX_RD1=ID_RA1_r_MEM_WA;
        WB_WD2EX_RD2=ID_RA2_r_MEM_WA;
        MEM_ALUD2EX_RD1=ID_RA1_r_EX_WA&!EX_MemLoad;
        MEM_ALUD2EX_RD2=ID_RA2_r_EX_WA&!EX_MemLoad;
    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 15:25:00
// Design Name: 
// Module Name: controler
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


module controler(
    input wire[31:0] IR,
    
    output wire[3:0] ALUOP,
    output wire [2:0] BTYPE,
    output wire MemWrite,
    output wire ALUSource,
    output wire RegWrite,
    output wire RegDst,
    output wire EXTOP,
    output wire LUI,
    output wire JMP,
    output wire JR,
    output wire JAL,
    output wire MemLoad,
    output wire RA1_READ,
    output wire RA2_READ,
    output wire LB_SB,
    output wire POF,
    output wire USE_SA,
    output wire [2:0] FUID,
    output wire MUL
    );
    wire [5:0]OP=IR[31:26];
    wire [5:0]FUNCT=IR[5:0];
    
    //decode
    wire addu=(OP==6'b000000)&(FUNCT==6'b100001);
    wire subu=(OP==6'b000000)&(FUNCT==6'b100011);
    wire ori=(OP==6'b001101);
    wire lw=(OP==6'b100011);
    wire sw=(OP==6'b101011);
    wire beq=(OP==6'b000100);
    wire lui=(OP==6'b001111);
//    wire nop=(OP==6'b0)&(FUNCT==6'b0);
    wire j=(OP==6'b000010);
    wire jal=(OP==6'b000011);
    wire jr=(OP==6'b000000)&(FUNCT==6'b001000);
    wire bne=(OP==6'b000101);
    wire andi=(OP==6'b001100);
    wire XOR=(OP==6'b000000)&(FUNCT==6'b100110);
    wire addiu=(OP==6'b001001);
    wire lb=(OP==6'b100000);
    wire sb=(OP==6'b101000);
    wire sll=(OP==6'b000000)&(FUNCT==6'b000000);
    wire add=(OP==6'b000000)&(FUNCT==6'b100000);
    wire srav=(OP==6'b000000)&(FUNCT==6'b000111);
    wire blez=(OP==6'b000110);
    wire OR=(OP==6'b000000)&(FUNCT==6'b100101);
    wire AND=(OP==6'b000000)&(FUNCT==6'b100100);
    wire xori=(OP==6'b001110);
    wire srl=(OP==6'b000000)&(FUNCT==6'b000010);
    wire bgtz=(OP==6'b000111);
    wire mul=(OP==6'b011100)&(FUNCT==6'b000010);
    wire slt=(OP==6'b000000)&(FUNCT==6'b101010);
    wire sltu=(OP==6'b000000)&(FUNCT==6'b101011);
    
    
    //generate control sigs
    assign ALUOP[0]=subu|lui|XOR|sll|xori|srl|sltu;
    assign ALUOP[1]=addu|lw|sw|jal|addiu|lb|sb|add|srav|srl|mul|sltu;
    assign ALUOP[2]=lui|sll|srav|srl|slt;
    assign ALUOP[3]=andi|XOR|AND|xori|mul;
    assign BTYPE[0]=beq|blez|bgtz;
    assign BTYPE[1]=bne;
    assign BTYPE[2]=blez;
    assign MemWrite=sw|sb;
    assign ALUSource=ori|lw|sw|lui|andi|addiu|lb|sb|xori;
    assign RegWrite=addu|subu|ori|lw|lui|jal|andi|XOR|addiu|lb|sll|add|srav|OR|AND|xori|srl|mul|slt|sltu;
    assign RegDst=addu|subu|jr|XOR|sll|add|srav|OR|AND|srl|mul|slt|sltu;
    assign EXTOP=lw|sw|beq|bne|addiu|lb|sb|blez|bgtz;
    assign LUI=lui;
    assign JMP=j|jal;
    assign JR=jr;
    assign JAL=jal;
    assign MemLoad=lw|lb;
    assign RA1_READ=addu|subu|ori|lw|sw|beq|jr|bne|andi|XOR|addiu|lb|sb|add|srav|blez|OR|AND|xori|bgtz|mul|slt|sltu;
    assign RA2_READ=addu|subu|sw|beq|bne|XOR|sll|add|srav|OR|AND|srl|mul|slt|sltu;
    assign LB_SB=lb|sb;
    assign POF=add;
    assign USE_SA=sll|srl;
//    assign ID_RegUse=beq|jr|bne|blez|bgtz;
    assign FUID[0]=lw|sw|beq|j|jr|bne|lb|sb|blez|bgtz|mul;
    assign FUID[1]=beq|j|jr|bne|blez|bgtz;
    assign FUID[2]=0;
    assign MUL=mul;
endmodule

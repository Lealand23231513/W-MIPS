`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/01 19:33:25
// Design Name: 
// Module Name: GRF
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
module RGF(
    input wire clk,
    input wire reset,//1 有效
    input wire [4:0]Ra1,
    input wire [4:0]Ra2, 
    
    input wire WE1, //1 valid
    input wire [4:0]WA1,//1 valid, low priority
    input wire [31:0]WD1,//1 有效
    
    input wire WE2,
    input wire [4:0]WA2,
    input wire [31:0]WD2,

    output wire [31:0]Rd1,
    output wire [31:0]Rd2
);
 
reg [31:0]DataReg[31:0];
integer i=0;
wire [31:0]data[31:0];
wire en[31:0];
genvar j;
generate 
    assign en[0]=0;
    assign data[0]=0;
    for(j=1;j<32;j=j+1) begin
        assign en[j]=(WA1==j&WE1|WA2==j&WE2);
        assign data[j]=(WA2==j&WE2?WD2:WD1);
    end
endgenerate
always@(posedge clk, posedge reset) begin 
    if (reset) begin
        for(i=0;i<32;i=i+1) begin
            DataReg[i]<=0;
        end  
    end
    else begin
        for(i=1;i<32;i=i+1) begin
            if(en[i]) DataReg[i]<=data[i];
        end 
    end
end  
assign Rd1 = en[Ra1]?data[Ra1]:DataReg[Ra1];
assign Rd2 = en[Ra2]?data[Ra2]:DataReg[Ra2];
 

endmodule

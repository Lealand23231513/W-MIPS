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


module RGF(
     input wire clk,
     input wire WE, //1 有效
     input wire reset,//1 有效
	 input wire [4:0]Ra1,
	 input wire [4:0]Ra2, 
	 input wire [4:0]WA,//1 有效
	 input wire [31:0]WD,//1 有效
	 output wire [31:0]Rd1,
	 output wire [31:0]Rd2
 );
 
reg [31:0]DataReg[31:0];
integer i=0;
 
always@(posedge clk, posedge reset) begin 
   if (reset) begin
        for(i=0;i<32;i=i+1) begin
            DataReg[i]<=0;
        end  
   end
   else if(WE && WA) begin
        DataReg[WA]<=WD;
   end
end  
 
assign Rd1 = (Ra1==5'd0)?32'd0:DataReg[Ra1];
assign Rd2 = (Ra2==5'd0)?32'd0:DataReg[Ra2];
 

endmodule

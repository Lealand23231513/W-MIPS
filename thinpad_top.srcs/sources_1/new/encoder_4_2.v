`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/10 11:42:14
// Design Name: 
// Module Name: encoder_4_2
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

module encoder_4_2(//large first
    input wire [3:0] in,
    input wire valid,
    output reg [1:0] out,
    output wire valid_o
    );
//    parameter prio_order=1;//0: small first, 1: large first
    assign valid_o=valid;
    always @(*) begin
        if (valid) begin
            if(in[3]) out=3;
            else if(in[2]) out=2;
            else if(in[1]) out=1;
            else if(in[0]) out=0;
            else out=0;
        end
        else out=0;
    end
endmodule
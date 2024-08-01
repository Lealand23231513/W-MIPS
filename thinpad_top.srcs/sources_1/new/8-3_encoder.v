`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 16:00:51
// Design Name: 
// Module Name: 8-3_encoder
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


module encoder_8_3(
    input wire [7:0]in,
    output wire [2:0]out,
    output wire valid
    );
    assign out =in[0]?3'd0:
                in[1]?3'd1:
                in[2]?3'd2:
                in[3]?3'd3:
                in[4]?3'd4:
                in[5]?3'd5:
                in[6]?3'd6:
                in[7]?3'd7:3'd0;
    assign valid = in[0]|in[1]|in[2]|in[3]|in[4]|in[5]|in[6]|in[7];
endmodule

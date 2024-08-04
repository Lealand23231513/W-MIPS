`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 11:10:57
// Design Name: 
// Module Name: sign_bit_extender
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


module sign_bit_extender#(
    parameter INPUT_WIDTH = 16,
    parameter OUTPUT_WIDTH = 32
)(
    input  wire signed [INPUT_WIDTH-1  : 0] input_n,
    output wire signed [OUTPUT_WIDTH-1 : 0] output_n
);

    assign output_n = {{(OUTPUT_WIDTH - INPUT_WIDTH){input_n[INPUT_WIDTH-1]}}, input_n};
endmodule

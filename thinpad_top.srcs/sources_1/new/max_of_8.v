`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 16:47:48
// Design Name: 
// Module Name: max_of_8
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


module max_of_8(
    input wire [31:0] data,
    output wire [2:0] max_idx,
    output wire [3:0] max_value
    );// 相同的情况下，idx小的优先
    wire [3:0] value[7:0];
    wire [3:0] max_1_value[3:0], max_2_value[1:0];
    wire max_1_idx[3:0], max_2_idx[1:0];
    genvar j;
    generate 
        for(j=0;j<8;j=j+1) begin
            assign value[j]=data[4*(j+1)-1:4*j];
        end
        for (j=0;j<4;j=j+1) begin
            assign {max_1_value[j], max_1_idx[j]}=(value[2*j]>=value[2*j+1])?{value[2*j], 2*j}:{value[2*j+1], 2*j+1};
        end
        for (j=0;j<2;j=j+1) begin
            assign {max_2_value[j], max_2_idx[j]}=(max_1_value[2*j]>=max_1_value[2*j+1])?{max_1_value[2*j],max_1_idx[2*j]}:{max_1_value[2*j+1],max_1_idx[2*j+1]};
        end
        assign {max_value, max_idx}=(max_2_value[0]>=max_1_value[1])?{max_1_value[0],max_1_idx[0]}:{max_1_value[1],max_1_idx[1]};
    endgenerate
    
endmodule

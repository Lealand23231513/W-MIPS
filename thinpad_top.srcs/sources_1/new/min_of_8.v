`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/08 10:18:06
// Design Name: 
// Module Name: min_of_8
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


module sel_from_8#(
    parameter VALUE_WIDTH=4
)(
    input wire [8*VALUE_WIDTH-1:0] value_st,
    input wire [7:0] valid_st,
    output wire [2:0] sel_idx,
    output wire [VALUE_WIDTH-1:0] sel_value_o,
    output wire valid_o
    );
    wire [VALUE_WIDTH:0] value[7:0], sel_3_value;
    wire [VALUE_WIDTH:0] sel_1_value[3:0], sel_2_value[1:0];
    wire [2:0] sel_1_idx[3:0], sel_2_idx[1:0];
    genvar j;
    generate 
        for(j=0;j<8;j=j+1) begin
            assign value[j]={valid_st[j], value_st[VALUE_WIDTH*(j+1)-1:VALUE_WIDTH*j]};
        end
        for (j=0;j<4;j=j+1) begin
            assign {sel_1_idx[j], sel_1_value[j]}=(value[2*j]>=value[2*j+1])?{2*j, value[2*j]}:{2*j+1, value[2*j+1]};
        end
        for (j=0;j<2;j=j+1) begin
            assign {sel_2_value[j], sel_2_idx[j]}=(sel_1_value[2*j]>=sel_1_value[2*j+1])?{sel_1_value[2*j],sel_1_idx[2*j]}:{sel_1_value[2*j+1],sel_1_idx[2*j+1]};
        end
        assign {sel_3_value, sel_idx}=(sel_2_value[0]>=sel_2_value[1])?{sel_2_value[0],sel_2_idx[0]}:{sel_2_value[1],sel_2_idx[1]};
    endgenerate
    assign {valid_o, sel_value_o}=sel_3_value;
endmodule

module sel_from_4#(
    parameter VALUE_WIDTH=4
)(
    input wire [4*VALUE_WIDTH-1:0] value_st,
    input wire [3:0] valid_st,
    output wire [1:0] sel_idx,
    output wire [VALUE_WIDTH-1:0] sel_value_o,
    output wire valid_o
    );
    wire [VALUE_WIDTH:0] value[3:0];
    wire [VALUE_WIDTH:0] sel_1_value[1:0], sel_2_value;
    wire [1:0] sel_1_idx[1:0], sel_2_idx;
    genvar j;
    generate 
        for(j=0;j<4;j=j+1) begin
            assign value[j]={valid_st[j], value_st[VALUE_WIDTH*(j+1)-1:VALUE_WIDTH*j]};
        end
        for (j=0;j<2;j=j+1) begin
            assign {sel_1_idx[j], sel_1_value[j]}=(value[2*j]>=value[2*j+1])?{2*j, value[2*j]}:{2*j+1, value[2*j+1]};
        end
        assign {sel_2_value, sel_idx}=(sel_1_value[0]>=sel_1_value[1])?{sel_1_value[0],sel_1_idx[0]}:{sel_1_value[1],sel_1_idx[1]};
    endgenerate
    assign {valid_o, sel_value_o}=sel_2_value;
endmodule

module sel_from_2#(
    parameter VALUE_WIDTH=4
)(
    input wire [2*VALUE_WIDTH-1:0] value_st,
    input wire [1:0] valid_st,
    output wire sel_idx,
    output wire [VALUE_WIDTH-1:0] sel_value_o,
    output wire valid_o
    );
    wire [VALUE_WIDTH:0] value[1:0];
    wire [VALUE_WIDTH:0] sel_1_value[1:0];
    genvar j;
    generate 
        for(j=0;j<2;j=j+1) begin
            assign value[j]={valid_st[j], value_st[VALUE_WIDTH*(j+1)-1:VALUE_WIDTH*j]};
        end
        assign {sel_idx, valid_o, sel_value_o}=(value[0]>=value[1])?{1'b0, value[0]}:{1'b1, value[1]};
    endgenerate
endmodule

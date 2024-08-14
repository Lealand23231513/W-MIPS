`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/11 12:24:22
// Design Name: 
// Module Name: flru_manager_8
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


module flru_manager_8(
    input wire clk, reset, en,
    input wire [2:0] hit_idx,
    output wire [2:0] rm_idx
    );
    reg lru_L1;
    reg [1:0]lru_L2; 
    reg [3:0]lru_L3;
    wire hit_L2_idx, L2_rm_idx;
    wire [1:0] hit_L3_idx;
    wire [1:0]L3_rm_idx;
    assign hit_L2_idx=hit_idx[2];
    assign hit_L3_idx=hit_idx[2:1];
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            lru_L1<=0;
            lru_L2<=0;
            lru_L3<=0;
        end
        else if (en) begin
            lru_L1<=~hit_idx[2];
            lru_L2[hit_L2_idx]<=~hit_idx[1];
            lru_L3[hit_L3_idx]<=~hit_idx[0];
        end
    end
    assign L2_rm_idx=lru_L1;
    assign L3_rm_idx={L2_rm_idx, lru_L2[L2_rm_idx]};
    assign rm_idx={lru_L1, lru_L2[L2_rm_idx], lru_L3[L3_rm_idx]};
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/25 12:35:44
// Design Name: 
// Module Name: BTB
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


module BTB(
    input wire clk,reset,
    input wire [31:0] PC,
    input wire [2:0]BR_BTYPE,
    input wire BR_BranchTaken,// Actual branch
    input wire BR_PredictBranch,
    input wire [31:0] BR_PC,
    input wire [31:0] BR_BranchAddr,
    output wire PredictBranch,//predict branch(PF)
    output wire [31:0]PredictBranchAddr
    );
    parameter BTB_SIZE=8;
    reg v [BTB_SIZE-1:0];
    reg [31:0] branchPC [BTB_SIZE-1:0], dstPC[BTB_SIZE-1:0];
    reg [1:0] history[BTB_SIZE-1:0];//2'b00, 2'b01: not branch; 2'b10, 2'b11: branch
    reg [3:0] lru[BTB_SIZE-1:0];
    wire [BTB_SIZE*4-1:0] lru_stack;
    wire [BTB_SIZE-1:0] PC_hit, BR_PC_hit;
    wire [2:0] PC_idx, BR_PC_idx, idx_replace, lru_idx_hit;
    wire valid_PC_idx, valid_BR_PC_idx;
    wire flru_en;
    integer i;
    genvar j;
    generate
        for (j=0;j<BTB_SIZE;j=j+1) begin
            assign PC_hit[j]=v[j]&(PC==branchPC[j]);
            assign BR_PC_hit[j]=v[j]&(BR_PC==branchPC[j]);
        end
    endgenerate
    encoder_8_3 encoder_8_3_1(
        .in(PC_hit),
        .out(PC_idx),
        .valid(valid_PC_idx)
    );
    encoder_8_3 encoder_8_3_2(
        .in(BR_PC_hit),
        .out(BR_PC_idx),
        .valid(valid_BR_PC_idx)
    );
    flru_manager_8 flru_manager_8(
        .clk(clk), 
        .reset(reset), 
        .en(flru_en),
        .hit_idx(lru_idx_hit),
        .rm_idx(idx_replace)
    );
    assign PredictBranch=valid_PC_idx&history[PC_idx][1];
    assign PredictBranchAddr=dstPC[PC_idx];
    assign flru_en=(BR_BTYPE!=0);
    assign lru_idx_hit=valid_BR_PC_idx?BR_PC_idx:idx_replace;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            for(i=0;i<BTB_SIZE;i=i+1) begin
                v[i]<=0;
                branchPC[i]<=0;
                dstPC[i]<=0;
                history[i]<=2'b00;
            end
        end
        else begin
            if (BR_BTYPE) begin
                if (valid_BR_PC_idx) begin
                    case (history[BR_PC_idx])
                        2'b00: begin
                            history[BR_PC_idx]<=BR_BranchTaken?2'b01:2'b00;
                        end
                        2'b01: begin
                            history[BR_PC_idx]<=BR_BranchTaken?2'b10:2'b00;
                        end
                        2'b10: begin
                            history[BR_PC_idx]<=BR_BranchTaken?2'b10:2'b11;
                        end
                        2'b11: begin
                            history[BR_PC_idx]<=BR_BranchTaken?2'b10:2'b00;
                        end
                    endcase
                end
                else begin//valid_BR_PC_idx==0
                    v[idx_replace]<=1;
                    history[idx_replace]<=BR_BranchTaken?2'b10:2'b00;
                    branchPC[idx_replace]<=BR_PC;
                    dstPC[idx_replace]<=BR_BranchAddr;
                end
            end
        end
    end
endmodule

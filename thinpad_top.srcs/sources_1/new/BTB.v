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
    input wire [2:0]EX_Btype,
    input wire EX_BranchTaken,//EX µº Branch
    input wire EX_PredictBranch,//EX‘§≤‚Branch
    input wire [31:0] EX_PC,
    input wire [31:0] EX_BranchAddr,
    output wire PredictBranch,// ‘§≤‚branch
    output wire [31:0]PredictBranchAddr
    );
    parameter BTB_SIZE=8;
    reg v [BTB_SIZE-1:0];
    reg [31:0] branchPC [BTB_SIZE-1:0], dstPC[BTB_SIZE-1:0];
    reg [1:0] history[BTB_SIZE-1:0];//2'b00, 2'b01: not branch; 2'b10, 2'b11: branch
    reg [3:0] lru[BTB_SIZE-1:0];
//    reg [31:0] EX_PC_hit_lst;
    wire [BTB_SIZE*4-1:0] lru_stack;
    wire [BTB_SIZE-1:0] PC_hit, EX_PC_hit;
    wire [2:0] PC_idx, EX_PC_idx, idx_replace;
    wire valid_PC_idx, valid_EX_PC_idx;
    integer i;
    genvar j;
    generate
        for (j=0;j<BTB_SIZE;j=j+1) begin
            assign PC_hit[j]=v[j]&(PC==branchPC[j]);
            assign EX_PC_hit[j]=v[j]&(EX_PC==branchPC[j]);
            assign lru_stack[4*(j+1)-1:4*j]=lru[j];
        end
    endgenerate
    encoder_8_3 encoder_8_3_1(
        .in(PC_hit),
        .out(PC_idx),
        .valid(valid_PC_idx)
    );
    encoder_8_3 encoder_8_3_2(
        .in(EX_PC_hit),
        .out(EX_PC_idx),
        .valid(valid_EX_PC_idx)
    );
    max_of_8 max_of_8(
        .data(lru_stack),
        .max_idx(idx_replace)
    );
    assign PredictBranch=valid_PC_idx&history[PC_idx][1];
    assign PredictBranchAddr=valid_PC_idx&history[PC_idx][1]?dstPC[PC_idx]:0;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            for(i=0;i<BTB_SIZE;i=i+1) begin
                v[i]<=0;
                branchPC[i]<=0;
                dstPC[i]<=0;
                history[i]<=2'b00;
                lru[i]<=4'b1111;
//                EX_PC_hit_lst<=0;
            end
        end
        else begin
            if (EX_Btype) begin
//                if (EX_PredictBranch)
//                EX_PC_hit_lst<=EX_PC;
                if (valid_EX_PC_idx) begin
                    case (history[EX_PC_idx])
                        2'b00: begin
                            history[EX_PC_idx]<=EX_BranchTaken?2'b01:2'b00;
                        end
                        2'b01: begin
                            history[EX_PC_idx]<=EX_BranchTaken?2'b10:2'b00;
                        end
                        2'b10: begin
                            history[EX_PC_idx]<=EX_BranchTaken?2'b10:2'b11;
                        end
                        2'b11: begin
                            history[EX_PC_idx]<=EX_BranchTaken?2'b10:2'b00;
                        end
                    endcase
                    for(i=0;i<BTB_SIZE;i=i+1) begin
                        if(i==EX_PC_idx) begin
                            lru[i]<=0;
                        end
                        else if (lru[i]!=4'b1111) begin
                            lru[i]<=lru[i]+1;
                        end
                    end
                end
                else begin//valid_EX_PC_idx==0
                    v[idx_replace]<=1;
                    lru[idx_replace]<=0;
                    history[idx_replace]<=EX_BranchTaken?2'b10:2'b00;
                    branchPC[idx_replace]<=EX_PC;
                    dstPC[idx_replace]<=EX_BranchAddr;
                end
            end
        end
    end
endmodule

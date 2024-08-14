`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/02 22:48:18
// Design Name: 
// Module Name: issue_log
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
module issue_log(
    input wire clk, reset,
    output wire full,
    output wire empty,
    output wire valid,
    output reg [`FID_WIDTH-1:0]FID_curr,
    input wire wr_en,
    input wire [1:0]rd_en,
    
    input wire [`FID_WIDTH:0] EX_FID_bus,
    input wire [`FID_WIDTH:0] EXF_FID_bus,
    input wire [`FID_WIDTH:0] AG_FID_bus,
    input wire [`FID_WIDTH:0] MEM_FID_bus,
    input wire [`FID_WIDTH:0] LSF_FID_bus,
    output wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EX_FID_idx,
    output wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] EXF_FID_idx,
    output wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] AG_FID_idx,
    output wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] MEM_FID_idx,
    output wire [`ISSUE_LOG_DEPTH_WIDTH-1:0] LSF_FID_idx
    );
    reg [`FID_WIDTH-1:0] fifo_mem[`ISSUE_LOG_DEPTH-1:0];
//    wire [`FID_WIDTH:0] head_fifo_mem[2:0];
    reg [`ISSUE_LOG_DEPTH_WIDTH-1:0] FID_table[`ISSUE_LOG_DEPTH-1:0];//highest: valid, else: FID
    reg [`ISSUE_LOG_DEPTH_WIDTH-1:0] FID2idx_table[`ISSUE_LOG_DEPTH-1:0];
    wire [`ISSUE_LOG_DEPTH-1:0] will_build;
//    wire [`FID_WIDTH*`ISSUE_LOG_DEPTH-1:0]fifo_mem_st;
//    reg [`ISSUE_LOG_DEPTH-1:0]v;
//    reg [`ISSUE_LOG_DEPTH_WIDTH-1:0]idx[`ISSUE_LOG_DEPTH-1:0], idx_nxt[`ISSUE_LOG_DEPTH-1:0];
//    wire [`ISSUE_LOG_DEPTH_WIDTH*`ISSUE_LOG_DEPTH-1:0]idx_st;
    reg [`ISSUE_LOG_DEPTH_WIDTH-1:0] head,tail, head_nxt, tail_nxt;
    `ifdef SIMULATION
    reg [`ISSUE_LOG_DEPTH_WIDTH-1:0] cnt, cnt_nxt;
    `endif
    reg [`FID_WIDTH-1:0]FID_nxt;
    wire [`FID_WIDTH-1:0] EX_FID, EXF_FID, EM1_FID, EM2_FID, EMF_FID, AG_FID, MEM_FID, LSF_FID;
    wire EX_FID_v, EXF_FID_v, EM1_FID_v, EM2_FID_v, AG_FID_v, MEM_FID_v, LSF_FID_v;
    integer i;
    genvar j;
    function [`ISSUE_LOG_DEPTH_WIDTH-1:0] offset2idx;
        input [`ISSUE_LOG_DEPTH_WIDTH-1:0] offset;
        input [`ISSUE_LOG_DEPTH_WIDTH-1:0] head;
        offset2idx=$signed({1'b0,offset})-$signed({1'b0,head});
    endfunction
    assign empty=(head==tail);
    assign full=(head==tail+1);
    assign valid=!empty;
    assign {EX_FID_v, EX_FID}=EX_FID_bus;
    
    assign EX_FID_idx=EX_FID_v?FID2idx_table[EX_FID]:`ISSUE_LOG_DEPTH-1;
    assign {EXF_FID_v, EXF_FID}=EXF_FID_bus;
    assign EXF_FID_idx=EXF_FID_v?FID2idx_table[EXF_FID]:`ISSUE_LOG_DEPTH-1;
    assign {AG_FID_v, AG_FID}=AG_FID_bus;
    assign AG_FID_idx=AG_FID_v?FID2idx_table[AG_FID]:`ISSUE_LOG_DEPTH-1;
    assign {MEM_FID_v, MEM_FID}=MEM_FID_bus;
    assign MEM_FID_idx=MEM_FID_v?FID2idx_table[MEM_FID]:`ISSUE_LOG_DEPTH-1;
    assign {LSF_FID_v, LSF_FID}=LSF_FID_bus;
    assign LSF_FID_idx=LSF_FID_v?FID2idx_table[LSF_FID]:`ISSUE_LOG_DEPTH-1;
    generate 
        for(j=0;j<`ISSUE_LOG_DEPTH;j=j+1) begin
            assign will_build[j]=(j==FID_curr&&wr_en&&!full);
        end
    endgenerate
    always @(*) begin
        if(!empty) begin
            case(rd_en) 
                2'b01: head_nxt=head+1;
                2'b11: head_nxt=head+2;
                default: head_nxt=head;
            endcase
        end
        else head_nxt=head;       
        tail_nxt=tail+(wr_en&!full);
        FID_nxt=FID_curr+(wr_en&!full);
        `ifdef SIMULATION
        cnt_nxt=$signed({1'b0,tail_nxt})-$signed({1'b0,head_nxt});
        `endif
    end
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for(i=0;i<`ISSUE_LOG_DEPTH;i=i+1) begin
                fifo_mem[i]<=0;
                FID_table[i]<=0;
                FID2idx_table[i]<=0;
            end
            head<=0;
            tail<=0;
            FID_curr<=0;
            `ifdef SIMULATION
            cnt<=0;
            `endif
        end
        else begin
            head<=head_nxt;
            tail<=tail_nxt;
            FID_curr<=FID_nxt;
            if (wr_en&!full) begin
                fifo_mem[tail]<=FID_curr;
            end
            `ifdef SIMULATION
            cnt<=cnt_nxt;
            `endif
            for(i=0;i<`ISSUE_LOG_DEPTH;i=i+1) begin
                if (will_build[i]) begin
                    FID_table[i]<=tail;
                    FID2idx_table[i]<=offset2idx(tail, head_nxt);
                end
                else begin
                    FID2idx_table[i]<=offset2idx(FID_table[i], head_nxt);
                end
            end
        end
    end
endmodule

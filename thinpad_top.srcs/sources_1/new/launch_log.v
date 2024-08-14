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


module issue_log(
    input wire clk, reset,
    output wire full,
    output wire empty,
    output wire valid,
    input wire [63:0] PC_issue_stack,
    output wire [31:0] head_PC,
    input wire [1:0]wr_en,
    input wire [1:0]rd_en
    );
    parameter FIFO_DEPTH=8;
    reg [31:0] fifo_mem[FIFO_DEPTH-1:0];
    reg [2:0] head,tail;
    wire [31:0] PC_issue[1:0];
    assign PC_issue[0]=PC_issue_stack[31:0];// first PC issue
    assign PC_issue[1]=PC_issue_stack[63:32];//second PC issue
    integer i;
    assign empty=(head==tail);
    assign full=(head==tail+1);
    assign head_PC=fifo_mem[head];
    assign valid=!empty;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for(i=0;i<FIFO_DEPTH;i=i+1) begin
                fifo_mem[i]<=0;
            end
            head<=0;
            tail<=0;
        end
        else begin
            if (rd_en==1&!empty) begin
                head<=head+1;
            end
            else if (rd_en==2&!empty) begin//may have bugs
                head<=head+2;
            end
            if (wr_en==1&!full) begin
                tail<=tail+1;
                fifo_mem[tail]<=PC_issue[0];
            end
            else if (wr_en==2&!full) begin//may have bugs
                tail<=tail+2;
                fifo_mem[tail]<=PC_issue[0];
                fifo_mem[tail+1]<=PC_issue[1];
            end
        end
    end
endmodule

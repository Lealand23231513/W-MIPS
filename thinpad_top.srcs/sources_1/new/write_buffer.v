`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/23 19:08:13
// Design Name: 
// Module Name: write_buffer
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


module write_buffer(
    input wire clk, reset,
    output wire full,
    output wire empty,
    input wire [55:0] din,
    output wire [55:0] dout,
    input wire wr_en, rd_en
    );
    parameter FIFO_DEPTH=16;
    reg [55:0] fifo_mem[FIFO_DEPTH-1:0];
    reg [3:0] head,tail;
    integer i;
    assign empty=(head==tail);
    assign full=(head==tail+1);
    assign dout=fifo_mem[head];
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for(i=0;i<FIFO_DEPTH;i=i+1) begin
                fifo_mem[i]<=0;
            end
            head<=0;
            tail<=0;
        end
        else begin
            if (rd_en&!empty) begin
                head<=head+1;
                fifo_mem[head]<=0;
            end
            if (wr_en&!full) begin
                tail<=tail+1;
                fifo_mem[tail]<=din;
            end
        end
    end
endmodule


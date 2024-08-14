`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/08 22:37:31
// Design Name: 
// Module Name: FID2idx
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

//`include "global_def.vh"
//module FID2idx(
//    input wire [`FID_WIDTH:0] FID_bus,
//    input wire [`ISSUE_LOG_DEPTH-1:0] v,
//    input wire [`FID_WIDTH*`ISSUE_LOG_DEPTH-1:0]fifo_mem_st,
//    input wire [`ISSUE_LOG_DEPTH_WIDTH*`ISSUE_LOG_DEPTH-1:0]idx_st,
//    output reg [`ISSUE_LOG_DEPTH_WIDTH-1:0]idx_o
//    );
//    wire [`FID_WIDTH-1:0] fifo_mem[`ISSUE_LOG_DEPTH-1:0];
//    wire [`ISSUE_LOG_DEPTH-1:0]hit;
//    wire [`ISSUE_LOG_DEPTH_WIDTH-1:0]idx[`ISSUE_LOG_DEPTH-1:0];
//    wire [`FID_WIDTH-1:0] FID;
//    wire FID_v;
//    assign {FID_v, FID}=FID_bus;
//    genvar j;
//    generate 
//        for(j=0;j<`ISSUE_LOG_DEPTH;j=j+1) begin
//            assign fifo_mem[j]=fifo_mem_st[`FID_WIDTH*(j+1)-1:`FID_WIDTH*j];
//            assign hit[j]=(fifo_mem[j]==FID)&v[j];
//            assign idx[j]=idx_st[`ISSUE_LOG_DEPTH_WIDTH*(j+1)-1:`ISSUE_LOG_DEPTH_WIDTH*j];
//        end
//    endgenerate
////    function OR;
////        input wire [`ISSUE_LOG_DEPTH-1:0] value;
////        integer k;
////        begin
////            OR=0;
////            for(k=0;k<`ISSUE_LOG_DEPTH;k=k+1) begin
////                OR=OR|value[k];
////            end
////            OR=OR;
////        end
////    endfunction
//    integer k;
//    always @(*) begin
//        idx_o=`ISSUE_LOG_DEPTH-1;
//        if (FID_v) begin
//            for(k=0;k<`ISSUE_LOG_DEPTH;k=k+1) begin
//                if(hit[k]) idx_o=idx[k];
//            end
//        end
//        else idx_o=`ISSUE_LOG_DEPTH-1;
//    end
//endmodule

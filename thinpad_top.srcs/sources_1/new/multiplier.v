`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/15 20:07:27
// Design Name: 
// Module Name: multiplier
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


module multiplier(
    input wire clk, reset,valid,
    input wire [31:0] A,B,
    output wire [31:0] LO,
    output wire [31:0] HI,
    output reg done
    );
    wire signed [15:0] a1,a0,b1,b0;// a1,b1:high 16;a0,b0:low 16 
    reg [31:0] ll,lh,hl,hh;
    assign a1=A[31:16];
    assign a0=A[15:0];
    assign b1=B[31:16];
    assign b0=B[15:0];
    assign LO=ll+{lh[15:0],16'b0}+{hl[15:0], 16'b0};
    assign HI={16'b0,lh[31:16]}+{16'b0,hl[31:16]}+hh;
    always @(posedge clk, posedge reset) begin
        if (reset|!valid) begin
            ll<=0;
            lh<=0;
            hl<=0;
            hh<=0;
            done<=0;
        end
        else if (done) done<=0;
        else if (valid) begin
            ll<=$unsigned(a0)*$unsigned(b0);
            lh<=$unsigned(a0)*$unsigned(b1);
            hl<=$unsigned(a1)*$unsigned(b0);
            hh<=$unsigned(a1)*$unsigned(b1);
            done<=1;
        end
    end
    
    
endmodule

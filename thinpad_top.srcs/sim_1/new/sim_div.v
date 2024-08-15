`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 22:05:38
// Design Name: 
// Module Name: sim_div
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


module sim_div(

    );
    reg clk;
    always #10 clk<=~clk;
    reg reset;
    reg [31:0] A,B;
    wire A_ready, B_ready;
    reg [31:0] q,r;
    wire [31:0] q_curr, r_curr;
    wire done;
    reg valid;
    reg en;
    unsigned_div_gen your_instance_name (
      .aclk(clk),                                      // input wire aclk
      .aclken(en),                                  // input wire aclken
      .aresetn(~reset),                                // input wire aresetn //低位有效
      .s_axis_divisor_tvalid(valid),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tready(B_ready),    // output wire s_axis_divisor_tready 除数
      .s_axis_divisor_tdata(B),      // input wire [31 : 0] s_axis_divisor_tdata 被除数
      .s_axis_dividend_tvalid(valid),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tready(A_ready),  // output wire s_axis_dividend_tready
      .s_axis_dividend_tdata(A),    // input wire [31 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(done),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata({q_curr,r_curr})            // output wire [63 : 0] m_axis_dout_tdata
    );
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            q<=0;
            r<=0;
        end
        else if(done) begin
            q<=q_curr;
            r<=r_curr;
        end
    end
    initial begin
        clk=0;
        reset=1;
        A=121;
        B=10;
        valid=0;
        en=1;
        #15
        reset=0;
        #55
        valid=1;
        #80
        valid=0;
//        #20;
//        #815;
        valid=0;
//        #100
//        A=137;
//        B=2;
//        #100
//        A=140;
    end
endmodule

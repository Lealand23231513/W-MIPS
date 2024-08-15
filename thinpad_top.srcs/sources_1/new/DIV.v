`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 22:54:24
// Design Name: 
// Module Name: DIV
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


module DIV(
    input wire clk, reset,en, new_one,
    input wire[31:0] A, //dividend
    input wire[31:0] B, //divisor
    output wire[31:0] R,
    output reg stall
    );
    reg [1:0] state; //0: free 1: wait for ready 2: wait for done
    reg[31:0] R_reg;
    wire [63:0] div_out;
    wire [31:0] R_curr;
    wire done, ready, A_ready, B_ready;
    wire activate;
    reg valid_i;
    reg R_src; 
    assign R_curr=div_out[31:0];
//    assign R_src=state;
    assign ready=A_ready&B_ready;
    assign activate=en&new_one;
    assign R=R_src?R_curr:R_reg;
    unsigned_div_gen divider (
      .aclk(clk),                                      // input wire aclk
      .aclken(en),                                  // input wire aclken
      .aresetn(~reset),                                // input wire aresetn //低位有效
      .s_axis_divisor_tvalid(valid_i),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tready(A_ready),    // output wire s_axis_divisor_tready 除数
      .s_axis_divisor_tdata(B),      // input wire [31 : 0] s_axis_divisor_tdata 被除数
      .s_axis_dividend_tvalid(valid_i),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tready(B_ready),  // output wire s_axis_dividend_tready
      .s_axis_dividend_tdata(A),    // input wire [31 : 0] s_axis_dividend_tdata
      .m_axis_dout_tvalid(done),          // output wire m_axis_dout_tvalid
      .m_axis_dout_tdata(div_out)            // output wire [63 : 0] m_axis_dout_tdata
    );
    always @(*) begin
        case (state) 
            0: begin
                stall=activate;
                R_src=0;
//                valid_i=activate;
            end
            1: begin
                stall=1;
                R_src=0;
//                valid_i=!ready;
            end
            2: begin
                stall=en&!done;
                R_src=1;
//                valid_i=0;
            end
            default: begin
                stall=0;
                R_src=0;
//                valid_i=0;
            end
        endcase
    end
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state<=0;
            R_reg<=0;
            valid_i<=0;
        end
        else begin
            case (state)
                0: begin
                    if(activate) begin
                        state<=1;
                        valid_i<=1;
                    end
                end
                1: begin
                    if(ready) begin
                        state<=2;
                    end
                end
                2: begin
                    valid_i<=0;
                    if(done) begin
                        state<=0;
                        R_reg<=R_curr;
                    end
                end
            endcase
        end
    end
    
    
endmodule

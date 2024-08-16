`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/16 19:42:27
// Design Name: 
// Module Name: sqrter
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


module sqrter(
    input wire clk, reset,
    input wire [31:0] A,
    output reg[31:0] R,
    input wire valid,
    output reg stall 
    );
    reg state, done;
    reg [2:0] mult_state;
    reg [31:0] up_t, low_t;
    wire [63:0] P;
    wire [31:0] mid_t, P_lo;
    wire [31:0]A_sqrt_up;
    parameter INI_UP=32'h00010000;
    parameter INI_LOW=32'h0;
    parameter INI_MID=(INI_UP+INI_LOW)>>1;
    parameter MAX_MULT_CYCLE=2;
    assign A_sqrt_up=(A>>1)+2;
    assign mid_t=(up_t+low_t)>>1;
    assign P_lo=P[31:0];
    always @(*) begin
        case (state)
            0: begin
                stall=valid;
            end
            1: begin
                stall=!done;
            end
        endcase
    end
    mult_gen_0 mult_gen_pipe (
      .CLK(clk),  // input wire CLK
      .A(mid_t),      // input wire [31 : 0] A
      .B(mid_t),      // input wire [31 : 0] B
      .P(P)      // output wire [63 : 0] P
    );
    always @(posedge clk, posedge reset) begin
        if(reset)begin
            state<=0;
            up_t<=INI_UP;
            low_t<=INI_LOW;
//            mid_t_d<=INI_MID;
            done<=0;
            mult_state<=0;
            R<=0;
        end 
        else begin
//            mid_t_d<=mid_t;
            case (state)
                0: begin
                    done<=0;
                    if(valid) begin
                        state<=1;
                        low_t<=INI_LOW;
                        up_t<=A_sqrt_up>INI_UP?INI_UP:A_sqrt_up;
                        mult_state<=0;
                    end
                end
                1: begin
                    if(low_t+1==up_t) begin
                        done<=1;
                        R<=low_t;
                        state<=0;
                    end
                    if(mult_state==MAX_MULT_CYCLE) begin
                        if(P_lo>A) begin
                            up_t<=mid_t;
                        end
                        else begin
                            low_t<=mid_t;
                        end
                        mult_state<=0;
                    end
                    else begin
                        mult_state<=mult_state+1;
                    end
                end
            endcase
        end
    end
endmodule

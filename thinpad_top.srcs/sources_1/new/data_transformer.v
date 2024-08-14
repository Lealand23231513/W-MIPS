`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/06 20:46:26
// Design Name: 
// Module Name: data_transformer
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


module data_transformer(
    input wire [31:0] data_w_ori,
    input wire [31:0] data_r_ori,
    input wire [1:0] pad,
    input wire LB_SB,
    output reg [3:0] be, 
    output reg [31:0]data_w,
    output reg [31:0]data_r
    );
    wire [7:0] databyte=data_w_ori;
    reg [7:0] membyte;
    always @(*) begin
        if (LB_SB) begin
            case (pad)
                2'b00: begin
                    be=4'b1110;
                    data_w={24'd0,databyte};
                    membyte=data_r_ori[7:0];
                end
                2'b01: begin
                    be=4'b1101;
                    data_w={16'd0,databyte,8'd0};
                    membyte=data_r_ori[15:8];
                end
                2'b10: begin
                    be=4'b1011;
                    data_w={8'd0,databyte,16'd0};
                    membyte=data_r_ori[23:16];
                end
                2'b11: begin
                    be=4'b0111;
                    data_w={databyte,24'd0};
                    membyte=data_r_ori[31:24];
                end
            endcase
            data_r={{24{membyte[7]}}, membyte};
        end
        else begin
            be=4'b0000;
            data_w=data_w_ori;
            data_r=data_r_ori;
        end
    end
endmodule

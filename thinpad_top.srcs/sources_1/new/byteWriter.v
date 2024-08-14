`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/06 20:36:41
// Design Name: 
// Module Name: byteWriter
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


module byteWriter(
    input wire [31:0] word,
    input wire [1:0] pad,
    output reg [31:0] byte_word
    );
    always @(*) begin
        case (pad)
            2'b00: begin
                DMbe=4'b1110;
                data2mem={24'd0,databyte};
                membyte=data_resp[7:0];
            end
            2'b01: begin
                DMbe=4'b1101;
                data2mem={16'd0,databyte,8'd0};
                membyte=data_resp[15:8];
            end
            2'b10: begin
                DMbe=4'b1011;
                data2mem={8'd0,databyte,16'd0};
                membyte=data_resp[23:16];
            end
            2'b11: begin
                DMbe=4'b0111;
                data2mem={databyte,24'd0};
                membyte=data_resp[31:24];
            end
        endcase


    end
endmodule

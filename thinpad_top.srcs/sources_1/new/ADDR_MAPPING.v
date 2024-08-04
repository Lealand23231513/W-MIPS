`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 16:13:01
// Design Name: 
// Module Name: ADDR_MAPPING
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


module ADDR_MAPPING(
    input wire [31:0]vaddr,
    output reg [19:0]paddr,
    output reg [1:0] offset,
    output reg ISSA ,
    output reg ISEXT,
    output reg ISBase
    );
    always @(*) begin
        case(vaddr)
            32'hBFD003F8:begin
                paddr=19'd0;
                offset=2'd0;
                ISSA=1'b1;
                ISEXT=1'd0;
                ISBase=1'd0;
            end
            32'hBFD003FC:begin
                paddr=19'd1;
                offset=2'd0;
                ISSA=1'b1;
                ISEXT=1'd0;
                ISBase=1'd0;
            end
            default: begin
                ISSA=1'b0;
                if (vaddr>=32'h80000000&&vaddr<32'h80400000) begin
                    {paddr, offset}=vaddr-32'h80000000;
                    ISEXT=1'd0;
                    ISBase=1'd1;
                end
                else if (vaddr>=32'h80400000&& vaddr<32'h80800000) begin
                    {paddr, offset}=vaddr-32'h80400000;
                    ISEXT=1'd1;
                    ISBase=1'd0;
                end
                else begin
                    {paddr, offset}=32'h00000000;
                    ISEXT=1'd0;
                    ISBase=1'd0;
                end
            end
        endcase
    end
    
endmodule
module ADDR_MAPPING_v2(
    input wire [31:0]vaddr,
    output reg [19:0]paddr_wd,
    output reg [1:0] pad,
    output reg [1:0] dst//0:invalid 1: base 2: ext 3: spc
    );
    always @(*) begin
        case(vaddr)
            32'hBFD003F8:begin
                paddr_wd=19'd0;
                pad=2'd0;
                dst=3;
            end
            32'hBFD003FC:begin
                paddr_wd=19'd1;
                pad=2'd0;
                dst=3;
            end
            default: begin
                if (vaddr>=32'h80000000&&vaddr<32'h80400000) begin
                    {paddr_wd, pad}=vaddr-32'h80000000;
                    dst=1;
                end
                else if (vaddr>=32'h80400000&& vaddr<32'h80800000) begin
                    {paddr_wd, pad}=vaddr-32'h80400000;
                    dst=2;
                end
                else begin
                    {paddr_wd, pad}=32'h00000000;
                    dst=0;
                end
            end
        endcase
    end
    
endmodule
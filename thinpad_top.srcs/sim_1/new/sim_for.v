`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 19:44:43
// Design Name: 
// Module Name: sim_for
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


module sim_for(

    );
    parameter LINE_SIZE=16;
    parameter INDEX_WIDTH=2;
    reg [3:0] tag;
    reg [3:0] line_tag [LINE_SIZE-1:0];
    reg line_v [LINE_SIZE-1:0];
    wire line_hit [LINE_SIZE-1:0];
    reg hit;
    reg clk;
    always #10 clk<=~clk;
    integer i;
    genvar j;
    generate
        for(j=0;j<LINE_SIZE;j=j+1) begin
            assign line_hit[j]=(line_tag[j]==tag)&line_v[j]&(j[INDEX_WIDTH-1:0]);
        end
    endgenerate
    always @(*) begin
        hit=0;
        for(i=0;i<LINE_SIZE;i=i+1) begin
            if(line_hit[i]) begin
                hit=1;
            end
        end
    end
    reg wea;
    reg [5:0] addra;
    reg [31:0] dina;
    wire [31:0] douta;
    blk_mem_gen_0 your_instance_name (
      .clka(clk),    // input wire clka
      .ena(1),      // input wire ena
      .wea(wea),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [5 : 0] addra
      .dina(dina),    // input wire [31 : 0] dina
      .douta(douta)  // output wire [31 : 0] douta
    );
    initial begin
        clk=0;
        tag=3'd1;
        for(i=0;i<LINE_SIZE;i=i+1) begin
            line_tag[i]=i%4;
            line_v[i]=1;
        end
        #20
        tag=3'd4;
        #20 
        wea=1;
        addra=1;
        dina=10;
        #20
        wea=0;
        dina=0;
    end
endmodule

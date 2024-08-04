`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/26 20:32:13
// Design Name: 
// Module Name: sim_bram
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


module sim_bram(

    );
    reg clk=0;
    reg ena=0, wea=0;
    reg [7:0] addra=0;
    reg [31:0] dina=0;
    wire [31:0] douta;
    always #10 clk<=~clk;
    blk_mem_gen_0 your_instance_name (
      .clka(clk),    // input wire clka
      .ena(ena),      // input wire ena
      .wea(wea),      // input wire [0 : 0] wea
      .addra(addra),  // input wire [7 : 0] addra
      .dina(dina),    // input wire [31 : 0] dina
      .douta(douta)  // output wire [31 : 0] douta
    );
    always @(posedge clk) begin
        dina<=dina+1;
    end
    initial begin
    addra=0;
    ena=1;
    wea=1;
    #100
    wea=0;
    #100
    ena=0;
    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/03 17:30:42
// Design Name: 
// Module Name: sim_test_signed
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


module sim_test_signed(

    );
    reg  [7:0] a;
    reg  [7:0] b;
    wire [7:0] r1;
    wire [8:0] r2;
    reg [7:0] r3;
    reg [7:0] r4;
    test_signed t(
        .a(a),
        .b(b),
        .r1(r1),
        .r2(r2)
    );
    reg clk;
    reg x;
    always #10 clk<=~clk; 
    always @(posedge clk, negedge clk) begin
        x<=~x;
        a<=x;
//        else a<=0;
    end
    initial begin
       clk=0;
       x=0;
//        a=-8'd1;
//        b=8'd2;
//        #10
//        a=-8'd3;
//        #10
//        a=-8'd1;
//        b=-8'd1;
//        #10
//        a=8'd127;
//        b=8'd127;
//        a=-8'd127;
//        b=-8'd127;
//        r3=a*b;
//        #10
//        r3=$signed(8)*$signed(-8); 
//        #10
//        r3=8'd8*$unsigned(-8'd8);
//        r4=4'd5*-4'd3;
//        $display("%b",r4);
//        r4=$unsigned(4'd5)*$unsigned(-4'd3);
//        $display("%b", r4);
//        r4=$signed(4'd15)*$signed(4'd3);
//        $display("%d",$signed(4'd15));
//        $display("%d %b", $signed(r4),r4);
//        r4=$signed(r4)>>>$signed(4'd3);
//        r4=(3<4);
//        $display("%b", r4);
//        $display("%b", ($signed(-1)>$signed(0)));
//        r4=0;
//        r4[1]=1;
//        $display("%b", r4);
//        r4=(1&0||1);
//        $display("%b", r4);
    end
endmodule

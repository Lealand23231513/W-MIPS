`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/06 21:47:57
// Design Name: 
// Module Name: transceiver
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


module transceiver(
    input wire clk, reset,
    output reg stall,
    input wire oe, we, new_one,
    input wire [3:0] be,
    input wire [19:0] paddr_wd,
    input wire [31:0] data_w,
    output wire [31:0] data_r_ori,
    // MEM BUS
    output wire [`MEM_SEND_BUS_WIDTH-1:0] send_bus,
    input wire [`MEM_RECV_BUS_WIDTH-1:0] recv_bus
    );
    reg [1:0]state;//0:free or send 1:waiting for recv 2: waiting for end
    reg r_src;// 0: curr 1: buffer
    reg start_req;
    wire end_resp, recv_resp;
    wire [31:0] data_r_ori_curr;
    reg [31:0] data_r_ori_buf;
    wire activate;
    assign activate=(oe|we)&new_one;
    assign send_bus={start_req, paddr_wd, data_w, we, be};
    assign {recv_resp, end_resp, data_r_ori_curr}=recv_bus;
    assign data_r_ori=r_src?data_r_ori_buf:data_r_ori_curr;
    always @(*) begin
        case(state) 
            0: begin
                start_req=activate;
                stall=activate;
            end
            1: begin
                start_req=oe|we&!recv_resp;
                stall=oe|we&!recv_resp;
            end
            2: begin
                start_req=oe&!end_resp;
                stall=oe&!end_resp;
            end
            default: begin
                start_req=0;
                stall=0;
            end
        endcase
    end
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state<=0;
            r_src<=0;
            data_r_ori_buf<=0;
        end
        else begin
            case (state)
                0: begin
                    if (activate) state<=1;
                end
                1: begin
                    if(we&recv_resp) begin
                        state<=0;
                    end
                    else if(oe&recv_resp) begin
                        state<=2;
                        r_src<=0;
                    end
                end
                2: begin
                    if (oe&end_resp) begin
                        state<=0;
                        data_r_ori_buf<=data_r_ori_curr;
                        r_src<=1;
                    end
                end
            endcase
        end
    end
endmodule

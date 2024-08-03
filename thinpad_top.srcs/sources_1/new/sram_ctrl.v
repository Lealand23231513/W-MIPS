`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/19 20:15:04
// Design Name: 
// Module Name: sram_ctrl
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

`include "global_def.vh"
`define FREE_STATE 0
`define FIRST_STATE 1
`ifdef MEMVIS_5
    `define MIDDLE_STATE 1,2,3,4
    `define PENULT_STATE 4
    `define LAST_STATE 5
`elsif MEMVIS_4
    `define MIDDLE_STATE 1,2,3
    `define PENULT_STATE 3
    `define LAST_STATE 4
`else
    `define MIDDLE_STATE 1,2
    `define PENULT_STATE 2
    `define LAST_STATE 3
`endif

module sram_ctrl(
    input wire clk,reset,
    //sram
    input wire[31:0] data_r,
    output reg [31:0] data_w,
    output reg [19:0]addr,
    output reg [3:0]be,
    output reg ce,
    output reg oe,
    output reg we,
    output wire IO_ctrl,
    //DM
    input wire DM_start_req,
    input wire [1:0] DM_dst_req,
    input wire [19:0]DM_paddr_wd_req,
    input wire [31:0]DM_data_req,
    input wire DM_write_req,
    input wire [3:0] DM_be_req,
    output wire [31:0]DM_data_resp,
    output reg DM_hold_resp,
    output reg DM_end_resp,
    //icache
    input wire IC_send_req,
    input wire [1:0] IC_dst_req,
    input wire [`OFFSET_WIDTH-`PAD_WIDTH:0]IC_word_size_req,
    input wire [19:0] IC_start_paddr_wd_req,
    output reg IC_ready_resp,
    output wire [32*`BLOCK_SIZE-1:0] IC_data_bus_resp,
    //busy
    output reg busy,
    output reg will_busy
    );
    parameter [1:0] ram_id=0; //0:invalid 1: base 2: ext 3: spc
    reg [31:0] data_bus_resp_reg[`BLOCK_SIZE-1:0];
    `ifdef MEMVIS_5
    reg [2:0] ram_state;// 0: Free, 1,2,3,4,5: mem access
    `elsif MEMVIS_4  
    reg [2:0] ram_state;// 0: Free, 1,2,3,4: mem access
    `else
    reg [1:0]ram_state;// 0: Free, 1,2,3: mem access
    `endif
    reg [4:0] num_finished; // 注意，位宽要和word_size_req的最大值
    reg [1:0]ram_src; //0,3:invalid, 1:from icache, 2: from DM
    integer i;
    genvar j;
    assign IO_ctrl=we;
    assign DM_data_resp=data_r;
    generate
        for (j=0;j<`BLOCK_SIZE;j=j+1) begin
            assign IC_data_bus_resp[32*(j+1)-1:32*j]=data_bus_resp_reg[j];
        end
    endgenerate
    always @(*) begin
        busy=(ram_state!=0);
    end
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            data_w<=0;
            addr<=0;
            be<=4'b0000;
            ce<=1;
            oe<=1;
            we<=1;
            DM_end_resp<=0;
            IC_ready_resp<=0;
            ram_state<=0;
            ram_src<=0;
            num_finished<=0;
            will_busy<=0;
            DM_hold_resp<=0;
            for (i=0;i<`BLOCK_SIZE;i=i+1) begin
                data_bus_resp_reg[i]<=0;
            end
        end
        else begin
            case (ram_state)
                `FREE_STATE: begin
                    if (DM_start_req&ram_id==DM_dst_req) begin
                        ram_state<=ram_state+1;
                        ram_src<=2;
                        ce<=0;
                        oe<=DM_write_req;
                        we<=!DM_write_req;
                        be<=DM_be_req;
                        addr<=DM_paddr_wd_req;
                        data_w<=DM_write_req?DM_data_req:32'dz;
                        DM_end_resp<=DM_write_req;
                        will_busy<=1;
                        DM_hold_resp<=!DM_write_req;
                    end
                    else if(IC_send_req&ram_id==IC_dst_req) begin
                        ram_state<=ram_state+1;
                        ram_src<=1;
                        ce<=0;
                        oe<=0;
                        we<=1;
                        be<=0;
                        addr<=IC_start_paddr_wd_req;
                        data_w<=32'dz;
                        num_finished<=1;
                        will_busy<=1;
                    end
                end
                `MIDDLE_STATE: begin
                    ram_state<=ram_state+1;
                    if (ram_src==1) begin
                        IC_ready_resp<=0;
                        if (DM_start_req&ram_id==DM_dst_req) begin
                            DM_hold_resp<=1;
                        end
                    end
                    else if (ram_src==2) begin
                        if (DM_start_req&ram_id==DM_dst_req) begin 
                            if (ram_state==`PENULT_STATE&!oe) DM_hold_resp<=0;//this read req will end
                            else DM_hold_resp<=1;//hold req
                        end
                        if (ram_state==`FIRST_STATE&!we) begin//write
                            DM_end_resp<=0;
                        end
                        else if (ram_state==`PENULT_STATE&!oe) begin
                            DM_end_resp<=1;
                        end
                        if (ram_state==`PENULT_STATE) will_busy<=0;
                    end
                end
                `LAST_STATE: begin
                    if (ram_src==1) begin //IC
                        if (num_finished<IC_word_size_req) begin
                            data_bus_resp_reg[num_finished-1]<=data_r;
                            IC_ready_resp<=1;
                            addr<=addr+1;
                            num_finished<=num_finished+1;
                            ram_state<=`FIRST_STATE;
                        end
                        else if (IC_send_req&!IC_ready_resp) begin
                            data_bus_resp_reg[num_finished-1]<=data_r;
                            IC_ready_resp<=1;
                            ce<=1;
                            oe<=1;
                        end
                        else if (IC_send_req&IC_ready_resp) begin
                            IC_ready_resp<=0;
                            ram_state<=`FREE_STATE;
                            ram_src<=0;
                            will_busy<=0;
                        end 
                    end
                    else if (ram_src==2) begin //DM
                        if (DM_start_req&ram_id==DM_dst_req) begin
                            ram_state<=`FIRST_STATE;
                            ram_src<=2;
                            ce<=0;
                            oe<=DM_write_req;
                            we<=!DM_write_req;
                            be<=DM_be_req;
                            addr<=DM_paddr_wd_req;
                            data_w<=DM_write_req?DM_data_req:32'dz;
                            DM_end_resp<=DM_write_req;
                            will_busy<=1;
                            DM_hold_resp<=!DM_write_req;
                        end
                        else begin
                            ce<=1;
                            oe<=1;
                            we<=1;
                            ram_state<=`FREE_STATE;
                            DM_end_resp<=0;
                        end
                    end
                end
            endcase
        end
    end
endmodule

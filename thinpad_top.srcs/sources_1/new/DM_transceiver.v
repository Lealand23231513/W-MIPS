`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/19 16:29:15
// Design Name: 
// Module Name: DM_transceiver
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


module DM_transceiver(
    input wire clk,reset,
    input wire stage,//0 clk_core=1, 1 clk_core=0
    output reg stall,
    //cpu
    input wire [31:0] vaddr,
    input wire oe,
    input wire we,
    input wire LB_SB,
    input wire [31:0]mem_data_in,
    output wire [31:0]mem_data_out,
    //ram
    output reg start_req,
    output reg [19:0]paddr_wd_req,
    output reg [1:0]dst_req,
    output reg [31:0]data_req,
    output reg write_req,
    output reg [3:0] be_req,
    input wire [31:0]data_resp,
    input wire end_resp,
    input wire [3:0] will_busy
    );
    (*ASYNC_REG="true"*)reg end_resp_d, end_resp_dd;
    wire end_resp_d_rise;
    wire end_resp_rise;
    reg end_resp_d_rise_d;
    wire [7:0] databyte;
    wire [1:0] pad;
    reg [31:0] data2mem;
    reg [3:0] DMbe;
    reg mem_data_out_src;//逻辑没写
    reg [31:0] data_resp_curr;
    reg [31:0] data_resp_buffer;//buffer 如果后级流水线暂停导致无法读入，则从buffer读
    reg [7:0] membyte;
    wire [19:0] paddr_wd;
    wire [1:0] dst;
    assign databyte=mem_data_in[7:0];
    assign pad=vaddr[1:0];
    assign end_resp_d_rise=end_resp_d&~end_resp_dd;
    assign end_resp_rise=end_resp&~end_resp_d;
    assign mem_data_out=mem_data_out_src?data_resp_buffer:data_resp_curr;
    ADDR_MAPPING_v2 DM_addr_mapping(
        .vaddr(vaddr),
        .paddr_wd(paddr_wd),
        .dst(dst)//0:invalid 1: base 2: ext 3: spc
    );
    always @(*) begin
        if (LB_SB) begin
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
            data_resp_curr={{24{membyte[7]}}, membyte};
        end
        else begin
            DMbe=4'b0000;
            data2mem=mem_data_in;
            data_resp_curr=data_resp;
        end
    end
    always @(*) begin
        if(oe|we) begin
            if (stage) begin
                stall=!end_resp_rise&!end_resp_d_rise;
            end 
            else begin
                stall=1;
            end
        end
        else begin
            stall=0;
        end
    end
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            start_req<=0;
            paddr_wd_req<=0;
            data_req<=0;
            write_req<=0;
            be_req<=0;
            end_resp_d<=0;
            end_resp_dd<=0;
            mem_data_out_src<=0;//没写变化时序逻辑
            data_resp_buffer<=0;
            end_resp_d_rise_d<=0;
            dst_req<=0;
        end
        else if (oe|we) begin
            if(!start_req&!will_busy[dst]&!stage) begin
                start_req<=1;
                mem_data_out_src<=0;
                paddr_wd_req<=paddr_wd;
                dst_req<=dst;
                write_req<=we;
                be_req<=DMbe;
                if(we) begin//write memory
                    data_req<=data2mem;
                end
            end
            else if (start_req&end_resp) begin
                start_req<=0;
                dst_req<=0;
                if (oe) begin//read memory
                    data_resp_buffer<=data_resp_curr;
                    if (!stage) begin
                        mem_data_out_src<=1;
                    end
                end
            end
        end
        end_resp_d<=end_resp;
        end_resp_dd<=end_resp_d;
        end_resp_d_rise_d<=end_resp_d_rise;
    end
endmodule

module DM_transceiver_v2(
    input wire clk,reset,
    input wire stage,//0 clk_core=1, 1 clk_core=0
    output reg stall,
    //cpu
    input wire [31:0] MEM_PC,
    input wire [31:0] vaddr,
    input wire oe,
    input wire we,
    input wire LB_SB,
    input wire [31:0]mem_data_in,
    output wire [31:0]mem_data_out,
    //ram
    output wire start_req,
    output wire [19:0]paddr_wd_req,
    output wire [1:0]dst_req,
    output wire [31:0]data_req,
    output wire write_req,
    output wire [3:0] be_req,
    input wire hold_resp,
    input wire [31:0]data_resp,
    input wire end_resp,
    input wire [3:0] will_busy
    );
    (*ASYNC_REG="true"*)reg end_resp_d, end_resp_dd;
    reg [31:0] MEM_PC_d;
    wire end_resp_d_rise;
    wire end_resp_rise;
    reg end_resp_d_rise_d;
    wire [7:0] databyte;
    wire [1:0] pad;
    reg [31:0] data2mem;
    reg [3:0] DMbe;
    reg mem_data_out_src;//逻辑没写
    reg [31:0] data_resp_curr;
    reg [31:0] data_resp_buffer;//buffer 如果后级流水线暂停导致无法读入，则从buffer读
    reg [7:0] membyte;
    wire [19:0] paddr_wd;
    wire [1:0] dst;
    function  equal_judge;
        input [31:0]A;
        input [31:0]B;
        reg [31:0] t;  
        integer k;
        begin
            t=~(A^B);
            equal_judge=1;
            for(k=0;k<32;k=k+1) begin
                equal_judge=t[k]&equal_judge;
            end    
        end
    endfunction
    assign databyte=mem_data_in[7:0];
    assign pad=vaddr[1:0];
    assign end_resp_d_rise=end_resp_d&~end_resp_dd;
    assign end_resp_rise=end_resp&~end_resp_d;
    assign mem_data_out=mem_data_out_src?data_resp_buffer:data_resp_curr;
    assign paddr_wd_req=paddr_wd;
    assign dst_req=(oe|we)?dst:0;
    assign data_req=data2mem;
    assign write_req=we;
    assign be_req=DMbe;
    assign start_req=hold_resp|MEM_PC!=MEM_PC_d&(oe|we);
    ADDR_MAPPING_v2 DM_addr_mapping(
        .vaddr(vaddr),
        .paddr_wd(paddr_wd),
        .dst(dst)//0:invalid 1: base 2: ext 3: spc
    );
    always @(*) begin
        if (LB_SB) begin
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
            data_resp_curr={{24{membyte[7]}}, membyte};
        end
        else begin
            DMbe=4'b0000;
            data2mem=mem_data_in;
            data_resp_curr=data_resp;
        end
    end
    always @(*) begin
        stall=start_req;
    end
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            end_resp_d<=0;
            end_resp_dd<=0;
            mem_data_out_src<=0;//没写变化时序逻辑
            data_resp_buffer<=0;
            MEM_PC_d<=0;
        end
        else if (oe|we) begin
            if (end_resp) begin
                if (oe) begin//read memory
                    data_resp_buffer<=data_resp_curr;
                    mem_data_out_src<=1;
                end
            end
            else if (start_req) begin
                mem_data_out_src<=0;
            end
        end
        MEM_PC_d<=MEM_PC;
    end
endmodule
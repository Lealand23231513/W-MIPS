`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/16 17:25:11
// Design Name: 
// Module Name: cache
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
module icache(
    input wire clk,
    input wire PF2IF_en,
    input wire icache_en,
    input wire flush,
    input wire reset,
    output reg stall,
    //cpu
    input wire [31:0] PF_PC,
    input wire PF_PredictBranch,
    input wire [31:0] PF_PredictBranchAddr,
    output wire [31:0] IF_PC,
    output wire [31:0]IF_IR,
    output wire IF_PredictBranch,
    output wire [31:0] IF_PredictBranchAddr,
    //ram
    (*mark_debug = "true"*)output reg send_req,
    (*mark_debug = "true"*)output reg [`OFFSET_WIDTH-`PAD_WIDTH:0]word_size_req,
    (*mark_debug = "true"*)output reg [19:0] start_paddr_wd_req,
    (*mark_debug = "true"*)output reg [1:0] dst_req,
    (*mark_debug = "true"*)input wire ready_resp,
    (*mark_debug = "true"*)input wire [31:0] data_bus_resp,
    //LSU
    input wire[32:0] dirty_bus
    );
    parameter WORK_STATE=0;
    parameter TRANSPORT_STATE=1;
    //cache state
    reg state;
    reg done_d;
    reg [31:0]IR_lst_d;
    // receive
    reg ready_resp_d;
//    wire [31:0] data_resp [`BLOCK_SIZE-1:0];
    wire [31:0] data_resp;
    wire flush_IR;
    //cache line
    wire [`SET_SIZE-1:0] IF_way_hit;
    wire [31:0] IF_way_data[`SET_SIZE-1:0];
    wire hit;
    wire hit_rise;
    wire hit_fall;
    wire way_to_change_nxt;
    reg way_hit_d[`SET_SIZE-1:0];
    reg [31:0] resp_vaddr_buffer;
    reg way_to_change; 
    reg [31:0] way_din[`SET_SIZE-1:0];
    reg way_en [`SET_SIZE-1:0];
    reg way_is_write [`SET_SIZE-1:0];
    reg way_write_start [`SET_SIZE-1:0];
    reg way_write_end [`SET_SIZE-1:0];
    reg [4:0] num_write;
    reg IF_IR_src;
    reg [31:0] IF_IR_buffer;
    wire [31:0] start_vaddr_req;
    wire [19:0] IC_start_paddr_wd;
    wire [1:0] IC_dst;
    wire flush_IF;
    wire [31:0] vaddr;
    reg vaddr_src;
    wire [31:0] IF_PC_ori, IF_IR_ori;
    wire miss;
    reg [`WAY_SIZE-1:0] f_line_lru;
    wire [`TAG_WIDTH-1:0] tag_d;
    wire [`INDEX_WIDTH-1:0] index_d;
    wire [`OFFSET_WIDTH-1:0] offset_d;
    wire [31:0] dir_vaddr;
    wire dirty;
    reg [31:0] vaddr_d;
//    reg first;
    reg recover;
    integer i;
    genvar j;
    generate
        for(j=0;j<`SET_SIZE;j=j+1) begin
            cache_way cache_way(
                .clk(clk),
                .reset(reset),
                .vaddr(vaddr),
                .vaddr_w(resp_vaddr_buffer),
                .en(way_en[j]),
                .is_write(way_is_write[j]),
                .hit(IF_way_hit[j]),
                .dina(way_din[j]),
                .douta(IF_way_data[j]),
                .write_start(way_write_start[j]),
                .write_end(way_write_end[j]),
                .dir_vaddr(dir_vaddr),
                .dirty(dirty)
            );
        end
//        for (j=0;j<`BLOCK_SIZE;j=j+1) begin
//            assign data_resp[j]=data_bus_resp[(j+1)*32-1:j*32];
//        end
    endgenerate
    assign data_resp=data_bus_resp;
    assign {dirty, dir_vaddr}=dirty_bus;
    assign {tag_d, index_d, offset_d} = vaddr_d;
    assign hit=IF_way_hit[0]|IF_way_hit[1];
    assign miss=!hit&!flush_IF;
    assign way_to_change_nxt=f_line_lru[index_d];
    assign start_vaddr_req={vaddr[31:`OFFSET_WIDTH], {`OFFSET_WIDTH{1'b0}}};
    assign IF_IR_ori=IF_way_hit[0]?IF_way_data[0]:IF_way_hit[1]?IF_way_data[1]:32'dz;
    assign IF_IR=flush_IF?0:IF_IR_ori;
    assign IF_PC=flush_IF?0:IF_PC_ori;
    assign vaddr=miss?IF_PC_ori:PF_PC;
    ADDR_MAPPING_v2 IC_addr_mapping(
        .vaddr(start_vaddr_req),
        .paddr_wd(IC_start_paddr_wd),
        .dst(IC_dst)//0:invalid 1: base 2: ext 3: spc
    );
    // pipeline stage PF2IF
    PF2IF PF2IF(
        .clk(clk),
        .en(PF2IF_en),
        .reset(reset),
        .flush(flush),
        .PF_PC(PF_PC),
        .PredictBranch(PF_PredictBranch),
        .PredictBranchAddr(PF_PredictBranchAddr),
        .IF_PC_ori(IF_PC_ori),
        .PredictBranch_o(IF_PredictBranch),
        .PredictBranchAddr_o(IF_PredictBranchAddr),
        .flush_IF(flush_IF)
    );
    always @(*) begin
        word_size_req=`BLOCK_SIZE;
        if(reset) begin
            stall=0;
            for (i=0;i<`SET_SIZE;i=i+1) begin
                way_en[i]=0;
            end
        end
        else begin
            case (state)
                WORK_STATE: begin
                    stall=miss;
                    for(i=0;i<`SET_SIZE;i=i+1) begin
                        way_en[i]=miss|icache_en;
                    end
                end
                TRANSPORT_STATE: begin
                    stall=1;
                    for(i=0;i<`SET_SIZE;i=i+1) begin
                        way_en[i]=way_is_write[i];
                    end
                end
            endcase
        end
    end
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state<=WORK_STATE;
            way_to_change<=0;
            resp_vaddr_buffer<=0;
            send_req<=0;
            num_write<=0;
            dst_req<=0;
            start_paddr_wd_req<=0;
            recover<=0;
            vaddr_d<=0;
            for(i=0;i<`SET_SIZE;i=i+1) begin
                way_din[i]<=0;
                way_is_write[i]<=0;
                way_write_start[i]<=0;
                way_write_end[i]<=0;
            end
            for(i=0;i<`WAY_SIZE;i=i+1) begin
                f_line_lru[i]<=0;
            end
        end
        else begin
            vaddr_d<=vaddr;
            case(state)
                WORK_STATE: begin
                    if (recover) recover<=0;
                    else if (miss) begin//TRANSPORT_STATE
                        way_to_change<=way_to_change_nxt;
                        way_write_start[way_to_change_nxt]<=1;
                        for(i=0;i<`SET_SIZE;i=i+1)begin
                            way_is_write[i]<=0;
                        end
                        state<=TRANSPORT_STATE;
                        send_req<=1;
                        start_paddr_wd_req<=IC_start_paddr_wd;
                        dst_req<=IC_dst;
                        num_write<=0;
                    end
                    if(hit&!flush_IF) begin
                        f_line_lru[index_d]<=IF_way_hit[0];
                    end
                end
                TRANSPORT_STATE: begin
                    if (ready_resp&send_req) begin
                        way_write_start[way_to_change]<=0;
                        resp_vaddr_buffer<={start_vaddr_req[31:`OFFSET_WIDTH], num_write[`OFFSET_WIDTH-3:0], 2'b0};
                        way_din[way_to_change]<=data_resp;
                        way_is_write[way_to_change]<=1;
                        if (num_write<`BLOCK_SIZE-1) begin
                            num_write<=num_write+1;
                        end
                        else begin
                            way_write_end[way_to_change]<=1;
                            send_req<=0;
                        end
                    end
                    else if (!ready_resp & !send_req) begin
                        state<=WORK_STATE;
                        dst_req<=0;
                        recover<=1;
                        for(i=0;i<`SET_SIZE;i=i+1)begin
                            way_is_write[i]<=0;
                            way_write_start[i]<=0;
                            way_write_end[i]<=0;
                        end
                    end
                end
            endcase
        end
    end
    
    
endmodule

module cache_way(
    input wire clk,reset,
    output reg hit,
//    output reg [3:0] lru,
    //way bus protocol
    input wire [31:0] vaddr,
    input wire [31:0] vaddr_w,
    input wire [31:0] dina,
    input wire en,
    output wire [31:0] douta,
    input wire is_write,
    input wire write_start,
    input wire write_end,
    input wire dirty,
    input wire [31:0]dir_vaddr
);
    function  equal_judge;
        input [`TAG_WIDTH-1:0]A;
        input [`TAG_WIDTH-1:0]B;
        reg [`TAG_WIDTH-1:0] t;  
        integer k;
        begin
            t=~(A^B);
            equal_judge=1;
            for(k=0;k<`TAG_WIDTH;k=k+1) begin
                equal_judge=t[k]&equal_judge;
            end    
        end
    endfunction
    reg dirty_hit;
    reg [`TAG_WIDTH-1:0] line_tag [`WAY_SIZE-1:0];
    reg line_v [`WAY_SIZE-1:0];
    reg [`INDEX_WIDTH-1:0] dir_index_d;
    wire [`OFFSET_WIDTH-1:0] offset, offset_d, offset_w, dir_offset;
    wire [`INDEX_WIDTH-1:0] index, index_d, index_w, dir_index;
    wire [`TAG_WIDTH-1:0] tag, tag_d, line_tag_d, tag_w, dir_tag;
    wire [`INDEX_WIDTH+`OFFSET_WIDTH-3:0] caddr;
    wire [31:0] din_tag;
    wire [31:0] dout_tag;
    genvar j;
    assign {tag, index, offset} = vaddr;
    assign {tag_w, index_w, offset_w} = vaddr_w;
    assign din_tag={tag};
    assign {dir_tag, dir_index, dir_offset} = dir_vaddr;
    assign caddr=is_write?{index_w, offset_w[`OFFSET_WIDTH-1:2]}:{index, offset[`OFFSET_WIDTH-1:2]};//caddr_width=INDEX_WIDTH+OFFSET_WIDTH-PAD_WIDTH
    blk_mem_gen_0  cache_memory(
      .clka(clk),    
      .ena(en),      
      .wea(is_write),      
      .addra(caddr),  
      .dina(dina),    
      .douta(douta)  
    );
    integer i;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            dirty_hit<=0;
            dir_index_d<=0;
            for(i=0;i<`WAY_SIZE;i=i+1) begin
                line_tag[i]<=0;
                line_v[i]<=0;
            end
        end
        else begin
            if (write_start) begin
                line_v[index]<=0;
                if (dirty_hit&&dir_index_d!=index) begin
                    line_v[dir_index_d]<=0;
                end
            end
            else if (write_end) begin
                line_tag[index]<=tag;
                line_v[index]<=1;
                if (dirty_hit&&dir_index_d!=index) begin
                    line_v[dir_index_d]<=0;
                end
            end
            else if (dirty_hit) begin
                line_v[dir_index_d]<=0;
            end
            if (dirty) begin
                dirty_hit<=equal_judge(line_tag[dir_index], dir_tag)&line_v[dir_index];
                dir_index_d<=dir_index;
            end
            else begin
                dirty_hit<=0;
            end
        end
    end
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            hit<=1;
        end
        else begin
            if (en&!is_write) begin
                hit<=equal_judge(line_tag[index], tag)&line_v[index];
            end
        end
    end
endmodule

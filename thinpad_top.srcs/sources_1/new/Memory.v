`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 15:08:02
// Design Name: 
// Module Name: Memory
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


module Memory(
    input wire clk,
    input wire reset,
    output reg IM_DM_clash,
    output wire IM_DM_clash_nxt,
    output reg Read_IF_IR_buffer,
    input wire IF2ID_en,
    //IM
    input wire [31:0] IF_PC,
    input wire [31:0] IF_PC_next,
    output wire [31:0] IF_IR,
    //DM
    input wire [31:0] EX_DM_vaddr,
    input wire [31:0] MEM_DM_vaddr,
    input wire EX_DMoe,//高有效
    input wire EX_DMwe,//高有效
    input wire EX_LB_SB,
    input wire MEM_LB_SB,
    input wire [31:0] EX_mem_data_in,//输入DM的data
    output wire [31:0] MEM_mem_data_out,//从DM读出的data
    //base_ram
    input wire[31:0] base_ram_data_R,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output reg [31:0] base_ram_data_W,
    output reg[19:0] base_ram_addr, //BaseRAM地址
    output reg[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output reg base_ram_ce_n,       //BaseRAM片选，低有效
    output reg base_ram_oe_n,       //BaseRAM读使能，低有效
    output reg base_ram_we_n,       //BaseRAM写使能，低有效
    output wire base_ram_IO_ctrl,   //高电平读入，低电平写
    //ext_ram
    input wire [31:0] ext_ram_data_R,
    output reg [31:0] ext_ram_data_W,
    output reg [19:0] ext_ram_addr,
    output reg [3:0]ext_ram_be_n,
    output reg ext_ram_ce_n,
    output reg ext_ram_oe_n,
    output reg ext_ram_we_n,
    output wire ext_ram_IO_ctrl, 
    //SPC
    input wire [31:0] SPC_RD,
    output reg [31:0] SPC_WD,
    output reg SPC_WE,//高有效
    output reg SPC_RE,//高有效
    output reg [19:0] SPC_addr,
    
    //test
    output wire [15:0] leds
    );
    
    //IM
    wire [19:0] IM_paddr_next;
    wire [19:0] IM_paddr;
    ADDR_MAPPING addr_mapping_IM1(
        .vaddr(IF_PC),
        .paddr(IM_paddr) 
    );
    ADDR_MAPPING addr_mapping_IM2(
        .vaddr(IF_PC_next),
        .paddr(IM_paddr_next) 
    );

    wire [3:0]IMbe=4'd0;
    reg [31:0] IF_IR_buffer;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            Read_IF_IR_buffer<=0;
            IF_IR_buffer<=0;
        end
        else if (IM_DM_clash_nxt&!IF2ID_en) begin
            Read_IF_IR_buffer<=1;
            IF_IR_buffer<=base_ram_data_R;
        end
        else begin
            Read_IF_IR_buffer<=0;
            IF_IR_buffer<=0; 
        end
    end
    assign IF_IR=Read_IF_IR_buffer?IF_IR_buffer:base_ram_data_R;
    
    //DM
    wire [1:0] EX_addr_offset, MEM_addr_offset;
    wire [19:0] EX_DM_paddr, MEM_DM_paddr;
    wire EX_ISSA, MEM_ISSA;//1表示访问串口控制器
    wire EX_ISEXT, MEM_ISEXT;
    wire EX_ISbase, MEM_ISbase;
    ADDR_MAPPING addr_mapping_DM1(
        .vaddr(EX_DM_vaddr),
        .paddr(EX_DM_paddr),
        .offset(EX_addr_offset),
        .ISSA(EX_ISSA),
        .ISEXT(EX_ISEXT),
        .ISBase(EX_ISbase)
    );
    ADDR_MAPPING addr_mapping_DM2(
        .vaddr(MEM_DM_vaddr),
        .paddr(MEM_DM_paddr),
        .offset(MEM_addr_offset),
        .ISSA(MEM_ISSA),
        .ISEXT(MEM_ISEXT),
        .ISBase(MEM_ISbase)
    );
    wire [7:0] databyte=EX_mem_data_in[7:0];
    wire [31:0] data2mem=EX_LB_SB?(
                        (EX_addr_offset==2'd0)?{24'd0,databyte}:
                        (EX_addr_offset==2'd1)?{16'd0,databyte,8'd0}:
                        (EX_addr_offset==2'd2)?{8'd0,databyte,16'd0}:
                        {databyte,24'd0}
                        ):EX_mem_data_in;
    wire [3:0] DMbe = EX_LB_SB?
                    ((EX_addr_offset==2'd0)?4'b1110:
                     (EX_addr_offset==2'd1)?4'b1101:
                     (EX_addr_offset==2'd2)?4'b1011:4'b0111)
                    :4'b0000;
    wire [31:0] DataRead=MEM_ISSA?SPC_RD:
                          MEM_ISEXT?ext_ram_data_R:base_ram_data_R;
    wire [7:0] membyte= (MEM_addr_offset==2'd0)?DataRead[7:0]:
                        (MEM_addr_offset==2'd1)?DataRead[15:8]:
                        (MEM_addr_offset==2'd2)?DataRead[23:16]:
                        DataRead[31:24];
    assign MEM_mem_data_out=MEM_LB_SB?{{24{membyte[7]}}, membyte}:DataRead;
    wire DMWrite=EX_DMwe;
    wire DMRead=EX_DMoe;
    
    assign base_ram_IO_ctrl=base_ram_we_n;
    assign ext_ram_IO_ctrl =ext_ram_we_n;
    assign IM_DM_clash_nxt=EX_ISbase&(DMWrite|DMRead);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            IM_DM_clash<=0;
            //base
            base_ram_addr<=20'd0;
            base_ram_ce_n<=1'd0;
            base_ram_oe_n<=1'd0;
            base_ram_we_n<=1'd1;
            base_ram_be_n<=4'b0000;
            //ext
            ext_ram_addr<=20'd0;
            ext_ram_ce_n<=1'd1;
            ext_ram_oe_n<=1'd1;
            ext_ram_we_n<=1'd1;
            ext_ram_be_n<=4'b1111;
            //SPC
            SPC_WD<=32'd0;
            SPC_WE<=1'd0;
            SPC_RE<=1'd0;
            SPC_addr<=20'd0;
        end
        else begin
            IM_DM_clash<=IM_DM_clash_nxt;
            base_ram_data_W<=EX_ISbase&DMWrite?data2mem:32'bz;
            base_ram_addr<=EX_ISbase&(DMWrite|DMRead)?EX_DM_paddr:IM_paddr_next;
            base_ram_ce_n<=EX_ISbase&(DMWrite|DMRead)?!(DMWrite|DMRead):1'd0;
            base_ram_oe_n<=EX_ISbase&(DMWrite|DMRead)?!(DMRead):1'd0;
            base_ram_we_n<=EX_ISbase&(DMWrite|DMRead)?!(DMWrite):1'd1;
            base_ram_be_n<=EX_ISbase&(DMWrite|DMRead)?DMbe:IMbe;
            ext_ram_data_W<=EX_ISEXT&DMWrite?data2mem:32'bz;
            ext_ram_addr<=EX_DM_paddr;
            ext_ram_ce_n <=EX_ISEXT?!(DMWrite|DMRead):1'd1;
            ext_ram_oe_n <=EX_ISEXT?!(DMRead):1'd1;
            ext_ram_we_n <= EX_ISEXT?!(DMWrite):1'd1;
            ext_ram_be_n <=EX_ISEXT?DMbe:4'b1111;
            SPC_WD<=data2mem;
            SPC_WE<=EX_ISSA?DMWrite:1'd0;
            SPC_RE<=EX_ISSA?DMRead:1'd0;
            SPC_addr<=EX_DM_paddr;
        end
    end
    
endmodule

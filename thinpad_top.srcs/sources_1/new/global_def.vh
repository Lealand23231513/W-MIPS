//ctrl macro
// `define SIMULATION //remember to close before synthesis
//`define CLK_250M
//`define CLK_240M
//`define CLK_225M
//`define CLK_200M
//`define CLK_100M
`define CLK_140M
//sram ctrl
//`define MEMVIS_5//5 cycle memvis
//`define MEMVIS_4//4 cycle memvis
//default 3 cycle memvis
//params
//cache
`define SET_SIZE 2//·����Ҳ��һ���е�����
`define PAD_WIDTH 2// PADλ����һ����4B������?2
`define OFFSET_WIDTH 5
`define INDEX_WIDTH 5
`define TAG_WIDTH (32-`INDEX_WIDTH-`OFFSET_WIDTH)
`define WAY_SIZE 2**`INDEX_WIDTH//һ·���ж�����
`define BLOCK_SIZE 2**(`OFFSET_WIDTH-`PAD_WIDTH)//һ�����ж�����

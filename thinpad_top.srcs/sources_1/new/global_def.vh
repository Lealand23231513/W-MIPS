//ctrl macro
//`define SIMULATION //remember to close before synthesis
//`define CLK_300M //UNSTABLE
//`define CLK_280M //UNSTABLE
//`define CLK_260M //slow than 250M
// `define CLK_255M //ok
// `define CLK_250M //ok
//`define CLK_225M
`define CLK_200M  //ok
// `define CLK_140M //ok
//`define CLK_100M //ok
//sram ctrl
`ifdef CLK_300M
    `define MEMVIS_6
`elsif CLK_280M
    `define MEMVIS_6
`elsif CLK_260M
    `define MEMVIS_6
`elsif CLK_255M
    `define MEMVIS_5
`elsif CLK_250M
    `define MEMVIS_5//5 cycle memvis
`elsif CLK_225M
    `define MEMVIS_5
`elsif CLK_200M
    `define MEMVIS_4//4 cycle memvis
`endif
//`define MEMVIS_4//4 cycle memvis
//default 3 cycle memvis
//params
//cache
`define SET_SIZE 2//2 set(way)
`define PAD_WIDTH 2// PAD width, default 2
`define OFFSET_WIDTH 5
`define INDEX_WIDTH 5
`define TAG_WIDTH (32-`INDEX_WIDTH-`OFFSET_WIDTH)
`define WAY_SIZE 2**`INDEX_WIDTH//num of lines in a way
`define BLOCK_SIZE 2**(`OFFSET_WIDTH-`PAD_WIDTH)//num of words (1word=32bit) in a line
//issue log
`define ISSUE_LOG_DEPTH_WIDTH 3
`define ISSUE_LOG_DEPTH 2**`ISSUE_LOG_DEPTH_WIDTH
`define FID_WIDTH 3

//FU_ID
`define EXU_ID 0
//`define EMU_ID 1
`define LSU_ID 1
`define BRU_ID 3
//bus
`define IF2ID_BUS_WIDTH 97
`define ID2IS_BUS_WIDTH 168
`define ID2EM_BUS_WIDTH (135+`FID_WIDTH)
`define FU2RO_BUS_WIDTH (104+`FID_WIDTH)
`define EM12EM2_BUS_WIDTH (199+`FID_WIDTH)
`define ID2EX_BUS_WIDTH (176+`FID_WIDTH)
`define ID2BR_BUS_WIDTH 133
`define ID2LS_BUS_WIDTH (171+`FID_WIDTH)
`define AG2MEM_BUS_WIDTH (195+`FID_WIDTH)
`define MEM_SEND_BUS_WIDTH 58
`define MEM_RECV_BUS_WIDTH 34
`define RELATE_BUS_WIDTH (39+`ISSUE_LOG_DEPTH_WIDTH)
`define RO2WB_BUS_WIDTH 38
//`ifdef MAX_COMMIT_3
//`define RO2WB_BUS_WIDTH 114
//`elsif MAX_COMMIT_2
//`define RO2WB_BUS_WIDTH 76
//`else
//`define RO2WB_BUS_WIDTH
//`endif

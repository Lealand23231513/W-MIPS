//ctrl macro
//`define SIMULATION; //仿真设置，综合时记得关
`define USE_PLL //暂时没用
`define clk_100M_PLL // clk_100M使用PLL，综合时记得设置
`define OVER_CLOCK// 超频
//params
//cache
`define SET_SIZE 2//路数，也是一组中的行数
`define PAD_WIDTH 2// PAD位宽，一字是4B，因此为2
`define OFFSET_WIDTH 5
`define INDEX_WIDTH 5
`define TAG_WIDTH (32-`INDEX_WIDTH-`OFFSET_WIDTH)
`define WAY_SIZE 2**`INDEX_WIDTH//一路中有多少行
`define BLOCK_SIZE 2**(`OFFSET_WIDTH-`PAD_WIDTH)//一行中有多少字
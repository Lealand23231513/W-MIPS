//ctrl macro
//`define SIMULATION; //�������ã��ۺ�ʱ�ǵù�
`define USE_PLL //��ʱû��
`define clk_100M_PLL // clk_100Mʹ��PLL���ۺ�ʱ�ǵ�����
`define OVER_CLOCK// ��Ƶ
//params
//cache
`define SET_SIZE 2//·����Ҳ��һ���е�����
`define PAD_WIDTH 2// PADλ��һ����4B�����Ϊ2
`define OFFSET_WIDTH 5
`define INDEX_WIDTH 5
`define TAG_WIDTH (32-`INDEX_WIDTH-`OFFSET_WIDTH)
`define WAY_SIZE 2**`INDEX_WIDTH//һ·���ж�����
`define BLOCK_SIZE 2**(`OFFSET_WIDTH-`PAD_WIDTH)//һ�����ж�����
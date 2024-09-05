CPU Abstract
===============
第八届龙芯杯个人赛MIPS赛道参赛作品，基于MIPS架构的32位CPU，获得国二。
- 稳定版主频140MHZ（三周期访存），最高可超频至260MHZ（五周期访存）。
- 1 decode，2 issue，八级流水线，顺序单发射，有Icache（二路组相联，替换策略为伪LRU算法）、无Dcache，基于两位饱和计数器的分支预测。
- 支持31条指令，包括乘法指令在内的5条算术运算指令，6条逻辑运算指令，lw、sw、lb、sb共4条访存指令，6条移位指令和6条分支跳转指令。
- 使用数据旁路（Bypass）的方式解决数据冲突，使用流水线暂停（stall）解决访存结构冲突，使用延迟槽和动态分支预测解决分支冲突。
- 不支持 CP0 寄存器和异常，不实现 TLB MMU 和特权等级。

## Test Result

### 100M(stable)

| test name | STREAM | MATRIX | CRYPTONIGHT |  sum  |
| :-------: | :----: | :----: | :---------: | :---: |
|  time/s   | 0.079  | 0.143  |    0.320    | 0.542 |

### 140M(stable)

| test name | STREAM | MATRIX | CRYPTONIGHT |  sum  |
| :-------: | :----: | :----: | :---------: | :---: |
|  time/s   | 0.056  | 0.102  |    0.228    | 0.386 |

### 200M

| test name | STREAM | MATRIX | CRYPTONIGHT |  sum  |
| :-------: | :----: | :----: | :---------: | :---: |
|  time/s   | 0.043  | 0.085  |    0.176    | 0.304 |

### 250M

| test name | STREAM | MATRIX | CRYPTONIGHT |  sum  |
| :-------: | :----: | :----: | :---------: | :---: |
|  time/s   | 0.038  | 0.078  |    0.153    | 0.269 |

### 255M

| test name | STREAM | MATRIX | CRYPTONIGHT |  sum  |
| :-------: | :----: | :----: | :---------: | :---: |
|  time/s   | 0.037  | 0.077  |    0.150    | 0.264 |

## feature
- this submit: 140M
- frontend: 4 stage pipeline(PF, IF, ID, IS)
- backend: 
- LSU(2 stage)(AG, MEM) (merge with EMU(2 stage)(EM1, EM2) )
- EXU(1 stage)(EX)
- BRU(1 stage)(BR)
- ROU(2 stage)(RO, WB)
- commit: 2
- In-order
- 100M, 140M, 200M, 250M, 255M
- icache
- Dynamic prediction

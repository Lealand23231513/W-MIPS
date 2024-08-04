CPU Abstract
===============

## Test Result

| test name | STREAM | MATRIX | CRYPTONIGHT |  sum  |
| :-------: | :----: | :----: | :---------: | :---: |
|  time/s   | 0.045  |  0.091 |    0.170    | 0.306 |

## feature

- 6 stage pipeline(PF, IF, ID, EX(EM1), MEM(EM2), WB(WB2))
- In-order
- 225M
- icache
- Independent multiplication stages(EM1, EM2)
- bypass, from EX, EM1, EM2, MEM, WB, WB2 to ID
- Dynamic prediction

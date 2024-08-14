CPU Abstract
===============

## Test Result

## 100M(stable)

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
- this submit: 250M(**unstble!!**)
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

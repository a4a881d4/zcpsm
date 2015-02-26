# zcpsm
small processor like xilinx kcpsm (PicoBlaze)

## Chnage from KCPSM
1. 32 Reg file
2. support 4K programe
3. 18 bit instruction length ins(17)&ins(7-4)->sA ins(16)&ins(3-0)->sB ins(17-16)&ins(9-0)->PC 
4. one clock per ins expect JUMP and CALL
5. do not support INTERRUPT

## Feature
1. zcc pseudo-C Compile
# 为了使用zcpsm和ring bus 重写ethnet

重写

## Eth_Tx_HighPriority
- m48_Tx_Req_DesMac
- m16_Tx_Req_Addr
- m16_Tx_Req_Data

将改为内部寄存器

分装为独立IP core

## port_id全部从外面引入，内部产生ce信号，地址空间通过配置传入
1. g_ethtx 
2. g_ethrx 
3. ethrx_task
4. debug_io





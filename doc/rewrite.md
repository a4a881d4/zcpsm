# 为了使用zcpsm和ring bus 重写ethnet

重写

## 改为内部寄存器
- m48_Tx_Req_DesMac
- m16_Tx_Req_Addr
- m16_Tx_Req_Data



----------

> `ethrx_in_port <= 	local_id_MAC0_A when ethrx_port_id = PORT_ETH_LOCAL_ID_0_A else local_id_MAC0_B when ethrx_port_id = PORT_ETH_LOCAL_ID_0_B else local_id( 39 downto 32 ) when ethrx_port_id = PORT_ETH_LOCAL_ID_1 else local_id( 31 downto 24 ) when ethrx_port_id = PORT_ETH_LOCAL_ID_2 else local_id( 23 downto 16 ) when ethrx_port_id = PORT_ETH_LOCAL_ID_3 else local_id( 15 downto 8 ) when ethrx_port_id = PORT_ETH_LOCAL_ID_4 else local_id( 7 downto 0 ) when ethrx_port_id = PORT_ETH_LOCAL_ID_5 else (others => 'Z');`	

----------
> `ethtx_in_port <= 	local_id_MAC0_Req when ethtx_port_id = PORT_ETH_LOCAL_ID_0_REQ else
						local_id_MAC0_A when ethtx_port_id = PORT_ETH_LOCAL_ID_0_A else
						local_id_MAC0_B when ethtx_port_id = PORT_ETH_LOCAL_ID_0_B else
						local_id( 39 downto 32 ) when ethtx_port_id = PORT_ETH_LOCAL_ID_1 else
						local_id( 31 downto 24 ) when ethtx_port_id = PORT_ETH_LOCAL_ID_2 else
						local_id( 23 downto 16 ) when ethtx_port_id = PORT_ETH_LOCAL_ID_3 else
						local_id( 15 downto 8 ) when ethtx_port_id = PORT_ETH_LOCAL_ID_4 else
						local_id( 7 downto 0 ) when ethtx_port_id = PORT_ETH_LOCAL_ID_5 else
						(others => 'Z');`

----------
> `db_in_port <= 	local_id_MAC0_A when db_port_id = PORT_DB_LOCAL_ID_0_A else
					local_id_MAC0_B when db_port_id = PORT_DB_LOCAL_ID_0_B else
					local_id( 39 downto 32 ) when db_port_id = PORT_DB_LOCAL_ID_1 else
					local_id( 31 downto 24 ) when db_port_id = PORT_DB_LOCAL_ID_2 else
					local_id( 23 downto 16 ) when db_port_id = PORT_DB_LOCAL_ID_3 else
					local_id( 15 downto 8 ) when db_port_id = PORT_DB_LOCAL_ID_4 else
					local_id( 7 downto 0 ) when db_port_id = PORT_DB_LOCAL_ID_5 else
					(others => 'Z');`

----------


## port_id全部从外面引入，内部产生ce信号，地址空间通过配置传入
1. g_ethtx 
2. g_ethrx 
3. ethrx_task
4. debug_io
5. ethtx
6. ethrx

## kcpsm2dma -> zcpsm2dma
### stage1
将kcpsm换成zcpsm

### stage2
1. 读写模式可以改变
2. 不在使用asyncwrite接口





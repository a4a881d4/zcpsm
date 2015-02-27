library ieee;
use ieee.std_logic_1164.all;   
--use work.config.all;

-- ASYNCWRITE: data from asynchronous clock write to register with synchronous clock
-- reset		: global reset
-- async_clk	: clock of source data
-- async_wren	: source data valid
-- sync_clk		: clock of destination register
-- trigger		: condition when destination register can be written
-- sync_wren	: destination register writing enabled
-- over			: destination register writing finished
-- flag			: source data in but destination register not written
entity ASYNCWRITE is
	port(
		reset: in std_logic;
		async_clk: in std_logic;
		sync_clk: in std_logic;
		async_wren: in std_logic;
		trigger: in std_logic;
		sync_wren: out std_logic;
		over: out std_logic;
		flag: out std_logic
		);
end ASYNCWRITE;

architecture ASYNCWRITE of ASYNCWRITE is
	signal flag1: std_logic;
	signal flag2: std_logic;
	signal flag3: std_logic;
	
begin
	
	async: process( async_clk, reset )
	begin
		if reset = '1' then
			flag1 <= '0';
		elsif rising_edge(async_clk) then	
			if async_wren = '1' then
				flag1 <= not flag1;
			end if;
		end if;
	end process async;
	
	sync: process( sync_clk, reset )
	begin
		if reset = '1' then
			flag2 <= '0';
			flag3 <= '0';
			over <= '0';
		elsif rising_edge(sync_clk) then
			flag2 <= flag1;
			if flag2 /= flag3 and trigger = '1' then
				flag3 <= not flag3;	  
				over <= '1';
			else
				over <= '0';
			end if;
		end if;
	end process sync;
	
	sync_wren <= '1' when flag2 /= flag3 and trigger='1' else '0';
	flag <= '1' when flag1/=flag2 or flag2/=flag3 else '0';
	
end ASYNCWRITE;




----------------------------  
-- 2011/04/26:
--    debug_read_strobe控制信号在 zcpsm_read_strobe = '1' 时产生。
-------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity zcpsmIO2bus16 is
	port(
		reset				:	in	std_logic;
	
		debug_port_id		:	out	std_logic_vector(15 downto 0);
		debug_write_strobe	:	out	std_logic;
		debug_out_port		:	out	std_logic_vector(15 downto 0);
		debug_read_strobe	:	out	std_logic;
		debug_in_port		:	in	std_logic_vector(15 downto 0);
		
		zcpsm_clk			:	in	std_logic;
		zcpsm_ce			:	in	std_logic;
		zcpsm_port_id		:	in	std_logic_vector(3 downto 0);
		zcpsm_write_strobe	:	in	std_logic;
		zcpsm_out_port		:	in	std_logic_vector(7 downto 0);
		zcpsm_read_strobe	:	in	std_logic;
		zcpsm_in_port		:	out	std_logic_vector(7 downto 0)
		);
end entity;

architecture behave of zcpsmIO2bus16 is
	
	constant PORT_zcpsmIO2bus16_ADDR_L			:	std_logic_vector(3 downto 0)	:=	X"0";
	constant PORT_zcpsmIO2bus16_ADDR_H			:	std_logic_vector(3 downto 0)	:=	X"1";
	constant PORT_zcpsmIO2bus16_DATA_L			:	std_logic_vector(3 downto 0)	:=	X"2";
	constant PORT_zcpsmIO2bus16_DATA_H			:	std_logic_vector(3 downto 0)	:=	X"3";
	
begin
	
	AddrReg : process(zcpsm_clk, reset)
	begin
		if reset = '1' then
			debug_port_id <= (others => '0');
		elsif rising_edge(zcpsm_clk) then
			if zcpsm_ce = '1' and zcpsm_write_strobe = '1' then
				if zcpsm_port_id(3 downto 0) = PORT_zcpsmIO2bus16_ADDR_L then
					debug_port_id(7 downto 0) <= zcpsm_out_port;
				elsif zcpsm_port_id(3 downto 0) = PORT_zcpsmIO2bus16_ADDR_H then
					debug_port_id(15 downto 8) <= zcpsm_out_port;
				end if;
			end if;
		end if;
	end process;
	
	WriteIO : process(zcpsm_clk, reset)
	begin
		if reset = '1' then
			debug_write_strobe <= '0';
			debug_out_port <= (others => '0');
		elsif rising_edge(zcpsm_clk) then
			if zcpsm_ce = '1' and zcpsm_write_strobe = '1' and zcpsm_port_id(3 downto 0) = PORT_zcpsmIO2bus16_DATA_H then
				debug_write_strobe <= '1';
			else
				debug_write_strobe <= '0';
			end if;
			
			if zcpsm_ce = '1' and zcpsm_write_strobe = '1' then
				if zcpsm_port_id(3 downto 0) = PORT_zcpsmIO2bus16_DATA_L then
					debug_out_port(7 downto 0) <= zcpsm_out_port;
				elsif zcpsm_port_id(3 downto 0) = PORT_zcpsmIO2bus16_DATA_H then
					debug_out_port(15 downto 8) <= zcpsm_out_port;
				end if;
			end if;
		end if;
	end process;
	
	debug_read_strobe <= '1' when zcpsm_ce = '1' and zcpsm_read_strobe = '1' else '0';
	
	zcpsm_in_port <= debug_in_port(7 downto 0) when zcpsm_ce = '1' and zcpsm_port_id(3 downto 0) = PORT_zcpsmIO2bus16_DATA_L else
					 debug_in_port(15 downto 8) when zcpsm_ce = '1' and zcpsm_port_id(3 downto 0) = PORT_zcpsmIO2bus16_DATA_H else
					 (others => 'Z');
	
end behave;

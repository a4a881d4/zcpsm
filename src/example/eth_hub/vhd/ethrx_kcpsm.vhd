---------------------------------------------------------------------------------------------------
--
-- Title       : ethrx_kcpsm
-- Design      : eth_new
-- Author      : dove
-- Company     : google
--
---------------------------------------------------------------------------------------------------
--
-- File        : ethrx_kcpsm.vhd
-- Generated   : Sun Sep  3 10:28:09 2006
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
---------------------------------------------------------------------------------------------------
--
-- Description : 
--
---------------------------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {ethrx_kcpsm} architecture {arch_ethrx_kcpsm}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ethrx_kcpsm is
	port(
		reset				:	in	std_logic;
		kcpsm_clk			:	in	std_logic;
		
		port_id				:	out	std_logic_vector(7 downto 0);
		write_strobe		:	out	std_logic;
		out_port			:	out	std_logic_vector(7 downto 0);
		read_strobe			:	out	std_logic;
		in_port				:	in	std_logic_vector(7 downto 0);
		
		prog_ce				:	in	std_logic;
		prog_reset			:	in	std_logic;
		prog_wren			:	in	std_logic;
		prog_addr			:	in	std_logic_vector(9 downto 0);
		prog_wdata			:	in	std_logic_vector(15 downto 0);
		prog_rdata			:	out	std_logic_vector(15 downto 0)
		);
end ethrx_kcpsm;

--}} End of automatically maintained section

architecture arch_ethrx_kcpsm of ethrx_kcpsm is

--	component kcpsmbig
--		port(
--			address 		: out std_logic_vector(9 downto 0);
--			instruction 	: in std_logic_vector(15 downto 0);
--			port_id 		: out std_logic_vector(7 downto 0);
--			write_strobe 	: out std_logic;
--			out_port 		: out std_logic_vector(7 downto 0);
--			read_strobe 	: out std_logic;
--			in_port 		: in std_logic_vector(7 downto 0);
--			interrupt 		: in std_logic;
--			reset 			: in std_logic;
--			clk 			: in std_logic);
--	end component; 
--	for all : kcpsmBig use entity work.kcpsmBig(one_clock);
--	
--	component ethrxrom
--		port(
--			addra 			: in std_logic_vector(9 downto 0);
--			addrb 			: in std_logic_vector(9 downto 0);
--			clka 			: in std_logic;
--			clkb 			: in std_logic;
--			dina 			: in std_logic_vector(15 downto 0);
--			douta 			: out std_logic_vector(15 downto 0);
--			doutb 			: out std_logic_vector(15 downto 0);
--			wea 			: in std_logic);
--	end component;
	
--	component ethrxrom_romonly
--	port(
--		addrb 				: in std_logic_vector(9 downto 0);
--		clkb 				: in std_logic;
--		dob 				: out std_logic_vector(15 downto 0));
--	end component;	

	component zcpsm
		Port (     
			address 	: 	out std_logic_vector(11 downto 0);
			instruction :	in std_logic_vector(17 downto 0);
			port_id 	:	out std_logic_vector(7 downto 0);
			write_strobe :	out std_logic;
			out_port 	:	out std_logic_vector(7 downto 0);
			read_strobe :	out std_logic;
			in_port 	:	in std_logic_vector(7 downto 0);
			interrupt 	:	in std_logic;
			reset 		:	in std_logic;
			clk 		:	in std_logic);
	end component;
	for all : zcpsm use entity work.zcpsm(fast);

	component ethrxrom_romonly
	port(
		addrb : in std_logic_vector(11 downto 0);
		clkb : in std_logic;
		dob : out std_logic_vector(17 downto 0));
	end component;	

	signal address : std_logic_vector(11 downto 0);
	signal instruction : std_logic_vector(17 downto 0);	 

	component prog2kcpsm
		port(
			reset 			: in std_logic;
			prog_ce 		: in std_logic;
			prog_reset 		: in std_logic;
			prog_wren 		: in std_logic;
			prog_addr 		: in std_logic_vector(9 downto 0);
			prog_wdata 		: in std_logic_vector(15 downto 0);
			prog_rdata 		: out std_logic_vector(15 downto 0);
			kcpsm_reset 	: out std_logic;
			kcpsm_wren 		: out std_logic;
			kcpsm_addr 		: out std_logic_vector(9 downto 0);
			kcpsm_wdata 	: out std_logic_vector(15 downto 0);
			kcpsm_rdata 	: in std_logic_vector(15 downto 0));
	end component;
	
--	signal address 			: std_logic_vector(9 downto 0);
--	signal instruction 		: std_logic_vector(15 downto 0);
	signal kcpsm_reset 		: std_logic;
	signal kcpsm_wren 		: std_logic;
	signal kcpsm_addr 		: std_logic_vector(9 downto 0);
	signal kcpsm_wdata 		: std_logic_vector(15 downto 0);
	signal kcpsm_rdata 		: std_logic_vector(15 downto 0);	

begin

--	u_rx_kcpsm : kcpsmbig
--	port map(
--		address => address,
--		instruction => instruction,
--		port_id => port_id,
--		write_strobe => write_strobe,
--		out_port => out_port,
--		read_strobe => read_strobe,
--		in_port => in_port,
--		interrupt => '0',
--		reset => kcpsm_reset,
--		clk => kcpsm_clk
--		);
--	
--	u_rx_rom : ethrxrom
--	port map(
--		addra => kcpsm_addr,
--		clka => kcpsm_clk,
--		addrb => address,
--		clkb => kcpsm_clk,
--		dina => kcpsm_wdata,
--		douta => kcpsm_rdata,
--		doutb => instruction,
--		wea => kcpsm_wren
--		); 
--	

	u_rx_kcpsm : zcpsm
	port map(
		address => address,
		instruction => instruction,
		port_id => port_id,
		write_strobe => write_strobe,
		out_port => out_port,
		read_strobe => read_strobe,
		in_port => in_port,
		interrupt => '0',
		reset => kcpsm_reset,
		clk => kcpsm_clk
		);

	u_rx_rom : ethrxrom_romonly
	port map(
		addrb => address,
		clkb => kcpsm_clk,
		dob => instruction
		); 		
				
	
	u_rx_prog : prog2kcpsm
	port map(
		reset => reset,
		prog_ce => prog_ce,
		prog_reset => prog_reset,
		prog_wren => prog_wren,
		prog_addr => prog_addr,
		prog_wdata => prog_wdata,
		prog_rdata => prog_rdata,
		kcpsm_reset => kcpsm_reset,
		kcpsm_wren => kcpsm_wren,
		kcpsm_addr => kcpsm_addr,
		kcpsm_wdata => kcpsm_wdata,
		kcpsm_rdata => kcpsm_rdata
		);
	 -- enter your statements here --

end arch_ethrx_kcpsm;

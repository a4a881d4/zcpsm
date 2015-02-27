---------------------------------------------------------------------------------------------------
--
-- Title       : kcpsm2dsp
-- Design      : baseband
-- Author      : yanghb
-- Company     : tsinghua
--
---------------------------------------------------------------------------------------------------
--
-- File        : kcpsm2dsp.vhd
-- Generated   : Tue Jan  4 16:04:14 2005
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.20
--
---------------------------------------------------------------------------------------------------
--
-- Description : KCPSM to DSP interface transformer
--
---------------------------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {kcpsm2dsp} architecture {behave}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;



entity kcpsm2dsp is
	port(
		clk			: in std_logic;
		port_id		: in std_logic_vector(7 downto 0); 
		write_strobe	: in std_logic;
		out_port	: in std_logic_vector(7 downto 0);
		read_strobe	: in std_logic;
		in_port		: out std_logic_vector(7 downto 0);
		interrupt	: out std_logic;
		
		dsp_io		: out std_logic;
		dsp_rw		: out std_logic;
		dsp_a		: out std_logic_vector(7 downto 0);
		dsp_din		: out std_logic_vector(7 downto 0);
		dsp_dout	: in std_logic_vector(7 downto 0);
		dsp_int		: in std_logic
		);
end kcpsm2dsp;

--}} End of automatically maintained section

architecture behave of kcpsm2dsp is	
	
begin
	
	-- enter your statements here --
	
	dsp_io <= clk;
	dsp_rw <= not write_strobe;
	dsp_a <= port_id;
	dsp_din <= out_port;
	in_port <= dsp_dout; 
	interrupt <= dsp_int;
	
end behave;

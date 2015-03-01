---------------------------------------------------------------------------------------------------
--
-- Title       : zcpsmISP
-- Design      : eth_new
-- Author      : a4a881d4
-- Company     : a4a881d4
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity zcpsmISP is
	generic (
		AWIDTH	: natural := 10;
		PROG	: string := "program.bit"
	);
	port(
		reset				:	in	std_logic;
		clk					:	in	std_logic;
		
		port_ce				:	out	std_logic_vector(15 downto 0);
		port_id				:	out	std_logic_vector(3 downto 0);
		write_strobe		:	out	std_logic;
		out_port			:	out	std_logic_vector(7 downto 0);
		read_strobe			:	out	std_logic;
		in_port				:	in	std_logic_vector(7 downto 0);
		
		prog_we	: in std_logic;
		prog_clk: in std_logic;
		prog_addr : in std_logic_vector( AWIDTH-1 downto 0 );
		prog_din : in std_logic_vector( 17 downto 0 )
		
	);
end zcpsmISP;

--}} End of automatically maintained section

architecture behavior of zcpsmISP is

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
			clk 		:	in std_logic
		);
	end component;

	component zcpsmProgRam
	generic (
		AWIDTH	: natural := 10;
		PROG	: string := "program.bit"
	);
	port (
		clk : in std_logic;
		reset: in std_logic;
		
		addr : in std_logic_vector( AWIDTH-1 downto 0 );
		dout : out std_logic_vector( 17 downto 0 );
		soft_rst : out std_logic;
		
		prog_we	: in std_logic;
		prog_clk: in std_logic;
		prog_addr : in std_logic_vector( AWIDTH-1 downto 0 );
		prog_din : in std_logic_vector( 17 downto 0 )
	);
	end component;
	
	component zcpsmDecode
	port (
		port_id_H	: in std_logic_vector(3 downto 0);
		ce 			: out std_logic_vector(15 downto 0)
	);
	end component;
	
	signal address : std_logic_vector(11 downto 0);
	signal instruction : std_logic_vector(17 downto 0);	 
	signal port_id_i 	: std_logic_vector(7 downto 0);
	signal soft_reset : std_logic;
	signal zcpsm_reset : std_logic;
	
begin

	port_id <= port_id_i( 3 downto 0 );
	zcpsm_reset <= reset or soft_reset;
	
	u_rx_zcpsm : zcpsm
	port map(
		address => address,
		instruction => instruction,
		port_id => port_id_i,
		write_strobe => write_strobe,
		out_port => out_port,
		read_strobe => read_strobe,
		in_port => in_port,
		interrupt => '0',
		reset => zcpsm_reset,
		clk => clk
		);

	u_ram : zcpsmProgRam
	generic map(
		AWIDTH => 10,
        PROG => PROG
    )
	port map(
		clk => clk,
		reset => reset,
		
		addr => address( AWIDTH-1 downto 0 ),
		dout => instruction,
		soft_reset => soft_reset,
		
		prog_we	=> prog_we,
		prog_clk => prog_clk,
		prog_addr => prog_addr,
		prog_din => prog_din
		);
 		
	u_decode : zcpsmDecode
	port map(
		port_id_H	=> port_id_i( 7 downto 4 ),
		ce 			=> port_ce
	);

end behavior;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity kcpsm_programmer is
	port(
		reset				:	in	std_logic;
		kcpsm_clk			:	in	std_logic;
		
		prog_id				:	out	std_logic_vector(3 downto 0);
		prog_reset			:	out	std_logic;
		prog_wren			:	out	std_logic;
		prog_addr			:	out	std_logic_vector(9 downto 0);
		prog_wdata			:	out	std_logic_vector(15 downto 0);
		prog_rdata			:	in	std_logic_vector(15 downto 0);
		
		debug_ce			:	in	std_logic;
		debug_port_id		:	in	std_logic_vector(10 downto 0);
		debug_write_strobe	:	in	std_logic;
		debug_out_port		:	in	std_logic_vector(15 downto 0);
		debug_read_strobe	:	in	std_logic;
		debug_in_port		:	out	std_logic_vector(15 downto 0)
		);
end entity;

architecture behave of kcpsm_programmer is
	
	signal prog_ena : std_logic;
	
	constant PORT_PROG_ENA	:	std_logic_vector(10 downto 0)	:=	"00000000000";
	constant PORT_PROG_RST	:	std_logic_vector(10 downto 0)	:=	"00000000001";
	constant PORT_PROG_ID	:	std_logic_vector(10 downto 0)	:=	"00000000010";
	
begin
	
	prog_wren <= debug_write_strobe and prog_ena;
	
	prog_addr <= debug_port_id(9 downto 0);
	
	prog_wdata <= debug_out_port;
	
	debug_in_port <= prog_rdata when debug_ce = '1' else (others => 'Z');
	
	process(kcpsm_clk, reset)
	begin
		if reset = '1' then
			prog_ena <= '0';
			prog_reset <= '0';
			prog_id <= (others => '0');
		elsif rising_edge(kcpsm_clk) then
			if debug_ce = '1' and debug_write_strobe = '1' then
				if debug_port_id(10 downto 0) = PORT_PROG_ENA then
					prog_ena <= debug_out_port(0);
				end if;
				if debug_port_id(10 downto 0) = PORT_PROG_RST then
					prog_reset <= debug_out_port(0);
				end if;
				if debug_port_id(10 downto 0) = PORT_PROG_ID then
					prog_id <= debug_out_port(3 downto 0);
				end if;
			end if;
		end if;
	end process;
	
end behave;

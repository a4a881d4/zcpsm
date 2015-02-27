library ieee;
use ieee.std_logic_1164.all;

entity db_kcpsm is
	port(
		reset			:	in	std_logic;
		kcpsm_clk		:	in	std_logic;
		
		port_id			:	out	std_logic_vector(7 downto 0);
		write_strobe	:	out	std_logic;
		out_port		:	out	std_logic_vector(7 downto 0);
		read_strobe		:	out	std_logic;
		in_port			:	in	std_logic_vector(7 downto 0)
		);
end entity;

architecture struct of db_kcpsm is

--	component kcpsmbig
--		port(
--			address : out std_logic_vector(9 downto 0);
--			instruction : in std_logic_vector(15 downto 0);
--			port_id : out std_logic_vector(7 downto 0);
--			write_strobe : out std_logic;
--			out_port : out std_logic_vector(7 downto 0);
--			read_strobe : out std_logic;
--			in_port : in std_logic_vector(7 downto 0);
--			interrupt : in std_logic;
--			reset : in std_logic;
--			clk : in std_logic);
--	end component; 
--	for all : kcpsmBig use entity work.kcpsmBig(one_clock);

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

	component dbrom_romonly
	port(
		addrb : in std_logic_vector(11 downto 0);
		clkb : in std_logic;
		dob : out std_logic_vector(17 downto 0));
	end component;	

	signal address : std_logic_vector(11 downto 0);
	signal instruction : std_logic_vector(17 downto 0);	 
	
--	component dbrom_romonly
--	port(
--		addrb : in std_logic_vector(9 downto 0);
--		clkb : in std_logic;
--		dob : out std_logic_vector(15 downto 0));
--	end component;	
--	
--	component dbrom
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
	

--	signal address : std_logic_vector(9 downto 0);
--	signal instruction : std_logic_vector(15 downto 0);	 
--
--	signal kcpsm_wren 		: std_logic := '0';
--	signal kcpsm_addr 		: std_logic_vector(9 downto 0) := ( others => '0' );
--	signal kcpsm_wdata 		: std_logic_vector(15 downto 0) := ( others => '0' );
--	signal kcpsm_rdata 		: std_logic_vector(15 downto 0);		
	
begin

	u_kcpsm : zcpsm
	port map(
		address => address,
		instruction => instruction,
		port_id => port_id,
		write_strobe => write_strobe,
		out_port => out_port,
		read_strobe => read_strobe,
		in_port => in_port,
		interrupt => '0',
		reset => reset,
		clk => kcpsm_clk
		);
	
--	u_kcpsm : kcpsmbig
--	port map(
--		address => address,
--		instruction => instruction,
--		port_id => port_id,
--		write_strobe => write_strobe,
--		out_port => out_port,
--		read_strobe => read_strobe,
--		in_port => in_port,
--		interrupt => '0',
--		reset => reset,
--		clk => kcpsm_clk
--		);
	
	u_rom : dbrom_romonly
	port map(
		addrb => address,
		clkb => kcpsm_clk,
		dob => instruction
		); 
		
--	u_rom : dbrom
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
	
end struct;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity kcpsm2fifo is
	generic(
		BLOCK_AWIDTH		:	integer;
		DWIDTH				:	integer
		);
	port(
		clk					:	in	std_logic;
		reset				:	in	std_logic;
		
		kcpsm_clk			:	in	std_logic;
		kcpsm_ce			:	in	std_logic;
		kcpsm_port_id		:	in	std_logic_vector(3 downto 0);
		kcpsm_write_strobe	:	in	std_logic;
		kcpsm_out_port		:	in	std_logic_vector(7 downto 0);
		kcpsm_read_strobe	:	in	std_logic;
		kcpsm_in_port		:	out	std_logic_vector(7 downto 0);
		
		fifo_wr_block		:	out	std_logic;	
		fifo_wren			:	out	std_logic;
		fifo_waddr			:	out	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);
		fifo_wdata			:	out	std_logic_vector(DWIDTH - 1 downto 0);
		fifo_full			:	in	std_logic;
		fifo_empty			:	in	std_logic
		);
end entity;

architecture behave of kcpsm2fifo is

	component asyncwrite
	port(
		reset : in std_logic;
		async_clk : in std_logic;
		sync_clk : in std_logic;
		async_wren : in std_logic;
		trigger : in std_logic;
		sync_wren : out std_logic;
		over : out std_logic;
		flag : out std_logic);
	end component;

	signal kcpsm_we			:	std_logic;
	signal kcpsm_re			:	std_logic;
	signal kcpsm_addr		:	std_logic_vector(3 downto 0);
	signal wr_block_en		:	std_logic;
	signal fifo_waddr_reg	:	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);
--	signal flag_LastFrame	:   std_logic;
	
	constant PORT_IO_ADDR			:	std_logic_vector(3 downto 0)	:=	X"0";
	constant PORT_IO_DATA			:	std_logic_vector(3 downto 0)	:=	X"1";
	constant PORT_QUEUE_STATUS		:	std_logic_vector(3 downto 0)	:=	X"2"; 
--	constant PORT_LAST_FRAME		:	std_logic_vector(3 downto 0)	:=	X"3";
	constant PORT_WR_BLOCK			:	std_logic_vector(3 downto 0)	:=	X"4";
	
begin
	
	kcpsm_we <= kcpsm_ce and kcpsm_write_strobe;
	kcpsm_re <= kcpsm_ce and kcpsm_read_strobe;
	kcpsm_addr <= '0' & kcpsm_port_id(3 downto 1);
	
	kcpsm_in_port <= "000000" & fifo_empty & fifo_full when kcpsm_ce = '1' and kcpsm_addr = PORT_QUEUE_STATUS	  else (others => 'Z');
--	flag_LastFrame <= '1' when kcpsm_ce = '1' and kcpsm_addr = PORT_LAST_FRAME else '0';
		
	u_wr_block : asyncwrite
	port map(
		reset => reset,
		async_clk => kcpsm_clk,
		sync_clk => clk,
		async_wren => wr_block_en,
		trigger => '1',
		sync_wren => fifo_wr_block,
		over => open,
		flag => open
		);
	
	wr_block_en <= '1' when kcpsm_we = '1' and kcpsm_addr = PORT_WR_BLOCK else '0';
	
	process(kcpsm_clk, reset)
	begin
		if reset = '1' then
			fifo_waddr_reg <= (others => '0');
		elsif rising_edge(kcpsm_clk) then
			if kcpsm_we = '1' and kcpsm_addr = PORT_IO_ADDR then
				fifo_waddr_reg <= kcpsm_out_port(BLOCK_AWIDTH - 1 downto 0);
			elsif kcpsm_we = '1' and kcpsm_addr = PORT_IO_DATA then
				fifo_waddr_reg <= fifo_waddr_reg + 1;
			end if;
		end if;
	end process;
	
	fifo_wren <= '1' when kcpsm_we = '1' and kcpsm_addr = PORT_IO_DATA else '0';
	fifo_waddr <= fifo_waddr_reg;
	fifo_wdata <= kcpsm_out_port;
	
end behave;

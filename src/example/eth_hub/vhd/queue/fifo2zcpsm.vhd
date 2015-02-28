library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

------------------------------------------------------------------------------------------
--                zcpsm                           fifo2zcpsm 					fifo_block
--     							 km_clk --                       --  reset  
-- 		   -------------------		      \						 \
--         \                  \		 ------------------------------------
--  reset--\		   in_port\--<--\zcpsm_in_port			  		clk	\--<--\	clk
--km_clk --\		  out_port\-->--\zcpsm_out_port			  fifo_rdata\--<--\	fifo_rdata 
--		   \		   port_id\-->--\zcpsm_port_id			  fifo_raddr\-->--\	fifo_raddr
--		   \	   read_strobe\-->--\zcpsm_read_strobe		  fifo_full	\--<--\	fifo_full
--		   \      write_strobe\-->--\zcpsm_write_strobe 	  fifo_empty\--<--\	fifo_empty
--         \				  \		\					   fifo_rd_block\-->--\	fifo_rd_block
--															  			\
--																		\													
--															   zcpsm_ce \--<-- eth_dma_ce													


entity fifo2zcpsm is
	generic(
		BLOCK_AWIDTH		:	integer;    --5
		DWIDTH				:	integer		-- 8
		);
	port(
		clk					:	in	std_logic;
		reset				:	in	std_logic;
		
		zcpsm_clk			:	in	std_logic;
		zcpsm_ce			:	in	std_logic;
		zcpsm_port_id		:	in	std_logic_vector(3 downto 0);
		zcpsm_write_strobe	:	in	std_logic;
		zcpsm_out_port		:	in	std_logic_vector(7 downto 0);
		zcpsm_read_strobe	:	in	std_logic;
		zcpsm_in_port		:	out	std_logic_vector(7 downto 0);
		
		fifo_rd_block		:	out	std_logic;
		fifo_raddr			:	out	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);
		fifo_rdata			:	in	std_logic_vector(DWIDTH - 1 downto 0);
		fifo_full			:	in	std_logic;
		fifo_empty			:	in	std_logic
		);
end entity;

architecture behave of fifo2zcpsm is

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
	
	signal zcpsm_we			:	std_logic;
	signal zcpsm_re			:	std_logic;
	signal zcpsm_addr		:	std_logic_vector(3 downto 0);
	signal rd_block_en		:	std_logic;
	signal fifo_raddr_reg	:	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);
	
	constant PORT_IO_ADDR			:	std_logic_vector(3 downto 0)	:=	X"0";  		-- low 4 bits
	constant PORT_IO_DATA			:	std_logic_vector(3 downto 0)	:=	X"1";
	constant PORT_QUEUE_STATUS		:	std_logic_vector(3 downto 0)	:=	X"2";
	constant PORT_RD_BLOCK			:	std_logic_vector(3 downto 0)	:=	X"5";
	
begin
	
	zcpsm_we <= zcpsm_ce and zcpsm_write_strobe;
	zcpsm_re <= zcpsm_ce and zcpsm_read_strobe;
	zcpsm_addr <= '0' & zcpsm_port_id(3 downto 1);
	
	zcpsm_in_port <= "000000" & fifo_empty & fifo_full when zcpsm_ce = '1' and zcpsm_addr = PORT_QUEUE_STATUS	else (others => 'Z');
	
	u_rd_block : asyncwrite
	port map(
		reset => reset,
		async_clk => zcpsm_clk,
		sync_clk => clk,
		async_wren => rd_block_en,
		trigger => '1',
		sync_wren => fifo_rd_block,
		over => open,
		flag => open
		);
	
	rd_block_en <= '1' when zcpsm_we = '1' and zcpsm_addr = PORT_RD_BLOCK else '0';
	
	process(zcpsm_clk, reset)
	begin
		if reset = '1' then
			fifo_raddr_reg <= (others => '0');
		elsif rising_edge(zcpsm_clk) then
			if zcpsm_we = '1' and zcpsm_addr = PORT_IO_ADDR then
				fifo_raddr_reg <= zcpsm_out_port(BLOCK_AWIDTH - 1 downto 0);
			elsif zcpsm_re = '1' and zcpsm_addr = PORT_IO_DATA then
				fifo_raddr_reg <= fifo_raddr_reg + 1;
			end if;
		end if;
	end process;
	
	fifo_raddr <=	zcpsm_out_port(BLOCK_AWIDTH - 1 downto 0)	when zcpsm_we = '1' and zcpsm_addr = PORT_IO_ADDR	else
					fifo_raddr_reg + 1							when zcpsm_re = '1' and zcpsm_addr = PORT_IO_DATA	else
					fifo_raddr_reg;
	
	zcpsm_in_port <= fifo_rdata when zcpsm_ce = '1' and zcpsm_addr = PORT_IO_DATA else (others => 'Z');
	
end behave;

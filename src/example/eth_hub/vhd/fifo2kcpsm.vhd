library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

------------------------------------------------------------------------------------------
--                KCPSM                           fifo2kcpsm 					fifo_block
--     							 km_clk --                       --  reset  
-- 		   -------------------		      \						 \
--         \                  \		 ------------------------------------
--  reset--\		   in_port\--<--\kcpsm_in_port			  		clk	\--<--\	clk
--km_clk --\		  out_port\-->--\kcpsm_out_port			  fifo_rdata\--<--\	fifo_rdata 
--		   \		   port_id\-->--\kcpsm_port_id			  fifo_raddr\-->--\	fifo_raddr
--		   \	   read_strobe\-->--\kcpsm_read_strobe		  fifo_full	\--<--\	fifo_full
--		   \      write_strobe\-->--\kcpsm_write_strobe 	  fifo_empty\--<--\	fifo_empty
--         \				  \		\					   fifo_rd_block\-->--\	fifo_rd_block
--															  			\
--																		\													
--															   kcpsm_ce \--<-- eth_dma_ce													


entity fifo2kcpsm is
	generic(
		BLOCK_AWIDTH		:	integer;    --5
		DWIDTH				:	integer		-- 8
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
		
		fifo_rd_block		:	out	std_logic;
		fifo_raddr			:	out	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);
		fifo_rdata			:	in	std_logic_vector(DWIDTH - 1 downto 0);
		fifo_full			:	in	std_logic;
		fifo_empty			:	in	std_logic
		);
end entity;

architecture behave of fifo2kcpsm is

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
	signal rd_block_en		:	std_logic;
	signal fifo_raddr_reg	:	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);
	
	constant PORT_IO_ADDR			:	std_logic_vector(3 downto 0)	:=	X"0";  		-- low 4 bits
	constant PORT_IO_DATA			:	std_logic_vector(3 downto 0)	:=	X"1";
	constant PORT_QUEUE_STATUS		:	std_logic_vector(3 downto 0)	:=	X"2";
	constant PORT_RD_BLOCK			:	std_logic_vector(3 downto 0)	:=	X"5";
	
begin
	
	kcpsm_we <= kcpsm_ce and kcpsm_write_strobe;
	kcpsm_re <= kcpsm_ce and kcpsm_read_strobe;
	kcpsm_addr <= '0' & kcpsm_port_id(3 downto 1);
	
	kcpsm_in_port <= "000000" & fifo_empty & fifo_full when kcpsm_ce = '1' and kcpsm_addr = PORT_QUEUE_STATUS	else (others => 'Z');
	
	u_rd_block : asyncwrite
	port map(
		reset => reset,
		async_clk => kcpsm_clk,
		sync_clk => clk,
		async_wren => rd_block_en,
		trigger => '1',
		sync_wren => fifo_rd_block,
		over => open,
		flag => open
		);
	
	rd_block_en <= '1' when kcpsm_we = '1' and kcpsm_addr = PORT_RD_BLOCK else '0';
	
	process(kcpsm_clk, reset)
	begin
		if reset = '1' then
			fifo_raddr_reg <= (others => '0');
		elsif rising_edge(kcpsm_clk) then
			if kcpsm_we = '1' and kcpsm_addr = PORT_IO_ADDR then
				fifo_raddr_reg <= kcpsm_out_port(BLOCK_AWIDTH - 1 downto 0);
			elsif kcpsm_re = '1' and kcpsm_addr = PORT_IO_DATA then
				fifo_raddr_reg <= fifo_raddr_reg + 1;
			end if;
		end if;
	end process;
	
	fifo_raddr <=	kcpsm_out_port(BLOCK_AWIDTH - 1 downto 0)	when kcpsm_we = '1' and kcpsm_addr = PORT_IO_ADDR	else
					fifo_raddr_reg + 1							when kcpsm_re = '1' and kcpsm_addr = PORT_IO_DATA	else
					fifo_raddr_reg;
	
	kcpsm_in_port <= fifo_rdata when kcpsm_ce = '1' and kcpsm_addr = PORT_IO_DATA else (others => 'Z');
	
end behave;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ethtx_queue is
	generic(
		HEAD_AWIDTH			:	natural		:=	5;
		FIFO_AWIDTH			:	natural		:=	2;
		RAM_TYPE			:	string		:=	"DIS_RAM"
		);
	port (
		clk					:	in	std_logic;
		reset				:	in	std_logic;
		--	Tx Output
		queue_empty			:	out	std_logic;
		head_raddr			:	in	std_logic_vector(HEAD_AWIDTH - 1 downto 0);
		head_rdata			:	out	std_logic_vector(7 downto 0);
		head_rd_block		:	in	std_logic;
		--	zcpsm
		zcpsm_clk			:	in	std_logic;
		zcpsm_ce			:	in	std_logic;
		zcpsm_port_id		:	in	std_logic_vector(3 downto 0);
		zcpsm_write_strobe	:	in	std_logic;
		zcpsm_out_port		:	in	std_logic_vector(7 downto 0);
		zcpsm_read_strobe	:	in	std_logic;
		zcpsm_in_port		:	out	std_logic_vector(7 downto 0)
		);
end entity;

architecture arch_ethtx_queue of ethtx_queue is
	
	component fifo_block
	generic(
		DWIDTH : INTEGER;
		BLOCK_AWIDTH : INTEGER;
		FIFO_AWIDTH : INTEGER;
		RAM_TYPE : STRING);
	port(
		clk : in std_logic;
		reset : in std_logic;
		clr : in std_logic;
		wr_block : in std_logic;
		wr_clk : in std_logic;
		wren : in std_logic;
		waddr : in std_logic_vector((BLOCK_AWIDTH-1) downto 0);
		wdata : in std_logic_vector((DWIDTH-1) downto 0);
		rd_block : in std_logic;
		rd_clk : in std_logic;
		raddr : in std_logic_vector((BLOCK_AWIDTH-1) downto 0);
		rdata : out std_logic_vector((DWIDTH-1) downto 0);
		full : out std_logic;
		empty : out std_logic);
	end component;
	
	component zcpsm2fifo
	generic(
		BLOCK_AWIDTH : INTEGER;
		DWIDTH : INTEGER);
	port(
		clk : in std_logic;
		reset : in std_logic;
		zcpsm_clk : in std_logic;
		zcpsm_ce : in std_logic;
		zcpsm_port_id : in std_logic_vector(3 downto 0);
		zcpsm_write_strobe : in std_logic;
		zcpsm_out_port : in std_logic_vector(7 downto 0);
		zcpsm_read_strobe : in std_logic;
		zcpsm_in_port : out std_logic_vector(7 downto 0);
		fifo_wr_block : out std_logic;
		fifo_wren : out std_logic;
		fifo_waddr : out std_logic_vector((BLOCK_AWIDTH-1) downto 0);
		fifo_wdata : out std_logic_vector((DWIDTH-1) downto 0);
		fifo_full : in std_logic;
		fifo_empty : in std_logic);
	end component;
	
	signal fifo_full		:	std_logic;
	signal fifo_empty		:	std_logic;
	signal fifo_wren		:	std_logic;
	signal fifo_waddr		:	std_logic_vector(HEAD_AWIDTH - 1 downto 0);
	signal fifo_wdata		:	std_logic_vector(7 downto 0);
	signal fifo_wr_block	:	std_logic;	
	
begin
	
	u_queue : fifo_block
	generic map(
		DWIDTH => 8,
		BLOCK_AWIDTH => HEAD_AWIDTH,
		FIFO_AWIDTH => FIFO_AWIDTH,
		RAM_TYPE => RAM_TYPE
		)
	port map(
		clk => clk,
		reset => reset,
		clr => '0',
		wr_block => fifo_wr_block,
		wr_clk => zcpsm_clk,
		wren => fifo_wren,
		waddr => fifo_waddr,
		wdata => zcpsm_out_port,
		rd_block => head_rd_block,
		rd_clk => clk,
		raddr => head_raddr,
		rdata => head_rdata,
		empty => fifo_empty,
		full => fifo_full
		);
	
	u_zcpsm_intf : zcpsm2fifo
	generic map(
		BLOCK_AWIDTH => HEAD_AWIDTH,
		DWIDTH => 8
		)
	port map(
		clk => clk,
		reset => reset,
		zcpsm_clk => zcpsm_clk,
		zcpsm_ce => zcpsm_ce,
		zcpsm_port_id => zcpsm_port_id,
		zcpsm_write_strobe => zcpsm_write_strobe,
		zcpsm_out_port => zcpsm_out_port,
		zcpsm_read_strobe => zcpsm_read_strobe,
		zcpsm_in_port => zcpsm_in_port,
		fifo_wr_block => fifo_wr_block,
		fifo_wren => fifo_wren,
		fifo_waddr => fifo_waddr,
		fifo_wdata => fifo_wdata,
		fifo_full => fifo_full,
		fifo_empty => fifo_empty
		);
	
	queue_empty <= fifo_empty;
	
end arch_ethtx_queue;

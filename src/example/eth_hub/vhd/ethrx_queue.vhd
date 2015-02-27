library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ethrx_queue is
	generic(
		HEAD_AWIDTH			:	natural		:=	5;
		FIFO_AWIDTH			:	natural		:=	2;
		RAM_TYPE			:	string		:=	"DIS_RAM"
		);
	port(
		clk					:	in	std_logic;
		reset				:	in	std_logic;
		--	Rx Input
		head_wren			:	in	std_logic;
		head_waddr			:	in	std_logic_vector(HEAD_AWIDTH - 1 downto 0);
		head_wdata			:	in	std_logic_vector(7 downto 0);
		head_wr_block		:	in	std_logic;
		--	KCPSM
		kcpsm_clk			:	in	std_logic;
		kcpsm_ce			:	in	std_logic;
		kcpsm_port_id		:	in	std_logic_vector(3 downto 0);
		kcpsm_write_strobe	:	in	std_logic;
		kcpsm_out_port		:	in	std_logic_vector(7 downto 0);
		kcpsm_read_strobe	:	in	std_logic;
		kcpsm_in_port		:	out	std_logic_vector(7 downto 0)
		);
end entity;

architecture arch_ethrx_queue of ethrx_queue is
	
	component fifo_block
		generic(
			DWIDTH : INTEGER; 			-- 8
			BLOCK_AWIDTH : INTEGER;	-- 5
			FIFO_AWIDTH : INTEGER;	    -- 2
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
	
	component fifo2kcpsm
		generic(
			BLOCK_AWIDTH : INTEGER;
			DWIDTH : INTEGER);
		port(
			clk : in std_logic;
			reset : in std_logic;
			kcpsm_clk : in std_logic;
			kcpsm_ce : in std_logic;
			kcpsm_port_id : in std_logic_vector(3 downto 0);
			kcpsm_write_strobe : in std_logic;
			kcpsm_out_port : in std_logic_vector(7 downto 0);
			kcpsm_read_strobe : in std_logic;
			kcpsm_in_port : out std_logic_vector(7 downto 0);
			fifo_rd_block : out std_logic;
			fifo_raddr : out std_logic_vector((BLOCK_AWIDTH-1) downto 0);
			fifo_rdata : in std_logic_vector((DWIDTH-1) downto 0);
			fifo_full : in std_logic;
			fifo_empty : in std_logic);
	end component;
	
	signal fifo_full		:	std_logic;
	signal fifo_empty		:	std_logic;
	signal fifo_raddr		:	std_logic_vector(HEAD_AWIDTH - 1 downto 0);
	signal fifo_rdata		:	std_logic_vector(7 downto 0);
	signal fifo_rd_block	:	std_logic;
	
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
		wr_block => head_wr_block,
		wr_clk => clk,
		wren => head_wren,
		waddr => head_waddr,
		wdata => head_wdata,
		rd_block => fifo_rd_block,
		rd_clk => kcpsm_clk,
		raddr => fifo_raddr,
		rdata => fifo_rdata,
		empty => fifo_empty,
		full => fifo_full
		);
	
	u_kcpsm_intf : fifo2kcpsm
	generic map(
		BLOCK_AWIDTH => HEAD_AWIDTH,
--		BLOCK_AWIDTH => 6,
		DWIDTH => 8
		)
	port map(
		clk => clk,
		reset => reset,
		kcpsm_clk => kcpsm_clk,
		kcpsm_ce => kcpsm_ce,
		kcpsm_port_id => kcpsm_port_id,
		kcpsm_write_strobe => kcpsm_write_strobe,
		kcpsm_out_port => kcpsm_out_port,
		kcpsm_read_strobe => kcpsm_read_strobe,
		kcpsm_in_port => kcpsm_in_port,
		fifo_rd_block => fifo_rd_block,
		fifo_raddr => fifo_raddr,
		fifo_rdata => fifo_rdata,
		fifo_full => fifo_full,
		fifo_empty => fifo_empty
		);
	
end arch_ethrx_queue;

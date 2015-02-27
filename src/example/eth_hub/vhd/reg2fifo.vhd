library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity reg2fifo is
	generic (
		N_REG			:	integer;	
		FIFO_DWIDTH		:	integer;
		BLOCK_AWIDTH	:	integer
		);
	port(
		clk			:	in	std_logic;
		reset		:	in	std_logic;
		ce			:	in	std_logic;
		reg			:	in	std_logic_vector(FIFO_DWIDTH * N_REG - 1 downto 0);
		reg_ce		:	in	std_logic;
		wren		:	out	std_logic;
		waddr		:	out	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);
		wdata		:	out	std_logic_vector(FIFO_DWIDTH - 1 downto 0);
		wr_block	:	out	std_logic
		);
end entity;

architecture behave of reg2fifo is
	
	signal wr_cnt : integer range 0 to N_REG;
	signal wr_ena : std_logic;
	signal wr_ena_d1 : std_logic;
	signal reg_in : std_logic_vector(FIFO_DWIDTH * N_REG - 1 downto 0);
	
begin
	
	process(clk, reset)
	begin
		if reset = '1' then
			wr_cnt <= 0;
			wr_ena <= '0';
		elsif rising_edge(clk) then
			if ce = '1' then
				if reg_ce = '1' then
					wr_cnt <= 0;				
				elsif wr_ena = '1' then
					wr_cnt <= wr_cnt + 1;
				end if;
				if reg_ce = '1' then
					wr_ena <= '1';
				elsif wr_cnt = N_REG - 1 then
					wr_ena <= '0';
				end if;
			end if;
		end if;
	end process;
	
	process(clk, reset)
	begin
		if reset = '1' then
			reg_in <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				if reg_ce = '1' then
					reg_in <= reg;
				elsif wr_ena = '1' then
					reg_in <= reg_in(FIFO_DWIDTH * (N_REG - 1) - 1 downto 0) & conv_std_logic_vector(0, FIFO_DWIDTH);
				end if;
			end if;
		end if;
	end process;
	
	process(clk, reset)
	begin
		if reset = '1' then
			wr_ena_d1 <= '0';
		elsif rising_edge(clk) then
			if ce = '1' then
				wr_ena_d1 <= wr_ena;
			end if;
		end if;
	end process;
	
	wren <= '1' when wr_ena = '1' and ce = '1' else '0';
	waddr <= conv_std_logic_vector(wr_cnt, BLOCK_AWIDTH);
	wdata <= reg_in(FIFO_DWIDTH * N_REG - 1 downto FIFO_DWIDTH * (N_REG - 1));
	wr_block <= '1' when wr_ena_d1 = '1' and wr_ena = '0' and ce = '1' else '0';
	
end behave;

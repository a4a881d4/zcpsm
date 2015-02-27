library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- ft a : wr_block and rd_block must be synchronized with clk 
entity fifo_block is
	generic (
		DWIDTH			:	integer;						-- 8
		BLOCK_AWIDTH	:	integer;					    -- 5
		FIFO_AWIDTH		:	integer;			  			-- 2
		RAM_TYPE		:	string(1 to 7)
		);
	port (
		clk				:	in	std_logic;
		reset			:	in	std_logic;		
		clr				: 	in 	std_logic;
		
		wr_block		:	in	std_logic;
		wr_clk			:	in	std_logic;
		wren			:	in	std_logic;
		waddr			:	in	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);
		wdata			:	in	std_logic_vector(DWIDTH - 1 downto 0);
		
		rd_block		:	in	std_logic;
		rd_clk			:	in	std_logic;		 -- kcpsm_clk
		raddr			:	in	std_logic_vector(BLOCK_AWIDTH - 1 downto 0);   -- 由KCPSM提供
		rdata			:	out	std_logic_vector(DWIDTH - 1 downto 0);		   -- 提供给kcpsm
		
		full			: 	out	std_logic;
		empty			: 	out	std_logic
		);
end fifo_block;

architecture behave of fifo_block is
	
	component blockdram
		generic( 
			depth:	integer;
			Dwidth: integer;
			Awidth:	integer
			);
		port(
			addra: IN std_logic_VECTOR(Awidth-1 downto 0);
			clka: IN std_logic;
			addrb: IN std_logic_VECTOR(Awidth-1 downto 0);
			clkb: IN std_logic;
			dia: IN std_logic_VECTOR(Dwidth-1 downto 0);
			wea: IN std_logic;
			dob: OUT std_logic_VECTOR(Dwidth-1 downto 0)
			);
	end component;
	
	component disdram
		generic( 
			depth:	integer;
			Dwidth: integer;
			Awidth:	integer
			);
		port(
			A: IN std_logic_VECTOR(Awidth-1 downto 0);
			CLK: IN std_logic;
			D: IN std_logic_VECTOR(Dwidth-1 downto 0);
			WE: IN std_logic;
			DPRA: IN std_logic_VECTOR(Awidth-1 downto 0);
			DPO: OUT std_logic_VECTOR(Dwidth-1 downto 0);
			QDPO: OUT std_logic_VECTOR(Dwidth-1 downto 0)
			);
	end component;
	
	signal wp_block		: 	std_logic_vector(FIFO_AWIDTH - 1 downto 0)	:= (others => '0');
	signal rp_block		: 	std_logic_vector(FIFO_AWIDTH - 1 downto 0)	:= (others => '0');
	signal ram_we		: 	std_logic	:= '0';
	signal ram_waddr	: 	std_logic_vector(FIFO_AWIDTH + BLOCK_AWIDTH - 1 downto 0)	:= (others => '0');
	signal ram_raddr	: 	std_logic_vector(FIFO_AWIDTH + BLOCK_AWIDTH - 1 downto 0)	:= (others => '0');
	signal empty_flag	:	std_logic	:= '1';
	signal full_flag	:	std_logic	:= '0';
	signal rdata_buf	:	std_logic_vector(DWIDTH - 1 downto 0);
	
	constant FIFO_DEPTH		:	natural	:= 2 ** FIFO_AWIDTH;
	constant BLOCK_DEPTH	:	natural	:= 2 ** BLOCK_AWIDTH;
	
begin
	
	use_block_ram : if RAM_TYPE = "BLK_RAM" generate
		ram : blockdram
		generic map( 
			depth	=> FIFO_DEPTH * BLOCK_DEPTH,  	
			Dwidth	=> DWIDTH,						
			Awidth	=> FIFO_AWIDTH + BLOCK_AWIDTH	
			)
		port map(
			addra	=> ram_waddr,
			clka	=> wr_clk,
			addrb	=> ram_raddr,
			clkb	=> rd_clk,
			dia		=> wdata,
			wea		=> ram_we,
			dob		=> rdata
			);
	end generate use_block_ram;
	
	use_dis_ram : if RAM_TYPE = "DIS_RAM" generate
		ram	: disdram
		generic map( 
			depth	=> FIFO_DEPTH * BLOCK_DEPTH,	 
			Dwidth	=> DWIDTH,					  	 
			Awidth	=> FIFO_AWIDTH + BLOCK_AWIDTH	 
			)
		port map(
			A		=> ram_waddr,
			CLK		=> wr_clk,
			D		=> wdata,
			WE		=> ram_we,
			DPRA	=> ram_raddr,
			DPO		=> rdata_buf,
			QDPO	=> open
			);
		
		process(rd_clk)
		begin
			if rising_edge(rd_clk) then
				rdata <= rdata_buf;
			end if;
		end process;
	end generate use_dis_ram;
	
	g_multi_block : if FIFO_AWIDTH > 0 generate
		
		ram_we <= wren and (not full_flag);					-- ram_write_enable
		ram_waddr <= wp_block & waddr;						-- ram_write_addr
		ram_raddr <= rp_block & raddr;						-- ram_read_addr
		
		WritePointerCtrl : process(clk, reset)				-- 校验错误时包丢弃
		begin
			if reset = '1' then
				wp_block <= (others => '0');
			elsif rising_edge(clk) then
				if clr = '1' then
					wp_block <= (others => '0');
				elsif full_flag = '0' and wr_block = '1' then 		-- 非满时，一个以太包发送完毕写数据块地址加1
					wp_block <= wp_block + 1;
				end if;
			end if;
		end process;
			
		ReadPointerCtrl : process(clk, reset)
		begin
			if reset = '1' then
				rp_block <= (others => '0');
			elsif rising_edge(clk) then
				if clr = '1' then
					rp_block <= (others => '0');
				elsif empty_flag = '0' and rd_block = '1' then		-- 非空时，读数据块地址加1
					rp_block <= rp_block + 1;
				end if;
			end if;
		end process;
		
		GetEmptyFlag : process(clk, reset)
		begin
			if reset = '1' then
				empty_flag <= '1';
			elsif rising_edge(clk) then
				if clr = '1' then
					empty_flag <= '1';
				elsif (wp_block = rp_block) and (wr_block = '1') then    
					empty_flag <= '0';
				elsif (wp_block = rp_block + 1) and (rd_block = '1'and wr_block = '0') then
					empty_flag <= '1';
				end if;
			end if;
		end process;
		
		empty <= empty_flag;
		
		GetFullFlag : process(clk, reset)		          
		begin
			if reset = '1' then
				full_flag <= '0';
			elsif rising_edge(clk) then
				if clr = '1' then
					full_flag <= '0';
				elsif (wp_block = rp_block - 1) and (wr_block = '1' and rd_block = '0') then
					full_flag <= '1';
				elsif (wp_block = rp_block) and (rd_block = '1') then
					full_flag <= '0';
				end if;
			end if;
		end process;
		
		full <= full_flag;
		
	end generate;
	
	g_single_block : if FIFO_AWIDTH = 0 generate
		
		ram_we <= wren and (not full_flag);
		ram_waddr <= waddr;
		ram_raddr <= raddr;
		
		GetEmptyFlag : process(clk, reset)
		begin
			if reset = '1' then
				empty_flag <= '1';
			elsif rising_edge(clk) then
				if clr = '1' then
					empty_flag <= '1';
				elsif wr_block = '1' then
					empty_flag <= '0';
				elsif rd_block = '1'and wr_block = '0' then
					empty_flag <= '1';
				end if;
			end if;
		end process;
		
		empty <= empty_flag;
		
		GetFullFlag : process(clk, reset)
		begin
			if reset = '1' then
				full_flag <= '0';
			elsif rising_edge(clk) then
				if clr = '1' then
					full_flag <= '0';
				elsif wr_block = '1' and rd_block = '0' then
					full_flag <= '1';
				elsif rd_block = '1' then
					full_flag <= '0';
				end if;
			end if;
		end process;
		
		full <= full_flag;
		
	end generate;
	
end behave;

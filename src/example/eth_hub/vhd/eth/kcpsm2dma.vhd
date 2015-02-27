library ieee;
use ieee.std_logic_1164.all;

entity kcpsm2dma is
	generic	(
		RAM_AWIDTH			:	natural
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
		
		lastframe_flag		:	out std_logic;
		
		start				:	out	std_logic;
		length				:	out	std_logic_vector(15 downto 0);
		start_waddr			:	out	std_logic_vector(RAM_AWIDTH - 1 downto 0);
		start_raddr			:	out	std_logic_vector(RAM_AWIDTH - 1 downto 0);
		wstep				:	out	std_logic_vector(7 downto 0);
		rstep				:	out	std_logic_vector(7 downto 0);
		busy				:	in	std_logic
		);
end entity;

architecture behave of kcpsm2dma is

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
	
	constant PORT_DMA_START		:	std_logic_vector(3 downto 0)	:=	X"0";
	constant PORT_DMA_LENGTH_0	:	std_logic_vector(3 downto 0)	:=	X"1";
	constant PORT_DMA_LENGTH_1	:	std_logic_vector(3 downto 0)	:=	X"2";
	constant PORT_DMA_RADDR_0	:	std_logic_vector(3 downto 0)	:=	X"3";
	constant PORT_DMA_RADDR_1	:	std_logic_vector(3 downto 0)	:=	X"4";
	constant PORT_DMA_RADDR_2	:	std_logic_vector(3 downto 0)	:=	X"5";
	constant PORT_DMA_RADDR_3	:	std_logic_vector(3 downto 0)	:=	X"6";	
	constant PORT_DMA_WADDR_0	:	std_logic_vector(3 downto 0)	:=	X"7";
	constant PORT_DMA_WADDR_1	:	std_logic_vector(3 downto 0)	:=	X"8";
	constant PORT_DMA_WADDR_2	:	std_logic_vector(3 downto 0)	:=	X"9"; 
	constant PORT_DMA_WADDR_3	:	std_logic_vector(3 downto 0)	:=	X"A"; 	
	constant PORT_DMA_RSTEP		:	std_logic_vector(3 downto 0)	:=	X"B";
	constant PORT_DMA_WSTEP		:	std_logic_vector(3 downto 0)	:=	X"C";
	constant PORT_DMA_BUSY		:	std_logic_vector(3 downto 0)	:=	X"D"; 
	
	constant PORT_RX_LAST_FRAME	:	std_logic_vector(3 downto 0)	:=	X"E";
	
	signal kcpsm_we		:	std_logic;
	signal kcpsm_re		:	std_logic;
	signal kcpsm_addr	:	std_logic_vector(3 downto 0);
	signal start_en		:	std_logic;
	
begin
	
	kcpsm_we <= kcpsm_ce and kcpsm_write_strobe;
	kcpsm_re <= kcpsm_ce and kcpsm_read_strobe;
	kcpsm_addr <= kcpsm_port_id(3 downto 0);

	kcpsm_in_port <= "0000000" & busy when kcpsm_ce = '1' and kcpsm_addr = PORT_DMA_BUSY else (others => 'Z');
	
	WriteIO : process(kcpsm_clk, reset)
	begin
		if reset = '1' then
			wstep <= X"01";
			rstep <= X"01";
			length <= (others => '0');
			start_raddr <= (others => '0');
			start_waddr <= (others => '0');
		elsif rising_edge(kcpsm_clk) then			
			if kcpsm_we = '1' then
				case kcpsm_addr is
					when PORT_DMA_LENGTH_0	=>	length(7 downto 0) <= kcpsm_out_port;
					when PORT_DMA_LENGTH_1	=>	length(15 downto 8) <= kcpsm_out_port;
					when PORT_DMA_RADDR_0	=>	start_raddr(7 downto 0) <= kcpsm_out_port;
					when PORT_DMA_RADDR_1	=>	start_raddr(15 downto 8) <= kcpsm_out_port;
					when PORT_DMA_RADDR_2	=>	start_raddr(23 downto 16) <= kcpsm_out_port;
					when PORT_DMA_RADDR_3	=>	start_raddr(31 downto 24) <= kcpsm_out_port;
					when PORT_DMA_WADDR_0	=>	start_waddr(7 downto 0) <= kcpsm_out_port;
					when PORT_DMA_WADDR_1	=>	start_waddr(15 downto 8) <= kcpsm_out_port;
					when PORT_DMA_WADDR_2	=>	start_waddr(23 downto 16) <= kcpsm_out_port;
					when PORT_DMA_WADDR_3	=>	start_waddr(31 downto 24) <= kcpsm_out_port;
					when PORT_DMA_RSTEP		=>	rstep <= kcpsm_out_port;
					when PORT_DMA_WSTEP		=>	wstep <= kcpsm_out_port;
					when others => null;
				end case;
			end if;
		end if;
	end process;
	
	u_start : asyncwrite
	port map(
		reset => reset,
		async_clk => kcpsm_clk,
		sync_clk => clk,
		async_wren => start_en,
		trigger => '1',
		sync_wren => start,
		over => open,
		flag => open
		);
	
	start_en <= '1' when kcpsm_we = '1' and kcpsm_addr = PORT_DMA_START else '0';
	lastframe_flag <= '1' when kcpsm_we = '1' and kcpsm_addr = PORT_RX_LAST_FRAME else '0';
		
end behave;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;  

use work.Eth_TestSig_Cfg.all;

entity ethrx_input_RMII is
	generic(
		HEAD_AWIDTH		:	natural		:=	5;		-- ���ն��е�ַ��� 2^5 = 32 �ֽ�
		BUFF_AWIDTH		:	natural		:=	16 		-- BUFF16λ��ַ��
		);
	port( 
--		test_crc		:	out std_logic_vector(3 downto 0);
	
		clk				:	in	std_logic;	    -- FPGAʱ��
		reset			:	in	std_logic;		
		rmii_refclk		:	in	std_logic;
		rxclk			:	in	std_logic; 	-- MII���ʱ��
		rxd				:	in	std_logic_vector(3 downto 0);	 -- �����������ݣ�4bitΪ��λ��nipple��
		rxdv			:	in	std_logic;	          -- ��RXDV='1'������¼�⵽"5..5D"����ʾһ����̫���Ŀ�ʼ
		
		recvtime 		:	out std_logic_vector(31 downto 0);
		recvtime_valid	:	out	std_logic; 
		localtime_locked:	out std_logic;
		
		head_wren		:	out	std_logic;		
		head_waddr		:	out	std_logic_vector(HEAD_AWIDTH - 1 downto 0);	 --ÿһ������0��ʼ��������
		head_wdata		:	out	std_logic_vector(7 downto 0);
		head_wr_block	:	out	std_logic;			--  ָʾCRC�����'1'��ʾ��ȷ��'0'��ʾ����ȷ	  
		buff_wren		:	out	std_logic;
		buff_waddr		:	out	std_logic_vector(BUFF_AWIDTH - 1 downto 0);	  
		buff_wdata		:	out	std_logic_vector(7 downto 0)	 --  ��̫�����ݰ��ֽ�д����д��ַ���ϴ�д��ַ��ĩβ������������̫��ͷ 
		
		);
end ethrx_input_RMII;

architecture arch_ethrx_input_RMII of ethrx_input_RMII is
	
	component fifo_async
	generic(
		DEPTH : NATURAL;
		AWIDTH : NATURAL;
		DWIDTH : NATURAL;
		RAM_TYPE : STRING);
	port(
		reset : in std_logic;
		clr : in std_logic;
		clka : in std_logic;
		wea : in std_logic;
		dia : in std_logic_vector((DWIDTH-1) downto 0);
		clkb : in std_logic;
		rdb : in std_logic;
		dob : out std_logic_vector((DWIDTH-1) downto 0);
		empty : out std_logic;
		full : out std_logic;
		dn : out std_logic_vector((AWIDTH-1) downto 0));
	end component;
	for all: fifo_async use entity WORK.fifo_async(fast_read);

	component shiftreg
	generic(
		width : INTEGER;
		depth : INTEGER);
	port(
		clk : in std_logic;
		ce : in std_logic;
		D : in std_logic_vector((width-1) downto 0);
		Q : out std_logic_vector((width-1) downto 0);
		S : out std_logic_vector((width-1) downto 0));
	end component;
	
	component crcrom
	port(
		addr : in std_logic_vector(3 downto 0);
		dout : out std_logic_vector(31 downto 0));
	end component;
	
	constant INFO_LENGTH	:	natural		:=	4;	  		
	constant HEAD_LENGTH	:	natural		:=	2 ** HEAD_AWIDTH - INFO_LENGTH;
	
	signal rxdv_buf			:	std_logic;
	signal rxd_buf			:	std_logic_vector(3 downto 0);
	signal d_ext			:	std_logic_vector(4 downto 0);
	signal rxdv_int			:	std_logic;
	signal rxd_int			:	std_logic_vector(3 downto 0);
	signal d_int			:	std_logic_vector(4 downto 0);	
	signal ce				:	std_logic;
	signal rd_ena			:	std_logic;
	signal empty			:	std_logic;
	
	signal rx_state			:	std_logic_vector(1 downto 0);
	signal nibble_cnt		:	std_logic_vector(11 downto 0);	    
	
	signal rxd_int_d1		:	std_logic_vector(3 downto 0);
	signal rxd_int_d2		:	std_logic_vector(3 downto 0);
	signal byte_data		:	std_logic_vector(7 downto 0);
	
	signal buff_wren_buf	:	std_logic;
	signal buff_waddr_buf	:	std_logic_vector(BUFF_AWIDTH - 1 downto 0);
	
	signal crc_din			:	std_logic_vector(3 downto 0);
	signal crc_reg			:	std_logic_vector(31 downto 0);
	signal crcrom_addr		:	std_logic_vector(3 downto 0);
	signal crcrom_dout		:	std_logic_vector(31 downto 0);
	signal crc_flag			:	std_logic;
	
	signal info_cnt			:	integer range 0 to INFO_LENGTH;
	signal info_ena			:	std_logic;
	
	signal start_addr		:	std_logic_vector(15 downto 0);
	signal length			:	std_logic_vector(15 downto 0);
	
	signal head_wren_buf	:	std_logic;
	signal head_waddr_buf	:	std_logic_vector(HEAD_AWIDTH - 1 downto 0);
	signal head_wr_block_buf:	std_logic;
	
	signal rxclk_temp		:	std_logic;	
	signal localtime_locked_reg:	std_logic;
	
begin	  
	
 	
--	process(clk)
--	begin											 
--		if rising_edge(clk) then  
--			if info_ena = '1' then
--				test_crc(0) <=  crc_flag;    
--				test_crc(1) <=  crc_reg(2);  
--				test_crc(2) <=  crc_reg(4);    
--				test_crc(3) <=  crc_reg(8);      				
--			end if;
--		end if;
--	end process;
		
		
		
--	p_mii_din : process(rxclk)				   -- MII->ETH-RX �������ݻ���
--	begin
----		if rising_edge(rxclk) then
--		if falling_edge(rxclk) then
--			rxdv_buf <= rxdv;
--			rxd_buf <= rxd;
--		end if;
--	end process;
	
--	rxclk_temp	<= not rxclk;
			rxdv_buf <= rxdv;
			rxd_buf <= rxd;
	
	u_din_sync : fifo_async
	generic map(
		DEPTH => 4,
		AWIDTH => 2,
		DWIDTH => 5,
		RAM_TYPE => "DIS_RAM")
	port map(
		reset => reset,
		clr => '0',
		clka => rmii_refclk,
		wea => rxclk,
		dia => d_ext,
		clkb => clk,
		rdb => rd_ena,
		dob => d_int,
		empty => empty,
		full => open,
		dn => open
		);
			
	d_ext <= rxdv_buf & rxd_buf;				
	rxdv_int <= d_int(4);
	rxd_int <= d_int(3 downto 0);
	rd_ena <= not empty;
	
	p_ce : process(clk)
	begin
		if rising_edge(clk) then
			ce <= rd_ena;
		end if;
	end process;
	
	------------------------------------------------------------------------------
	
	p_state_machine : process(clk, reset)
	begin
		if reset = '1' then
			rx_state <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				case rx_state is
					when "00" =>
						if rxdv_int = '1' and rxd_int = "0101" then
							rx_state <= "01";
						else
							rx_state <= "00";
						end if;
					when "01" =>
						if rxdv_int = '1' then	   			
							if rxd_int = "1101" then
								rx_state <= "10";
							elsif rxd_int = "0101" then
								rx_state <= "01";
							else
								rx_state <= "00";
							end if;
						else
							rx_state <= "00";
						end if;
					when "10" =>
						if rxdv_int = '1' then
							rx_state <= "11";
						end if;
					when "11" =>
						if rxdv_int = '0' then
							rx_state <= "00";
						end if;
					when others	=>
						NULL;
				end case;
			end if;
		end if;
	end process;
		
	p_nibble_cnt : process(clk, reset)				-- nibble count
	begin
		if reset = '1' then
			nibble_cnt <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				if rx_state = "00" then
					nibble_cnt <= (others => '0');
				elsif rx_state = "11" then
					nibble_cnt <= nibble_cnt + 1;
				end if;
			end if;
		end if;
	end process;
	
	p_s2p : process(clk, reset)
	begin
		if reset = '1' then
			rxd_int_d1 <= (others => '0');
			rxd_int_d2 <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				rxd_int_d1 <= rxd_int;
				rxd_int_d2 <= rxd_int_d1;
			end if;
		end if;
	end process;
	
	byte_data <= rxd_int_d1 & rxd_int_d2;
	
	------------------------------------------------------------------------------ 
	
	p_recvtime	:	process(clk, reset)
	begin
		if reset = '1' then
			recvtime(31 downto 0) <= (others => '0');
			recvtime_valid <= '0';
		elsif rising_edge(clk) then
			if ce = '1' then
				case nibble_cnt is 
					when X"01B" => recvtime(27 downto 24) <= rxd_int;
					when X"01c" => recvtime(31 downto 28) <= rxd_int; 
					when X"01d" => recvtime(19 downto 16) <= rxd_int;
					when X"01e" => recvtime(23 downto 20) <= rxd_int;
					when X"01f" => recvtime(11 downto 8) <= rxd_int;
					when X"020" => recvtime(15 downto 12) <= rxd_int;
					when X"021" => recvtime(3 downto 0) <= rxd_int;
					when X"022" => recvtime(7 downto 4) <= rxd_int;
					when X"023" => recvtime_valid <= '1'; 
					when others => 	recvtime_valid <= '0';
				end case;
			end if;
		end if;			
	end process; 
	
	p_localtime_locked	:	process(clk, reset)
	begin
		if reset = '1' then
			localtime_locked_reg <= '0';
		elsif rising_edge(clk) then
			if ce = '1' and rx_state = "10" and localtime_locked_reg = '0' then
				localtime_locked_reg <= '1';   
			elsif localtime_locked_reg = '1' then 
				localtime_locked_reg <= '0';
			end if;
		end if;			
	end process; 	
	
	localtime_locked <= localtime_locked_reg;
	------------------------------------------------------------------------------
	
	p_buff_wren : process(clk, reset)							
	begin
		if reset = '1' then
			buff_wren_buf <= '0';
		elsif rising_edge(clk) then
			if ce = '1' then
				if nibble_cnt(0) = '1' and rx_state = "11" then	 		-- 2nibbleдʹ�ܣ�
					buff_wren_buf <= '1';
				else
					buff_wren_buf <= '0';
				end if;
			end if;
		end if;
	end process;
	
	p_buff_waddr : process(clk, reset)
	begin
		if reset = '1' then
			buff_waddr_buf <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				if buff_wren_buf = '1' then
					buff_waddr_buf <= buff_waddr_buf + 1;					-- buffer address ++
				end if;
			end if;
		end if;
	end process;
	
	p_buff_wdata : process(clk, reset)
	begin
		if reset = '1' then
			buff_wdata <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				buff_wdata <= byte_data;
			end if;
		end if;
	end process;
	
	buff_wren <= buff_wren_buf and ce;
	buff_waddr <= buff_waddr_buf;
	
	------------------------------------------------------------------------------
	
	u_crc_rom : CRCRom
	port map(
		addr => crcrom_addr,
		dout => crcrom_dout
		);
	
	crcrom_addr <= crc_reg(31 downto 28);
	
	p_calc_crc : process(clk, reset)
	begin
		if reset = '1' then
			crc_din <= (others => '0');
			crc_reg <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				if nibble_cnt < 7 then
					crc_din <= not (rxd_int(0) & rxd_int(1) & rxd_int(2) & rxd_int(3));
				else
					crc_din <= rxd_int(0) & rxd_int(1) & rxd_int(2) & rxd_int(3);
				end if;
				
				if rx_state = "10" then
					crc_reg <= (others => '0');
				elsif rx_state = "11" then
					crc_reg <= (crc_reg(27 downto 0) & crc_din) xor crcrom_dout;
				end if;
			end if;
		end if;
	end process;
	
	p_crc_flag : process(clk, reset)
	begin
		if reset = '1' then
			crc_flag <= '0'; 
			g_Test_EthRec_CRCFlag	<= '0';
		elsif rising_edge(clk) then
			if ce = '1' then
				if rx_state = "00" and crc_reg = X"FFFFFFFF" then
					crc_flag <= '1';
				elsif rx_state = "10" then
					crc_flag <= '0';
				end if;
			end if;	 
			g_Test_EthRec_CRCFlag <= crc_flag;
		end if;
	end process;
	
	------------------------------------------------------------------------------
	
	p_start_addr : process(clk, reset)
	begin
		if reset = '1' then
			start_addr <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				if rx_state = "10" then
					start_addr <= EXT(buff_waddr_buf, 16);	  --  ����CRC��ַ
				end if;
			end if;
		end if;
	end process;
	
	p_length : process(clk, reset)
	begin
		if reset = '1' then
			length <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				if rx_state = "11" and rxdv_int = '0' then
					length <= "00000" & nibble_cnt(11 downto 1) - 3;   -- ���ݳ��ȣ�����4Bytes CRCУ��
				end if;
			end if;
		end if;
	end process;
	
	p_info_cnt : process(clk, reset)
	begin
		if reset = '1' then
			info_ena <= '0';
			info_cnt <= 0;
		elsif rising_edge(clk) then
			if ce = '1' then
				if rx_state = "11" and rxdv_int = '0' then
					info_ena <= '1';
				elsif info_cnt = INFO_LENGTH - 1 then
					info_ena <=	'0';
				end if;
				if info_ena = '0' then
					info_cnt <= 0;
				else
					info_cnt <= info_cnt + 1;
				end if;
			end if;
		end if;
	end process;
	
	------------------------------------------------------------------------------
	
	p_head_wren : process(clk, reset)
	begin
		if reset = '1' then
			head_wren_buf <= '0';
		elsif rising_edge(clk) then
			if ce = '1' then
				if (nibble_cnt(0) = '1' and rx_state = "11" and rxdv_int = '1' and nibble_cnt(11 downto 1) < HEAD_LENGTH) or info_ena = '1' then	  -- ǰ32���ֽ�дʱ���Լ����д��ַ�볤��4�ֽ�ʱΪ1
					head_wren_buf <= '1';
				else
					head_wren_buf <= '0';
				end if;
			end if;
		end if;
	end process;
	
	p_head_waddr : process(clk, reset)
	begin
		if reset = '1' then
			head_waddr_buf <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				if rx_state = "10" then
					head_waddr_buf <= conv_std_logic_vector(INFO_LENGTH, HEAD_AWIDTH);
				elsif rx_state = "11" and rxdv_int = '0' then
					head_waddr_buf <= conv_std_logic_vector(0, HEAD_AWIDTH);
				elsif head_wren_buf = '1' then
					head_waddr_buf <= head_waddr_buf + 1;
				end if;
			end if;
		end if;
	end process;
	
	p_head_wdata : process(clk, reset)
	begin
		if reset = '1' then
			head_wdata <= (others => '0');
		elsif rising_edge(clk) then
			if ce = '1' then
				if info_ena = '1' then
					case info_cnt is
						when 0 => head_wdata <= length(7 downto 0);
						when 1 => head_wdata <= length(15 downto 8);
						when 2 => head_wdata <= start_addr(7 downto 0);
						when 3 => head_wdata <= start_addr(15 downto 8);
						when others => null;
					end case;
				else
					head_wdata <= byte_data;
				end if;
			end if;
		end if;
	end process;
	
	head_wren <= head_wren_buf and ce;
	head_waddr <= head_waddr_buf;
	
	p_head_wr_block : process(clk, reset)
	begin
		if reset = '1' then
			head_wr_block_buf <= '0';
		elsif rising_edge(clk) then
			if ce = '1' then
				if info_cnt = INFO_LENGTH and crc_flag = '1' then 		-- crcУ����ȷ
					head_wr_block_buf <= '1';
				else
					head_wr_block_buf <= '0';
				end if;
			end if;
		end if;
	end process;
	
	head_wr_block <= head_wr_block_buf and ce;		   -- crcУ��ָ��
	
end arch_ethrx_input_RMII;

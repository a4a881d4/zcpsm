---------------------------------------------------------------------------------------------------
--
-- Title       : zcpsmProgRam
-- Design      : eth_new
-- Author      : a4a881d4
-- Company     : a4a881d4
--
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use std.textio.all;

entity zcpsmProgRam is
	generic (
		AWIDTH	: natural := 10;
		PROG	: string := "program.bit"
	);
	port (
		clk : in std_logic;
		reset: in std_logic;
		
		addr : in std_logic_vector( AWIDTH-1 downto 0 );
		dout : out std_logic_vector( 17 downto 0 );
		soft_rst : out std_logic;
		
		prog_we	: in std_logic;
		prog_clk: in std_logic;
		prog_addr : in std_logic_vector( AWIDTH-1 downto 0 );
		prog_din : in std_logic_vector( 17 downto 0 )
	);
end zcpsmProgRam;
 
architecture syn of zcpsmProgRam is
 
	type RamType is array( 0 to (2**AWIDTH-1) ) of bit_vector( 17 downto 0 );
	impure function InitRamFromFile (RamFileName : in string) return RamType is
            FILE RamFile    : text is in RamFileName;
            variable RamFileLine : line;
            variable RAM    : RamType;
            begin
            for I in RamType'range loop
                readline (RamFile, RamFileLine);
                read (RamFileLine, RAM(I));
            end loop;
            return RAM;
        end function;
	signal RAM : RamType := InitRamFromFile(PROG);
	signal soft_rst_i : std_logic;
	signal ones : std_logic_vector( 31 downto 0 );
begin

	soft_rst <= soft_rst_i;
	ones <= ( others=>'0' );
	
	process( clk, reset )
	begin
		if reset='1' then
			dout <= ( others=>'0' );
		elsif clk'event and clk = '1' then
			dout <= to_stdlogicvector(RAM(conv_integer(addr)));
		end if;
	end process;

	program : process (prog_clk)
	begin
		if prog_clk'event and prog_clk = '1' then
			if prog_we = '1' then 
				RAM(conv_integer(prog_addr)) <= to_bitvector(prog_din);
			end if;
		end if;
	end process;

	soft_reset : process( prog_clk, reset )
	begin
		if reset='1' then
			soft_rst_i <= '0';
		elsif prog_clk'event and prog_clk = '1' then
			if prog_we = '1' and prog_addr = ones( AWIDTH-1 downto 0 ) then 
				soft_rst_i <= prog_din(0);
			end if;
		end if; 
	end process;
	
end syn;

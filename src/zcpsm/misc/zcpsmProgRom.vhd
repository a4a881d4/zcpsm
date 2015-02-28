---------------------------------------------------------------------------------------------------
--
-- Title       : zcpsmProgRom
-- Design      : eth_new
-- Author      : a4a881d4
-- Company     : a4a881d4
--
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use std.textio.all;

entity zcpsmProgRom is
	generic (
		AWIDTH	: natural := 10;
		PROG	: string := "program.bit"
	);
	port (
		clk : in std_logic;
		addr : in std_logic_vector( AWIDTH-1 downto 0 );
		dout : out std_logic_vector( 17 downto 0 )
	);
end zcpsmProgRom;
 
architecture syn of zcpsmProgRom is
 
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
	begin
	process (clk)
	begin
		if clk'event and clk = '1' then
			dout <= to_stdlogicvector(RAM(conv_integer(addr)));
		end if;
	end process;
 
end syn;

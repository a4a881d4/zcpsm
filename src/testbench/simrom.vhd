----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/03/01 00:47:15
-- Design Name: 
-- Module Name: simrom - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simrom is
    Port ( clk : in STD_LOGIC);
end simrom;

architecture Behavioral of simrom is
signal addr : std_logic_vector( 9 downto 0 ):=(others=>'0');
signal dout : std_logic_vector( 17 downto 0 );

component zcpsmProgRom
	generic (
		AWIDTH	: natural := 10;
		PROG	: string := "program.bit"
	);
	port (
		clk : in std_logic;
		addr : in std_logic_vector( AWIDTH-1 downto 0 );
		dout : out std_logic_vector( 17 downto 0 )
	);
end component;

begin

arom : zcpsmProgRom
    generic map(
        AWIDTH => 10,
        PROG => "E:\zhaom\works\zcpsm\.work\ethtxrom.bit"
        )
    port map(
        clk => clk,
        addr => addr,
        dout => dout
    );

process(clk)
begin
    if clk'event and clk = '1' then
        addr<=addr+1;
    end if;
end process;
end Behavioral;

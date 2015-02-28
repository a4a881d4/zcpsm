library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity crcrom is
	port(
		addr	:	in	std_logic_vector(3 downto 0);
		dout	:	out	std_logic_vector(31 downto 0)
		);
end entity;

architecture behavior of crcrom is
	
	type array16x32 is array(0 to 15) of std_logic_vector(31 downto 0);
	constant data_array	:	array16x32	:=	(
	"00000000000000000000000000000000",
	"00000100110000010001110110110111",
	"00001001100000100011101101101110",
	"00001101010000110010011011011001",
	"00010011000001000111011011011100",
	"00010111110001010110101101101011",
	"00011010100001100100110110110010",
	"00011110010001110101000000000101",
	"00100110000010001110110110111000",
	"00100010110010011111000000001111",
	"00101111100010101101011011010110",
	"00101011010010111100101101100001",
	"00110101000011001001101101100100",
	"00110001110011011000011011010011",
	"00111100100011101010000000001010",
	"00111000010011111011110110111101");
	
begin
	
	dout <= data_array(conv_integer(addr));
	
end behavior;
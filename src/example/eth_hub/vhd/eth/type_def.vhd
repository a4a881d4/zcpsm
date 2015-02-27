library ieee;
use ieee.std_logic_1164.all;

package type_def is

	type std_logic_vector19_array is array(integer range<>) of std_logic_vector(18 downto 0);
	type std_logic_vector18_array is array(integer range<>) of std_logic_vector(17 downto 0);
	type std_logic_vector16_array is array(integer range<>) of std_logic_vector(15 downto 0);
	type std_logic_vector8_array is array(integer range<>) of std_logic_vector(7 downto 0);

end package;

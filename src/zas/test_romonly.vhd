library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
ENTITY test_romonly IS
	port (		addrb: IN std_logic_VECTOR(9 downto 0);
		clkb: IN std_logic;
		dob: OUT std_logic_VECTOR(15 downto 0)	:= (others => '0')
	);
end test_romonly;
architecture behavior of test_romonly is
signal addr : std_logic_vector(11 downto 0):=(others=>'0');
begin
	addr<="00"&addrb;
process(clkb)
begin
	if clkb'event and clkb='1' then
		case addr is
			when X"000" => dob<=X"0300";
			when X"001" => dob<=X"0201";
			when X"002" => dob<=X"0F00";
			when X"003" => dob<=X"C020";
			when X"004" => dob<=X"6001";
			when X"005" => dob<=X"9408";
			when X"006" => dob<=X"4301";
			when X"007" => dob<=X"8009";
			when X"008" => dob<=X"6301";
			when X"009" => dob<=X"C020";
			when X"00A" => dob<=X"6001";
			when X"00B" => dob<=X"940E";
			when X"00C" => dob<=X"4301";
			when X"00D" => dob<=X"800F";
			when X"00E" => dob<=X"6301";
			when X"00F" => dob<=X"8800";
			when others => dob<=X"0000";
		end case;
	end if;
end process;
end behavior;

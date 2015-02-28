library ieee;
use ieee.std_logic_1164.all;

entity zcpsmDecode is
	port (
	port_id		: in std_logic_vector(7 downto 4);
	ce 			: out std_logic_vector(15 downto 0)
	);
end zcpsmDecode;

architecture behave of zcpsmDecode is
begin
	decode : process( port_id )
	begin 
		case port_id is
            when X"0" => ce <= X"0001";
            when X"1" => ce <= X"0002";
            when X"2" => ce <= X"0004";
            when X"3" => ce <= X"0008";
            when X"4" => ce <= X"0010";
            when X"5" => ce <= X"0020";
            when X"6" => ce <= X"0040";
            when X"7" => ce <= X"0080";
            when X"8" => ce <= X"0100";
            when X"9" => ce <= X"0200";
            when X"A" => ce <= X"0400";
            when X"B" => ce <= X"0800";
            when X"C" => ce <= X"1000";
            when X"D" => ce <= X"2000";
            when X"E" => ce <= X"4000";
            when X"F" => ce <= X"8000";
            when others => ce <= X"0000";
         end case;
	end process;
end behave;
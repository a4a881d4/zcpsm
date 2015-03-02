library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity zOutReg is
	generic (
		port_ixd : natural := 0
	);
	port (
		zClk					: in std_logic;
		port_ce				: in std_logic;
		port_id				: in std_logic_vector(3 downto 0);
		write_strobe	: in std_logic;
		out_port			: in std_logic_vector(7 downto 0);

		Q							: out std_logic_vector(7 downto 0)
	);
end zOutReg;

architecture behave of zOutReg is
begin
	RegOut : process( zClk )
	begin 
		if zClk'event and zClk='1' then
			if port_ce='1' and port_id = conv_std_logic_vector(port_ixd) and write_strobe = '1' then
				Q <= out_port;
			end if;
		end if;
	end process;
end behave;
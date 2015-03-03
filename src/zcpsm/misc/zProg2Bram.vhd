library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity zProg2Bram is
  port (
    BRAM_PORTA_addr : in STD_LOGIC_VECTOR ( 12 downto 0 );
    BRAM_PORTA_clk : in STD_LOGIC;
    BRAM_PORTA_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_en : in STD_LOGIC;
    BRAM_PORTA_rst : in STD_LOGIC;
    BRAM_PORTA_we : in STD_LOGIC_VECTOR ( 3 downto 0 );
    
	prog_we	: out std_logic;
	prog_clk	: out std_logic;
	prog_addr : out std_logic_vector( 9 downto 0 );
	prog_din : out std_logic_vector( 17 downto 0 )

  );
end zProg2Bram;

architecture STRUCTURE of zProg2Bram is
begin
	prog_clk <= BRAM_PORTA_clk;
	prog_addr <= BRAM_PORTA_addr( 11 downto 2 );
	prog_we <= BRAM_PORTA_en when (BRAM_PORTA_addr( 1 downto 0) = "00") and ( BRAM_PORTA_we = "1111" ) else '0'; 
	prog_din <= BRAM_PORTA_din( 17 downto 0 );
	
end STRUCTURE;

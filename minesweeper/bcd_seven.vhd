library ieee;
use ieee.std_logic_1164.all;
 
entity bcd_seven is
	port(bcd: in std_logic_vector(3 downto 0);
			H0: out std_logic_vector(6 downto 0));
end bcd_seven;

architecture behavioral of bcd_seven is
	begin
		  with bcd select H0 <=
								 "1000000" when "0000",
								 "1111001" when "0001",
								 "0100100" when "0010",
								 "0110000" when "0011",
								 "0011001" when "0100",
								 "0010010" when "0101",
								 "0000010" when "0110",
								 "1111000" when "0111",
								 "0000000" when "1000",
								 "0010000" when "1001",
								 "0111111" when others;
end behavioral;
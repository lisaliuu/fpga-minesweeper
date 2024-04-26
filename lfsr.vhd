library ieee; 
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity lfsr is 
generic(
  G_M             : integer           := 10          ;
  G_POLY          : std_logic_vector  := "0001100010") ;  -- x^7+x^6+1 
port (
  i_clk           : in  std_logic;
  --async_reset          : in  std_logic;
  enable            : in  std_logic;
  seed          : in  std_logic_vector (G_M-1 downto 0);
  outputLSFR          : out std_logic_vector (G_M-1 downto 0));
end lfsr;
architecture rtl of lfsr is  
signal r_lfsr           : std_logic_vector (G_M downto 1);
signal w_mask           : std_logic_vector (G_M downto 1);
signal w_poly           : std_logic_vector (G_M downto 1);
signal set_seed			: std_logic  := '0';
signal stuck				: std_logic_vector (G_M downto 1) := (others => '0');

begin
outputLSFR  <= r_lfsr(G_M downto 1);
w_poly  <= G_POLY;
g_mask : for k in G_M downto 1 generate
  w_mask(k)  <= w_poly(k) and r_lfsr(1);
end generate g_mask;
p_lfsr : process (i_clk) begin
--p_lfsr : process (i_clk,async_reset) begin 
  --if (async_reset = '0') then 
    --r_lfsr   <= seed;
	if (set_seed = '0' or unsigned(r_lfsr) = unsigned(stuck)) then
		r_lfsr <= seed;
		set_seed <= '1';
  elsif rising_edge(i_clk) then 
    if (enable = '1') then 
      r_lfsr   <= '0'&r_lfsr(G_M downto 2) xor w_mask;
    end if; 
  end if; 
end process p_lfsr; 
end architecture rtl;
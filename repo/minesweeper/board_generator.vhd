-------------------------------------------------------------------------------
--
-- Project					: VGA_ColorBar
-- File name				: VGA_ColorBar.vhd
-- Title						: VGA display test colors
-- Description				:  
--								: 
-- Design library			: N/A
-- Analysis Dependency	: VGA_SYNC.vhd
-- Simulator(s)			: ModelSim-Altera version 6.1g
-- Initialization			: none
-- Notes						: This model is designed for synthesis
--								: Compile with VHDL'93
--
-------------------------------------------------------------------------------
--
-- Revisions
--			Date		Author			Revision		Comments
--		3/11/2008		W.H.Robinson	Rev A			Creation
--		3/13/2012		W.H.Robinson	Rev B			Update for DE2-115 Board
--
--			
-------------------------------------------------------------------------------

-- Always specify the IEEE library in your design

-- Move this to top level when it works


LIBRARY work;
USE work.ALL;
USE work.board_layout_pkg.ALL;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.ALL;

-- Entity declaration
-- 		Defines the interface to the entity

ENTITY board_generator IS
generic(
	G_M								: integer				:= 10          ;
	internal_seed            	: std_logic_vector	:= "1001010101";
	bomb_count      				: natural				:= 10);

	PORT
	(
-- 	Note: It is easier to identify individual ports and change their order
--	or types when their declarations are on separate lines.
--	This also helps the readability of your code.

		-- Clocks
    
		CLOCK_50						: IN STD_LOGIC;  -- 50 MHz

		-- Enable Board Maker Input
    
		start_randomizer 			: IN STD_LOGIC;         -- Start Randomizer Input
		
		banned_position			: IN user_pos;			-- Position where a bomb can't be
		
		-- Randomized Board Output
	 
		board_output				: OUT board_size;			-- Minesweeper Game Board
		
		completed					: OUT STD_LOGIC			-- Signifies when board is made
	);
END board_generator;


-- Architecture body 
-- 		Describes the functionality or internal implementation of the entity

ARCHITECTURE structural OF board_generator IS
type bound is array (9 downto 0) of integer;

COMPONENT lfsr
			
	PORT(	i_clk, enable : in std_logic;
			seed : in std_logic_vector(G_M-1 downto 0); 
			outputLSFR : out std_logic_vector(G_M-1 downto 0));

END COMPONENT;


signal lfsr_out : std_logic_vector(G_M-1 downto 0);
signal number_counter : integer := 0; -- Integer except only positive
signal inc_box : natural := 0;
signal positions : bound := (others => 0);
signal board : board_size;

BEGIN

	U1: lfsr PORT MAP
		(i_clk				=>	CLOCK_50,
		 enable 				=> start_randomizer,
		 seed				   => internal_seed,
		 outputLSFR			=> lfsr_out		 
		);
		
	gen_capture : process (CLOCK_50)
	begin
		if rising_edge(CLOCK_50) and number_counter < bomb_count and start_randomizer = '1' then
			-- Reset the board and position on start
			if number_counter = 0 then
				for i in 0 to 7 loop -- Column
					for j in 0 to 7 loop -- Row
						board(i, j) <= 0;
					end loop;
				end loop;
				for t in 0 to 9 loop
					positions(t) <= 0;
				end loop;
			end if;
			completed <= '0';
			number_counter <= number_counter + 1;
			positions(number_counter) <= (to_integer(unsigned(lfsr_out)) mod 64);
			-- Make sure every position is unique
			for item in 0 to 9 loop
					if positions(item) = (to_integer(unsigned(lfsr_out)) mod 64) or 
						 (to_integer(unsigned(lfsr_out)) mod 64) = (banned_position(0) * 8 + banned_position(1)) then
							positions(number_counter) <= 0;
							number_counter <= number_counter;
					end if;
			end loop;
			-- WARNING: If any issues arise due to board timing, fix it here
			if inc_box = bomb_count then
				board_output <= board;
				completed <= '1';
				inc_box <= 0;
			end if;
		elsif rising_edge(CLOCK_50) and number_counter = 10 then
			for index in 0 to bomb_count-1 loop
				board(positions(index)/8, positions(index) mod 8) <= 9;
			end loop;			
			number_counter <= number_counter + 1;
		-- Implies this is 11 or greater or else it can't reach here
		elsif rising_edge(CLOCK_50) and number_counter > 10 then			
			-- Left Column of the Center
			if positions(inc_box)/8 > 0 and positions(inc_box) mod 8 > 0
					and board(positions(inc_box)/8 - 1, positions(inc_box) mod 8 - 1) /= 9 then
						board(positions(inc_box)/8 - 1, (positions(inc_box) mod 8) - 1) <= 
								board(positions(inc_box)/8 - 1, (positions(inc_box) mod 8) - 1) + 1;
			end if;
			if positions(inc_box)/8 > 0 and board(positions(inc_box)/8 - 1, (positions(inc_box) mod 8)) /= 9 then
				board(positions(inc_box)/8 - 1, (positions(inc_box) mod 8)) <= 
							board(positions(inc_box)/8 - 1, (positions(inc_box) mod 8)) + 1;
			end if;
			if positions(inc_box)/8 > 0 and positions(inc_box) mod 8 < 7
				and board(positions(inc_box)/8 - 1, (positions(inc_box) mod 8) + 1) /= 9	then
					board(positions(inc_box)/8 - 1, (positions(inc_box) mod 8) + 1) <= 
							board(positions(inc_box)/8 - 1, (positions(inc_box) mod 8) + 1) + 1;
			end if;
			
			
			-- Middle Column of the Center
			if positions(inc_box) mod 8 > 0 and board(positions(inc_box)/8, (positions(inc_box) mod 8) - 1) /= 9 then
				board(positions(inc_box)/8, (positions(inc_box) mod 8) - 1) <= 
							board(positions(inc_box)/8, (positions(inc_box) mod 8) - 1) + 1;
			end if;
			if positions(inc_box) mod 8 < 7 and board(positions(inc_box)/8, (positions(inc_box) mod 8) + 1) /= 9 then
				board(positions(inc_box)/8, (positions(inc_box) mod 8) + 1) <= 
							board(positions(inc_box)/8, (positions(inc_box) mod 8) + 1) + 1;
			end if;
			
			-- Right Column of the Center
			if positions(inc_box)/8 < 7 and positions(inc_box) mod 8 < 7
				and board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8) + 1) /= 9 then
					board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8) + 1) <= 
							board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8) + 1) + 1;
			end if;
			if positions(inc_box)/8 < 7 and board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8)) /= 9 then
				board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8)) <= 
							board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8)) + 1;
			end if;
			if positions(inc_box)/8 < 7 and positions(inc_box) mod 8 > 0
				and board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8) - 1) /= 9 then
					board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8) - 1) <= 
							board(positions(inc_box)/8 + 1, (positions(inc_box) mod 8) - 1) + 1;
			end if;
			
			inc_box <= inc_box + 1;
			if inc_box = 9 then
				number_counter <= 0;
				inc_box <= bomb_count;
			end if;
		end if;
		-- Make it so each box increment is done on clock cycle
		
   end process gen_capture;

END structural;


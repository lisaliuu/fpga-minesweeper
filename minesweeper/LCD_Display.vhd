LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
USE  IEEE.NUMERIC_STD.all;



ENTITY LCD_Display IS
-- Enter number of live Hex hardware data values to display
-- (do not count ASCII character constants)
	GENERIC(Num_Hex_Digits: Integer:= 2); 

-----------------------------------------------------------------------
-- LCD Displays 16 Characters on 2 lines
-- LCD_display string is an ASCII character string entered in hex for 
-- the two lines of the  LCD Display   (See ASCII to hex table below)
-- Edit LCD_Display_String entries above to modify display
-- Enter the ASCII character's 2 hex digit equivalent value
-- (see table below for ASCII hex values)
-- To display character assign ASCII value to LCD_display_string(x)
-- To skip a character use X"20" (ASCII space)
-- To dislay "live" hex values from hardware on LCD use the following: 
--   make array element for that character location X"0" & 4-bit field from Hex_Display_Data
--   state machine sees X"0" in high 4-bits & grabs the next lower 4-bits from Hex_Display_Data input
--   and performs 4-bit binary to ASCII conversion needed to print a hex digit
--   Num_Hex_Digits must be set to the count of hex data characters (ie. "00"s) in the display
--   Connect hardware bits to display to Hex_Display_Data input
-- To display less than 32 characters, terminate string with an entry of X"FE"
--  (fewer characters may slightly increase the LCD's data update rate)
------------------------------------------------------------------- 
--                        ASCII HEX TABLE
--  Hex						Low Hex Digit
-- Value  0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
------\----------------------------------------------------------------
--H  2 |  SP  !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /
--i  3 |  0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?
--g  4 |  @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O
--h  5 |  P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _
--   6 |  `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o
--   7 |  p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~ DEL
-----------------------------------------------------------------------
-- Example "A" is row 4 column 1, so hex value is X"41"
-- *see LCD Controller's Datasheet for other graphics characters available

	PORT(	reset, clk_50MHz			: IN STD_LOGIC;
			flag_count			        : IN INTEGER RANGE 0 TO 99;
			LCD_RS, LCD_E				: OUT STD_LOGIC;
			LCD_RW						: OUT STD_LOGIC;
			DATA_BUS					: INOUT STD_LOGIC_VECTOR(7 DOWNTO 0));

END ENTITY LCD_Display;

ARCHITECTURE a OF LCD_Display IS

TYPE character_string IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 7 DOWNTO 0 );

TYPE STATE_TYPE IS (RESET1, RESET2, RESET3, FUNC_SET, DISPLAY_OFF, DISPLAY_CLEAR, DISPLAY_ON,
MODE_SET, Print_String, LINE2, RETURN_HOME, DROP_LCD_E, HOLD);


SIGNAL state, next_command: STATE_TYPE;
SIGNAL LCD_display_string	: character_string;

-- Enter new ASCII hex data above for LCD Display
SIGNAL DATA_BUS_VALUE, Next_Char: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL CLK_COUNT_200HZ: STD_LOGIC_VECTOR(19 DOWNTO 0);
SIGNAL CHAR_COUNT: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL CLK_200HZ_Enable,LCD_RW_INT : STD_LOGIC;
SIGNAL Line1_chars, Line2_chars: STD_LOGIC_VECTOR(127 DOWNTO 0);
SIGNAL COUNTER: INTEGER;
SIGNAL flags: STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

flags <= std_logic_vector(to_unsigned(flag_count, flags'length));

LCD_display_string <= (
-- ASCII hex values for LCD Display
-- Enter Live Hex Data Values from hardware here
-- LCD DISPLAYS THE FOLLOWING:
------------------------------
--| Flags:XX             |
--| FPGA Minesweeper     |
------------------------------
-- Line 1
X"46",X"6C",X"61",X"67",X"73",X"3A",X"0" & flags(7 DOWNTO 4),X"0" & flags(3 DOWNTO 0),
X"20",X"20",X"20",X"20",X"20",X"20",X"20",X"20",
-- Line 2
X"46",X"50",X"47",X"41",X"20",X"4D",X"69",X"6E",
X"65",X"73",X"77",X"65",X"65",X"70",X"65",X"72");


-- BIDIRECTIONAL TRI STATE LCD DATA BUS
	DATA_BUS <= DATA_BUS_VALUE WHEN LCD_RW_INT = '0' ELSE "ZZZZZZZZ";
-- get next character in display string
	Next_Char <= LCD_display_string(CONV_INTEGER(CHAR_COUNT));
	LCD_RW <= LCD_RW_INT;
	
-- Makes a 200 Hz Clock CLK_200HZ_Enable
	PROCESS
	BEGIN
		wAIT UNTIL clk_50MHz'EVENT AND clk_50MHz = '1';
		IF RESET = '0' THEN
			CLK_COUNT_200HZ <= X"00000";
			CLK_200HZ_Enable <= '0';
		ELSE
			IF CLK_COUNT_200HZ < X"1E848" THEN 
				CLK_COUNT_200HZ <= CLK_COUNT_200HZ + 1;
				CLK_200HZ_Enable <= '0';
			ELSE
				CLK_COUNT_200HZ <= X"00000";
				CLK_200HZ_Enable <= '1';
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (clk_50MHz, reset)
	BEGIN
		IF reset = '0' THEN
			state <= RESET1;
			DATA_BUS_VALUE <= X"38";
			next_command <= RESET2;
			LCD_E <= '1';
			LCD_RS <= '0';
			LCD_RW_INT <= '1';
		ELSIF clk_50MHz'EVENT AND clk_50MHz = '1' THEN
-- State Machine to send commands and data to LCD DISPLAY			
		  IF CLK_200HZ_Enable = '1' THEN
			CASE state IS
-- Set Function to 8-bit transfer and 2 line display with 5x8 Font size
-- see Hitachi HD44780 family data sheet for LCD command and timing details
				WHEN RESET1 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= DROP_LCD_E;
						next_command <= RESET2;
						CHAR_COUNT <= "00000";
				WHEN RESET2 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= DROP_LCD_E;
						next_command <= RESET3;
				WHEN RESET3 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= DROP_LCD_E;
						next_command <= FUNC_SET;
-- EXTRA STATES ABOVE ARE NEEDED FOR RELIABLE PUSHBUTTON RESET OF LCD
				WHEN FUNC_SET =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"38";
						state <= DROP_LCD_E;
						next_command <= DISPLAY_OFF;
-- Turn off Display and Turn off cursor
				WHEN DISPLAY_OFF =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"08";
						state <= DROP_LCD_E;
						next_command <= DISPLAY_CLEAR;
-- Clear Display and Turn off cursor
				WHEN DISPLAY_CLEAR =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"01";
						state <= DROP_LCD_E;
						next_command <= DISPLAY_ON;
-- Turn on Display and Turn off cursor
				WHEN DISPLAY_ON =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"0C";
						state <= DROP_LCD_E;
						next_command <= MODE_SET;
-- Set write mode to auto increment address and move cursor to the right
				WHEN MODE_SET =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"06";
						state <= DROP_LCD_E;
						next_command <= Print_String;
-- Write ASCII hex character in first LCD character location
				WHEN Print_String =>
						state <= DROP_LCD_E;
						LCD_E <= '1';
						LCD_RS <= '1';
						LCD_RW_INT <= '0';
-- ASCII character to output
						IF Next_Char(7 DOWNTO  4) /= X"0" THEN
							DATA_BUS_VALUE <= Next_Char;
						ELSE
-- Convert 4-bit value to an ASCII hex digit
							IF Next_Char(3 DOWNTO 0) >9 THEN -- ASCII A...F
								DATA_BUS_VALUE <= X"4" & (Next_Char(3 DOWNTO 0)-9);
							ELSE -- ASCII 0...9
								DATA_BUS_VALUE <= X"3" & Next_Char(3 DOWNTO 0);
							END IF;
						END IF;
						state <= DROP_LCD_E;
-- Loop to send out 32 characters to LCD Display  (16 by 2 lines)
						IF (CHAR_COUNT < 31) AND (Next_Char /= X"FE") THEN 
							CHAR_COUNT <= CHAR_COUNT +1;
						ELSE 
							CHAR_COUNT <= "00000"; 
						END IF;
-- Jump to second line?
						IF CHAR_COUNT = 15 THEN next_command <= line2;
-- Return to first line?
						ELSIF (CHAR_COUNT = 31) OR (Next_Char = X"FE") THEN
							next_command <= return_home;
						ELSE next_command <= Print_String; END IF;
-- Set write address to line 2 character 1
				WHEN LINE2 =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"C0";
						state <= DROP_LCD_E;
						next_command <= Print_String;
-- Return write address to first character postion on line 1
				WHEN RETURN_HOME =>
						LCD_E <= '1';
						LCD_RS <= '0';
						LCD_RW_INT <= '0';
						DATA_BUS_VALUE <= X"80";
						state <= DROP_LCD_E;
						next_command <= Print_String;
-- The next three states occur at the end of each command or data transfer to the LCD
-- Drop LCD E line - falling edge loads inst/data to LCD controller
				WHEN DROP_LCD_E =>
						LCD_E <= '0';
						state <= HOLD;
-- Hold LCD inst/data valid after falling edge of E line				
				WHEN HOLD =>
						state <= next_command;
			END CASE;
		  END IF;
		END IF;
	END PROCESS;
END a;

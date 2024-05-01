--
-- DE2-115 top-level module (entity declaration)
--
-- William H. Robinson, Vanderbilt University University
--   william.h.robinson@vanderbilt.edu
--
-- Updated from the DE2 top-level module created by 
-- Stephen A. Edwards, Columbia University, sedwards@cs.columbia.edu
--

PACKAGE board_layout_pkg IS
	SUBTYPE small_range IS NATURAL RANGE 0 TO 10;
	SUBTYPE smallest_range IS NATURAL RANGE 0 TO 1;
	TYPE board_size IS ARRAY (0 TO 7, 0 TO 7) OF small_range;
	TYPE board_bool IS ARRAY (0 TO 7, 0 TO 7) OF smallest_range;
	TYPE user_pos IS ARRAY(0 TO 1) OF small_range;
END board_layout_pkg;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.board_layout_pkg.ALL;
ENTITY DE2_115_TOP IS

	PORT
	(
		-- Clocks

		CLOCK_50 : IN STD_LOGIC; -- 50 MHz
		CLOCK2_50 : IN STD_LOGIC; -- 50 MHz
		CLOCK3_50 : IN STD_LOGIC; -- 50 MHz
		SMA_CLKIN : IN STD_LOGIC; -- External Clock Input
		SMA_CLKOUT : OUT STD_LOGIC; -- External Clock Output

		-- Buttons and switches

		KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Push buttons
		SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0); -- DPDT switches

		-- LED displays

		HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display (active low)
		HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display (active low)
		HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display (active low)
		HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display (active low)
		HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display (active low)
		HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display (active low)
		HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display (active low)
		HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 7-segment display (active low)
		LEDG : OUT STD_LOGIC_VECTOR(8 DOWNTO 0); -- Green LEDs (active high)
		LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0); -- Red LEDs (active high)

		-- RS-232 interface

		UART_CTS : OUT STD_LOGIC; -- UART Clear to Send   
		UART_RTS : IN STD_LOGIC; -- UART Request to Send   
		UART_RXD : IN STD_LOGIC; -- UART Receiver
		UART_TXD : OUT STD_LOGIC; -- UART Transmitter   

		-- 16 X 2 LCD Module

		LCD_BLON : OUT STD_LOGIC; -- Back Light ON/OFF
		LCD_EN : OUT STD_LOGIC; -- Enable
		LCD_ON : OUT STD_LOGIC; -- Power ON/OFF
		LCD_RS : OUT STD_LOGIC; -- Command/Data Select, 0 = Command, 1 = Data
		LCD_RW : OUT STD_LOGIC; -- Read/Write Select, 0 = Write, 1 = Read
		LCD_DATA : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Data bus 8 bits

		-- PS/2 ports

		PS2_CLK : INOUT STD_LOGIC; -- Clock
		PS2_DAT : INOUT STD_LOGIC; -- Data

		PS2_CLK2 : INOUT STD_LOGIC; -- Clock
		PS2_DAT2 : INOUT STD_LOGIC; -- Data

		-- VGA output

		VGA_BLANK_N : OUT STD_LOGIC; -- BLANK
		VGA_CLK : OUT STD_LOGIC; -- Clock
		VGA_HS : OUT STD_LOGIC; -- H_SYNC
		VGA_SYNC_N : OUT STD_LOGIC; -- SYNC
		VGA_VS : OUT STD_LOGIC; -- V_SYNC
		VGA_R : OUT unsigned(7 DOWNTO 0); -- Red[9:0]
		VGA_G : OUT unsigned(7 DOWNTO 0); -- Green[9:0]
		VGA_B : OUT unsigned(7 DOWNTO 0); -- Blue[9:0]

		-- SRAM

		SRAM_ADDR : OUT unsigned(19 DOWNTO 0); -- Address bus 20 Bits
		SRAM_DQ : INOUT unsigned(15 DOWNTO 0); -- Data bus 16 Bits
		SRAM_CE_N : OUT STD_LOGIC; -- Chip Enable
		SRAM_LB_N : OUT STD_LOGIC; -- Low-byte Data Mask 
		SRAM_OE_N : OUT STD_LOGIC; -- Output Enable
		SRAM_UB_N : OUT STD_LOGIC; -- High-byte Data Mask 
		SRAM_WE_N : OUT STD_LOGIC; -- Write Enable

		-- Audio CODEC

		AUD_ADCDAT : IN STD_LOGIC; -- ADC Data
		AUD_ADCLRCK : INOUT STD_LOGIC; -- ADC LR Clock
		AUD_BCLK : INOUT STD_LOGIC; -- Bit-Stream Clock
		AUD_DACDAT : OUT STD_LOGIC; -- DAC Data
		AUD_DACLRCK : INOUT STD_LOGIC; -- DAC LR Clock
		AUD_XCK : OUT STD_LOGIC -- Chip Clock

	);

END DE2_115_TOP;

ARCHITECTURE Structure OF DE2_115_TOP IS
	-- Compoment
	COMPONENT logic IS
		PORT
		(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC; -- sw[0]
			buttons : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			switches : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

			VGA_UPDATE : OUT STD_LOGIC;
			cell_status : INOUT board_bool;
			cell_flagged : INOUT board_bool;
			cell_value : INOUT board_size;
			cur_sel_cell : INOUT user_pos;
			T_one : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			T_two : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			game_won : OUT STD_LOGIC;
			game_lost : OUT STD_LOGIC;
			flag_count : INOUT INTEGER RANGE 0 TO 99
		);
	END COMPONENT;

	COMPONENT board IS
		PORT
		(
			Vert_sync, Horiz_sync : IN STD_LOGIC;
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			Red, Green, Blue : OUT STD_LOGIC;
			-- 
			cell_status : IN board_bool;
			cell_flagged : IN board_bool;
			cell_value : IN board_size;
			cell_userb : IN user_pos;

			game_won : IN STD_LOGIC;
			game_lost : IN STD_LOGIC

		);
	END COMPONENT;

	COMPONENT LCD_Display

		GENERIC
			(Num_Hex_Digits : INTEGER := 2);
		PORT
		(
			reset, clk_50MHz : IN STD_LOGIC;
			flag_count : IN INTEGER RANGE 0 TO 99;
			LCD_RS, LCD_E : OUT STD_LOGIC;
			LCD_RW : OUT STD_LOGIC;
			DATA_BUS : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT VGA_SYNC_MODULE
		PORT
		(
			clock_50Mhz : IN STD_LOGIC;
			red, green, blue : IN STD_LOGIC;
			red_out, green_out, blue_out : OUT STD_LOGIC;
			horiz_sync_out, vert_sync_out, video_on, pixel_clock : OUT STD_LOGIC;
			pixel_row, pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT bcd_seven
		PORT
		(
			bcd : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			H0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		);
	END COMPONENT;

	-- Signals
	--     VGA
	SIGNAL red_int : STD_LOGIC;
	SIGNAL green_int : STD_LOGIC;
	SIGNAL blue_int : STD_LOGIC;
	SIGNAL video_on_int : STD_LOGIC;
	SIGNAL vert_sync_int : STD_LOGIC;
	SIGNAL horiz_sync_int : STD_LOGIC;
	SIGNAL pixel_clock_int : STD_LOGIC;
	SIGNAL pixel_row_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL pixel_column_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
	--    Board status
	SIGNAL VGA_update_int : STD_LOGIC;
	SIGNAL cell_status_signal : board_bool;
	SIGNAL cell_flagged_signal : board_bool;
	SIGNAL cell_value_signal : board_size;
	SIGNAL cell_user : user_pos;
	SIGNAL number_one : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL number_two : STD_LOGIC_VECTOR(3 DOWNTO 0);

	SIGNAL g_won : STD_LOGIC;
	SIGNAL g_lost : STD_LOGIC;

	SIGNAL flag_count_signal : INTEGER RANGE 0 TO 99;

BEGIN

	logic_block : logic PORT MAP
	(
		-- IN
		clk => CLOCK_50,
		reset => SW(0),
		buttons => KEY(3 DOWNTO 0),
		switches => SW(2 DOWNTO 0),
		-- OUT
		VGA_UPDATE => VGA_update_int,
		-- INOUT
		cell_status => cell_status_signal,
		cell_flagged => cell_flagged_signal,
		cell_value => cell_value_signal,
		cur_sel_cell => cell_user,
		T_one => number_one(3 DOWNTO 0),
		T_two => number_two(3 DOWNTO 0),
		-- cur_sel_cell : INOUT user_pos; -- <- I don't think this is needed
		game_lost => g_lost,
		game_won => g_won,

		flag_count => flag_count_signal

	);

	VGA_R(6 DOWNTO 0) <= "0000000";
	VGA_G(6 DOWNTO 0) <= "0000000";
	VGA_B(6 DOWNTO 0) <= "0000000";

	VGA_HS <= horiz_sync_int;
	VGA_VS <= vert_sync_int;

	VGA_sync : VGA_SYNC_module PORT
	MAP (
	-- IN
	clock_50Mhz => CLOCK_50,
	red => red_int,
	green => green_int,
	blue => blue_int,
	red_out => VGA_R(7),
	green_out => VGA_G(7),
	blue_out => VGA_B(7),
	-- OUT
	horiz_sync_out => horiz_sync_int,
	vert_sync_out => vert_sync_int,
	video_on => VGA_BLANK_N,
	pixel_clock => VGA_CLK,
	pixel_row => pixel_row_int,
	pixel_column => pixel_column_int
	);

	Board_display : board PORT
	MAP(
	-- IN
	Vert_sync => vert_sync_int,
	Horiz_sync => horiz_sync_int,
	pixel_row => pixel_row_int,
	pixel_column => pixel_column_int,
	-- OUT
	Red => red_int,
	Green => green_int,
	Blue => blue_int,
	-- IN
	cell_status => cell_status_signal,
	cell_flagged => cell_flagged_signal,
	cell_value => cell_value_signal,
	cell_userb => cell_user,

	game_lost => g_lost,
	game_won => g_won
	);

	LCD_ON <= '1';
	LCD_BLON <= '1';
	LCD : LCD_Display PORT
	MAP (
	reset => NOT SW(0),
	clk_50MHz => CLOCK_50,
	flag_count => flag_count_signal,
	LCD_RS => LCD_RS,
	LCD_E => LCD_EN,
	LCD_RW => LCD_RW,
	DATA_BUS => LCD_DATA

	);

	Seg7_1 : bcd_seven PORT
	MAP (
	number_one(3 DOWNTO 0), HEX0);
	Seg7_2 : bcd_seven PORT
	MAP (
	number_two(3 DOWNTO 0), HEX1);

END Structure;
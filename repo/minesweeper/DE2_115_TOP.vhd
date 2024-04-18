--
-- DE2-115 top-level module (entity declaration)
--
-- William H. Robinson, Vanderbilt University University
--   william.h.robinson@vanderbilt.edu
--
-- Updated from the DE2 top-level module created by 
-- Stephen A. Edwards, Columbia University, sedwards@cs.columbia.edu
--

-- KEY QUESTION: Can we represent 3 values using STD_LOGIC_VECTOR?

PACKAGE board_layout_pkg IS
	-- TYPE piece IS (player_1, player_2, empty);
	-- TYPE BOARD_SCHEME IS ARRAY(0 TO 6, 0 TO 5) OF PIECE;
	TYPE board_status IS ARRAY(0 TO 7, 0 TO 7); -- bool
	TYPE board_value IS ARRAY(0 TO 7, 0 TO 7); -- int from 0 to 8 & 9 (for bomb)
END board_layout_pkg;

LIBRARY work;
USE work.ALL;
USE work.board_layout_pkg.ALL;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY DE2_115_TOP IS

	PORT (
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
ARCHITECTURE Arch OF DE2_115_TOP IS

	COMPONENT logic IS
		PORT (
			clk : IN STD_LOGIC;
			VGA_RDY : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			buttons : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			switches : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

			VGA_UPDATE : OUT STD_LOGIC;
			boardLayout : BUFFER BOARD_SCHEME;
			currentPlayer : BUFFER STD_LOGIC;
			nextPieceColumn : BUFFER unsigned(6 DOWNTO 0);
			winner : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT board IS
		PORT (
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			Red, Green, Blue : OUT STD_LOGIC;
			Vert_sync, Horiz_sync : IN STD_LOGIC;
			boardLayout : IN BOARD_SCHEME;
			currentPlayer : IN STD_LOGIC;
			nextPieceColumn : IN unsigned(6 DOWNTO 0);
			winner : IN STD_LOGIC
		);
	END COMPONENT;

	COMPONENT VGA_SYNC_MODULE
		PORT (
			clock_50Mhz : IN STD_LOGIC;
			red, green, blue : IN STD_LOGIC;
			red_out, green_out, blue_out : OUT STD_LOGIC;
			horiz_sync_out, vert_sync_out, video_on, pixel_clock : OUT STD_LOGIC;
			pixel_row, pixel_column : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
		);

	END COMPONENT;

	COMPONENT LCD_Display IS
		PORT (
			reset, clk_50MHz : IN STD_LOGIC;
			currPlayer : IN STD_LOGIC;
			winner : IN STD_LOGIC;
			LCD_E : OUT STD_LOGIC; -- Enable
			LCD_RS : OUT STD_LOGIC; -- Command/Data Select, 0 = Command, 1 = Data
			LCD_RW : OUT STD_LOGIC;
			DATA_BUS : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;

	SIGNAL red_int : STD_LOGIC;
	SIGNAL green_int : STD_LOGIC;
	SIGNAL blue_int : STD_LOGIC;
	SIGNAL video_on_int : STD_LOGIC;
	SIGNAL vert_sync_int : STD_LOGIC;
	SIGNAL horiz_sync_int : STD_LOGIC;
	SIGNAL pixel_clock_int : STD_LOGIC;
	SIGNAL pixel_row_int : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL pixel_column_int : STD_LOGIC_VECTOR(9 DOWNTO 0);

	SIGNAL VGA_RDY_SIGNAL : STD_LOGIC;
	SIGNAL VGA_UPDATE_SIGNAL : STD_LOGIC;
	SIGNAL CURRENT_PLAYER_SIGNAL : STD_LOGIC;
	SIGNAL BOARD_LAYOUT_SIGNAL : BOARD_SCHEME;
	SIGNAL NEXT_PIECE_COLUMN_SIG : unsigned(6 DOWNTO 0);
	SIGNAL WIN_DETECTED : STD_LOGIC;

BEGIN

	VGA_RDY_SIGNAL <= '1';
	LCD_ON <= '1';
	LCD_BLON <= '1';

	logicBlock : logic PORT MAP(
		clk => CLOCK_50,
		VGA_RDY => VGA_RDY_SIGNAL,
		reset => SW(17),
		buttons => KEY(2 DOWNTO 0),
		switches => SW(6 DOWNTO 0),

		VGA_UPDATE => VGA_UPDATE_SIGNAL,
		currentPlayer => CURRENT_PLAYER_SIGNAL,
		nextPieceColumn => NEXT_PIECE_COLUMN_SIG,
		boardLayout => BOARD_LAYOUT_SIGNAL,
		winner => WIN_DETECTED

	);

	VGA_HS <= horiz_sync_int;
	VGA_VS <= vert_sync_int;

	VGA_R(6 DOWNTO 0) <= "0000000";
	VGA_G(6 DOWNTO 0) <= "0000000";
	VGA_B(6 DOWNTO 0) <= "0000000";

	U1 : VGA_SYNC_module PORT MAP
	(
		clock_50Mhz => CLOCK_50,
		red => red_int,
		green => green_int,
		blue => blue_int,
		red_out => VGA_R(7),
		green_out => VGA_G(7),
		blue_out => VGA_B(7),
		horiz_sync_out => horiz_sync_int,
		vert_sync_out => vert_sync_int,
		video_on => VGA_BLANK_N,
		pixel_clock => VGA_CLK,
		pixel_row => pixel_row_int,
		pixel_column => pixel_column_int
	);

	vgaBlock : board PORT MAP(
		pixel_row => pixel_row_int,
		pixel_column => pixel_column_int,
		Red => red_int,
		Green => green_int,
		Blue => blue_int,
		Vert_sync => vert_sync_int,
		Horiz_sync => horiz_sync_int,
		boardLayout => BOARD_LAYOUT_SIGNAL,
		currentPlayer => CURRENT_PLAYER_SIGNAL,
		nextPieceColumn => NEXT_PIECE_COLUMN_SIG,
		winner => WIN_DETECTED
	);

	lcd : LCD_Display PORT MAP(
		reset => NOT SW(17),
		clk_50MHz => CLOCK_50,
		currPlayer => CURRENT_PLAYER_SIGNAL,
		winner => WIN_DETECTED,
		LCD_RS => LCD_RS,
		LCD_E => LCD_EN,
		LCD_RW => LCD_RW,
		DATA_BUS => LCD_DATA
	);

	LEDR(6 DOWNTO 0) <= STD_LOGIC_VECTOR(NEXT_PIECE_COLUMN_SIG);

END Arch;
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
	subtype small_range is natural range 0 to 10;
	subtype smallest_range is natural range 0 to 1;
	type board_size is array (0 to 7, 0 to 7) of small_range;
	type board_bool is array (0 to 7, 0 to 7) of smallest_range;
	type user_pos is array(0 TO 1) of small_range;
END board_layout_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

USE work.board_layout_pkg.ALL;


entity DE2_115_TOP is

  port (
    -- Clocks
    
    CLOCK_50 	: in std_logic;                     -- 50 MHz
    CLOCK2_50 	: in std_logic;                     -- 50 MHz
    CLOCK3_50 	: in std_logic;                     -- 50 MHz
    SMA_CLKIN  : in std_logic;                     -- External Clock Input
    SMA_CLKOUT : out std_logic;                    -- External Clock Output

    -- Buttons and switches
    
    KEY : in std_logic_vector(3 downto 0);         -- Push buttons
    SW  : in std_logic_vector(17 downto 0);        -- DPDT switches

    -- LED displays

    HEX0 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX1 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX2 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX3 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX4 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX5 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX6 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    HEX7 : out std_logic_vector(6 downto 0);       -- 7-segment display (active low)
    LEDG : out std_logic_vector(8 downto 0);       -- Green LEDs (active high)
    LEDR : out std_logic_vector(17 downto 0);      -- Red LEDs (active high)

    -- RS-232 interface

    UART_CTS : out std_logic;                      -- UART Clear to Send   
    UART_RTS : in std_logic;                       -- UART Request to Send   
    UART_RXD : in std_logic;                       -- UART Receiver
    UART_TXD : out std_logic;                      -- UART Transmitter   

    -- 16 X 2 LCD Module
    
    LCD_BLON : out std_logic;      							-- Back Light ON/OFF
    LCD_EN   : out std_logic;      							-- Enable
    LCD_ON   : out std_logic;      							-- Power ON/OFF
    LCD_RS   : out std_logic;	   							-- Command/Data Select, 0 = Command, 1 = Data
    LCD_RW   : out std_logic; 	   						-- Read/Write Select, 0 = Write, 1 = Read
    LCD_DATA : inout std_logic_vector(7 downto 0); 	-- Data bus 8 bits

    -- PS/2 ports

    PS2_CLK : inout std_logic;     -- Clock
    PS2_DAT : inout std_logic;     -- Data

    PS2_CLK2 : inout std_logic;    -- Clock
    PS2_DAT2 : inout std_logic;    -- Data

    -- VGA output
    
    VGA_BLANK_N : out std_logic;            -- BLANK
    VGA_CLK 	 : out std_logic;            -- Clock
    VGA_HS 		 : out std_logic;            -- H_SYNC
    VGA_SYNC_N  : out std_logic;            -- SYNC
    VGA_VS 		 : out std_logic;            -- V_SYNC
    VGA_R 		 : out unsigned(7 downto 0); -- Red[9:0]
    VGA_G 		 : out unsigned(7 downto 0); -- Green[9:0]
    VGA_B 		 : out unsigned(7 downto 0); -- Blue[9:0]

    -- SRAM
    
    SRAM_ADDR : out unsigned(19 downto 0);         -- Address bus 20 Bits
    SRAM_DQ   : inout unsigned(15 downto 0);       -- Data bus 16 Bits
    SRAM_CE_N : out std_logic;                     -- Chip Enable
    SRAM_LB_N : out std_logic;                     -- Low-byte Data Mask 
    SRAM_OE_N : out std_logic;                     -- Output Enable
    SRAM_UB_N : out std_logic;                     -- High-byte Data Mask 
    SRAM_WE_N : out std_logic;                     -- Write Enable

    -- Audio CODEC
    
    AUD_ADCDAT 	: in std_logic;               -- ADC Data
    AUD_ADCLRCK 	: inout std_logic;            -- ADC LR Clock
    AUD_BCLK 		: inout std_logic;            -- Bit-Stream Clock
    AUD_DACDAT 	: out std_logic;              -- DAC Data
    AUD_DACLRCK 	: inout std_logic;            -- DAC LR Clock
    AUD_XCK 		: out std_logic               -- Chip Clock
    
    );
  
end DE2_115_TOP;

architecture Structure of DE2_115_TOP is
	-- Compoment
	component logic IS
	port(
		clk: in std_logic;
		reset: in std_logic; -- sw[0]
		buttons : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		switches : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

    	VGA_UPDATE : OUT STD_LOGIC;
		cell_status : INOUT board_bool;
		cell_flagged : INOUT board_bool;
		cell_value : INOUT board_size;
		cur_sel_cell : INOUT user_pos;
		test:OUT std_logic
	);
	end component;
	COMPONENT board IS
		PORT (
			Vert_sync, Horiz_sync : IN STD_LOGIC;
			pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			Red, Green, Blue : OUT STD_LOGIC;
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
	signal cell_status_signal : board_bool;
	signal cell_flagged_signal : board_bool;
	signal cell_value_signal : board_size;

begin

	logic_block: logic port map (
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
		cell_value => cell_value_signal
		-- cur_sel_cell : INOUT user_pos; -- <- I don't think this is needed
	);
	
	VGA_R(6 DOWNTO 0) <= "0000000";
	VGA_G(6 DOWNTO 0) <= "0000000";
	VGA_B(6 DOWNTO 0) <= "0000000";

	VGA_HS <= horiz_sync_int;
	VGA_VS <= vert_sync_int;

	VGA_SYNC_module PORT MAP(
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
	
	board PORT MAP(
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
		cell_value => cell_value_signal
	);

end Structure;
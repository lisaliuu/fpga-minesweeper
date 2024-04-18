--
-- DE2-115 top-level module (entity declaration)
--
-- William H. Robinson, Vanderbilt University University
--   william.h.robinson@vanderbilt.edu
--
-- Updated from the DE2 top-level module created by 
-- Stephen A. Edwards, Columbia University, sedwards@cs.columbia.edu
--

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
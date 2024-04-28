LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

USE work.board_layout_pkg.ALL;

ENTITY board IS
	PORT (
		Vert_sync, Horiz_sync : IN STD_LOGIC;
		pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		Red, Green, Blue : OUT STD_LOGIC;
		-- 
		cell_status : IN board_bool;
		cell_flagged : IN board_bool;
		cell_value : IN board_size
	);
END board;

-- Board is a 8x8 grid of squares
-- 50 x 50 pixels for each square
-- |                   four pixels                 | WIDTH = 640
-- | <= 80 => | 01 02 03 04 05 06 07 08 | <= 80 => | HEIGHT = 480
-- | <= 80 => | 09 10 11 12 13 14 15 16 | <= 80 => | 640 x 480
-- | <= 80 => | 17 18 19 20 21 22 23 24 | <= 80 => |
-- | <= 80 => | 25 26 27 28 29 30 31 32 | <= 80 => |
-- | <= 80 => | 33 34 35 36 37 38 39 40 | <= 80 => |
-- | <= 80 => | 41 42 43 44 45 46 47 48 | <= 80 => |
-- | <= 80 => | 49 50 51 52 53 54 55 56 | <= 80 => |
-- | <= 80 => | 57 58 59 60 61 62 63 64 | <= 80 => | (80, 4) <-> (560-1, 476-1)
-- |                   four pixels                 | 480 x 472

ARCHITECTURE behavior OF board IS
	SIGNAL background_color : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000"; -- white
	SIGNAL grid_color : STD_LOGIC_VECTOR(2 DOWNTO 0) := "111"; -- black
	SIGNAL closed_cell_color : STD_LOGIC_VECTOR(2 DOWNTO 0) := "010"; -- green
	-- Video Display Signals
	-- signal for background
	SIGNAL margin_width, margin_height : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL margin_x, margin_y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	-- signal for cells
	SIGNAL cell_width, cell_height : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_1x, cell_1y, cell_2x, cell_2y, cell_3x, cell_3y, cell_4x, cell_4y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_5x, cell_5y, cell_6x, cell_6y, cell_7x, cell_7y, cell_8x, cell_8y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_9x, cell_9y, cell_10x, cell_10y, cell_11x, cell_11y, cell_12x, cell_12y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_13x, cell_13y, cell_14x, cell_14y, cell_15x, cell_15y, cell_16x, cell_16y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_17x, cell_17y, cell_18x, cell_18y, cell_19x, cell_19y, cell_20x, cell_20y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_21x, cell_21y, cell_22x, cell_22y, cell_23x, cell_23y, cell_24x, cell_24y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_25x, cell_25y, cell_26x, cell_26y, cell_27x, cell_27y, cell_28x, cell_28y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_29x, cell_29y, cell_30x, cell_30y, cell_31x, cell_31y, cell_32x, cell_32y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_33x, cell_33y, cell_34x, cell_34y, cell_35x, cell_35y, cell_36x, cell_36y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_37x, cell_37y, cell_38x, cell_38y, cell_39x, cell_39y, cell_40x, cell_40y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_41x, cell_41y, cell_42x, cell_42y, cell_43x, cell_43y, cell_44x, cell_44y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_45x, cell_45y, cell_46x, cell_46y, cell_47x, cell_47y, cell_48x, cell_48y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_49x, cell_49y, cell_50x, cell_50y, cell_51x, cell_51y, cell_52x, cell_52y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_53x, cell_53y, cell_54x, cell_54y, cell_55x, cell_55y, cell_56x, cell_56y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_57x, cell_57y, cell_58x, cell_58y, cell_59x, cell_59y, cell_60x, cell_60y : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL cell_61x, cell_61y, cell_62x, cell_62y, cell_63x, cell_63y, cell_64x, cell_64y : STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN
	-- display the grid of the board
	RGB_Display : PROCESS (pixel_row, pixel_column)
		-- RGB_Display : PROCESS (Vert_sync, Horiz_sync, pixel_row, pixel_column)
	BEGIN
		-- TODO: set cell regiion (cell_#x and cell_#y)
		-- That first long section

		IF ('0' & margin_x <= pixel_column + margin_width) AND
			(margin_x + 640 >= '0' & pixel_column)
			-- set the background
			THEN
			-- 'background color' to white
			Red <= background_color(2);
			Green <= background_color(1);
			Blue <= background_color(0);
		ELSE
			-- if-else statement defining the cells
			-- if chains <- cell region
			-- TODO: check and set the region
			-- seperate the value as states
			Red <= grid_color(2);
			Green <= grid_color(1);
			Blue <= grid_color(0);
			-- IF expression THEN
			-- 	-- (last) else <- grid region
			-- ELSE
			-- 	Red <= grid_color(2);
			-- 	Green <= grid_color(1);
			-- 	Blue <= grid_color(0);
			-- END IF;
		END IF;
	END PROCESS RGB_Display;

	-- Update_cell : PROCESS
	-- 	-- rising_edge(init_board)
	-- BEGIN
	-- 	IF Vert_sync = '1' AND rising_edge(key_press) THEN
	-- 		-- FIXME: logic to update the cell
	-- 		-- (maybe logic isn't needed)
	-- 	END IF;
	-- END PROCESS Update_cell;

END behavior;
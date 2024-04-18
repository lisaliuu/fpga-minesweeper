-- Board Entity
-- Designed by Meredith Hunter, Madison Veliky
-- EECE 4377: FPGA Design
-- April 23, 2022

-- Connect4 board
LIBRARY work;
USE work.ALL;
USE work.board_layout_pkg.ALL;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Connect4 board 
ENTITY BOARD IS
	PORT (
		pixel_row, pixel_column : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		Red, Green, Blue : OUT STD_LOGIC;
		Vert_sync, Horiz_sync : IN STD_LOGIC;
		boardLayout : IN BOARD_SCHEME;
		currentPlayer : IN STD_LOGIC;
		nextPieceColumn : IN unsigned(6 DOWNTO 0);
		winner : IN STD_LOGIC
	);

END BOARD;

ARCHITECTURE behavior OF BOARD IS

	-- Video Display Signals 
	SIGNAL P_1x, P1x, P_1y, P1y : INTEGER;
	SIGNAL P_2x, P2x, P_2y, P2y : INTEGER;
	SIGNAL P_3x, P3x, P_3y, P3y : INTEGER;
	SIGNAL P_4x, P4x, P_4y, P4y : INTEGER;
	SIGNAL P_5x, P5x, P_5y, P5y : INTEGER;
	SIGNAL P_6x, P6x, P_6y, P6y : INTEGER;
	SIGNAL P_7x, P7x, P_7y, P7y : INTEGER;
	SIGNAL P_8x, P8x, P_8y, P8y : INTEGER;
	SIGNAL P_9x, P9x, P_9y, P9y : INTEGER;
	SIGNAL P_10x, P10x, P_10y, P10y : INTEGER;
	SIGNAL P_11x, P11x, P_11y, P11y : INTEGER;
	SIGNAL P_12x, P12x, P_12y, P12y : INTEGER;
	SIGNAL P_13x, P13x, P_13y, P13y : INTEGER;
	SIGNAL P_14x, P14x, P_14y, P14y : INTEGER;
	SIGNAL P_15x, P15x, P_15y, P15y : INTEGER;
	SIGNAL P_16x, P16x, P_16y, P16y : INTEGER;
	SIGNAL P_17x, P17x, P_17y, P17y : INTEGER;
	SIGNAL P_18x, P18x, P_18y, P18y : INTEGER;
	SIGNAL P_19x, P19x, P_19y, P19y : INTEGER;
	SIGNAL P_20x, P20x, P_20y, P20y : INTEGER;
	SIGNAL P_21x, P21x, P_21y, P21y : INTEGER;
	SIGNAL P_22x, P22x, P_22y, P22y : INTEGER;
	SIGNAL P_23x, P23x, P_23y, P23y : INTEGER;
	SIGNAL P_24x, P24x, P_24y, P24y : INTEGER;
	SIGNAL P_25x, P25x, P_25y, P25y : INTEGER;
	SIGNAL P_26x, P26x, P_26y, P26y : INTEGER;
	SIGNAL P_27x, P27x, P_27y, P27y : INTEGER;
	SIGNAL P_28x, P28x, P_28y, P28y : INTEGER;
	SIGNAL P_29x, P29x, P_29y, P29y : INTEGER;
	SIGNAL P_30x, P30x, P_30y, P30y : INTEGER;
	SIGNAL P_31x, P31x, P_31y, P31y : INTEGER;
	SIGNAL P_32x, P32x, P_32y, P32y : INTEGER;
	SIGNAL P_33x, P33x, P_33y, P33y : INTEGER;
	SIGNAL P_34x, P34x, P_34y, P34y : INTEGER;
	SIGNAL P_35x, P35x, P_35y, P35y : INTEGER;
	SIGNAL P_36x, P36x, P_36y, P36y : INTEGER;
	SIGNAL P_37x, P37x, P_37y, P37y : INTEGER;
	SIGNAL P_38x, P38x, P_38y, P38y : INTEGER;
	SIGNAL P_39x, P39x, P_39y, P39y : INTEGER;
	SIGNAL P_40x, P40x, P_40y, P40y : INTEGER;
	SIGNAL P_41x, P41x, P_41y, P41y : INTEGER;
	SIGNAL P_42x, P42x, P_42y, P42y : INTEGER;
	SIGNAL P_43x, P43x, P_43y, P43y : INTEGER;
	SIGNAL player1, player2 : STD_LOGIC;
	SIGNAL nextCol : INTEGER;

	--------- BOARD LAYOUT -------------

	--   1
	--   2  3  4  5  6  7  8
	--   9 10 11 12 13 14 15
	--  16 17 18 19 20 21 22
	--  23 24 25 26 27 28 29
	--  30 31 32 33 34 35 36
	--  37 38 39 40 41 42 43

BEGIN

	RED <= player1 OR NOT player2;
	GREEN <= player1 XNOR player2;
	BLUE <= player2;

	WITH nextPieceColumn SELECT
		nextCol <= 50 WHEN "1000000",
		140 WHEN "0100000",
		230 WHEN "0010000",
		320 WHEN "0001000",
		410 WHEN "0000100",
		500 WHEN "0000010",
		590 WHEN "0000001",
		0 WHEN OTHERS;

	RGB_Display : PROCESS (pixel_row, pixel_column) BEGIN

		P_1x <= CONV_INTEGER(pixel_row) - 46;
		P_1y <= CONV_INTEGER(pixel_column) - nextCol;
		P1x <= P_1x * P_1x;
		P1y <= P_1y * P_1y;

		P_2x <= CONV_INTEGER(pixel_row) - 117;
		P_2y <= CONV_INTEGER(pixel_column) - 50;
		P2x <= P_2x * P_2x;
		P2y <= P_2y * P_2y;

		P_3x <= CONV_INTEGER(pixel_row) - 117;
		P_3y <= CONV_INTEGER(pixel_column) - 140;
		P3x <= P_3x * P_3x;
		P3y <= P_3y * P_3y;

		P_4x <= CONV_INTEGER(pixel_row) - 117;
		P_4y <= CONV_INTEGER(pixel_column) - 230;
		P4x <= P_4x * P_4x;
		P4y <= P_4y * P_4y;

		P_5x <= CONV_INTEGER(pixel_row) - 117;
		P_5y <= CONV_INTEGER(pixel_column) - 320;
		P5x <= P_5x * P_5x;
		P5y <= P_5y * P_5y;

		P_6x <= CONV_INTEGER(pixel_row) - 117;
		P_6y <= CONV_INTEGER(pixel_column) - 410;
		P6x <= P_6x * P_6x;
		P6y <= P_6y * P_6y;

		P_7x <= CONV_INTEGER(pixel_row) - 117;
		P_7y <= CONV_INTEGER(pixel_column) - 500;
		P7x <= P_7x * P_7x;
		P7y <= P_7y * P_7y;

		P_8x <= CONV_INTEGER(pixel_row) - 117;
		P_8y <= CONV_INTEGER(pixel_column) - 590;
		P8x <= P_8x * P_8x;
		P8y <= P_8y * P_8y;

		P_9x <= CONV_INTEGER(pixel_row) - 183;
		P_9y <= CONV_INTEGER(pixel_column) - 50;
		P9x <= P_9x * P_9x;
		P9y <= P_9y * P_9y;

		P_10x <= CONV_INTEGER(pixel_row) - 183;
		P_10y <= CONV_INTEGER(pixel_column) - 140;
		P10x <= P_10x * P_10x;
		P10y <= P_10y * P_10y;

		P_11x <= CONV_INTEGER(pixel_row) - 183;
		P_11y <= CONV_INTEGER(pixel_column) - 230;
		P11x <= P_11x * P_11x;
		P11y <= P_11y * P_11y;

		P_12x <= CONV_INTEGER(pixel_row) - 183;
		P_12y <= CONV_INTEGER(pixel_column) - 320;
		P12x <= P_12x * P_12x;
		P12y <= P_12y * P_12y;

		P_13x <= CONV_INTEGER(pixel_row) - 183;
		P_13y <= CONV_INTEGER(pixel_column) - 410;
		P13x <= P_13x * P_13x;
		P13y <= P_13y * P_13y;

		P_14x <= CONV_INTEGER(pixel_row) - 183;
		P_14y <= CONV_INTEGER(pixel_column) - 500;
		P14x <= P_14x * P_14x;
		P14y <= P_14y * P_14y;

		P_15x <= CONV_INTEGER(pixel_row) - 183;
		P_15y <= CONV_INTEGER(pixel_column) - 590;
		P15x <= P_15x * P_15x;
		P15y <= P_15y * P_15y;

		P_16x <= CONV_INTEGER(pixel_row) - 249;
		P_16y <= CONV_INTEGER(pixel_column) - 50;
		P16x <= P_16x * P_16x;
		P16y <= P_16y * P_16y;

		P_17x <= CONV_INTEGER(pixel_row) - 249;
		P_17y <= CONV_INTEGER(pixel_column) - 140;
		P17x <= P_17x * P_17x;
		P17y <= P_17y * P_17y;

		P_18x <= CONV_INTEGER(pixel_row) - 249;
		P_18y <= CONV_INTEGER(pixel_column) - 230;
		P18x <= P_18x * P_18x;
		P18y <= P_18y * P_18y;

		P_19x <= CONV_INTEGER(pixel_row) - 249;
		P_19y <= CONV_INTEGER(pixel_column) - 320;
		P19x <= P_19x * P_19x;
		P19y <= P_19y * P_19y;

		P_20x <= CONV_INTEGER(pixel_row) - 249;
		P_20y <= CONV_INTEGER(pixel_column) - 410;
		P20x <= P_20x * P_20x;
		P20y <= P_20y * P_20y;

		P_21x <= CONV_INTEGER(pixel_row) - 249;
		P_21y <= CONV_INTEGER(pixel_column) - 500;
		P21x <= P_21x * P_21x;
		P21y <= P_21y * P_21y;

		P_22x <= CONV_INTEGER(pixel_row) - 249;
		P_22y <= CONV_INTEGER(pixel_column) - 590;
		P22x <= P_22x * P_22x;
		P22y <= P_22y * P_22y;

		P_23x <= CONV_INTEGER(pixel_row) - 315;
		P_23y <= CONV_INTEGER(pixel_column) - 50;
		P23x <= P_23x * P_23x;
		P23y <= P_23y * P_23y;

		P_24x <= CONV_INTEGER(pixel_row) - 315;
		P_24y <= CONV_INTEGER(pixel_column) - 140;
		P24x <= P_24x * P_24x;
		P24y <= P_24y * P_24y;

		P_25x <= CONV_INTEGER(pixel_row) - 315;
		P_25y <= CONV_INTEGER(pixel_column) - 230;
		P25x <= P_25x * P_25x;
		P25y <= P_25y * P_25y;

		P_26x <= CONV_INTEGER(pixel_row) - 315;
		P_26y <= CONV_INTEGER(pixel_column) - 320;
		P26x <= P_26x * P_26x;
		P26y <= P_26y * P_26y;

		P_27x <= CONV_INTEGER(pixel_row) - 315;
		P_27y <= CONV_INTEGER(pixel_column) - 410;
		P27x <= P_27x * P_27x;
		P27y <= P_27y * P_27y;

		P_28x <= CONV_INTEGER(pixel_row) - 315;
		P_28y <= CONV_INTEGER(pixel_column) - 500;
		P28x <= P_28x * P_28x;
		P28y <= P_28y * P_28y;

		P_29x <= CONV_INTEGER(pixel_row) - 315;
		P_29y <= CONV_INTEGER(pixel_column) - 590;
		P29x <= P_29x * P_29x;
		P29y <= P_29y * P_29y;

		P_30x <= CONV_INTEGER(pixel_row) - 381;
		P_30y <= CONV_INTEGER(pixel_column) - 50;
		P30x <= P_30x * P_30x;
		P30y <= P_30y * P_30y;

		P_31x <= CONV_INTEGER(pixel_row) - 381;
		P_31y <= CONV_INTEGER(pixel_column) - 140;
		P31x <= P_31x * P_31x;
		P31y <= P_31y * P_31y;

		P_32x <= CONV_INTEGER(pixel_row) - 381;
		P_32y <= CONV_INTEGER(pixel_column) - 230;
		P32x <= P_32x * P_32x;
		P32y <= P_32y * P_32y;

		P_33x <= CONV_INTEGER(pixel_row) - 381;
		P_33y <= CONV_INTEGER(pixel_column) - 320;
		P33x <= P_33x * P_33x;
		P33y <= P_33y * P_33y;

		P_34x <= CONV_INTEGER(pixel_row) - 381;
		P_34y <= CONV_INTEGER(pixel_column) - 410;
		P34x <= P_34x * P_34x;
		P34y <= P_34y * P_34y;

		P_35x <= CONV_INTEGER(pixel_row) - 381;
		P_35y <= CONV_INTEGER(pixel_column) - 500;
		P35x <= P_35x * P_35x;
		P35y <= P_35y * P_35y;

		P_36x <= CONV_INTEGER(pixel_row) - 381;
		P_36y <= CONV_INTEGER(pixel_column) - 590;
		P36x <= P_36x * P_36x;
		P36y <= P_36y * P_36y;

		P_37x <= CONV_INTEGER(pixel_row) - 447;
		P_37y <= CONV_INTEGER(pixel_column) - 50;
		P37x <= P_37x * P_37x;
		P37y <= P_37y * P_37y;

		P_38x <= CONV_INTEGER(pixel_row) - 447;
		P_38y <= CONV_INTEGER(pixel_column) - 140;
		P38x <= P_38x * P_38x;
		P38y <= P_38y * P_38y;

		P_39x <= CONV_INTEGER(pixel_row) - 447;
		P_39y <= CONV_INTEGER(pixel_column) - 230;
		P39x <= P_39x * P_39x;
		P39y <= P_39y * P_39y;

		P_40x <= CONV_INTEGER(pixel_row) - 447;
		P_40y <= CONV_INTEGER(pixel_column) - 320;
		P40x <= P_40x * P_40x;
		P40y <= P_40y * P_40y;

		P_41x <= CONV_INTEGER(pixel_row) - 447;
		P_41y <= CONV_INTEGER(pixel_column) - 410;
		P41x <= P_41x * P_41x;
		P41y <= P_41y * P_41y;

		P_42x <= CONV_INTEGER(pixel_row) - 447;
		P_42y <= CONV_INTEGER(pixel_column) - 500;
		P42x <= P_42x * P_42x;
		P42y <= P_42y * P_42y;

		P_43x <= CONV_INTEGER(pixel_row) - 447;
		P_43y <= CONV_INTEGER(pixel_column) - 590;
		P43x <= P_43x * P_43x;
		P43y <= P_43y * P_43y;

		IF ((P1x + P1y) < 784) THEN
			IF (winner = '1') THEN
				player1 <= '1';
				player2 <= '1';
			ELSE
				player1 <= NOT currentPlayer;
				player2 <= currentPlayer;
			END IF;
		ELSIF (pixel_row < 79) THEN
			player1 <= '1';
			player2 <= '1';
		ELSIF ((P2x + P2y) < 784) THEN
			IF (boardLayout(0, 0) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(0, 0) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(0, 0) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P3x + P3y) < 784) THEN
			IF (boardLayout(1, 0) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(1, 0) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(1, 0) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P4x + P4y) < 784) THEN
			IF (boardLayout(2, 0) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(2, 0) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(2, 0) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P5x + P5y) < 784) THEN
			IF (boardLayout(3, 0) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(3, 0) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(3, 0) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P6x + P6y) < 784) THEN
			IF (boardLayout(4, 0) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(4, 0) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(4, 0) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P7x + P7y) < 784) THEN
			IF (boardLayout(5, 0) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(5, 0) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(5, 0) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P8x + P8y) < 784) THEN
			IF (boardLayout(6, 0) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(6, 0) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(6, 0) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P9x + P9y) < 784) THEN
			IF (boardLayout(0, 1) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(0, 1) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(0, 1) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P10x + P10y) < 784) THEN
			IF (boardLayout(1, 1) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(1, 1) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(1, 1) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P11x + P11y) < 784) THEN
			IF (boardLayout(2, 1) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(2, 1) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(2, 1) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P12x + P12y) < 784) THEN
			IF (boardLayout(3, 1) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(3, 1) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(3, 1) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P13x + P13y) < 784) THEN
			IF (boardLayout(4, 1) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(4, 1) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(4, 1) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P14x + P14y) < 784) THEN
			IF (boardLayout(5, 1) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(5, 1) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(5, 1) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P15x + P15y) < 784) THEN
			IF (boardLayout(6, 1) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(6, 1) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(6, 1) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P16x + P16y) < 784) THEN
			IF (boardLayout(0, 2) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(0, 2) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(0, 2) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P17x + P17y) < 784) THEN
			IF (boardLayout(1, 2) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(1, 2) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(1, 2) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P18x + P18y) < 784) THEN
			IF (boardLayout(2, 2) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(2, 2) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(2, 2) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P19x + P19y) < 784) THEN
			IF (boardLayout(3, 2) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(3, 2) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(3, 2) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P20x + P20y) < 784) THEN
			IF (boardLayout(4, 2) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(4, 2) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(4, 2) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P21x + P21y) < 784) THEN
			IF (boardLayout(5, 2) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(5, 2) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(5, 2) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P22x + P22y) < 784) THEN
			IF (boardLayout(6, 2) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(6, 2) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(6, 2) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P23x + P23y) < 784) THEN
			IF (boardLayout(0, 3) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(0, 3) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(0, 3) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P24x + P24y) < 784) THEN
			IF (boardLayout(1, 3) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(1, 3) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(1, 3) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P25x + P25y) < 784) THEN
			IF (boardLayout(2, 3) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(2, 3) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(2, 3) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P26x + P26y) < 784) THEN
			IF (boardLayout(3, 3) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(3, 3) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(3, 3) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P27x + P27y) < 784) THEN
			IF (boardLayout(4, 3) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(4, 3) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(4, 3) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P28x + P28y) < 784) THEN
			IF (boardLayout(5, 3) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(5, 3) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(5, 3) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P29x + P29y) < 784) THEN
			IF (boardLayout(6, 3) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(6, 3) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(6, 3) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P30x + P30y) < 784) THEN
			IF (boardLayout(0, 4) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(0, 4) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(0, 4) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P31x + P31y) < 784) THEN
			IF (boardLayout(1, 4) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(1, 4) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(1, 4) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P32x + P32y) < 784) THEN
			IF (boardLayout(2, 4) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(2, 4) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(2, 4) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P33x + P33y) < 784) THEN
			IF (boardLayout(3, 4) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(3, 4) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(3, 4) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P34x + P34y) < 784) THEN
			IF (boardLayout(4, 4) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(4, 4) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(4, 4) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P35x + P35y) < 784) THEN
			IF (boardLayout(5, 4) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(5, 4) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(5, 4) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P36x + P36y) < 784) THEN
			IF (boardLayout(6, 4) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(6, 4) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(6, 4) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P37x + P37y) < 784) THEN
			IF (boardLayout(0, 5) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(0, 5) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(0, 5) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P38x + P38y) < 784) THEN
			IF (boardLayout(1, 5) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(1, 5) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(1, 5) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P39x + P39y) < 784) THEN
			IF (boardLayout(2, 5) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(2, 5) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(2, 5) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P40x + P40y) < 784) THEN
			IF (boardLayout(3, 5) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(3, 5) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(3, 5) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P41x + P41y) < 784) THEN
			IF (boardLayout(4, 5) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(4, 5) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(4, 5) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P42x + P42y) < 784) THEN
			IF (boardLayout(5, 5) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(5, 5) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(5, 5) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSIF ((P43x + P43y) < 784) THEN
			IF (boardLayout(6, 5) = empty) THEN
				player1 <= '1';
				player2 <= '1';
			ELSIF (boardLayout(6, 5) = player_1) THEN
				player1 <= '1';
				player2 <= '0';
			ELSIF (boardLayout(6, 5) = player_2) THEN
				player1 <= '0';
				player2 <= '1';
			END IF;
		ELSE
			player1 <= '0';
			player2 <= '0';
		END IF;

	END PROCESS RGB_Display;

END behavior;
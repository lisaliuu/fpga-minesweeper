-- Logic Block Entity
-- Designed by Michael Delaney, Jenna Kronenberg
-- EECE 4377: FPGA Design
-- April 19, 2022

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;
USE work.board_layout_pkg.ALL;

ENTITY logic IS

	PORT (
		clk : IN STD_LOGIC;
		VGA_RDY : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		buttons : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		switches : IN STD_LOGIC_VECTOR(6 DOWNTO 0);

		VGA_UPDATE : OUT STD_LOGIC;
		currentPlayer : BUFFER STD_LOGIC;
		nextPieceColumn : BUFFER unsigned(6 DOWNTO 0);
		boardLayout : BUFFER BOARD_SCHEME;
		winner : OUT STD_LOGIC

	);

END logic;

ARCHITECTURE ARCH OF logic IS

	SIGNAL prevButtons : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN

	--nextPieceColumn <= unsigned(switches(6 downto 0));

	PROCESS (clk, reset)

		VARIABLE dropColumn : INTEGER := 0;
		VARIABLE dropRow : INTEGER := 0;
		VARIABLE winDetector : INTEGER := 0;

	BEGIN

		IF (reset = '1') THEN

			-- Do the same thing as "display board"
			VGA_UPDATE <= '1';
			currentPlayer <= '0';
			prevButtons <= buttons;
			nextPieceColumn <= "1000000";
			winner <= '0';

			FOR i IN 0 TO 6 LOOP -- Column
				FOR j IN 0 TO 5 LOOP -- Row
					boardLayout(i, j) <= empty;
				END LOOP;
			END LOOP;

		ELSIF (rising_edge(clk) AND prevButtons /= buttons) THEN

			CASE buttons IS

				WHEN "110" =>
					-- Shift right
					CASE nextPieceColumn IS
						WHEN "1000000" => nextPieceColumn <= "0100000";
						WHEN "0100000" => nextPieceColumn <= "0010000";
						WHEN "0010000" => nextPieceColumn <= "0001000";
						WHEN "0001000" => nextPieceColumn <= "0000100";
						WHEN "0000100" => nextPieceColumn <= "0000010";
						WHEN "0000010" => nextPieceColumn <= "0000001";
						WHEN "0000001" => nextPieceColumn <= "1000000";
						WHEN OTHERS => nextPieceColumn <= "1000000";
					END CASE;
					VGA_UPDATE <= '0';

				WHEN "101" =>
					CASE nextPieceColumn IS
						WHEN "1000000" =>
							dropColumn := 0;
						WHEN "0100000" =>
							dropColumn := 1;
						WHEN "0010000" =>
							dropColumn := 2;
						WHEN "0001000" =>
							dropColumn := 3;
						WHEN "0000100" =>
							dropColumn := 4;
						WHEN "0000010" =>
							dropColumn := 5;
						WHEN "0000001" =>
							dropColumn := 6;
						WHEN OTHERS =>
							-- ERROR!
							dropColumn := - 1;
					END CASE;
					-- Update the board layout
					IF (dropColumn /= - 1) THEN

						FOR i IN 0 TO 5 LOOP
							IF (boardLayout(dropColumn, i) = empty) THEN
								dropRow := i;
							END IF;
						END LOOP;

						IF (boardLayout(dropColumn, dropRow) = empty) THEN
							IF (currentPlayer = '0') THEN
								boardLayout(dropColumn, dropRow) <= player_1;
							ELSE
								boardLayout(dropColumn, dropRow) <= player_2;
							END IF;

							VGA_UPDATE <= '0';
							currentPlayer <= NOT(currentPlayer);
						END IF;
					END IF;

					--Win detection (vertical)
					winDetector := 1;
					FOR i IN -3 TO 3 LOOP
						IF ((dropRow + i) >= 0) AND ((dropRow + i) < 6) THEN
							IF (currentPlayer = '0' AND boardLayout(dropColumn, (dropRow + i)) = player_1) OR
								(currentPlayer = '1' AND boardLayout(dropColumn, (dropRow + i)) = player_2) THEN
								winDetector := winDetector + 1;
								IF (winDetector >= 4) THEN
									winner <= '1';
								END IF;
							END IF;
						END IF;
					END LOOP;

					--Win detection (horizontal)
					winDetector := 1;
					FOR i IN -3 TO 3 LOOP
						IF ((dropColumn + i) >= 0) AND ((dropColumn + i) < 7) THEN
							IF (currentPLayer = '0' AND boardLayout((dropColumn + i), dropRow) = player_1) OR
								(currentPlayer = '1' AND boardLayout((dropColumn + i), dropRow) = player_2) THEN
								winDetector := winDetector + 1;
								IF (winDetector >= 4) THEN
									winner <= '1';
								END IF;
							END IF;
						END IF;
					END LOOP;

					--Win detection (diagonal right)
					winDetector := 1;
					FOR i IN -3 TO 3 LOOP
						IF ((dropColumn + i) >= 0) AND ((dropColumn + i) < 7) AND
							((dropRow + i) >= 0) AND ((dropRow + i) < 6) THEN
							IF (currentPlayer = '0' AND boardLayout((dropColumn + i), (dropRow + i)) = player_1) OR
								(currentPlayer = '1' AND boardLayout((dropColumn + i), (dropRow + i)) = player_2) THEN
								winDetector := winDetector + 1;
								IF (winDetector >= 4) THEN
									winner <= '1';
								END IF;
							END IF;
						END IF;
					END LOOP;

					--Win detection (diagonal left)
					winDetector := 1;
					FOR i IN -3 TO 3 LOOP
						IF ((dropColumn + i) >= 0) AND ((dropColumn + i) < 7) AND
							((dropRow - i) >= 0) AND ((dropRow - i) < 6) THEN
							IF (currentPlayer = '0' AND boardLayout((dropColumn + i), (dropRow - i)) = player_1) OR
								(currentPlayer = '1' AND boardLayout((dropColumn + i), (dropRow - i)) = player_2) THEN
								winDetector := winDetector + 1;
								IF (winDetector >= 4) THEN
									winner <= '1';
								END IF;
							END IF;
						END IF;
					END LOOP;

				WHEN "011" =>

					CASE nextPieceColumn IS
						WHEN "1000000" => nextPieceColumn <= "0000001";
						WHEN "0100000" => nextPieceColumn <= "1000000";
						WHEN "0010000" => nextPieceColumn <= "0100000";
						WHEN "0001000" => nextPieceColumn <= "0010000";
						WHEN "0000100" => nextPieceColumn <= "0001000";
						WHEN "0000010" => nextPieceColumn <= "0000100";
						WHEN "0000001" => nextPieceColumn <= "0000010";
						WHEN OTHERS => nextPieceColumn <= "1000000";
					END CASE;

					VGA_UPDATE <= '0';

				WHEN OTHERS =>
					VGA_UPDATE <= '1';

			END CASE;

			prevButtons <= buttons;

		END IF;

	END PROCESS;

END ARCH;
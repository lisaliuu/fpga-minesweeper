-- TYPE board_status IS ARRAY(0 TO 7, 0 TO 7); -- bool
-- TYPE board_value IS ARRAY(0 TO 7, 0 TO 7); -- int from 0 to 8, 9 (bomb), 10 (flag)

-- determine the status of the cell
-- input: IN ports <- user input (buttons, switches)
---- output
--PACKAGE board_layout_pkg IS
--	subtype small_range is natural range 0 to 10;
--	subtype smallest_range is natural range 0 to 1;
--	type board_size is array (0 to 7, 0 to 7) of small_range;
--	type board_bool is array (0 to 7, 0 to 7) of smallest_range;
--	type user_pos is array(0 TO 1) of small_range;
--END board_layout_pkg;

LIBRARY work;
USE work.ALL;
USE work.board_layout_pkg.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY logic IS
	PORT
	(
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		-- user input
		buttons : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		switches : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

		VGA_UPDATE : OUT STD_LOGIC;
		cell_status : INOUT board_bool;
		cell_flagged : INOUT board_bool;
		cell_value : INOUT board_size;
		cur_sel_cell : INOUT user_pos;
		T_one : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		T_two : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		game_won : INOUT STD_LOGIC := '0';
		game_lost : INOUT STD_LOGIC := '0';
		flag_count : INOUT INTEGER RANGE 0 TO 99
	);
END logic;

ARCHITECTURE struct OF logic IS
	-- SINGAL cell_status_signal
	COMPONENT board_generator
		PORT
		(
			CLOCK_50, start_randomizer : IN STD_LOGIC;
			banned_position : IN user_pos;
			board_output : OUT board_size;
			completed : INOUT STD_LOGIC);
	END COMPONENT;

	SIGNAL first_pressed : STD_LOGIC := '0';
	SIGNAL start_gen : STD_LOGIC := '0';
	SIGNAL check_win : STD_LOGIC := '1';
	SIGNAL finished_gen : STD_LOGIC := '0';
	SIGNAL ban_position : user_pos;
	--signal counter : unsigned(29 downto 0) := "000000000000000000000000000000";
	SIGNAL button_state : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
	SIGNAL switch_state : STD_LOGIC := '0';

BEGIN

	U1 : board_generator PORT MAP
	(
		CLOCK_50 => clk,
		start_randomizer => start_gen,
		banned_position => ban_position,
		board_output => cell_value,
		completed => finished_gen
	);

	user_input : PROCESS (clk, buttons, finished_gen)
		-- switch 0 == 0 for playing
		-- switch 0 == 1 for game over/reset
	BEGIN
		-- generate a new board when sw = 1
		T_one <= STD_LOGIC_VECTOR(to_unsigned(cur_sel_cell(0), 4));
		T_two <= STD_LOGIC_VECTOR(to_unsigned(cur_sel_cell(1), 4));
		-- start the game when sw=0	
		-- initialize blank board
		IF finished_gen = '1' THEN
			start_gen <= '0';
		END IF;

		VGA_UPDATE <= '1';
		IF (switches(0) = '1') THEN
			first_pressed <= '0';
			cur_sel_cell <= (0, 0);
			game_won <= '0';
			game_lost <= '0';
			FOR i IN 0 TO 7 LOOP -- Column
				FOR j IN 0 TO 7 LOOP -- Row
					cell_status(i, j) <= 0;
					cell_flagged(i, j) <= 0;
				END LOOP;
			END LOOP;
		END IF;
		-- ←↑↓→
		IF game_won = '0' AND game_lost = '0' THEN
			-- do nothing
			IF (rising_edge(CLK)) THEN
				--counter <= counter + 1;
				IF (buttons(0) = '0' AND button_state(0) = '1') THEN
					-- go left
					--button_state(0) <= buttons(0);
					IF (cur_sel_cell(0) > 0) THEN
						cur_sel_cell(0) <= cur_sel_cell(0) - 1;
					ELSE
						cur_sel_cell(0) <= 7;
					END IF;

					-- go right
				ELSIF (buttons(1) = '0' AND button_state(1) = '1') THEN
					--button_state(1) <= buttons(1);
					IF (cur_sel_cell(0) < 7) THEN
						cur_sel_cell(0) <= cur_sel_cell(0) + 1;
					ELSE
						cur_sel_cell(0) <= 0;
					END IF;

					-- go down
				ELSIF (buttons(2) = '0' AND button_state(2) = '1') THEN
					--button_state(2) <= buttons(2);
					IF (cur_sel_cell(1) < 7) THEN
						cur_sel_cell(1) <= cur_sel_cell(1) + 1;
					ELSE
						cur_sel_cell(1) <= 0;
					END IF;

					-- go up
				ELSIF (buttons(3) = '0' AND button_state(3) = '1') THEN
					--button_state(3) <= buttons(3);
					IF (cur_sel_cell(1) > 0) THEN
						cur_sel_cell(1) <= cur_sel_cell(1) - 1;
					ELSE
						cur_sel_cell(1) <= 7;
					END IF;
				END IF;
				button_state(0) <= buttons(0);
				button_state(1) <= buttons(1);
				button_state(2) <= buttons(2);
				button_state(3) <= buttons(3);
			ELSE
				cur_sel_cell <= cur_sel_cell;
			END IF;
			IF (switches(1) = '1') THEN
				-- click (closed -> open)
				IF (first_pressed = '0') THEN
					--first press
					ban_position <= cur_sel_cell;
					-- board is now partially open
					first_pressed <= '1';
					start_gen <= '1';
					-- ELSE 
				ELSIF finished_gen = '1' THEN
					cell_status(cur_sel_cell(0), cur_sel_cell(1)) <= 1;
					IF (cell_value(cur_sel_cell(0), cur_sel_cell(1)) = 9) THEN -- hit a bomb
						game_lost <= '1'; -- lost
					END IF;

					FOR i IN 0 TO 7 LOOP -- Column
						FOR j IN 0 TO 7 LOOP -- Row
							IF (NOT (cell_status(i, j) = 1 OR cell_flagged(i, j) = 1)) THEN
								check_win <= '0';
							END IF;
						END LOOP;
					END LOOP;
					IF (check_win = '1') THEN
						game_won <= '1'; -- won
					END IF;
				END IF;
			END IF;
			IF (rising_edge(clk)) THEN
				IF (switches(2) = '1' AND switch_state = '0') THEN
					-- flag
					IF (cell_flagged(cur_sel_cell(0), cur_sel_cell(1)) = 0) THEN
						cell_flagged(cur_sel_cell(0), cur_sel_cell(1)) <= 1;
						flag_count <= (flag_count - 1);
					ELSE
						cell_flagged(cur_sel_cell(0), cur_sel_cell(1)) <= 0;
						flag_count <= (flag_count + 1);
					END IF;
				END IF;
				switch_state <= switches(2);
			ELSE
				cell_flagged <= cell_flagged;
			END IF;
		END IF;
	END PROCESS user_input;
END struct;
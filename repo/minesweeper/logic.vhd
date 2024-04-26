PACKAGE board_layout_pkg IS
	subtype small_range is natural range 0 to 10;
	type board_size is array (0 to 7, 0 to 7) of small_range;
	type user_pos is array(0 TO 1) of small_range;
END board_layout_pkg;

LIBRARY work;
USE work.ALL;
USE work.board_layout_pkg.ALL;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- TYPE board_status IS ARRAY(0 TO 7, 0 TO 7); -- bool
-- TYPE board_value IS ARRAY(0 TO 7, 0 TO 7); -- int from 0 to 8, 9 (bomb), 10 (flag)

-- determine the status of the cell
-- input: IN ports <- user input (buttons, switches)
-- output

ENTITY logic IS

	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		-- user input
		buttons : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		switches : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		
		VGA_UPDATE : OUT STD_LOGIC;
		cell_status : BUFFER ARRAY(0 TO 7, 0 TO 7) OF STD_LOGIC; -- cell is closed or opened
		cell_flagged : BUFFER ARRAY(0 TO 7, 0 TO 7) OF STD_LOGIC; -- cell is flagged or not flagged
		cell_value : board_size; -- contains number of how many adjacent cells are bombs, or 9 if a bomb
		cur_sel_cell : BUFFER ARRAY(0 TO 1) OF INTEGER;

	);
END ENTITY logic;



ARCHITECTURE architecture OF logic IS

	COMPONENT board_generator
			
		PORT(	CLOCK_50, start_randomizer 	: in std_logic;
				banned_position 					: in user_pos;
				board_output 						: out board_size;
				completed							: out std_logic);

	END COMPONENT;

	SIGNAL game_over : STD_LOGIC;
	SIGNAL first_pressed : STD_LOGIC := '0';
	SIGNAL check_win : STD_LOGIC := '1';
	signal board_ready : std_logic := '0';
	signal ban_position : user_pos;

BEGIN
	
	U1: board_generator PORT MAP
		(CLOCK_50				=>	clk,
		 start_randomizer		=> not board_ready and first_pressed,
		 banned_position		=> ban_position,
		 board_output 			=> cell_value,
		 completed				=> board_ready
		);

	PROCESS (switches, buttons)
	-- switch 0 == 0 for playing
	-- switch 0 == 1 for game over/reset
	BEGIN
	-- generate a new board when sw = 1
	
	-- start the game when sw=0	
	-- initialize blank board
		VGA_UPDATE <= '1';
		IF (switches(0) = '0') THEN
			cur_sel_cell <= (0, 0);
			FOR i IN 0 TO 7 LOOP -- Column
				FOR j IN 0 TO 7 LOOP -- Row
					cell_status(i, j) <= '0';
					cell_flagged(i, j) <= '0';
				END LOOP;
			END LOOP;
		ENd IF;
			
		
		-- ←↑↓→
		IF (buttons(0)='0') THEN
		-- go left
			if cur_sel_cell(0) then
			end if;
			cur_sel_cell(0) <= cur_sel_cell(0) - 1;
		-- go right
		ELIF (buttons(1)='0') THEN
			cur_sel_cell(0) <= cur_sel_cell(0) + 1;
		-- go down
		ELIF (buttons(2)='0') THEN
			cur_sel_cell(1)<= cur_sel_cell(1) - 1;
		-- go up
		ELIF (buttons(3)='0') THEN
			cur_sel_cell(1) <= cur_sel_cell(1) + 1;
		END IF;

		IF (switches(1)='1') THEN
			-- click (closed -> open)
			IF (first_pressed='0') THEN
				--first press
				-- @TEYON PUT UR STUFF HERE
				ban_position <= cur_sel_cell;
				-- board is now partially open
				first_pressed='1';
			-- ELSE 
			END if;
			if board_ready = '1' then
				cell_status(cur_sel_cell(0)*8, cur_sel_cell(1)) <= '1';
				IF (cell_value(cur_sel_cell(0)*8, cur_sel_cell(1)) = 9) THEN -- hit a bomb
					game_over = '1'; -- lost
				END IF;

				FOR i IN 0 TO 7 LOOP -- Column
					FOR j IN 0 TO 7 LOOP -- Row
						IF (NOT (cell_status(i*8, j)='1' or cell_flagged(i*8, j)='1')) THEN
							check_win <= '0';

				IF (check_win='1') then
					game_over = '1'; -- won
				END IF;
			end if;
		elsif (switches(2)='1') THEN
			-- flag
			IF(cell_status(cur_sel_cell(0)*8, cur_sel_cell(1))='0') THEN
				cell_flagged(cur_sel_cell(0)*8, cur_sel_cell(1)) <= '1';
			ELSE
				cell_flagged(cur_sel_cell(0)*8, cur_sel_cell(1)) <= '0';
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;
-- TYPE board_status IS ARRAY(0 TO 7, 0 TO 7); -- bool
-- TYPE board_value IS ARRAY(0 TO 7, 0 TO 7); -- int from 0 to 8, 9 (bomb), 10 (flag)

-- determine the status of the cell
-- input: IN ports <- user input (buttons, switches)
-- output

LIBRARY work;
USE work.ALL;
USE work.board_layout_pkg.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY logic IS
	PORT (
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
		test:OUT std_logic
	);
END logic;



ARCHITECTURE struct OF logic IS

	COMPONENT board_generator
			
		PORT(	CLOCK_50, start_randomizer 	: in std_logic;
				banned_position 					: in user_pos;
				board_output 						: out board_size;
				completed							: inout std_logic);

	END COMPONENT;

	SIGNAL game_over : STD_LOGIC := '0';
	SIGNAL first_pressed : STD_LOGIC := '0';
	signal start_gen : STD_LOGIC := '0';
	SIGNAL check_win : STD_LOGIC := '1';
	signal finished_gen : STD_LOGIC := '0';
	signal ban_position : user_pos;
	signal flag_count : STD_LOGIC_VECTOR(7 DOWNTO 0); -- number of flags avaiable, shown on LCD display

BEGIN
	
	U1: board_generator PORT MAP
		(CLOCK_50				=>	clk,
		 start_randomizer		=> start_gen,
		 banned_position		=> ban_position,
		 board_output 			=> cell_value,
		 completed				=> finished_gen
		);

	
	user_input: PROCESS (switches, buttons, finished_gen)
	-- switch 0 == 0 for playing
	-- switch 0 == 1 for game over/reset
	BEGIN
	-- generate a new board when sw = 1
	
	-- start the game when sw=0	
	-- initialize blank board
		if finished_gen = '1' then
			start_gen <='0';
		end if;
		
		VGA_UPDATE <= '1';
		IF (switches(0) = '1') THEN
			first_pressed <= '0';
			cur_sel_cell <= (0, 0);
			FOR i IN 0 TO 7 LOOP -- Column
				FOR j IN 0 TO 7 LOOP -- Row
					cell_status(i, j) <= 0;
					cell_flagged(i, j) <= 0;
				END LOOP;
			END LOOP;
		ENd IF;
			
		
		-- ←↑↓→
		IF (buttons(0)='0') THEN
		-- go left
			IF (cur_sel_cell(0) > 0) THEN
				cur_sel_cell(0) <= cur_sel_cell(0) - 1;
			ELSE 
				cur_sel_cell(0) <= 7;
			END IF;
			
		-- go right
		ELsIF (buttons(1)='0') THEN
			IF (cur_sel_cell(0) < 7) THEN
				cur_sel_cell(0) <= cur_sel_cell(0) + 1;
			ELSE 
				cur_sel_cell(0) <= 0;
			END IF;
			
		-- go down
		ELsIF (buttons(2)='0') THEN
			IF (cur_sel_cell(1) < 7) THEN
				cur_sel_cell(1) <= cur_sel_cell(1) + 1;
			ELSE 
				cur_sel_cell(1) <= 0;
			END IF;
			
		-- go up
		ELsIF (buttons(3)='0') THEN
			IF (cur_sel_cell(1) > 0) THEN
				cur_sel_cell(1) <= cur_sel_cell(1) - 1;
			ELSE 
				cur_sel_cell(1) <= 7;
			END IF;
		END IF;

		IF (switches(1)='1') THEN
			-- click (closed -> open)
			IF (first_pressed='0') THEN
				--first press
				ban_position <= cur_sel_cell;
				-- board is now partially open
				first_pressed <= '1';
				start_gen <='1';
			-- ELSE 
			elsif finished_gen = '1' then
				cell_status(cur_sel_cell(0), cur_sel_cell(1)) <= 1;
				IF (cell_value(cur_sel_cell(0), cur_sel_cell(1)) = 9) THEN -- hit a bomb
					game_over <= '1'; -- lost
				END IF;

				FOR i IN 0 TO 7 LOOP -- Column
					FOR j IN 0 TO 7 LOOP -- Row
						IF (NOT (cell_status(i, j)=1 or cell_flagged(i, j)=1)) THEN
							check_win <= '0';
						END IF;
					END LOOP;
				END LOOP;
				IF (check_win='1') then
					game_over <= '1'; -- won
				END IF;
			end if;
		end if;
		if (switches(2)='1') THEN
			-- flag
			test<='1';
			IF(cell_flagged(cur_sel_cell(0), cur_sel_cell(1))=0) THEN
				cell_flagged(cur_sel_cell(0), cur_sel_cell(1)) <= 1;
			ELSE
				cell_flagged(cur_sel_cell(0), cur_sel_cell(1)) <= 0;
			END IF;
		END IF;
	END PROCESS user_input;
END struct;